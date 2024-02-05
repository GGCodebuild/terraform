###
# File: variables.tf
# File Created: Friday, 7th May 2021 1:02:57 pm
# -----
# Last Modified: Tuesday July 26th 2022 2:05:59 pm
# Modified By: Jorge Agüero Zamora <jorge.aguerozamora@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

variable "public_dns_name" {
  type    = set(string)
  default = ["zerot"]
}
variable "dns_names" { type = set(string) }
variable "tozny_dns_names" { type = set(string) }
variable "domains" {
  type        = map(string)
  description = "Map of domain prefixes to full domain names."
}
variable "nat_gateway_ips" { type = list(string) }

variable "enable_zerot" {
  type    = bool
  default = false
}
variable "hosted_zone" {
  type    = string
  default = ""
}

variable "is_private_dns" {
  description = "Whether the Route53 hosted zone is Private (true) or Public (false). Default = false"
  type        = bool
  default     = false
}

variable "smtp_domain" {
  type    = string
  default = ""
}

variable "ingress_load_balancer_hostnames" {
  type = list(any)
}

variable "public_ingress_load_balancer_hostnames" {
  type = list(any)
}

variable "smarthost_address" {
  type    = string
  default = ""
}
