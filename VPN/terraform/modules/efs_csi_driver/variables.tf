###
# File: variables.tf
# File Created: Monday, 10th May 2021 10:20:41 pm
# -----
# Last Modified: Friday September 30th 2022 10:07:53 pm
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
variable "cloud_account_id" {
  type = string
}

variable "csi_driver_role_arn" {
  type = string
}

variable "k8s_context" {
  type = string
}
