###
# File: variables.tf
# File Created: Thursday, 20th May 2021 11:58:39 am
# -----
# Last Modified: Friday September 30th 2022 10:07:26 pm
# Modified By: Jorge Agüero Zamora <jorge.aguerozamora@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

variable "docker_image_dict" {}
variable "image_pull_policy" {
  type    = string
  default = "IfNotPresent"
}
variable "csi_driver_name" {
  type    = string
  default = "efs.csi.aws.com"
}

variable "cloud_account_id" {
  type = string
}

variable "csi_driver_role_arn" {
  type = string
}

variable "k8s_context" {
  type = string
}
