###
# File: outputs.tf
# File Created: Wednesday, 10th August 2022 10:02:13 am
# -----
# Last Modified: Sunday August 21st 2022 5:14:55 pm
# Modified By: Jordan Craven <jordan.craven@windriver.com>
# -----
# Copyright (c) 2022 Wind River Systems, Inc.
# 
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###
output "csi_driver_name" {
  value = var.csi_driver_name
}
