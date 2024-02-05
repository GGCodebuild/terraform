###
# File: locals.tf
# File Created: Friday, 7th May 2021 1:02:54 pm
# -----
# Last Modified: Wednesday June 15th 2022 1:04:20 pm
# Modified By: Jorge Agüero Zamora <jorge.aguerozamora@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

locals {
  cloud_account_id     = data.aws_caller_identity.current.account_id
  region               = var.region
  region_bucket_name   = var.region_bucket_name != null ? var.region_bucket_name : "${local.region}-resource-bucket-${local.cloud_account_id}"
  project              = var.project
  environment          = var.environment
  parent_region        = var.parent_region
  separate_dns_account = var.separate_dns_account
  arn_partition        = length(regexall("us-gov-", var.region)) > 0 ? "aws-us-gov" : "aws"
  cluster_name         = var.cluster_name #data.terraform_remote_state.cluster_core.outputs.cluster_config.cluster_name

  hosted_zone_list = var.hosted_zone_list

  hosted_zone = var.hosted_zone
  smtp_domain = var.smtp_domain
  dns_names   = var.dns_names

  smarthost_address = var.smarthost_address

  public_dns_name = var.enable_zerot ? ["zerot"] : []

  tozny_dns_names = var.tozny_dns_names

  manifest = yamldecode(file("metadata/manifest.yaml"))

  docker_image_dict = {
    for image in keys(local.manifest.images) : image => {
      registry : "${var.registry_hostname}",
      repo : "${var.registry_hostname}/${image}",
      tags : "${local.manifest.images[image].tags}",
    }
  }

#data.terraform_remote_state.windshare_migration.outputs.docker_image_dict
  image_pull_policy = var.image_pull_policy

  storage_class = var.storage_class

  k8s_usp_namespaces              = { for n in var.k8s_usp_namespaces_suffix : n => "${var.environment}-${n}" }
  k8s_usp_with_istio_namespaces   = { for n in var.k8s_usp_with_istio_namespaces_suffix : n => "${var.environment}-${n}" }
  k8s_usp_no_istio_namespaces     = { for n in var.k8s_usp_no_istio_namespaces_suffix : n => "${var.environment}-${n}" }
  k8s_tools_namespaces            = { for n in var.k8s_tools_namespaces_suffix : n => "${var.environment}-${n}" }
  k8s_tools_with_istio_namespaces = { for n in var.k8s_tools_with_istio_namespaces_suffix : n => "${var.environment}-${n}" }
  k8s_tools_no_istio_namespaces   = { for n in var.k8s_tools_no_istio_namespaces_suffix : n => "${var.environment}-${n}" }
  k8s_tozny_namespaces            = { for n in var.k8s_tozny_namespaces_suffix : n => "${var.environment}-${n}" }

  k8s_config = {
    k8s_usp_namespaces              = local.k8s_usp_namespaces
    k8s_usp_with_istio_namespaces   = local.k8s_usp_with_istio_namespaces
    k8s_tools_namespaces            = local.k8s_tools_namespaces
    k8s_tools_with_istio_namespaces = local.k8s_tools_with_istio_namespaces
    k8s_tozny_namespaces            = local.k8s_tozny_namespaces
    k8s_admin_role                  = var.k8s_admin_role
    k8s_viewer_role                 = var.k8s_viewer_role
    k8s_developer_role              = var.k8s_developer_role
    k8s_operator_role               = var.k8s_operator_role
    k8s_cluster_actions_role        = var.k8s_cluster_actions_role
  }


  #oidc_provider_arn = var.oidc_provider_arn #data.terraform_remote_state.cluster_core.outputs.oidc_provider_arn
  #oidc_provider_url = var.oidc_provider_url #data.terraform_remote_state.cluster_core.outputs.oidc_provider_url

  ingress_istio_enabled      = var.ingress_istio_enabled
  enable_public_ingress      = var.enable_zerot
  public_ingress_cidr_blocks = var.public_ingress_cidr_blocks

  # local_ecr_user_id     = var.external_ecr_user_id != "" ? var.external_ecr_user_id : module.iam.svc-tools1_ak_id
  # local_ecr_user_secret = var.external_ecr_user_key != "" ? var.external_ecr_user_key : module.iam.svc-tools1_ak_secret
  local_ecr_region      = var.external_ecr_region != "" ? var.external_ecr_region : var.region

  local_mcp_user_ak_secret = var.create_iam_resources ? module.iam[0].svc-usp-mcp_ak_secret : var.mcp_credentials_key
  local_mcp_user_ak_id = var.create_iam_resources ? module.iam[0].svc-usp-mcp_ak_id : var.mcp_credentials_id
  mcp_user_arn = var.create_iam_resources ? module.iam[0].svc_usp_mcp_arn : var.mcp_user_arn
  wr_studio_logs_secret = var.create_iam_resources ? module.iam[0].wr_studio_logs_secret: var.logs_access_key_id
  wr_studio_logs_ak_id = var.create_iam_resources ? module.iam[0].wr_studio_logs_ak_id : var.logs_access_key_secret
  network_flow_logs_secret = var.create_iam_resources ? module.iam[0].network_flow_logs_secret : var.networking_flow_logs_access_key_id
  network_flow_logs_ak_id = var.create_iam_resources ? module.iam[0].network_flow_logs_ak_id  : var.networking_flow_logs_access_key_secret


}
