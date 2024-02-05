###
# File: variables.tf
# File Created: Thursday, 20th May 2021 11:58:39 am
# -----
# Last Modified: Friday March 18th 2022 9:10:29 pm
# Modified By: Johan Setyobudi <johan.setyobudi@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###
#-- kubernetes context
variable "deployment_namespace" {
  default     = "prod-backup"
  type        = string
  description = "Kubernetes deployment namespace where velero will be deployed"
}

variable "cluster_name" { type = string }
variable "docker_image_dict" {
  description = "Docker image dictionairy for all images in the project"
}
variable "image_pull_policy" {
  type    = string
  default = "IfNotPresent"
}
variable "region" { type = string }

variable "parent_region" {
  description = "Region containing Velero backup from old cluster to be restored to this new cluster.If left empty a secondary backups bucket will not be configured."
  type        = string
  default     = ""
}

variable "k8s_context" {
  type = string
}

variable "create_iam_resources" {
  type    = bool
}

variable "velero_access_key_id" {
  type    = string
}

variable "velero_access_key_secret" {
  type    = string
}
