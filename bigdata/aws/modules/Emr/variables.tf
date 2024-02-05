variable "emr_name_cluster" {
  type        = string
  description = "Nome do cluster EMR"
}


variable "s3_bootstrap" {
  type = string
}

variable "s3_log" {
  type = string
}

variable "emr_release" {
  type        = string
  description = "Versão do cluster EMR"
}

variable "ec2_key_name" {
  type        = string
  description = "Chave pem utilizada para as instâncias EC2 do cluster"
}

variable "public_subnet_id" {
  type        = string
  description = "ID da subnet private"
}

variable "security_group_master_id" {
  type        = string
  description = "ID do grupo de segurança principal"
}

variable "security_group_slave_id" {
  type        = string
  description = "ID do grupo de segurança dos executors"
}

variable "security_access_slave_id" {
  type = string
}

variable "ec2_type_master_instance" {
  type = string
}

variable "ec2_type_executor_instance" {
  type = string
}

variable "num_instance_master" {
  type = number
}

variable "num_instance_executors" {
  type = number
}

variable "size_storage" {
  type = number
}

variable "aws_vpc_id" {
  type = string
}

variable "iam_emr_service_role_arn" {
  type = string
}

variable "emr_profile_arn" {
  type = string
}

variable "idle_timeout_emr" {
  type = number
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