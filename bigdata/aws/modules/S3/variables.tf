variable "aws_bucket_name" {
  type        = string
  description = "Nome do bucket"
}

variable "aws_acl_bucket" {
  type        = string
  default     = "private"
  description = "Indica se o bucket utilizado como repositório é publico ou privado."
}

variable "flag_acl" {
  type        = bool
  default     = true
  description = "Indica se o bucket utilizado como repositório é publico ou privado."
}

variable "aws_force_destroy_bucket" {
  type        = bool
  description = "Indica se o bucket sempre será destruído"
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
