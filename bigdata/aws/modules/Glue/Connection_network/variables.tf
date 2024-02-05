variable "name_connection" {
  type        = string
  description = "Define o nome da conexão do glue"
}

variable "availability_zone" {
  type        = string
  description = "Zona de disponibilizade"
}

variable "security_group" {
  type        = string
  description = "Id do security group"
}

variable "subnet_id" {
  type        = string
  description = "Id da subnet"
}

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