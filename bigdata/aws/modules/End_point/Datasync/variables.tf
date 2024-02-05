variable "id_vpc" {
  type        = string
  description = "Área responsável da conta."
}

variable "id_subnet" {
  type        = string
  description = "Área responsável da conta."
}

variable "ids_security_group" {
  type        = list(string)
  description = "Área responsável da conta."
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
