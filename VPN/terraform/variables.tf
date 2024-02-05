###
# File: variables.tf
# File Created: Friday, 7th May 2021 1:03:03 pm
# -----
# Last Modified: Friday January 13th 2023 8:15:22 am
# Modified By: Jordan Craven <jordan.craven@windriver.com>
# -----
# Copyright (c) 2022 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

variable "region" {
  type    = string
  default = null
}
variable "separate_dns_account" {
  type    = bool
  default = false
}
variable "parent_region" {
  type    = string
  default = null
}
variable "region_bucket_name" {
  type    = string
  default = null
}
variable "project" {
  type    = string
  default = null
}
variable "environment" {
  type    = string
  default = null
}
variable "hosted_zone" {
  type    = string
  default = null
}
variable "hosted_zone_list" {
  type = set(string)
}
variable "smtp_domain" {
  type    = string
  default = null
}

variable "smarthost_address" {
  type    = string
  default = ""
}
variable "image_pull_policy" {
  type    = string
  default = "IfNotPresent"
}
variable "storage_class" {
  type    = string
  default = "efs-sc"
}
variable "dns_names" {
  type = set(string)
  default = [
    "gitlab",
    "registry.gitlab",
    "jenkins",
    "artifacts",
    "console.artifacts",
    "usp",
    "mcp",
    "mcp.gateway",
    "usp.gateway",
    "ntf",
    "ntf.gateway",
    "portal.gateway",
    "lxbs",
    "lxbs.gateway",
    "ota",
    "vxbs",
    "vxbs.gateway",
    "vxbs.vxbs-config-sr0660",
    "vxbs.vxbs-config-sr0650",
    "vxbs.vxbs-config-sr0640",
    "vxbs.vxbs-config-sr0630",
    "vxbs.vxbs-config-sr0620",
    "vxbs.vxbs-config-sr0610",
    "vxbs.vxbs-config-sr0541",
    "vxbs.vxbs-config-2103",
    "vxbs.vxbs-config-2107",
    "vxbs.vxbs-config-2111",
    "vxbs.vxbs-config-2203",
    "system.registry",
    "system.notary",
    "device.registry",
    "device.notary",
    "fossology",
    "codeinsight",
    "coverity",
    "wrsc",
    "hive",
    "hive.gateway",
    "hive.ssh-handler",
    "hive.slc-dis",
    "hive.slc-dms",
    "target",
    "prometheus",
    "plm",
    "plm.gateway",
    "gallery",
    "gallery.gateway",
    "zerot-manage",
    "tekton-dashboard",
    "webhook",
    "oauth-tekton-dashboard",
    "lxbs.metadata",
    "lxbs.layers",
    "kiali",
    "grafana",
    "tracing",
    "platformhealth",
    "openapi.usp",
    "um.gateway",
    "lxbs.hawkbit",
    "vault",
    "taf",
    "taf.gateway",
    "um.openapi",
    "schedule.gateway",
    "gitlab.connector"
  ]

}
variable "enable_zerot" {
  type    = bool
  default = false
}

variable "domains" {
  type        = map(string)
  description = "Map of domain prefixes to full domain names."
}
variable "tozny_dns_names" {
  type = set(string)
  default = [
    "tozny.dashboard", #[0] always dashboard
    "tozny.id",        #[1] always ID
    "tozny.api"        #[2] always API
  ]
}

variable "ingress_istio_enabled" {
  type    = bool
  default = true
}

variable "tozny_istio_enabled" {
  type    = bool
  default = true
}

variable "default_istio_enabled" {
  type    = bool
  default = true
}

variable "k8s_usp_namespaces_suffix" {
  type = list(string)
  default = [
    "device-manager",
    "wrai-usp-mcp",
    "wrai-usp-generic",
    "wrai-usp-datapipeline",
    "wrai-usp-lxbs",
    "wrai-usp-vxbs",
    "wrai-usp-hive",
    "wrai-usp-hive-virtual-target",
    "wrai-usp-plm",
    "wrai-usp-ntf",
    "wrai-usp-plm-workloads",
    "wrai-usp-gallery",
    "wrai-portal",
    "wrai-usp-taf",
    "um",
    "wrai-usp-schedule",
    "wrai-usp-schedule-jobs"
  ]
}
variable "k8s_usp_with_istio_namespaces_suffix" {
  type = list(string)
  default = [
    "wrai-usp-mcp",
    "wrai-usp-datapipeline",
    "wrai-usp-lxbs",
    "wrai-usp-vxbs",
    "device-manager",
    "wrai-portal",
    "um",
    "wrai-usp-ntf"
  ]
}

