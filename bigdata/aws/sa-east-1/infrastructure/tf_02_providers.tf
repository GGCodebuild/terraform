locals {
  environment = lookup(var.workspace_to_environment, terraform.workspace, null)
}

provider "aws" {
  region     = lookup(var.aws_regiao_conta, terraform.workspace, null)
  access_key = var.access_key
  secret_key = var.secret_key

  #Em testes locais descomentar comando abaixo, no jenkins deixar comentando
  # token      = var.token

}

provider "spc" {
  alias = "custom"
}