###
# File: outputs.tf
# File Created: Friday, 7th May 2021 1:03:01 pm
# -----
# Last Modified: Tuesday May 11th 2021 11:51:02 am
# Modified By: Gabriel Vidaurre <gabriel.vidaurrerodriguez@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
# 
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

output "usp_namespaces" {
  value       = kubernetes_namespace.usp_namespaces
  description = "USP Kubernetes namespaces"
}

output "tools_namespaces" {
  value       = kubernetes_namespace.tools_namespaces
  description = "Tools Kubernetes namespaces"
}

output "tozny_namespaces" {
  value       = kubernetes_namespace.tozny_namespaces
  description = "Tozny Kubernetes namespaces"
}
