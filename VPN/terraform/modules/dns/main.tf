###
# File: main.tf
# File Created: Friday, 7th May 2021 1:02:57 pm
# -----
# Last Modified: Saturday September 17th 2022 11:46:22 am
# Modified By: Jorge Agüero Zamora <jorge.aguerozamora@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###
# resource "local_file" "updated_calico_yaml" {
#   filename = "${path.module}/helm/charts/calico/calico-updated.yaml"
#   content = templatefile("${path.module}/helm/charts/calico/calico.yaml", {
#     calico_node_registry_url                     = var.docker_image_dict["wr-studio-product/calico/node"]["repo"]
#     calico_node_tag                              = var.docker_image_dict["wr-studio-product/calico/node"]["tags"][0]
#     calico_node_pull_policy                      = var.image_pull_policy
#     calico_typha_registry_url                    = var.docker_image_dict["wr-studio-product/calico/typha"]["repo"]
#     calico_typha_tag                             = var.docker_image_dict["wr-studio-product/calico/typha"]["tags"][0]
#     calico_typha_pull_policy                     = var.image_pull_policy
#     cluster_proportional_autoscaler_registry_url = var.docker_image_dict["wr-studio-product/cluster-proportional-autoscaler-amd64"]["repo"]
#     cluster_proportional_autoscaler_tag          = var.docker_image_dict["wr-studio-product/cluster-proportional-autoscaler-amd64"]["tags"][0]
#     cluster_proportional_autoscaler_pull_policy  = var.image_pull_policy
#   })
# }

# resource "null_resource" "install_calico_plugin" {
#   triggers = {
#     hash        = md5(local_file.updated_calico_yaml.content)
#     k8s_context = var.k8s_context
#   }
#   provisioner "local-exec" {
#     command = "kubectl apply -f ${local_file.updated_calico_yaml.filename} --context ${var.k8s_context}"
#   }
#   provisioner "local-exec" {
#     when    = destroy
#     command = "kubectl --context ${self.triggers.k8s_context} delete -f ${path.module}/helm/charts/calico/calico.yaml"
#   }
# }

resource "helm_release" "calico_operator" {
  name             = "calico-operator"
  chart            = "${path.module}/helm/charts/tigera-operator"
  create_namespace = true
  namespace        = "tigera-operator"
  wait             = true
  timeout          = 300

  set {
    name  = "installation.kubernetesProvider"
    value = "EKS"
  }
  set {
    name  = "apiServer.enabled"
    value = "true"
  }

  set {
    name  = "installation.registry"
    value = var.docker_image_dict["wr-studio-product/quay.io/tigera/operator"]["registry"]
  }
  set {
    name  = "installation.imagePrefix"
    value = ""
  }
  set {
    name  = "installation.imagePath"
    value = "wr-studio-product/calico"
  }
  set {
    name  = "tigeraOperator.image"
    value = "wr-studio-product/quay.io/tigera/operator"
  }
  set {
    name  = "tigeraOperator.registry"
    value = var.docker_image_dict["wr-studio-product/quay.io/tigera/operator"]["registry"]
  }
  set {
    name  = "tigeraOperator.tag"
    value = var.docker_image_dict["wr-studio-product/quay.io/tigera/operator"]["tags"][0]
  }
  set {
    name  = "calicoctl.image"
    value = "wr-studio-product/calico/ctl"
  }
  set {
    name  = "calicoctl.registry"
    value = var.docker_image_dict["wr-studio-product/calico/ctl"]["registry"]
  }
  set {
    name  = "calicoctl.tag"
    value = var.docker_image_dict["wr-studio-product/calico/ctl"]["tags"][0]
  }
}


resource "kubernetes_namespace" "istio_system" {
  depends_on = [helm_release.calico_operator]
  metadata {
    name = "istio-system"
  }
}

resource "time_sleep" "wait_for_calico" {
  depends_on      = [helm_release.calico_operator]
  create_duration = "60s"
}

# Istio required clusterrole, crds
resource "helm_release" "istio_base" {
  depends_on = [kubernetes_namespace.istio_system, helm_release.calico_operator, time_sleep.wait_for_calico]
  name       = "istio-base"
  chart      = "${path.module}/helm/charts/istio-1.10.4/base"
  namespace  = "istio-system"
  wait       = true
  timeout    = 300
}

# Istiod service
resource "helm_release" "istiod" {
  depends_on = [helm_release.istio_base, helm_release.calico_operator]
  name       = "istiod"
  chart      = "${path.module}/helm/charts/istio-1.10.4/istio-control/istio-discovery"
  namespace  = "istio-system"
  wait       = true
  timeout    = 300

  set {
    name  = "global.hub"
    value = format("%s/wr-studio-product/external/docker.io/istio", var.docker_image_dict["wr-studio-product/external/docker.io/istio/pilot"]["registry"])
  }
  set {
    name  = "global.tag"
    value = format("%s", var.docker_image_dict["wr-studio-product/external/docker.io/istio/pilot"]["tags"][0])
  }
  set {
    name  = "global.proxy.image"
    value = "proxyv2"
  }
  set {
    name  = "global.proxy_init.image"
    value = "proxyv2"
  }
  set {
    name  = "global.pilot.image"
    value = "pilot"
  }

  set {
    name  = "global.pullPolicy"
    value = var.image_pull_policy
  }
}

