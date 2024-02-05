###
# File: data.tf
# File Created: Friday, 7th May 2021 1:02:56 pm
# -----
# Last Modified: Tuesday July 26th 2022 1:59:27 pm
# Modified By: Jorge Agüero Zamora <jorge.aguerozamora@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

data "aws_lb" "ingress" {
  depends_on = [helm_release.ingress_nginx_controller, data.kubernetes_service.ingress_nginx]
  name       = split("-", local.ingress_load_balancer_hostnames[0])[0]
}

data "aws_lb" "public_ingress" {
  count      = var.enable_public_ingress ? 1 : 0
  depends_on = [helm_release.public_ingress_nginx_controller, data.kubernetes_service.public_ingress_nginx]
  name       = var.enable_public_ingress ? split("-", local.public_ingress_load_balancer_hostnames[0])[0] : ""
}

data "aws_route53_zone" "main" {
  count    = length(var.hosted_zone_list)
  name     = element(tolist(var.hosted_zone_list), count.index)
  private_zone = var.is_private_dns
  provider = aws.dns
}

data "kubernetes_service" "ingress_nginx" {
  depends_on = [helm_release.ingress_nginx_controller, time_sleep.ingress_nginx]
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

data "kubernetes_service" "public_ingress_nginx" {
  count      = var.enable_public_ingress ? 1 : 0
  depends_on = [helm_release.public_ingress_nginx_controller, time_sleep.public_ingress_nginx]
  metadata {
    name      = "public-ingress-nginx-controller"
    namespace = "public-ingress-nginx"
  }
}
