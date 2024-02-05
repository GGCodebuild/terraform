###
# File: main.tf
# File Created: Friday, 7th May 2021 1:02:57 pm
# -----
# Last Modified: Tuesday July 26th 2022 6:53:32 pm
# Modified By: Jorge Agüero Zamora <jorge.aguerozamora@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

resource "aws_route53_record" "apex_alias_record" {
  zone_id  = local.wrai_zone.zone_id
  name     = var.hosted_zone #"gitlab.engineering.devstar.cloud"
  type     = "A"

  alias {
    name                   = data.aws_lb.ingress.dns_name
    zone_id                = data.aws_lb.ingress.zone_id
    evaluate_target_health = true
  }
  provider = aws.dns
}

resource "aws_route53_record" "wrai_dns_records" {
  for_each = local.domains_to_create
  zone_id  = local.wrai_zone.zone_id
  name     = "${each.value}" #"gitlab.engineering.devstar.cloud"
  type     = "CNAME"
  ttl      = "60"
  records  = var.ingress_load_balancer_hostnames
  provider = aws.dns
}

resource "aws_route53_record" "public_dns_records" {
  depends_on = [var.public_ingress_load_balancer_hostnames]
  for_each   = var.enable_zerot ? { for dns in local.public_dns_list : dns.formatted_dns_name => dns } : {}
  zone_id    = each.value.zone_id
  name       = "${each.value.dns_name}.${each.value.hosted_zone}" #"gitlab.engineering.devstar.cloud"
  type       = "CNAME"
  ttl        = "60"
  records    = var.public_ingress_load_balancer_hostnames
  provider   = aws.dns
}

## SMTP DNS record resource creation
data "aws_route53_zone" "smtp" {
  // Create this data source only when an SMTP DNS zone name has been specified in the tfvars file.
  count    = ((var.smarthost_address == "") && (var.nat_gateway_ips[0] != "")) ? 1 : 0
  name     = var.smtp_domain
  provider = aws.dns
}

resource "aws_route53_record" "smtp_mx" {
  // Create this DNS record only when an AWS SMTP DNS zone data source exists.
  count    = ((var.smarthost_address == "") && (var.nat_gateway_ips[0] != "")) ? 1 : 0
  zone_id = data.aws_route53_zone.smtp[0].zone_id
  name    = var.smtp_domain
  type    = "MX"
  ttl     = "300"
  records = [
    "10 smtp1.${var.smtp_domain}",
    "20 smtp2.${var.smtp_domain}"
  ]
  provider = aws.dns
}

resource "aws_route53_record" "smtp_subnet0_a" {
  // Create this DNS record only when an AWS SMTP DNS zone data source exists.
  count    = ((var.smarthost_address == "") && (var.nat_gateway_ips[0] != "")) ? 1 : 0
  zone_id  = data.aws_route53_zone.smtp[0].zone_id
  name     = "smtp1.${var.smtp_domain}"
  type     = "A"
  ttl      = "300"
  records  = [var.nat_gateway_ips[0]]
  provider = aws.dns
}

resource "aws_route53_record" "smtp_subnet1_a" {
  // Create this DNS record only when an AWS SMTP DNS zone data source exists.
  count    = ((var.smarthost_address == "") && (var.nat_gateway_ips[0] != "")) ? 1 : 0
  zone_id  = data.aws_route53_zone.smtp[0].zone_id
  name     = "smtp2.${var.smtp_domain}"
  type     = "A"
  ttl      = "300"
  records  = [var.nat_gateway_ips[1]]
  provider = aws.dns
}

resource "aws_route53_record" "smtp_txt" {
  // Create this DNS record only when an AWS SMTP DNS zone data source exists.
  count    = ((var.smarthost_address == "") && (var.nat_gateway_ips[0] != "")) ? 1 : 0
  zone_id  = data.aws_route53_zone.smtp[0].zone_id
  name     = var.smtp_domain
  type     = "TXT"
  ttl      = "300"
  records  = ["v=spf1 mx ~all"]
  provider = aws.dns
}

# resource "aws_route53_record" "root_dns_url" {
#   zone_id  = local.wrai_zone.zone_id
#   name     = local.wrai_zone.name
#   type     = "A"
#   provider = aws.dns
#   alias {
#     name                   = var.ingress_load_balancer_hostnames[0]
#     zone_id                = data.aws_lb.ingress.zone_id
#     evaluate_target_health = false
#   }
# }