resource "helm_release" "istio_proxy_config" {
  depends_on = [helm_release.istiod]
  name       = "istio-proxy-config"
  chart      = "${path.module}/helm/charts/istio-proxy-config"
  namespace  = "istio-system"
  wait       = true
  timeout    = 60
}

resource "helm_release" "ingress_nginx_controller" {
  depends_on       = [helm_release.calico_operator, helm_release.istiod]
  name             = "ingress-nginx"
  chart            = "${path.module}/helm/charts/ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  wait             = true
  timeout          = 600

  values = [<<EOF
controller:
  watchIngressWithoutClass: true
  ingressClassResource:
    default: true
  ingressClassByName: true
  image:
    repository: ${var.docker_image_dict["wr-studio-product/ingress-nginx/controller"]["repo"]}
    tag: ${var.docker_image_dict["wr-studio-product/ingress-nginx/controller"]["tags"][0]}
    pullPolicy: ${var.image_pull_policy}
    digest: ""
  config:
    proxy-buffer-size: 8k
    hsts-preload: "true"
  service:
    loadBalancerSourceRanges:
      - ${var.vpc_cidr_block}
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
      service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: true
      service.beta.kubernetes.io/aws-load-balancer-internal: true
      service.beta.kubernetes.io/aws-load-balancer-type: nlb
    externalTrafficPolicy: Local
  admissionWebhooks:
    patch:
      image:
        repository: ${var.docker_image_dict["wr-studio-product/external/registry.k8s.io/ingress-nginx/kube-webhook-certgen"]["repo"]}
        tag: ${var.docker_image_dict["wr-studio-product/external/registry.k8s.io/ingress-nginx/kube-webhook-certgen"]["tags"][0]}
        pullPolicy: ${var.image_pull_policy}
      podAnnotations:
        sidecar.istio.io/inject: "false"
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
            - key: pe
              operator: In
              values:
                - ingress-controller
  tolerations:
    - effect: NoSchedule
      key: ingress-controller
      operator: Equal
      value: "true"
  annotations:
    traffic.sidecar.istio.io/excludeInboundPorts: "80, 443"
tcp:
  22: "prod-wrai-tools-gitlab-dev/gitlab-dev-gitlab-shell:22"
  2222: "prod-wrai-usp-hive/ssh-portal:2222"
EOF
  ]
}

resource "null_resource" "label_ingress_nginx_namespace" {
  depends_on = [helm_release.ingress_nginx_controller]
  provisioner "local-exec" {
    command = "kubectl patch namespace ingress-nginx -p ${local.ingress_nginx_labels} --context ${var.k8s_context}"
  }
}

# this is a patch for https://github.com/kubernetes/cloud-provider-aws/issues/301
resource "null_resource" "patch_ingress_nginx_service" {
  depends_on = [null_resource.label_ingress_nginx_namespace]
  provisioner "local-exec" {
    command = "kubectl patch service ingress-nginx-controller -n ingress-nginx -p '{ \"metadata\": { \"annotations\": { \"service.beta.kubernetes.io/aws-load-balancer-scheme\": \"internal\" } } }' --context ${var.k8s_context}"
  }
}

resource "helm_release" "public_ingress_nginx_controller" {
  count            = var.enable_public_ingress ? 1 : 0
  depends_on       = [helm_release.calico_operator]
  name             = "public-ingress-nginx"
  chart            = "${path.module}/helm/charts/ingress-nginx"
  namespace        = "public-ingress-nginx"
  create_namespace = true
  wait             = true
  timeout          = 60

  values = [<<EOF
controller:
  image:
    repository: ${var.docker_image_dict["wr-studio-product/ingress-nginx/controller"]["repo"]}
    tag: ${var.docker_image_dict["wr-studio-product/ingress-nginx/controller"]["tags"][0]}
    pullPolicy: ${var.image_pull_policy}
    digest: ""
  config:
    proxy-buffer-size: 8k
    hsts-preload: "true"
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
      service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
      service.beta.kubernetes.io/aws-load-balancer-type: nlb
      service.beta.kubernetes.io/aws-load-balancer-internal: "false"
    externalTrafficPolicy: "Local"
    loadBalancerSourceRanges: ${jsonencode(var.public_ingress_cidr_blocks)}
  admissionWebhooks:
    patch:
      image:
        repository: ${var.docker_image_dict["wr-studio-product/external/registry.k8s.io/ingress-nginx/kube-webhook-certgen"]["repo"]}
        tag: ${var.docker_image_dict["wr-studio-product/external/registry.k8s.io/ingress-nginx/kube-webhook-certgen"]["tags"][0]}
        pullPolicy: ${var.image_pull_policy}
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
            - key: pe
              operator: In
              values:
                - public-ingress-controller
  tolerations:
    - effect: NoSchedule
      key: public-ingress-controller
      operator: Equal
      value: "true"
  ingressClass: public-nginx
EOF
  ]
}

