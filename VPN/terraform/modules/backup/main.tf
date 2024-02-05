###
# File: main.tf
# File Created: Thursday, 20th May 2021 11:58:39 am
# -----
# Last Modified: Friday February 10th 2023 2:48:59 pm
# Modified By: Jordan Craven <jordan.craven@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###
locals {
  arn_partition = length(regexall("us-gov-", var.region)) > 0 ? "aws-us-gov" : "aws"
}
resource "aws_s3_bucket" "backups_bucket" {
  bucket_prefix = "backups-${var.region}-"
  acl           = "private"
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "backups_bucket" {
  bucket = aws_s3_bucket.backups_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_user" "velero_user" {
  count = var.create_iam_resources ? 1 : 0
  name  = "backup-${var.region}-${var.cluster_name}"
}

resource "aws_iam_access_key" "velero_access_key" {
  count = var.create_iam_resources ? 1 : 0
  user  = aws_iam_user.velero_user[0].name
}

resource "aws_iam_policy" "velero_policy" {
  count       = var.create_iam_resources ? 1 : 0
  name        = "backup-${var.region}-${var.cluster_name}"
  path        = "/"
  description = "Permissions needed for Velero for backups."

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "${aws_s3_bucket.backups_bucket.arn}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "${aws_s3_bucket.backups_bucket.arn}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "velero_user_policy_attach" {
  count      = var.create_iam_resources ? 1 : 0
  user       = aws_iam_user.velero_user[0].name
  policy_arn = aws_iam_policy.velero_policy[0].arn
}

resource "null_resource" "get_parent_region_S3_bucket" {
  count    = var.parent_region == "" ? 0 : 1
  triggers = { always_run = timestamp() }
  provisioner "local-exec" {
    command = "rm -rf parent_region_bucket.txt; aws s3 ls | grep -o 'backups-${var.parent_region}-[0-9]*' | head -1 | tr -d '\n' >> parent_region_bucket.txt"
  }
}

data "local_file" "parent_region_bucket_name" {
  count      = var.parent_region == "" ? 0 : 1
  filename   = "parent_region_bucket.txt"
  depends_on = [null_resource.get_parent_region_S3_bucket]
}

resource "aws_iam_policy" "velero_parent_region_backups_bucket_policy" {
  count       = var.parent_region == "" ? 0 : (var.create_iam_resources ? 1 : 0)
  name        = "backup-parent-${var.region}-${var.cluster_name}"
  path        = "/"
  description = "Permissions needed for Velero for backups from parent region."

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:${local.arn_partition}:s3:::${data.local_file.parent_region_bucket_name[0].content}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:${local.arn_partition}:s3:::${data.local_file.parent_region_bucket_name[0].content}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "velero_parent_region_backups_bucket_policy_attach" {
  count      = var.parent_region == "" ? 0 : (var.create_iam_resources ? 1 : 0)
  user       = aws_iam_user.velero_user[0].name
  policy_arn = aws_iam_policy.velero_parent_region_backups_bucket_policy[0].arn
}

resource "helm_release" "velero" {
  name             = "velero"
  chart            = "${path.module}/velero"
  namespace        = var.deployment_namespace
  create_namespace = true
  wait             = false

  values = [
    file("${path.module}/velero/values.yaml")
  ]

  set {
    name  = "upgradeCRDs"
    value = "false"
  }

  set {
    name  = "configuration.provider"
    value = "aws"
  }

  set {
    name  = "configuration.backupStorageLocation.bucket"
    value = aws_s3_bucket.backups_bucket.bucket
  }

  set {
    name  = "configuration.backupStorageLocation.config.region"
    value = var.region
  }

  set {
    name  = "configuration.volumeSnapshotLocation.config.region"
    value = var.region
  }

  set {
    name  = "initContainers[0].name"
    value = "velero-plugin-for-aws"
  }

  set {
    name  = "initContainers[0].image"
    value = "${var.docker_image_dict["wr-studio-product/external/docker.io/velero/velero-plugin-for-aws"]["repo"]}:${var.docker_image_dict["wr-studio-product/external/docker.io/velero/velero-plugin-for-aws"]["tags"][0]}"
  }

  set {
    name  = "initContainers[0].imagePullPolicy"
    value = var.image_pull_policy
  }

  set {
    name  = "initContainers[0].volumeMounts[0].mountPath"
    value = "/target"
  }

  set {
    name  = "initContainers[0].volumeMounts[0].name"
    value = "plugins"
  }

  set {
    name  = "credentials.secretContents.cloud"
    value = var.create_iam_resources ? format("[default]\naws_access_key_id=%s\naws_secret_access_key=%s\n", aws_iam_access_key.velero_access_key[0].id, aws_iam_access_key.velero_access_key[0].secret) : format("[default]\naws_access_key_id=%s\naws_secret_access_key=%s\n", var.velero_access_key_id, var.velero_access_key_secret)
  }

  set {
    name  = "image.repository"
    value = var.docker_image_dict["wr-studio-product/external/docker.io/velero/velero"]["repo"]
  }

  set {
    name  = "image.tag"
    value = var.docker_image_dict["wr-studio-product/external/docker.io/velero/velero"]["tags"][0]
  }

  set {
    name  = "image.pullPolicy"
    value = var.image_pull_policy
  }

  set {
    name  = "configMaps.restic-restore-action-config.data.image"
    value = "${var.docker_image_dict["wr-studio-product/external/docker.io/velero/velero-restic-restore-helper"]["repo"]}:${var.docker_image_dict["wr-studio-product/external/docker.io/velero/velero-restic-restore-helper"]["tags"][0]}"
  }

  set {
    name  = "configMaps.restic-restore-action-config.data.pullPolicy"
    value = var.image_pull_policy
  }
}

resource "null_resource" "configure_parent_bucket_access" {
  count      = var.parent_region == "" ? 0 : 1
  depends_on = [helm_release.velero]

  triggers = {
    k8s_context          = var.k8s_context
    deployment_namespace = var.deployment_namespace
  }
  provisioner "local-exec" {
    when    = create
    command = "velero backup-location create backups-secondary --kubecontext ${self.triggers.k8s_context} --provider aws --bucket ${data.local_file.parent_region_bucket_name[0].content} --config region=${var.parent_region} --namespace ${self.triggers.deployment_namespace} || true"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "yes | velero backup-location delete backups-secondary --kubecontext ${self.triggers.k8s_context} --namespace ${self.triggers.deployment_namespace}"
  }
}
