###
# File: outputs.tf
# File Created: Friday, 7th May 2021 1:03:03 pm
# -----
# Last Modified: Wednesday June 15th 2022 1:04:39 pm
# Modified By: Jorge Agüero Zamora <jorge.aguerozamora@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

output "k8s_config" {
  value = local.k8s_config
}

# TODO: Move the DNS and SMTP modules into the global_resources portion of the installer.
output "hosted_zone" {
  value = local.hosted_zone
}

output "region" {
  value = local.region
}

output "smtp_domain" {
  value = local.smtp_domain
}

output "domains" {
  value = module.dns_record.domains
}

output "usp_namespaces" {
  value = module.rbac_namespaces.usp_namespaces
}

output "tools_namespaces" {
  value = module.rbac_namespaces.tools_namespaces
}

output "tozny_namespaces" {
  value = module.rbac_namespaces.tozny_namespaces
}

# TODOL Create storage_config object in locals.
output "storage_class" {
  value = local.storage_class
}

output "efs_security_group_id" {
  value = module.storage.efs_security_group_id
}

output "csi_driver_name" {
  value = module.efs_csi_driver.csi_driver_name
}
output "wr_studio_gitlab_efs_ids" {
  description = "EFS IDs for Monitoring Solution"
  value       = module.storage.wr_studio_gitlab_efs_ids
}

output "wr_studio_minio_efs_ids" {
  description = "EFS IDs for Monitoring Solution"
  value       = module.storage.wr_studio_minio_efs_ids
}


output "mcp_user_ak_secret" {
  description = "MCP user secret access key"
  value       = local.local_mcp_user_ak_secret
  sensitive   = true
}

output "mcp_user_ak_id" {
  description = "MCP user access key id"
  value       = local.local_mcp_user_ak_id
  sensitive = true
}

output "wr_studio_logs_secret" {
  value = local.wr_studio_logs_secret
  sensitive = true
}

output "wr_studio_logs_ak_id" {
  value = local.wr_studio_logs_ak_id
  sensitive = true
}

output "network_flow_logs_secret" {
  value = local.network_flow_logs_secret
  sensitive = true
}

output "network_flow_logs_ak_id" {
  value = local.network_flow_logs_ak_id
  sensitive = true
}

# output "container_migration_ak_secret" {
#   description = "Container Migration user access key id"
#   value       = local.local_ecr_user_secret
#   sensitive   = true
# }

# output "container_migration_ak_id" {
#   description = "Container Migration user secret access key"
#   value       = local.local_ecr_user_id
# }

output "container_migration_ecr_region" {
  description = "Container Migration ECR region"
  value       = local.local_ecr_region
}

output "wr_studio_logs_bucket_arn" {
  description = "Container Migration ECR region"
  value       = module.storage.wr_studio_logs_bucket_arn
}
