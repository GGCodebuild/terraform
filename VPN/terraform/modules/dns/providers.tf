###
# File: providers.tf
# File Created: Wednesday, 13th October 2021 11:23:11 am
# -----
# Last Modified: Thursday February 17th 2022 8:13:58 pm
# Modified By: Jordan Craven <jordan.craven@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
# 
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "< 4.0.0"
      configuration_aliases = [aws.dns]
    }
  }
}
