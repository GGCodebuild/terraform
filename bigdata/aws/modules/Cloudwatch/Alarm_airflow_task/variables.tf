variable "alarm_name" {
  type        = string
  description = "Nome do alerta."
}

variable "airflow_environment_name" {
  type        = string
  description = "Nome do cluster airflow."
}

variable "dag_name" {
  type        = string
  description = "Nome da DAG."
}

variable "task_name" {
  type        = string
  description = "Nome da Task."
}

variable "state" {
  type        = string
  description = "Estado da Task que irá acionar o alarme."
}

variable "arn_sns_topics" {
  type        = list(string)
  description = "Lista de sns."
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