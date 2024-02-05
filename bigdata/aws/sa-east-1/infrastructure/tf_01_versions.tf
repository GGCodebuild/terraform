terraform {

  required_version = "1.3.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.16.0"
    }

    spc = {
      version = "~> 1.0.0"
      source  = "hashicorp/spc"
    }

  }

  backend "s3" {
    key = "infraestrutura/terraform.tfstate"
  }


}