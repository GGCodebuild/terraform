###
# File: outputs.tf
# File Created: Friday, 7th May 2021 1:02:57 pm
# -----
# Last Modified: Wednesday December 22nd 2021 7:21:06 pm
# Modified By: Tracy Zhang <tracy.zhang@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

output "wrai_dns_records" {
  value = aws_route53_record.wrai_dns_records
}

output "domains" {
  value = local.domains
}
