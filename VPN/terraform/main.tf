###
# File: main.tf
# File Created: Friday, 7th May 2021 1:02:54 pm
# -----
# Last Modified: Tuesday January 17th 2023 7:17:21 am
# Modified By: Jordan Craven <jordan.craven@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

# This module installs the aws-efs-csi-driver

# This module create iam policies
module "iam" {
  source               = "./modules/iam"
  count                = var.create_iam_resources ? 1 : 0
  project              = local.project
  environment          = local.environment
  cloud_account_id     = local.cloud_account_id
  region               = local.region
  cluster_name         = local.cluster_name
  separate_dns_account = local.separate_dns_account
  providers = {
    aws     = aws,
    aws.dns = aws.dns
  }
}


module "efs_csi_driver" {
  depends_on          = [module.iam]
  source              = "./modules/efs_csi_driver"
  docker_image_dict   = local.docker_image_dict
  image_pull_policy   = local.image_pull_policy
  cloud_account_id    = local.cloud_account_id
  csi_driver_role_arn = var.create_iam_resources ? module.iam[0].efs_csi_driver_role_arn : var.efs_csi_role_arn
  k8s_context         = var.k8s_context
}

# Link to dns module
# dns module can run only if EKS has been created
# output is
module "dns" {
  source = "./modules/dns"

  region           = local.region
  hosted_zone_list = local.hosted_zone_list

  enable_public_ingress = local.enable_public_ingress
  dns_manager_ak_id     = var.create_iam_resources ? module.iam[0].dns_manager_ak_id : var.dns_manager_ak_id
  dns_manager_ak_secret = var.create_iam_resources ? module.iam[0].dns_manager_ak_secret : var.dns_manager_ak_secret
  # dns_manager_role_arn       = var.create_iam_resources ? module.iam[0].dns_manager_role_arn : var.dns_manager_role_arn
  docker_image_dict          = local.docker_image_dict
  is_private_dns             = var.is_private_dns
  private_dns_server_ip      = var.private_dns_server_ip
  private_dns_server_port    = var.private_dns_server_port
  image_pull_policy          = local.image_pull_policy
  acme_eab_secret            = var.acme_eab_secret
  acme_eab_kid               = var.acme_eab_kid
  acme_url                   = var.acme_url
  smtp_domain                = var.smtp_domain
  acme_use_eab_credentials   = var.acme_use_eab_credentials
  ingress_istio_enabled      = local.ingress_istio_enabled
  public_ingress_cidr_blocks = local.public_ingress_cidr_blocks
  k8s_context                = var.k8s_context
  vpc_cidr_block             = var.vpc_cidr_block
  providers = {
    aws     = aws,
    aws.dns = aws.dns
  }
}

module "dns_record" {
  source     = "./modules/dns_record"
  depends_on = [module.dns]
  domains = var.domains
  public_dns_name                        = local.public_dns_name
  tozny_dns_names                        = local.tozny_dns_names
  dns_names                              = local.dns_names
  is_private_dns                         = var.is_private_dns
  hosted_zone                            = local.hosted_zone
  smtp_domain                            = local.smtp_domain
  smarthost_address                      = local.smarthost_address
  nat_gateway_ips                        = var.nat_gateway_ips #cluster_core.outputs.nat_gateway_ips
  public_ingress_load_balancer_hostnames = module.dns.public_ingress_load_balancer_hostnames
  ingress_load_balancer_hostnames        = module.dns.ingress_load_balancer_hostnames
  providers = {
    aws     = aws,
    aws.dns = aws.dns
  }
}

## This module create all namespaces
module "rbac_namespaces" {
  source     = "./modules/rbac_namespaces"
  depends_on = [module.efs_csi_driver, module.dns]

  cloud_account_id                = local.cloud_account_id
  region                          = local.region
  environment         = var.environment
  k8s_usp_namespaces              = local.k8s_config.k8s_usp_namespaces
  k8s_usp_with_istio_namespaces   = local.k8s_config.k8s_usp_with_istio_namespaces
  k8s_tools_namespaces            = local.k8s_config.k8s_tools_namespaces
  k8s_tools_with_istio_namespaces = local.k8s_config.k8s_tools_with_istio_namespaces
  k8s_tozny_namespaces            = local.k8s_config.k8s_tozny_namespaces
  k8s_admin_role                  = local.k8s_config.k8s_admin_role
  k8s_viewer_role                 = local.k8s_config.k8s_viewer_role
  k8s_developer_role              = local.k8s_config.k8s_developer_role
  k8s_operator_role               = local.k8s_config.k8s_operator_role
  k8s_cluster_actions_role        = local.k8s_config.k8s_cluster_actions_role
  mcp_user_arn                    = local.mcp_user_arn
  k8s_context                     = var.k8s_context
}

##
module "logging_subclouds" {
  source = "./modules/logging/subclouds"

  cluster_name = local.cluster_name
}

# This module creates pv, pvc
module "storage" {
  source     = "./modules/storage"
  depends_on = [module.rbac_namespaces]

  project             = local.project
  environment         = local.environment
  vpc_cidr_block      = var.vpc_cidr_block
  vpc_id              = var.vpc_id
  private_subnet_id_a = var.private_subnet_ids[0]
  storage_class       = local.storage_class
  csi_driver_name     = module.efs_csi_driver.csi_driver_name
  ebs_csi_role_arn    = var.create_iam_resources ? module.iam[0].ebs_csi_driver_role_arn : var.ebs_csi_role_arn
  efs_security_group_id = var.efs_security_group_id
  k8s_cluster_name    = var.cluster_name
  region               = local.region
}

module "backup" {
  source = "./modules/backup"

  region                   = local.region
  deployment_namespace     = "${var.environment}-backup"
  docker_image_dict        = local.docker_image_dict
  image_pull_policy        = local.image_pull_policy
  parent_region            = local.parent_region
  k8s_context              = var.k8s_context
  create_iam_resources     = var.create_iam_resources
  velero_access_key_id     = var.velero_access_key_id
  velero_access_key_secret = var.velero_access_key_secret
  cluster_name = var.cluster_name
}

# module "vault" {
#   source            = "./modules/vault"
#   depends_on        = [module.dns_record, module.dns, module.storage]
#   k8s_context       = var.k8s_context
#   docker_image_dict = local.docker_image_dict
#   domain            = module.dns_record.domains["vault"]
#   namespace = "${var.environment}-vault"
# }
