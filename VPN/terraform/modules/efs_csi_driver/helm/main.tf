###
# File: main.tf
# File Created: Thursday, 20th May 2021 11:58:39 am
# -----
# Last Modified: Tuesday January 17th 2023 6:33:53 am
# Modified By: Jordan Craven <jordan.craven@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###
resource "helm_release" "csi_driver" {
  name  = "csi-driver"
  chart = "${path.module}/charts/csi-driver"

  set {
    name  = "image.repository"
    value = var.docker_image_dict["wr-studio-product/aws-efs-csi-driver"]["repo"]
  }
  set {
    name  = "image.tag"
    value = var.docker_image_dict["wr-studio-product/aws-efs-csi-driver"]["tags"][0]
  }

  # set {
  #   name  = "image.repository"
  #   value = "registry.hub.docker.com/amazon/aws-efs-csi-driver"
  # }
  # set {
  #   name  = "image.tag"
  #   value = "master"
  # }
  set {
    name  = "image.pullPolicy"
    value = var.image_pull_policy
  }

  set {
    name  = "sidecars.livenessProbe.image.repository"
    value = var.docker_image_dict["wr-studio-product/eks-distro/kubernetes-csi/livenessprobe"]["repo"]
  }
  set {
    name  = "sidecars.livenessProbe.image.tag"
    value = var.docker_image_dict["wr-studio-product/eks-distro/kubernetes-csi/livenessprobe"]["tags"][0]
  }
  set {
    name  = "sidecars.livenessProbe.image.pullPolicy"
    value = var.image_pull_policy
  }

  set {
    name  = "sidecars.nodeDriverRegistrar.image.repository"
    value = var.docker_image_dict["wr-studio-product/eks-distro/kubernetes-csi/node-driver-registrar"]["repo"]
  }
  set {
    name  = "sidecars.nodeDriverRegistrar.image.tag"
    value = var.docker_image_dict["wr-studio-product/eks-distro/kubernetes-csi/node-driver-registrar"]["tags"][0]
  }
  set {
    name  = "sidecars.nodeDriverRegistrar.image.pullPolicy"
    value = var.image_pull_policy
  }

  set {
    name  = "sidecars.csiProvisioner.image.repository"
    value = var.docker_image_dict["wr-studio-product/eks-distro/kubernetes-csi/external-provisioner"]["repo"]
  }
  set {
    name  = "sidecars.csiProvisioner.image.tag"
    value = var.docker_image_dict["wr-studio-product/eks-distro/kubernetes-csi/external-provisioner"]["tags"][0]
  }
  set {
    name  = "sidecars.csiProvisioner.image.pullPolicy"
    value = var.image_pull_policy
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.csi_driver_role_arn
  }
  set {
    name  = "node.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.csi_driver_role_arn
  }
  set {
    name  = "node.serviceAccount.name"
    value = "efs-csi-controller-sa"
  }
  set {
    name  = "node.serviceAccount.create"
    value = "false"
  }
  set {
    name  = "controller.deleteAccessPointRootDir"
    value = "true"
  }
}

resource "null_resource" "delete_default_storage_class" {
  provisioner "local-exec" {
    command = "kubectl get storageclasses.storage.k8s.io gp2 --context ${var.k8s_context}; if [ $? -eq 0 ]; then kubectl delete storageclass gp2 --context ${var.k8s_context}; fi"
  }
}

# STORAGE CLASS
