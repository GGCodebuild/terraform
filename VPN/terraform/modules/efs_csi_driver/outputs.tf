###
# File: outputs.tf
# File Created: Monday, 10th May 2021 10:20:41 pm
# -----
# Last Modified: Tuesday May 11th 2021 11:52:18 am
# Modified By: Gabriel Vidaurre <gabriel.vidaurrerodriguez@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
# 
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

output "csi_driver_name" {
  value = module.helmcharts.csi_driver_name
}
