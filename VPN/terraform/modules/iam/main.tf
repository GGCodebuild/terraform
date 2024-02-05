###
# File: main.tf
# File Created: Friday, 7th May 2021 1:02:57 pm
# -----
# Last Modified: Wednesday September 14th 2022 3:03:36 pm
# Modified By: Jorge Agüero Zamora <jorge.aguerozamora@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

# <-- LOCAL VARIABLES -->

# <-- ECR POLICIES -->

# data.aws_eks_cluster.example.identity[0].oidc[0].issuer
# data "aws_eks_cluster" "example" {
#   name = var.cluster_name
# }


resource "aws_iam_role" "ebs-csi-role" {
  name = "ebs-csi-role-${var.cluster_name}"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "${local.eks_oidc_arn}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${local.eks_issuer}:aud": "sts.amazonaws.com",
            "${local.eks_issuer}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ebs-aws-managed-policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs-csi-role.name
}


resource "aws_iam_policy" "efs-csi-policy" {
  name = "efs-csi-policy-${var.cluster_name}"
  path = "/"
  policy = templatefile("${path.module}/policy-templates/efs-csi-policy.json", {
    partition        = local.arn_partition
    region           = var.region
    cloud_account_id = var.cloud_account_id
    cluster_name     = var.cluster_name
  })
}

resource "aws_iam_role" "efs-csi-role" {
  name = "efs-csi-role-${var.cluster_name}"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Federated : "${local.eks_oidc_arn}"
        },
        Action : "sts:AssumeRoleWithWebIdentity",
        Condition : {
          StringEquals : {
            "${local.eks_issuer}:aud" : "sts.amazonaws.com",
            "${local.eks_issuer}:sub" : "system:serviceaccount:default:efs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "efs-csi-role-attach" {
  role       = aws_iam_role.efs-csi-role.name
  policy_arn = aws_iam_policy.efs-csi-policy.arn
}

resource "aws_iam_policy" "policy" {
  for_each = local.iam_policies
  name     = "${var.region}-${each.key}-${var.cluster_name}"
  path     = "/"
  policy = templatefile("${path.module}/policy-templates/${each.value}.json", {
    partition        = local.arn_partition
    region           = var.region
    cloud_account_id = var.cloud_account_id
    cluster_name     = var.cluster_name
  })
}

# <-- IAM USERS -->

resource "aws_iam_user" "user" {
  for_each = local.iam_users
  name     = "${var.region}-${each.key}-${var.cluster_name}"
  tags     = local.tags
}

resource "aws_iam_user_policy" "for" {
  depends_on = [aws_iam_user.user]
  for_each   = toset([for user, meta in local.iam_users : user if meta.change_password])
  user       = "${var.region}-${each.value}-${var.cluster_name}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:ChangePassword"
        ],
        "Resource" : [
          "arn:${local.arn_partition}:iam::*:user/${var.region}-${each.value}-${var.cluster_name}"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:GetAccountPasswordPolicy"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# <-- IAM ACCESS KEYS -->

resource "aws_iam_access_key" "dns_manager_ak" {
  depends_on = [aws_iam_user.user]
  user       = "${var.region}-dns_manager-${var.cluster_name}"
}

resource "aws_iam_access_key" "svc-tools1_ak" {
  depends_on = [aws_iam_user.user]
  user       = "${var.region}-svc-tools1-${var.cluster_name}"
}

resource "aws_iam_access_key" "svc-usp-mcp_ak" {
  depends_on = [aws_iam_user.user]
  user       = "${var.region}-svc-usp-mcp-${var.cluster_name}"
}

# <-- IAM ROLE -->

resource "aws_iam_role" "role" {
  for_each = local.iam_roles
  name     = "${var.region}-${each.key}-${var.cluster_name}"
  tags     = local.tags
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : each.value.principal,
        "Action" : "sts:AssumeRole",
        "Condition" : {}
      }
    ]
  })
}

# <-- IAM GROUP -->

resource "aws_iam_group" "group" {
  for_each = local.iam_groups
  name     = "${var.region}-${each.key}-${var.cluster_name}"
}

