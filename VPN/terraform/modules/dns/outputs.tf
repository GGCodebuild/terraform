###
# File: outputs.tf
# File Created: Monday, 3rd January 2022 6:55:20 pm
# -----
# Last Modified: Monday January 3rd 2022 7:02:13 pm
# Modified By: Tracy Zhang <tracy.zhang@windriver.com>
# -----
# Copyright (c) 2022 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###
output "ingress_load_balancer_hostnames" {
  value = local.ingress_load_balancer_hostnames
}

output "public_ingress_load_balancer_hostnames" {
  value = local.public_ingress_load_balancer_hostnames
}