variable "k8s_usp_no_istio_namespaces_suffix" {
  type = list(string)
  default = [
    "wrai-usp-generic",
    "wrai-usp-hive-virtual-target",
    "wrai-usp-hive"
  ]
}
variable "k8s_tools_namespaces_suffix" {
  type = list(string)
  default = [
    "wrai-tools-artifacts-dev",
    "wrai-tools-artifacts-forensic",
    "wrai-tools-gitlab-dev",
    "wrai-tools-jenkins",
    "wrai-tools-jenkins-agents",
    "system-registry",
    "device-registry",
    "wrai-tools-codeinsight",
    "wrai-tools-fossology",
    "wrai-tools-coverity",
    "wrsc",
    "wrai-infra-logs-signing-proxy",
    "wrai-infra-networking-flow-logs",
    "wrai-tools-fluentbit",
    "wrai-tools-monitoring",
    "wrai-tools-tekton-pipelines",
    "wrai-tools-kong",
    "gitlab-connector"
  ]
}

variable "k8s_tools_no_istio_namespaces_suffix" {
  type = list(string)
  default = [
    "wrai-tools-codeinsight",
    "wrai-tools-fossology",
    "wrai-tools-coverity",
    "wrai-tools-kong",
    "gitlab-connector"
  ]
}

