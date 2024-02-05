###
# File: outputs.tf
# File Created: Friday, 7th May 2021 1:02:57 pm
# -----
# Last Modified: Friday September 30th 2022 10:08:35 pm
# Modified By: Jorge Agüero Zamora <jorge.aguerozamora@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

output "cloudWatch_read_policy_arn" {
  value = aws_iam_policy.policy["CloudWatch_Read_Policy"].arn
}

output "scale_ec2_arn" {
  value = aws_iam_policy.policy["Scale_EC2_Policy"].arn
}

output "mcp_suspend_subcloud_role_arn" {
  value = aws_iam_role.role["mcp_suspend_subcloud_role"].arn
}

output "mcp_resume_subcloud_role_arn" {
  value = aws_iam_role.role["mcp_resume_subcloud_role"].arn
}

# output keys from other account if using it, otherwise the local user key
output "dns_manager_ak_secret" {
  value = local.separate_dns_account ? aws_iam_access_key.cross_account_dns_manager_ak[0].secret : aws_iam_access_key.dns_manager_ak.secret
  sensitive = true
}

# output keys from other account if using it, otherwise the local user key
output "dns_manager_ak_id" {
  value = local.separate_dns_account ? aws_iam_access_key.cross_account_dns_manager_ak[0].id : aws_iam_access_key.dns_manager_ak.id
  sensitive = true
}


output "svc-usp-mcp_ak_secret" {
  value = aws_iam_access_key.svc-usp-mcp_ak.secret
  sensitive = true
}

output "svc-usp-mcp_ak_id" {
  value = aws_iam_access_key.svc-usp-mcp_ak.id
  sensitive = true
}

output "svc_usp_mcp_arn" {
  value = data.aws_iam_user.mcp.arn
}

output "svc-tools1_ak_secret" {
  value = aws_iam_access_key.svc-tools1_ak.secret
  sensitive = true
}

output "svc-tools1_ak_id" {
  value = aws_iam_access_key.svc-tools1_ak.id
  sensitive = true
}

# output the role for the local account unless the config is for a cross account DNS or gov cloud config
output "dns_manager_role_arn" {
  value = local.is_gov_cloud || local.separate_dns_account ? null : aws_iam_role.role["dns_manager_role"].arn
}

output "efs_csi_driver_role_arn" {
  value = aws_iam_role.efs-csi-role.arn
}

output "ebs_csi_driver_role_arn" {
  value = aws_iam_role.ebs-csi-role.arn
}

output "wr_studio_logs_secret" {
  value = aws_iam_access_key.logs_access_key.secret
  sensitive = true
}

output "wr_studio_logs_ak_id" {
  value = aws_iam_access_key.logs_access_key.id
  sensitive = true
}

output "network_flow_logs_secret" {
  value = aws_iam_access_key.networking_flow_logs_access_key.secret
  sensitive = true
}

output "network_flow_logs_ak_id" {
  value = aws_iam_access_key.networking_flow_logs_access_key.id
  sensitive = true
}
