###
# File: variables.tf
# File Created: Friday, 7th May 2021 1:03:01 pm
# -----
# Last Modified: Monday October 3rd 2022 12:23:59 pm
# Modified By: Jorge Agüero Zamora <jorge.aguerozamora@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

variable "cloud_account_id" { type = string }
variable "region" { type = string }
variable "k8s_usp_namespaces" { type = map(any) }
variable "k8s_tools_namespaces" { type = map(any) }
variable "k8s_tozny_namespaces" { type = map(any) }
variable "k8s_admin_role" { type = map(any) }
variable "k8s_viewer_role" { type = map(any) }
variable "k8s_developer_role" { type = map(any) }
variable "k8s_operator_role" { type = map(any) }
variable "k8s_cluster_actions_role" { type = map(any) }
variable "k8s_usp_with_istio_namespaces" { type = map(any) }
variable "k8s_tools_with_istio_namespaces" { type = map(any) }
variable "mcp_user_arn"{
  type = string
  description = "ARN of the MCP user to map on the AWS configmap"
}
variable "tozny_istio_enabled" {
  type    = bool
  default = true
}
variable "default_istio_enabled" {
  type    = bool
  default = true
}

variable "k8s_context" {
  type = string
}
variable "environment" {
  type = string
}
