###
# File: main.tf
# File Created: Friday, 7th May 2021 1:03:01 pm
# -----
# Last Modified: Monday October 3rd 2022 11:57:16 am
# Modified By: Jorge Agüero Zamora <jorge.aguerozamora@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###


# <-- LOCAL VARIABLES -->

locals {
  is_gov_cloud  = length(regexall("us-gov-", var.region)) > 0
  arn_partition = local.is_gov_cloud ? "aws-us-gov" : "aws"
  all_roles = concat(yamldecode(data.kubernetes_config_map.kubernetes_users.data.mapRoles), [
    {
      "rolearn"  = "arn:${local.arn_partition}:iam::${var.cloud_account_id}:role/devstar-tools-developer"
      "username" = "tools-user"
    },
    {
      "rolearn"  = "arn:${local.arn_partition}:iam::${var.cloud_account_id}:role/devstar-usp-developer"
      "username" = "usp-user"
    }
  ])
  all_roles_de_dup = values({ for arn, roles in { for role in local.all_roles : role.rolearn => role... } : arn => roles[0] })

  aws_auth_configmap = yamlencode({
    "apiVersion" = "v1"
    "data" = {
      "mapRoles" = yamlencode(local.all_roles_de_dup)
      "mapUsers" = yamlencode([
        {
          "groups"   = ["system:masters"]
          "userarn"  = "${var.mcp_user_arn}"
          "username" = "svc-usp-mcp"
        },
        {
          "groups"   = ["system:masters"]
          "userarn"  = "arn:${local.arn_partition}:iam::${var.cloud_account_id}:user/svc-tools1"
          "username" = "svc-tools1"
        }
      ])
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "name"      = "aws-auth"
      "namespace" = "kube-system"
    }
  })
}

# <-- DATA SOURCES -->

/**
  The aim by using this data sources is to fetch the last data information about kube-system/aws-auth config map and append default roles
*/

data "kubernetes_config_map" "kubernetes_users" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
}

# <-- AWS-AUTH CONFIG MAP -->

resource "null_resource" "replace_aws_auth_configmap" {
  triggers = {
    hash = md5(local.aws_auth_configmap)
  }

  provisioner "local-exec" {
    command = "echo '\n${local.aws_auth_configmap}' | kubectl replace --context ${var.k8s_context} -f -"
  }
}

#<-- NAMESPACES -->

# resource "kubernetes_namespace" "usp_istio_namespaces" {
#   for_each = var.k8s_usp_with_istio_namespaces
#   metadata {
#     name = each.value
#     labels = {
#       name = each.value
#       istio-injection = "enabled"
#     }
#   }
# }

resource "kubernetes_namespace" "usp_namespaces" {
  for_each = var.k8s_usp_namespaces
  metadata {
    name = each.value
    labels = {
      name       = each.value
      vaultagent = "enabled"
    }
  }
}

# resource "kubernetes_namespace" "tools_istio_namespaces" {
#   for_each = var.k8s_tools_with_istio_namespaces
#   metadata {
#     name = each.value
#     labels = {
#       name = each.value
#       istio-injection = "enabled"
#     }
#   }
# }

resource "kubernetes_namespace" "tools_namespaces" {
  for_each = var.k8s_tools_namespaces
  metadata {
    name = each.value
    labels = {
      name       = each.value
      vaultagent = "enabled"
    }
  }
}

resource "kubernetes_namespace" "ns_vault" {
  metadata {
    name = "${var.environment}-vault"
  }
}

resource "kubernetes_namespace" "tozny_namespaces" {
  for_each = var.k8s_tozny_namespaces
  metadata {
    name = each.value
    labels = {
      name            = each.value
      istio-injection = var.tozny_istio_enabled ? "enabled" : "disabled"
      vaultagent      = "enabled"
    }
  }
}

locals {
  istio_label_default = var.default_istio_enabled
}

// Terraform doesn't own the default namespace to the istio label must be attached manually
resource "null_resource" "default_namespace_istio" {
  count = local.istio_label_default ? 1 : 0

  triggers = {
    hash        = md5(local.istio_label_default)
    k8s_context = var.k8s_context
  }

  provisioner "local-exec" {
    command = "kubectl label namespace default istio-injection=enabled --overwrite --context ${var.k8s_context}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl --context ${self.triggers.k8s_context} label namespace default istio-injection-"
  }

}

resource "null_resource" "istio_usp_namespace_labels_tools" {
  depends_on = [
    kubernetes_namespace.usp_namespaces
  ]

  for_each = var.k8s_usp_with_istio_namespaces
  triggers = {
    build_number = timestamp()
  }
  provisioner "local-exec" {
    command = "kubectl label namespace ${each.value} istio-injection=enabled --overwrite --context ${var.k8s_context}"
  }
}

resource "null_resource" "istio_tools_namespace_labels_tools" {
  depends_on = [
    kubernetes_namespace.tools_namespaces
  ]
  for_each = var.k8s_tools_with_istio_namespaces
  triggers = {
    build_number = timestamp()
  }
  provisioner "local-exec" {
    command = "kubectl label namespace ${each.value} istio-injection=enabled --overwrite --context ${var.k8s_context}"
  }

}

#<-- CLUSTER ROLES -->

resource "kubernetes_cluster_role" "admin_role" {
  metadata {
    name = "admin-role"
  }

  dynamic "rule" {
    for_each = var.k8s_admin_role
    content {
      api_groups = rule.value.api_groups
      resources  = rule.value.resources
      verbs      = rule.value.verbs
    }

  }
}



# <-- ROLEBINDINGS -->



resource "kubernetes_role_binding" "usp_admin_rolebinding" {

  depends_on = [kubernetes_namespace.usp_namespaces, kubernetes_cluster_role.admin_role]
  for_each   = var.k8s_usp_namespaces

  metadata {
    name      = "admin"
    namespace = each.value
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin-role"
  }
  subject {
    kind      = "User"
    name      = "usp-admin"
    api_group = "rbac.authorization.k8s.io"
  }
}



resource "kubernetes_role_binding" "tools_admin_rolebinding" {
  depends_on = [kubernetes_namespace.tools_namespaces, kubernetes_cluster_role.admin_role]
  for_each   = var.k8s_tools_namespaces

  metadata {
    name      = "admin"
    namespace = each.value
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin-role"
  }
  subject {
    kind      = "User"
    name      = "tools-admin"
    api_group = "rbac.authorization.k8s.io"
  }
}



# <-- CLUSTER ROLEBINDINGS  -->