resource "aws_iam_group_policy" "for" {
  depends_on = [aws_iam_group.group, aws_iam_role.role]
  for_each   = toset([for group, meta in local.iam_groups : group if meta.assume_role != null])
  group      = "${var.region}-${each.value}-${var.cluster_name}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowAssumeOrganizationAccountRole",
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Resource" : "arn:${local.arn_partition}:iam::${var.cloud_account_id}:role/${var.region}-${local.iam_groups[each.value].assume_role}"
      }
    ]
  })
}

# <-- IAM USERS GROUP MEMBERSHIP -->

resource "aws_iam_user_group_membership" "for" {
  depends_on = [aws_iam_user.user, aws_iam_group.group]
  for_each   = toset([for user, meta in local.iam_users : user if length(meta.groups) > 0])
  user       = "${var.region}-${each.value}-${var.cluster_name}"
  groups     = [for group in local.iam_users[each.value].groups : "${var.region}-${group}-${var.cluster_name}"]
}

# <-- POLICY ATTACHMENTS -->

resource "aws_iam_user_policy_attachment" "for" {
  depends_on = [aws_iam_user.user, aws_iam_policy.policy]
  for_each   = local.iam_user_policies
  user       = "${var.region}-${each.value.user}-${var.cluster_name}"
  policy_arn = "arn:${local.arn_partition}:iam::${var.cloud_account_id}:policy/${var.region}-${each.value.policy}-${var.cluster_name}"
}

resource "aws_iam_role_policy_attachment" "for" {
  depends_on = [aws_iam_role.role, aws_iam_policy.policy]
  for_each   = local.iam_role_policies
  role       = "${var.region}-${each.value.role}-${var.cluster_name}"
  policy_arn = "arn:${local.arn_partition}:iam::${var.cloud_account_id}:policy/${var.region}-${each.value.policy}-${var.cluster_name}"
}

resource "aws_iam_group_policy_attachment" "for" {
  depends_on = [aws_iam_group.group, aws_iam_policy.policy]
  for_each   = local.iam_group_policies
  group      = "${var.region}-${each.value.group}-${var.cluster_name}"
  policy_arn = "arn:${local.arn_partition}:iam::${var.cloud_account_id}:policy/${var.region}-${each.value.policy}-${var.cluster_name}"
}

# cross account route 53

resource "aws_iam_policy" "dns_manager" {
  count = local.separate_dns_account ? 1 : 0
  name  = "${var.cloud_account_id}-${var.region}-dns_manager_policy-${var.cluster_name}"
  path  = "/"
  policy = templatefile("${path.module}/policy-templates/dns_manager_policy.json", {
    partition = "aws" # won't be govcloud so the partition will be aws
  })
  provider = aws.dns
}

resource "aws_iam_user" "dns_manager" {
  count    = local.separate_dns_account ? 1 : 0
  name     = "${var.cloud_account_id}-${var.region}-dns_manager-${var.cluster_name}"
  tags     = local.tags
  provider = aws.dns
}

resource "aws_iam_user_policy_attachment" "dns_manager" {
  count      = local.separate_dns_account ? 1 : 0
  user       = aws_iam_user.dns_manager[0].name
  policy_arn = aws_iam_policy.dns_manager[0].arn
  provider   = aws.dns
}

resource "aws_iam_access_key" "cross_account_dns_manager_ak" {
  count      = local.separate_dns_account ? 1 : 0
  depends_on = [aws_iam_user.dns_manager]
  user       = aws_iam_user.dns_manager[0].name
  provider   = aws.dns
}

# can be implemented for cross account access
# resource "aws_iam_role" "dns_manager_cross_account_role" {
#   count      = var.separate_dns_account && !local.is_gov_cloud ? 1 : 0
#   name     = "${var.cloud_account_id}-${var.region}-dns_manager_role"
#   tags     = local.tags
#   provider = aws.dns
#   assume_role_policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Principal" : "arn:${local.arn_partition}:iam::${var.cloud_account_id}:user/${var.region}-dns_manager",
#         "Action" : "sts:AssumeRole",
#         "Condition" : {}
#       }
#     ]
#   })
# }


#####
# get MCP user ARN

data "aws_iam_user" "mcp" {
  depends_on = [aws_iam_user.user]
  user_name       = "${var.region}-svc-usp-mcp-${var.cluster_name}"
}
