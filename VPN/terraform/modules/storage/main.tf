###
# File: main.tf
# File Created: Friday, 7th May 2021 1:03:02 pm
# -----
# Last Modified: Sunday January 15th 2023 3:24:27 pm
# Modified By: Jordan Craven <jordan.craven@windriver.com>

# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

locals {
  vpc_id = var.vpc_id
  #  file_systems = aws_efs_file_system.wrai_file_systems
}


# resource "aws_efs_file_system" "wrai_file_systems" {
#   depends_on     = [aws_security_group.efs_sg_wrai]
#   for_each       = var.storage_mappings
#   creation_token = "${var.environment}-${each.value.pv}"
#   encrypted      = "true"

#   tags = merge(
#     {
#       Project       = var.project,
#       Environment   = var.environment,
#       pv_claim_name = each.value.pv
#     },
#     var.tags
#   )
# }

resource "aws_efs_file_system" "default_wrai_file_system" {
  creation_token = "${var.environment}-default"
  encrypted      = "true"

  tags = merge(
    {
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_efs_file_system" "wrai_file_system_1000" {
  creation_token = "${var.environment}-1000"
  encrypted      = "true"

  tags = merge(
    {
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

# resource "aws_efs_mount_target" "wrai_mount_targets" {
#   depends_on      = [aws_efs_file_system.wrai_file_systems, aws_security_group.efs_sg_wrai]
#   for_each        = aws_efs_file_system.wrai_file_systems
#   file_system_id  = each.value.id
#   subnet_id       = var.private_subnet_id_a
#   security_groups = [aws_security_group.efs_sg_wrai.id]
# }

resource "aws_efs_mount_target" "default_wrai_mount_target" {
  depends_on      = [aws_efs_file_system.default_wrai_file_system]
  file_system_id  = aws_efs_file_system.default_wrai_file_system.id
  subnet_id       = var.private_subnet_id_a
  security_groups = [var.efs_security_group_id]
}

resource "aws_efs_mount_target" "wrai_mount_target_1000" {
  depends_on      = [aws_efs_file_system.wrai_file_system_1000]
  file_system_id  = aws_efs_file_system.wrai_file_system_1000.id
  subnet_id       = var.private_subnet_id_a
  security_groups = [var.efs_security_group_id]
}


resource "kubernetes_storage_class" "default_efs_storage_class" {
  depends_on = [aws_efs_mount_target.default_wrai_mount_target]
  metadata {
    name = "efs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true" # cannot set to default due to https://github.com/hashicorp/terraform-provider-kubernetes/issues/872
    }
  }
  parameters = {
    basePath         = "/dynamic"
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.default_wrai_file_system.id
    directoryPerms   = "700"
    uid              = "0"
    gid              = "0"
  }
  storage_provisioner = var.csi_driver_name
}

resource "kubernetes_storage_class" "efs_storage_class_1000" {
  depends_on = [aws_efs_mount_target.wrai_mount_target_1000]
  metadata {
    name = "efs-sc-1000"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "false" # cannot set to default due to https://github.com/hashicorp/terraform-provider-kubernetes/issues/872
    }
  }
  parameters = {
    basePath         = "/dynamic"
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.wrai_file_system_1000.id
    directoryPerms   = "700"
    uid              = "1000"
    gid              = "1000"
  }
  storage_provisioner = var.csi_driver_name
}

# <-- PERSISTENT VOLUMES CLAIM -->
# resource "kubernetes_persistent_volume" "wrai_persistent_volumes" {
#   depends_on = [local.file_systems]
#   # can't create pvs or pvc until the mount targets have been assigned to a file system or efs file system won't work
#   for_each = var.storage_mappings
#   metadata {
#     name = each.value.pv
#   }
#   spec {
#     capacity = {
#       storage = each.value.size
#     }
#     access_modes                     = [each.value.access_modes]
#     persistent_volume_reclaim_policy = try(each.value.reclaim_policy, "Retain")
#     persistent_volume_source {
#       csi {
#         driver        = var.csi_driver_name
#         volume_handle = local.file_systems[each.key].id
#       }
#     }
#   }
# }

# resource "kubernetes_persistent_volume_claim" "wrai_persistent_volume_claims" {
#   depends_on = [kubernetes_persistent_volume.wrai_persistent_volumes, local.file_systems]
#   for_each   = var.storage_mappings
#   metadata {
#     name      = each.value.pvc
#     namespace = each.value.namespace
#   }
#   spec {
#     resources {
#       requests = {
#         storage = each.value.size
#       }
#     }
#     access_modes       = [each.value.access_modes]
#     storage_class_name = ""
#     volume_name        = each.value.pv
#   }
#   wait_until_bound = true
# }

# PROMETHUS CONFIG for PV
# this is the only way to create a PV without PVC, because the PVC is created from the Helm chart of kube-prometheus-stack
# resource "aws_efs_file_system" "prometheus_file_systems" {
#   creation_token = "${var.environment}-storage-volume-prometheus-pv"
#   encrypted      = "true"

#   tags = merge(
#     {
#       Project       = var.project,
#       Environment   = var.environment,
#       pv_claim_name = "prometheus-prometheus-prometheus-oper-prometheus-db-prometheus-prometheus-prometheus-oper-prometheus-0"
#     },
#     var.tags
#   )
# }
# resource "aws_efs_mount_target" "prometheus_mount_targets" {
#   depends_on      = [aws_efs_file_system.prometheus_file_systems]
#   file_system_id  = aws_efs_file_system.prometheus_file_systems.id
#   subnet_id       = var.private_subnet_id_a
#   security_groups = [var.efs_security_group_id]
# }

# # <-- PROMETHEUS PERSISTENT VOLUME -->
# resource "kubernetes_persistent_volume" "prometheus_persistent_volumes" {
#   depends_on = [aws_efs_file_system.prometheus_file_systems, aws_efs_mount_target.prometheus_mount_targets]
#   # can't create pv until the mount targets have been assigned to a file system or efs file system won't work
#   metadata {
#     name = "storage-volume-prometheus-pv"
#     labels = {
#       app : "plaformhealth-prometheus-pv"
#     }
#   }
#   spec {
#     capacity = {
#       storage = "50Gi"
#     }
#     access_modes                     = ["ReadWriteMany"]
#     persistent_volume_reclaim_policy = "Retain"
#     storage_class_name               = var.storage_class
#     persistent_volume_source {
#       csi {
#         driver        = var.csi_driver_name
#         volume_handle = aws_efs_file_system.prometheus_file_systems.id
#       }
#     }
#   }
# }


resource "aws_eks_addon" "ebs-csi-addon" {
  cluster_name             = var.k8s_cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = var.ebs_csi_role_arn

}

resource "kubernetes_storage_class" "ebs-sc" {
  depends_on = [aws_eks_addon.ebs-csi-addon]
  metadata {
    name = "ebs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "false" # cannot set to default due to https://github.com/hashicorp/terraform-provider-kubernetes/issues/872
    }
  }
  volume_binding_mode = "WaitForFirstConsumer"
  storage_provisioner = "ebs.csi.aws.com"
}
