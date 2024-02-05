###
# File: variables.tf
# File Created: Friday, 7th May 2021 1:02:57 pm
# -----
# Last Modified: Tuesday October 26th 2021 1:29:40 pm
# Modified By: Drew Kalina <drew.kalina@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
# 
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

variable "cloud_account_id" { type = string }
variable "region" { type = string }
variable "cluster_name" { type = string }

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Extra tags to attach to the VPC resources"
}

variable "project" {
  type = string
}
variable "environment" {
  type = string
}
variable "separate_dns_account" {
  type    = bool
  default = false
}