# Wait for 3m when ingress_nginx changes
resource "time_sleep" "ingress_nginx" {
  depends_on = [helm_release.ingress_nginx_controller]

  create_duration = "3m"
}

# Wait for 3m when public_ingress_nginx changes
resource "time_sleep" "public_ingress_nginx" {
  count      = var.enable_public_ingress ? 1 : 0
  depends_on = [helm_release.public_ingress_nginx_controller]

  create_duration = "3m"
}

# Cert Manager
resource "helm_release" "cert_manager" {
  depends_on       = [helm_release.ingress_nginx_controller, data.kubernetes_service.ingress_nginx]
  name             = "cert-manager"
  chart            = "${path.module}/helm/charts/cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  wait             = true
  timeout          = 60

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "prometheus.enabled"
    value = "false"
  }

  set {
    name  = "image.repository"
    value = var.docker_image_dict["wr-studio-product/external/quay.io/jetstack/cert-manager-controller"]["repo"]
  }

  set {
    name  = "image.tag"
    value = var.docker_image_dict["wr-studio-product/external/quay.io/jetstack/cert-manager-controller"]["tags"][0]
  }

  set {
    name  = "image.pullPolicy"
    value = var.image_pull_policy
  }

  set {
    name  = "webhook.image.repository"
    value = var.docker_image_dict["wr-studio-product/external/quay.io/jetstack/cert-manager-webhook"]["repo"]
  }

  set {
    name  = "webhook.image.tag"
    value = var.docker_image_dict["wr-studio-product/external/quay.io/jetstack/cert-manager-webhook"]["tags"][0]
  }

  set {
    name  = "webhook.image.pullPolicy"
    value = var.image_pull_policy
  }

  set {
    name  = "cainjector.image.repository"
    value = var.docker_image_dict["wr-studio-product/external/quay.io/jetstack/cert-manager-cainjector"]["repo"]
  }

  set {
    name  = "cainjector.image.tag"
    value = var.docker_image_dict["wr-studio-product/external/quay.io/jetstack/cert-manager-cainjector"]["tags"][0]
  }

  set {
    name  = "cainjector.image.pullPolicy"
    value = var.image_pull_policy
  }

  dynamic "set" {
    for_each = var.is_private_dns ? [var.is_private_dns] : []
    content {
      name  = "extraArgs[0]"
      value = "--dns01-recursive-nameservers-only"
    }

  }

  dynamic "set" {
    for_each = var.is_private_dns ? [var.is_private_dns] : []
    content {
      name  = "extraArgs[1]"
      value = "--dns01-recursive-nameservers=${var.private_dns_server_ip}:${var.private_dns_server_port}"
    }
  }
}

# MANAGER SECRET
resource "kubernetes_secret" "secret_k8s" {
  depends_on = [helm_release.cert_manager]
  metadata {
    name      = "aws-route53"
    namespace = "cert-manager"
  }

  # ACME
  data = {
    secret = var.dns_manager_ak_secret
  }

  type = "Opaque"
}

resource "kubernetes_secret" "acme_eab_secret" {
  count      = var.acme_use_eab_credentials ? 1 : 0
  depends_on = [helm_release.cert_manager]
  metadata {
    name      = local.acme_eab_secret_name
    namespace = "cert-manager"
  }

  # ACME
  data = {
    secret = var.acme_eab_secret
  }

  type = "Opaque"
}

resource "time_sleep" "wait_for_cert_manager" { # after cert manager is deployed, wait for cainjector to inject the CA certificate into webhook
  depends_on      = [helm_release.cert_manager]
  create_duration = "50s"
}

resource "null_resource" "create_clusterissuer" {
  count      = var.acme_use_eab_credentials ? 1 : 0
  depends_on = [time_sleep.wait_for_cert_manager, helm_release.cert_manager]

  triggers = {
    hash        = md5(local.clusterissuer_yaml)
    k8s_context = var.k8s_context
  }

  provisioner "local-exec" {
    command = "echo '\n${local.clusterissuer_yaml}' | kubectl apply --context ${var.k8s_context} -f -"
  }


  provisioner "local-exec" {
    when       = destroy
    command    = "kubectl --context ${self.triggers.k8s_context} delete ClusterIssuer letsencrypt-devstar --ignore-not-found"
    on_failure = continue
  }
}

resource "null_resource" "create_clusterissuer_default" {
  count      = var.acme_use_eab_credentials == false ? 1 : 0
  depends_on = [time_sleep.wait_for_cert_manager, helm_release.cert_manager]

  triggers = {
    hash        = md5(local.clusterissuer_default_yaml)
    k8s_context = var.k8s_context
  }

  provisioner "local-exec" {
    command = "echo '\n${local.clusterissuer_default_yaml}' | kubectl apply --context ${var.k8s_context} -f -"
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "kubectl --context ${self.triggers.k8s_context} delete ClusterIssuer letsencrypt-devstar --ignore-not-found"
    on_failure = continue
  }
}
