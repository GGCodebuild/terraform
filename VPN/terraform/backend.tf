###
# File: backend.tf
# File Created: Friday, 7th May 2021 1:02:54 pm
# -----
# Last Modified: Wednesday January 5th 2022 5:28:18 pm
# Modified By: Tracy Zhang <tracy.zhang@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###
/* Cant use variables, how do we do this in cloudify?
terraform {
  backend "s3" {
    bucket = local.region_bucket_name
    key = "tfstate/infra_resources/terraform.tfstate"
    region = var.region
    encrypt = true
  }
}
*/
