#Task
variable "cdc_start_time_task" {
  type        = number
  description = "Data prevista para inicio do CDC."
}

variable "migration_type_task" {
  type        = string
  description = "Tipo de migração: full-load | cdc | full-load-and-cdc."
}

variable "replication_task_id" {
  type        = string
  description = "Id da task de replicação."
}

variable "replication_task_settings" {
  type        = string
  description = "Configuração para a task de replicação."
}

variable "table_mappings_task" {
  type        = string
  description = "Configurações de mapeamento da base de dados."
}

variable "replication_instance_arn" {
  type        = string
  description = "Arn da instancia de replicação."
}

variable "source_endpoint_arn" {
  type        = string
  description = "Arn do source endpoint."
}

variable "target_endpoint_arn" {
  type        = string
  description = "Arn do target endpoint."
}

variable "environment" {
  type        = string
  description = "Ambiente."
}

##Informações tags
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