###
# File: variables.tf
# File Created: Friday, 7th May 2021 1:02:57 pm
# -----
# Last Modified: Saturday September 17th 2022 11:46:23 am
# Modified By: Jorge Agüero Zamora <jorge.aguerozamora@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

variable "region" { type = string }

variable "smtp_domain" { type = string }
variable "hosted_zone_list" { type = set(string) }
variable "is_private_dns" {
  description = "Whether the Route53 hosted zone is Private (true) or Public (false). Default = false"
  type        = bool
  default     = false
}

variable "private_dns_server_ip" {
  description = "IP address of the DNS server when using private DNS"
  type        = string
  default     = ""
}

variable "private_dns_server_port" {
  description = "Port where the private DNS server listens for requests. (Default = 53)"
  type        = number
  default     = 53
}
variable "enable_public_ingress" { type = bool }

variable "dns_manager_ak_secret" { type = string }
# variable "dns_manager_role_arn" { type = string }
variable "dns_manager_ak_id" { type = string }
variable "docker_image_dict" {}
variable "image_pull_policy" {
  type    = string
  default = "IfNotPresent"
}
variable "tags" {
  default     = {}
  type        = map(string)
  description = "Extra tags to attach to the VPC resources"
}

variable "acme_eab_secret" {
  description = "External Account Binding HMAC used by the ACME client for authentication. Ignored if 'acme_use_eab_credentials' is false"
  type        = string
  default     = ""
}
variable "acme_eab_kid" {
  description = "External Account Binding key id used by the ACME client for authentication. Ignored if 'acme_use_eab_credentials' is false"
  type        = string
  default     = ""
}

variable "acme_use_eab_credentials" {
  description = "Used by the ACME client to know if the server requires External Account Binding credentials"
  type        = bool
  default     = false
}

variable "acme_url" {
  description = "The URL used by cert-manager for the ACME process"
  type        = string
}

variable "istio_custom_cert_required" {
  description = "If set to true will not install istio until a custom cert secret is present in the istio namespace"
  type        = string
  default     = false
}

variable "ingress_istio_enabled" {
  type    = bool
  default = false
}

variable "public_ingress_cidr_blocks" {
  default     = []
  type        = list(string)
  description = "Populating will block access to public ingress from other IP addresses"
}

variable "k8s_context" {
  type = string
}

variable "vpc_cidr_block" { type = string }
