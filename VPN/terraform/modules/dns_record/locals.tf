###
# File: locals.tf
# File Created: Tuesday, 8th June 2021 4:26:54 pm
# -----
# Last Modified: Monday January 3rd 2022 7:24:58 pm
# Modified By: Tracy Zhang <tracy.zhang@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###
locals {
  all_dns_names = setunion(var.tozny_dns_names, var.dns_names) # merging tozny + rest of dns_names
  #formatted_dns_names = concat(formatlist("%s.${var.hosted_zone}", local.all_dns_names), [var.hosted_zone]) #gitlab.wrai.cloud or tozny.id.wrai.cloud"
  wrai_zone = data.aws_route53_zone.main
  domains_to_create = { for k, v in var.domains: k => v if  k != "hosted_zone" }
  public_dns_list = var.enable_zerot ? flatten([
    for name in var.public_dns_name : {
      dns_name           = name
      zone_id            = local.wrai_zone.zone_id
      hosted_zone        = local.wrai_zone.name
      formatted_dns_name = "${name}.${local.wrai_zone.name}"
    }
  ]) : []

  domains = merge(
    { for key, record in aws_route53_record.wrai_dns_records :
      key => record.name
    },
    { "hosted_zone" = var.hosted_zone }
  )

}
