###
# File: locals.tf
# File Created: Tuesday, 8th June 2021 4:26:54 pm
# -----
# Last Modified: Tuesday July 26th 2022 2:00:43 pm
# Modified By: Jorge Agüero Zamora <jorge.aguerozamora@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###
locals {
  #all_dns_names       = setunion(var.tozny_dns_names, var.dns_names)                                        # merging tozny + rest of dns_names
  #formatted_dns_names = concat(formatlist("%s.${var.hosted_zone}", local.all_dns_names), [var.hosted_zone]) #gitlab.wrai.cloud or tozny.id.wrai.cloud"
  is_govcloud          = length(regexall("us-gov-", var.region)) > 0
  wrai_zones           = data.aws_route53_zone.main
  acme_eab_secret_name = "acme-ssl-eab-secret"
  # ACME using LetsEncrypt (default)
  clusterissuer_default_yaml = yamlencode({
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name"      = "letsencrypt-devstar"
      "namespace" = "cert-manager"
    },
    "spec" = {
      "acme" = {
        "email" = "devops@${var.smtp_domain}"
        "privateKeySecretRef" = {
          "name" = "wrstudio-clusterissuer"
        },
        "server" = var.acme_url
        "solvers" = [
          for zone in local.wrai_zones :
          {
            "dns01" = {
              "route53" = {
                "accessKeyID"  = var.dns_manager_ak_id
                "hostedZoneID" = zone.zone_id
                "region"       = local.is_govcloud ? replace(var.region, "-gov", "") : var.region
                # "role"         = var.dns_manager_role_arn
                "secretAccessKeySecretRef" = {
                  "key"  = "secret"
                  "name" = "aws-route53"
                }
              }
            },
            "selector" = {
              "dnsZones" = [zone.name]
            }
          }
        ]
      }
    }
  })
  # ACME using ZeroSSL
  clusterissuer_yaml = yamlencode({
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name"      = "letsencrypt-devstar"
      "namespace" = "cert-manager"
    },
    "spec" = {
      "acme" = {
        "server" = var.acme_url #"https://acme-v02.api.letsencrypt.org/directory"
        "privateKeySecretRef" = {
          "name" = "wrstudio-clusterissuer"
        }
        "externalAccountBinding" = {
          "keyID" = var.acme_eab_kid
          "keySecretRef" = {
            "name" = local.acme_eab_secret_name
            "key"  = "secret"
          }
        }
        "solvers" = [
          for zone in local.wrai_zones :
          {
            "dns01" = {
              "route53" = {
                "accessKeyID"  = var.dns_manager_ak_id
                "hostedZoneID" = zone.zone_id
                "region"       = local.is_govcloud ? replace(var.region, "-gov", "") : var.region
                # "role"         = var.dns_manager_role_arn
                "secretAccessKeySecretRef" = {
                  "key"  = "secret"
                  "name" = "aws-route53"
                }
              }
            },
            "selector" = {
              "dnsZones" = [zone.name]
            }
          }
        ]
      }
    }
  })

  #domains = merge(
  #  { for key, record in merge(aws_route53_record.tozny_dns_records, aws_route53_record.wrai_dns_records) :
  #    key => record.name
  #  },
  #  { "hosted_zone" = var.hosted_zone }
  #)

  ingress_load_balancer_hostnames        = [for ingress in data.kubernetes_service.ingress_nginx.status.0.load_balancer.0.ingress : ingress.hostname]
  ready_status                           = "'{range .items[*]}{.status.containerStatuses[*].ready.true}{.metadata.name}{ \"\\n\"}{end}'"
  istio_status                           = var.ingress_istio_enabled ? "enabled" : "disabled"
  ingress_nginx_labels                   = "'{\"metadata\":{\"labels\":{\"istio-injection\": ${jsonencode(local.istio_status)}, \"app.kubernetes.io/name\": \"ingress-nginx\"}}}'"
  public_ingress_load_balancer_hostnames = var.enable_public_ingress ? [for ingress in data.kubernetes_service.public_ingress_nginx[0].status.0.load_balancer.0.ingress : ingress.hostname] : []
}
