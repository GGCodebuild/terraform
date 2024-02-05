###
# File: data.tf
# File Created: Friday, 7th May 2021 1:02:56 pm
# -----
# Last Modified: Tuesday July 26th 2022 2:03:50 pm
# Modified By: Jorge Agüero Zamora <jorge.aguerozamora@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###
data "aws_lb" "ingress" {
  name = split("-", var.ingress_load_balancer_hostnames[0])[0]
}

data "aws_route53_zone" "main" {
  name     = var.hosted_zone
  private_zone = var.is_private_dns
  provider = aws.dns
}
