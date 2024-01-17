terraform {
  required_version = ">= 1.0.0, < 2.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  
  backend "s3" {
    bucket = "terraform-state-eduardo"
    key = "global/s3/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = "XXXXXXXXXXXXXXX"
  secret_key = "XXXXXXXXXXXXXXXXXX"
}

module "eks" {
 
# public_subnets  = ["172.30.0.0/20", "172.30.16.0/20"]

  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = "EKS-STG-CLUSTER"
  cluster_version = "1.27"

  vpc_id                         = "vpc-XXXXXXXXXX"
  subnet_ids                     = ["subnet-XXXXXXXXXXXX", "subnet-XXXXXXXXX"]
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "eks-stg-nodes"

      instance_types = ["m5.large"]

      min_size     = 1
      max_size     = 4
      desired_size = 2
      create_security_group = false
    }

    two = {
      name = "eks-stg-nodes-high-cpu"

      instance_types = ["m5.2xlarge"]

      min_size     = 1
      max_size     = 9
      desired_size = 3
      create_security_group = false
              labels = {
            group = "high-cpu"
        }
    }
  }
}
