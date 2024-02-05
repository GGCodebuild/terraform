###
# File: variables.tf
# File Created: Friday, 7th May 2021 1:03:02 pm
# -----
# Last Modified: Tuesday October 25th 2022 4:24:29 pm
# Modified By: Johan Setyobudi <johan.setyobudi@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###
variable "region" { type = string }
variable "project" { type = string }
variable "environment" { type = string }
variable "vpc_cidr_block" { type = string }
variable "vpc_id" { type = string }

variable "private_subnet_id_a" {
  type        = string
  description = "Private subnet A ID for EKS creation"
}

variable "efs_security_group_id" {
  type    = string
  default = null
}

variable "storage_class" { type = string }

variable "csi_driver_name" {
  type = string
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Extra tags to attach to the VPC resources"
}

variable "ebs_csi_role_arn"{
  type = string
  description = "ARN of the IAM role to be used by the AWS EBS CSI driver"
}

variable "k8s_cluster_name" {
  type = string
  description = "Name of the K8s cluster"
}

