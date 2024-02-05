###
# File: providers.tf
# File Created: Friday, 7th May 2021 1:03:03 pm
# -----
# Last Modified: Tuesday July 26th 2022 1:57:57 pm
# Modified By: Jorge Agüero Zamora <jorge.aguerozamora@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 4.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}

provider "aws" {
  region = var.region
}
provider "aws" {
  alias   = "dns"
  region  = var.region
  profile = "dns"
}
provider "helm" {
  kubernetes {
    config_context = var.k8s_context
    config_path    = "~/.kube/config"
  }
}
provider "kubernetes" {
  config_context = var.k8s_context
  config_path    = "~/.kube/config"
}

provider "tls" {}