variable "k8s_tools_with_istio_namespaces_suffix" {
  type = list(string)
  default = [
    "device-registry",
    "system-registry",
    "wrai-tools-artifacts-dev",
    "wrai-tools-artifacts-forensic",
    "wrai-tools-gitlab-dev",
    "wrai-tools-jenkins",
    "wrai-tools-jenkins-agents",
    "wrai-infra-logs-signing-proxy",
    "wrai-tools-fluentbit",
    "wrsc" #WRSC and above have istio configuration available
  ]
}
variable "k8s_tozny_namespaces_suffix" {
  type = list(string)
  default = [
    "wrai-infra-tozny"
  ]
}
variable "k8s_admin_role" {
  type = map(any)
  default = {
    "0" = {
      "api_groups" = [
        "cert-manager.io"
      ],
      "resources" = [
        "certificates",
        "certificaterequests",
        "issuers"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "1" = {
      "api_groups" = [
        "cert-manager.io"
      ],
      "resources" = [
        "certificates",
        "certificaterequests",
        "issuers"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "2" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "pods/attach",
        "pods/exec",
        "pods/portforward",
        "pods/proxy",
        "secrets",
        "services/proxy"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "3" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "serviceaccounts"
      ],
      "verbs" = [
        "impersonate"
      ]
    },
    "4" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "pods",
        "pods/attach",
        "pods/exec",
        "pods/portforward",
        "pods/proxy"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "5" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "configmaps",
        "endpoints",
        "persistentvolumeclaims",
        "replicationcontrollers",
        "replicationcontrollers/scale",
        "secrets",
        "serviceaccounts",
        "services",
        "services/proxy"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "6" = {
      "api_groups" = [
        "apps"
      ],
      "resources" = [
        "daemonsets",
        "deployments",
        "deployments/rollback",
        "deployments/scale",
        "replicasets",
        "replicasets/scale",
        "statefulsets",
        "statefulsets/scale"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "7" = {
      "api_groups" = [
        "autoscaling"
      ],
      "resources" = [
        "horizontalpodautoscalers"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "8" = {
      "api_groups" = [
        "batch"
      ],
      "resources" = [
        "cronjobs",
        "jobs"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "9" = {
      "api_groups" = [
        "extensions"
      ],
      "resources" = [
        "daemonsets",
        "deployments",
        "deployments/rollback",
        "deployments/scale",
        "ingresses",
        "networkpolicies",
        "replicasets",
        "replicasets/scale",
        "replicationcontrollers/scale"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "10" = {
      "api_groups" = [
        "policy"
      ],
      "resources" = [
        "poddisruptionbudgets"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "11" = {
      "api_groups" = [
        "networking.k8s.io"
      ],
      "resources" = [
        "ingresses",
        "networkpolicies"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "12" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "configmaps",
        "endpoints",
        "persistentvolumeclaims",
        "persistentvolumeclaims/status",
        "pods",
        "replicationcontrollers",
        "replicationcontrollers/scale",
        "serviceaccounts",
        "services",
        "services/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "13" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "bindings",
        "events",
        "limitranges",
        "namespaces/status",
        "pods/log",
        "pods/status",
        "replicationcontrollers/status",
        "resourcequotas",
        "resourcequotas/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "14" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "namespaces"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "15" = {
      "api_groups" = [
        "apps"
      ],
      "resources" = [
        "controllerrevisions",
        "daemonsets",
        "daemonsets/status",
        "deployments",
        "deployments/scale",
        "deployments/status",
        "replicasets",
        "replicasets/scale",
        "replicasets/status",
        "statefulsets",
        "statefulsets/scale",
        "statefulsets/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "16" = {
      "api_groups" = [
        "autoscaling"
      ],
      "resources" = [
        "horizontalpodautoscalers",
        "horizontalpodautoscalers/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "17" = {
      "api_groups" = [
        "batch"
      ],
      "resources" = [
        "cronjobs",
        "cronjobs/status",
        "jobs",
        "jobs/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "18" = {
      "api_groups" = [
        "extensions"
      ],
      "resources" = [
        "daemonsets",
        "daemonsets/status",
        "deployments",
        "deployments/scale",
        "deployments/status",
        "ingresses",
        "ingresses/status",
        "networkpolicies",
        "replicasets",
        "replicasets/scale",
        "replicasets/status",
        "replicationcontrollers/scale"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "19" = {
      "api_groups" = [
        "policy"
      ],
      "resources" = [
        "poddisruptionbudgets",
        "poddisruptionbudgets/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "20" = {
      "api_groups" = [
        "networking.k8s.io"
      ],
      "resources" = [
        "ingresses",
        "ingresses/status",
        "networkpolicies"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "21" = {
      "api_groups" = [
        "authorization.k8s.io"
      ],
      "resources" = [
        "localsubjectaccessreviews"
      ],
      "verbs" = [
        "create"
      ]
    },
    "22" = {
      "api_groups" = [
        "rbac.authorization.k8s.io"
      ],
      "resources" = [
        "rolebindings",
        "roles"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ]
    },
    "23" = {
      "api_groups" = [
        "velero.io"
      ],
      "resources" = [
        "backups",
        "restores",
        "downloadrequests",
        "schedules",
        "backupstoragelocations",
        "volumesnapshotlocations",
        "podvolumerestores",
        "podvolumebackups",
        "deletebackuprequests"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "24" = {
      "api_groups" = [
        "velero.io"
      ],
      "resources" = [
        "backups",
        "restores",
        "downloadrequests",
        "schedules",
        "backupstoragelocations",
        "volumesnapshotlocations",
        "podvolumerestores",
        "podvolumebackups",
        "deletebackuprequests"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    }
  }
}
variable "k8s_viewer_role" {
  type = map(any)
  default = {
    "0" = {
      "api_groups" = [
        "cert-manager.io"
      ],
      "resources" = [
        "certificates",
        "certificaterequests",
        "issuers"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "1" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "configmaps",
        "endpoints",
        "persistentvolumeclaims",
        "persistentvolumeclaims/status",
        "pods",
        "replicationcontrollers",
        "replicationcontrollers/scale",
        "serviceaccounts",
        "services",
        "services/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "2" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "bindings",
        "events",
        "limitranges",
        "namespaces/status",
        "pods/log",
        "pods/status",
        "replicationcontrollers/status",
        "resourcequotas",
        "resourcequotas/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "3" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "namespaces"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "4" = {
      "api_groups" = [
        "apps"
      ],
      "resources" = [
        "controllerrevisions",
        "daemonsets",
        "daemonsets/status",
        "deployments",
        "deployments/scale",
        "deployments/status",
        "replicasets",
        "replicasets/scale",
        "replicasets/status",
        "statefulsets",
        "statefulsets/scale",
        "statefulsets/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "5" = {
      "api_groups" = [
        "autoscaling"
      ],
      "resources" = [
        "horizontalpodautoscalers",
        "horizontalpodautoscalers/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "6" = {
      "api_groups" = [
        "batch"
      ],
      "resources" = [
        "cronjobs",
        "cronjobs/status",
        "jobs",
        "jobs/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "7" = {
      "api_groups" = [
        "extensions"
      ],
      "resources" = [
        "daemonsets",
        "daemonsets/status",
        "deployments",
        "deployments/scale",
        "deployments/status",
        "ingresses",
        "ingresses/status",
        "networkpolicies",
        "replicasets",
        "replicasets/scale",
        "replicasets/status",
        "replicationcontrollers/scale"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "8" = {
      "api_groups" = [
        "policy"
      ],
      "resources" = [
        "poddisruptionbudgets",
        "poddisruptionbudgets/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "9" = {
      "api_groups" = [
        "networking.k8s.io"
      ],
      "resources" = [
        "ingresses",
        "ingresses/status",
        "networkpolicies"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    }
  }
}
variable "k8s_developer_role" {
  type = map(any)
  default = {
    "0" = {
      "api_groups" = [
        "cert-manager.io"
      ],
      "resources" = [
        "certificates",
        "certificaterequests",
        "issuers"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "1" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "pods/attach",
        "pods/exec",
        "pods/portforward",
        "pods/proxy",
        "secrets",
        "services/proxy"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "2" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "pods",
        "pods/attach",
        "pods/exec",
        "pods/portforward",
        "pods/proxy"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "3" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "configmaps",
        "endpoints",
        "replicationcontrollers",
        "replicationcontrollers/scale",
        "secrets",
        "serviceaccounts",
        "services",
        "services/proxy"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "4" = {
      "api_groups" = [
        "apps"
      ],
      "resources" = [
        "daemonsets",
        "deployments",
        "deployments/rollback",
        "deployments/scale",
        "replicasets",
        "replicasets/scale",
        "statefulsets",
        "statefulsets/scale"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "5" = {
      "api_groups" = [
        "batch"
      ],
      "resources" = [
        "cronjobs",
        "jobs"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "6" = {
      "api_groups" = [
        "extensions"
      ],
      "resources" = [
        "daemonsets",
        "deployments",
        "deployments/rollback",
        "deployments/scale",
        "ingresses",
        "replicasets",
        "replicasets/scale",
        "replicationcontrollers/scale"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "7" = {
      "api_groups" = [
        "policy"
      ],
      "resources" = [
        "poddisruptionbudgets"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "8" = {
      "api_groups" = [
        "networking.k8s.io"
      ],
      "resources" = [
        "ingresses"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "9" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "configmaps",
        "endpoints",
        "persistentvolumeclaims",
        "persistentvolumeclaims/status",
        "pods",
        "replicationcontrollers",
        "replicationcontrollers/scale",
        "serviceaccounts",
        "services",
        "services/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "10" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "bindings",
        "events",
        "limitranges",
        "namespaces/status",
        "pods/log",
        "pods/status",
        "replicationcontrollers/status",
        "resourcequotas",
        "resourcequotas/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "11" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "namespaces"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "12" = {
      "api_groups" = [
        "apps"
      ],
      "resources" = [
        "controllerrevisions",
        "daemonsets",
        "daemonsets/status",
        "deployments",
        "deployments/scale",
        "deployments/status",
        "replicasets",
        "replicasets/scale",
        "replicasets/status",
        "statefulsets",
        "statefulsets/scale",
        "statefulsets/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "13" = {
      "api_groups" = [
        "autoscaling"
      ],
      "resources" = [
        "horizontalpodautoscalers",
        "horizontalpodautoscalers/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "14" = {
      "api_groups" = [
        "batch"
      ],
      "resources" = [
        "cronjobs",
        "cronjobs/status",
        "jobs",
        "jobs/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "15" = {
      "api_groups" = [
        "extensions"
      ],
      "resources" = [
        "daemonsets",
        "daemonsets/status",
        "deployments",
        "deployments/scale",
        "deployments/status",
        "ingresses",
        "ingresses/status",
        "networkpolicies",
        "replicasets",
        "replicasets/scale",
        "replicasets/status",
        "replicationcontrollers/scale"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "16" = {
      "api_groups" = [
        "policy"
      ],
      "resources" = [
        "poddisruptionbudgets",
        "poddisruptionbudgets/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "17" = {
      "api_groups" = [
        "networking.k8s.io"
      ],
      "resources" = [
        "ingresses",
        "ingresses/status",
        "networkpolicies"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "18" = {
      "api_groups" = [
        "rbac.authorization.k8s.io"
      ],
      "resources" = [
        "rolebindings",
        "roles"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    }
  }
}
variable "k8s_operator_role" {
  type = map(any)
  default = {
    "0" = {
      "api_groups" = [
        "cert-manager.io"
      ],
      "resources" = [
        "certificates",
        "certificaterequests",
        "issuers"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "1" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "pods/attach",
        "pods/exec",
        "pods/portforward",
        "pods/proxy",
        "secrets",
        "services/proxy"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "2" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "pods",
        "pods/attach",
        "pods/exec",
        "pods/portforward",
        "pods/proxy"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "3" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "configmaps",
        "endpoints",
        "replicationcontrollers",
        "replicationcontrollers/scale",
        "secrets",
        "serviceaccounts",
        "services",
        "services/proxy"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "4" = {
      "api_groups" = [
        "apps"
      ],
      "resources" = [
        "daemonsets",
        "deployments",
        "deployments/rollback",
        "deployments/scale",
        "replicasets",
        "replicasets/scale",
        "statefulsets",
        "statefulsets/scale"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "5" = {
      "api_groups" = [
        "extensions"
      ],
      "resources" = [
        "daemonsets",
        "deployments",
        "deployments/rollback",
        "deployments/scale",
        "ingresses",
        "replicasets",
        "replicasets/scale",
        "replicationcontrollers/scale"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "6" = {
      "api_groups" = [
        "policy"
      ],
      "resources" = [
        "poddisruptionbudgets"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "7" = {
      "api_groups" = [
        "networking.k8s.io"
      ],
      "resources" = [
        "ingresses"
      ],
      "verbs" = [
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update"
      ]
    },
    "8" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "configmaps",
        "endpoints",
        "persistentvolumeclaims",
        "persistentvolumeclaims/status",
        "pods",
        "replicationcontrollers",
        "replicationcontrollers/scale",
        "serviceaccounts",
        "services",
        "services/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "9" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "bindings",
        "events",
        "limitranges",
        "namespaces/status",
        "pods/log",
        "pods/status",
        "replicationcontrollers/status",
        "resourcequotas",
        "resourcequotas/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "10" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "namespaces"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "11" = {
      "api_groups" = [
        "apps"
      ],
      "resources" = [
        "controllerrevisions",
        "daemonsets",
        "daemonsets/status",
        "deployments",
        "deployments/scale",
        "deployments/status",
        "replicasets",
        "replicasets/scale",
        "replicasets/status",
        "statefulsets",
        "statefulsets/scale",
        "statefulsets/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "12" = {
      "api_groups" = [
        "autoscaling"
      ],
      "resources" = [
        "horizontalpodautoscalers",
        "horizontalpodautoscalers/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "13" = {
      "api_groups" = [
        "batch"
      ],
      "resources" = [
        "cronjobs",
        "cronjobs/status",
        "jobs",
        "jobs/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "14" = {
      "api_groups" = [
        "extensions"
      ],
      "resources" = [
        "daemonsets",
        "daemonsets/status",
        "deployments",
        "deployments/scale",
        "deployments/status",
        "ingresses",
        "ingresses/status",
        "networkpolicies",
        "replicasets",
        "replicasets/scale",
        "replicasets/status",
        "replicationcontrollers/scale"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "15" = {
      "api_groups" = [
        "policy"
      ],
      "resources" = [
        "poddisruptionbudgets",
        "poddisruptionbudgets/status"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "16" = {
      "api_groups" = [
        "networking.k8s.io"
      ],
      "resources" = [
        "ingresses",
        "ingresses/status",
        "networkpolicies"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "17" = {
      "api_groups" = [
        "rbac.authorization.k8s.io"
      ],
      "resources" = [
        "rolebindings",
        "roles"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    }
  }
}
variable "k8s_cluster_actions_role" {
  type = map(any)
  default = {
    "0" = {
      "api_groups" = [
        ""
      ],
      "resources" = [
        "namespaces",
        "namespaces/status",
        "nodes"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    },
    "1" = {
      "api_groups" = [
        "rbac.authorization.k8s.io"
      ],
      "resources" = [
        "clusterroles"
      ],
      "verbs" = [
        "get",
        "list",
        "watch"
      ]
    }
  }
}

variable "is_private_dns" {
  description = "Whether the Route53 hosted zone is Private (true) or Public (false). Default = false"
  type        = bool
  default     = false
}

variable "private_dns_server_ip" {
  description = "IP address of the DNS server when using private DNS"
  type        = string
  default     = ""
}

variable "private_dns_server_port" {
  description = "Port where the private DNS server listens for requests. (Default = 53)"
  type        = number
  default     = 53
}

variable "acme_eab_secret" {
  description = "External Account Binding HMAC used by the ACME client for authentication. Ignored if 'acme_use_eab_credentials' is false"
  type        = string
  default     = ""
}
variable "acme_eab_kid" {
  description = "External Account Binding key id used by the ACME client for authentication. Ignored if 'acme_use_eab_credentials' is false"
  type        = string
  default     = ""
}

variable "acme_use_eab_credentials" {
  description = "Used by the ACME client to know if the server requires External Account Binding credentials"
  type        = bool
  default     = false
}
variable "acme_url" {
  description = "The URL used by cert-manager for the ACME process"
  type        = string
  default     = "https://acme.zerossl.com/v2/DV90"
}

variable "public_ingress_cidr_blocks" {
  default     = []
  type        = list(string)
  description = "Populating will block access to public ingress from other IP addresses"
}

variable "k8s_context" {
  type = string
}

variable "nat_gateway_ips" { type = list(string) }
variable "vpc_cidr_block" { type = string }
variable "vpc_id" { type = string }

variable "private_subnet_ids" {
  type        = list(string)
  description = "Subnet Ids the Nodes"
}
variable "cluster_name" {
  type = string
}
variable "registry_hostname" {
  description = "Domain of the registry where the Studio images are located"
  type = string
}

variable "external_ecr_user_id" {
  description = "AWS access key id with access to existing ECR"
  default     = ""
}

variable "external_ecr_user_key" {
  description = "AWS secret access key with access to existing ECR"
  default     = ""
}

variable "external_ecr_region" {
  description = "AWS region of existing ECR"
  default     = ""
}

variable "create_iam_resources" {
  type = bool
}

variable "mcp_credentials_id" {
  type = string
}

variable "mcp_credentials_key" {
  type = string
}

variable "mcp_user_arn" {
  type = string
}

variable "dns_manager_ak_id" {
  type = string
}

variable "dns_manager_ak_secret" {
  type = string
}

# variable "dns_manager_role_arn" {
#   type    = string
# }

variable "velero_access_key_id" {
  type = string
}

variable "velero_access_key_secret" {
  type = string
}

variable "logs_access_key_id" {
  type = string
}

variable "logs_access_key_secret" {
  type = string
}

variable "networking_flow_logs_access_key_id" {
  type = string
}

variable "networking_flow_logs_access_key_secret" {
  type = string
}

variable "ebs_csi_role_arn" {
  type    = string
  default = ""
}

variable "efs_csi_role_arn" {
  type    = string
  default = ""
}

variable "efs_security_group_id" {
  type    = string
  default = null
}
