variable "name_crawler" {
  type        = string
  description = "Define o nome do Glue crawler"
}

variable "database_name" {
  type        = string
  description = "Define o nome do banco de dados no glue"
}

variable "table_prefix" {
  type = string
  default = ""
}

variable "path_s3" {
  type        = string
  description = "Path do S3 onde os arquivos estão armazenados"
}

variable "aws_iam_glue_role_arn" {
  type        = string
  description = "Iam regra glue"
}

variable "environment" {
  type        = string
  description = "Ambiente."
}

##Informações tags
variable "tag_service" {
  type        = string
  description = "Nome do recursos ou serviço AWS."
}

variable "tag_vn" {
  type        = string
  description = "Área responsável."
}

variable "tag_cost_center" {
  type        = string
  description = "Centro de custo da conta."
}

variable "tag_project" {
  type        = string
  description = "Nome do projeto."
}

variable "tag_create_date" {
  type        = string
  description = "data criação do ambiente e/ou a data da ultima atualização do ambiente."
}