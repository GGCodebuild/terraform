variable "glue_job_name" {
  type        = string
  description = "Nome do Glue Job"
}

variable "role_glue_arn" {
  type        = string
  description = "Policy do Glue Job"
}

variable "path_script_execute" {
  type        = string
  description = "Caminho do script do Glue Job que será executado"
}

variable "glue_version" {
  type        = string
  description = "Versão do Glue"
}

variable "worker_type" {
  type        = string
  description = "Tipo do worker do Glue Job"
}

variable "number_of_workers" {
  type        = string
  description = "Número de workers do Glue Job"
}

variable "timeout" {
  type        = string
  description = "Timeout da execução do Glue Job"
}

variable "aws_cloudwatch_log_group" {
  type        = string
  description = "Log Group do CloudWatch onde se encontram os logs do Glue Job"
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

variable "class" {
  type        = string
  description = "Nome do primeiro objeto que será chamado"
}

variable "extra_jars" {
  type        = string
  description = "Extra jars"
}

variable "list_of_buckets" {
  type        = string
  description = "Lista de buckets que serão utilizados"
}