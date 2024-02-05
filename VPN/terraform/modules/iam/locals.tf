###
# File: locals.tf
# File Created: Friday, 7th May 2021 1:02:57 pm
# -----
# Last Modified: Tuesday September 13th 2022 3:38:15 pm
# Modified By: Jorge Agüero Zamora <jorge.aguerozamora@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

# <-- LOCAL VARIABLES -->
data "aws_eks_cluster" "example" {
  name = var.cluster_name
}
locals {

  eks_issuer = trimprefix(data.aws_eks_cluster.example.identity[0].oidc[0].issuer, "https://")
  eks_oidc_arn ="arn:${local.arn_partition}:iam::${var.cloud_account_id}:oidc-provider/${local.eks_issuer}"

  tags = merge(var.tags, {
    Project     = var.project,
    Environment = var.environment
  })

  is_gov_cloud         = length(regexall("us-gov-", var.region)) > 0
  arn_partition        = local.is_gov_cloud ? "aws-us-gov" : "aws"
  separate_dns_account = var.separate_dns_account || local.is_gov_cloud

  # MUST match file names in the ./policy-templates directory
  iam_policies = toset([
    "Billing_Budget_Read",
    "CloudWatch_Read_Policy",
    "dns_manager_policy",
    "ECR_Admin_dev_5a",
    "ECR_Operator_Build_And_Config",
    "ECR_ReadOnly_build-and-config",
    "EKS_Read_List",
    "MCP_Lambda_Invoke_Policy",
    "mcp_resume_subcloud_role_log_policies",
    "mcp_suspend_subcloud_role_log_policies",
    "MFA_Policy",
    "Price_List_Service_API",
    "Scale_EC2_Policy",
    "Suspend_Resume_EKS_Worker",
    "WRAI_Cost_Explorer_Policy",
    "WRAI_ECR_Read_Write"
  ])

  iam_users = {
    "test-user" = {
      groups          = ["EKS_Read_List"]
      policies        = []
      change_password = true
    }
    "svc-usp-mcp" = {
      groups          = ["MFA_Policy", "MCP_Monitor_Scale", "EKS_Read_List", "Billing_Read_Access"]
      policies        = []
      change_password = true
    }
    "svc-tools1" = {
      groups          = ["WRAI_ECR_Read_Write"]
      policies        = []
      change_password = true
    }
    "dns_manager" = {
      groups          = []
      policies        = ["dns_manager_policy"]
      change_password = false
    }
  }

  # Creates map of policies for each user
  iam_user_policies = merge([for user, meta in local.iam_users :
    { for policy in meta.policies :
      "${user}-${policy}" => {
        "user"   = user
        "policy" = policy
      }
    } if length(meta.policies) > 0
  ]...)

  iam_groups = {
    "EKS_Read_List" = {
      assume_role = null
      policies    = ["EKS_Read_List"]
    }
    "MCP_Monitor_Scale" = {
      assume_role = null
      policies    = ["Scale_EC2_Policy", "Suspend_Resume_EKS_Worker"]
    }
    "MFA_Policy" = {
      assume_role = null
      policies    = ["MFA_Policy"]
    }
    "WRAI_ECR_Read_Write" = {
      assume_role = null
      policies    = ["WRAI_ECR_Read_Write"]
    }
    "Billing_Read_Access" = {
      assume_role = null
      policies    = ["WRAI_Cost_Explorer_Policy", "Billing_Budget_Read", "Price_List_Service_API"]
    }
  }

  # Creates map of polices for each group
  iam_group_policies = merge([for group, meta in local.iam_groups :
    { for policy in meta.policies :
      "${group}-${policy}" => {
        "group"  = group
        "policy" = policy
      }
    } if length(meta.policies) > 0
  ]...)

  iam_roles = {
    "usp-developer" = {
      principal = {
        "AWS" = "arn:${local.arn_partition}:iam::${var.cloud_account_id}:root"
      }
      policies = []
    }
    "dns_manager_role" = {
      principal = {
        "AWS" = "arn:${local.arn_partition}:iam::${var.cloud_account_id}:user/${var.region}-dns_manager-${var.cluster_name}"
      }
      policies = ["dns_manager_policy"]
    }
    "mcp_resume_subcloud_role" = {
      principal = {
        "Service" = "lambda.amazonaws.com"
      }
      policies = ["mcp_resume_subcloud_role_log_policies", "CloudWatch_Read_Policy", "Scale_EC2_Policy"]
    }
    "mcp_suspend_subcloud_role" = {
      principal = {
        "Service" = "lambda.amazonaws.com"
      }
      policies = ["mcp_suspend_subcloud_role_log_policies", "CloudWatch_Read_Policy", "Scale_EC2_Policy"]
    }
  }

  # Create map of policies for each role
  iam_role_policies = merge([for role, meta in local.iam_roles :
    { for policy in meta.policies :
      "${role}-${policy}" => {
        "role"   = role
        "policy" = policy
      }
    } if length(meta.policies) > 0
  ]...)
}
