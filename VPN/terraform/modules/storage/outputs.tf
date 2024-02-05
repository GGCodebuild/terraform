###
# File: outputs.tf
# File Created: Friday, 7th May 2021 1:03:02 pm
# -----
# Last Modified: Thursday January 12th 2023 9:35:25 pm
# Modified By: Jordan Craven <jordan.craven@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

# output "file_systems" {
#   value       = aws_efs_file_system.wrai_file_systems
#   description = "EFS File Systems to be used in PV and PVC"
# }

# disabled for dynamic provisioning
# does not appear to be used anywhere else
# output "mount_targets" {
#   value       = aws_efs_mount_target.wrai_mount_targets
#   description = "EFS Mount Targets to be used in PV and PVC for mounting EFS filesystems"
# }

/**
output "wrai_persistent_volume_claims" {
  value = module.persistent_storage.wrai_persistent_volume_claims
  description = "All K8s Persistent volume claims for WRAI"
}
*/
# output "wrai_persistent_volume_claims" {
#   value       = kubernetes_persistent_volume_claim.wrai_persistent_volume_claims
#   description = "All K8s Persistent volume claims for WRAI"
# }

output "efs_security_group_id" {
  value = var.efs_security_group_id
}

output "wr_studio_gitlab_efs_ids" {
  description = "EFS IDs for Monitoring Solution"
  value       = [] # disabled because of dynamic provisioning
  # value = {
  #   gitlab_redis    = aws_efs_file_system.wrai_file_systems["59"].id
  #   gitlab_postgres = aws_efs_file_system.wrai_file_systems["57"].id
  #   gitlab_gitlay   = aws_efs_file_system.wrai_file_systems["60"].id
  # }
}

output "wr_studio_minio_efs_ids" {
  description = "EFS IDs for Monitoring Solution"
  value       = [] # disabled because of dynamic provisioning
  # value = [
  #   aws_efs_file_system.wrai_file_systems["66"].id,
  #   aws_efs_file_system.wrai_file_systems["67"].id,
  #   aws_efs_file_system.wrai_file_systems["68"].id,
  #   aws_efs_file_system.wrai_file_systems["68"].id
  # ]
}

output "wr_studio_logs_bucket_arn" {
  value = aws_s3_bucket.logs_bucket.arn
  description = "logs signer bucket arn"
}
