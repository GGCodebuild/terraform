###
# File: main.tf
# File Created: Monday, 10th May 2021 10:20:41 pm
# -----
# Last Modified: Friday September 30th 2022 10:07:42 pm
# Modified By: Jorge Agüero Zamora <jorge.aguerozamora@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

module "helmcharts" {
  source = "./helm"

  docker_image_dict    = var.docker_image_dict
  image_pull_policy    = var.image_pull_policy
  csi_driver_role_arn  = var.csi_driver_role_arn
  cloud_account_id     = var.cloud_account_id
  k8s_context          = var.k8s_context
}
