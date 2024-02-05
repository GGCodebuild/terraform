variable "tag_vn" {
  type        = string
  description = "Área responsável"
}

variable "tag_cost_center" {
  type        = string
  description = "Centro de custo da conta"
}

variable "tag_project" {
  type        = string
  description = "Nome do projeto"
}

variable "tag_service" {
  type        = string
  description = "Nome do recursos ou serviço AWS"
}

variable "tag_create_date" {
  type        = string
  description = "Data criação do ambiente e/ou a data da última atualização do ambiente"
}

variable "environment" {
  type        = string
  description = "Ambiente"
}