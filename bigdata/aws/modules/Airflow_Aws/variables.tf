variable "execution_role_arn" {
  type = string
}

variable "airflow_aws_name" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "source_bucket_arn" {
  type = string
}

variable "webserver_access_mode" {
  type        = string
  default     = "PRIVATE_ONLY"
  description = "PRIVATE_ONLY or PUBLIC_ONLY"
}

variable "max_workers" {
  type        = number
  default     = 1
  description = "Number of max workers"
}

variable "environment_class" {
  type        = string
  default     = "mw1.small"
  description = "mw1.small or mw1.medium or mw1.large"
}

variable "airflow_version" {
  type        = string
  default     = "2.0.2"
  description = "1.10.12 or 2.0.2"
}

#Variaveis globais
variable "environment_sub_net" {
  type        = string
  description = "Área responsável da conta."
}

variable "environment_pem_key" {
  type        = string
  description = "Área responsável da conta."
}

variable "environment_master_security_group" {
  type        = string
  description = "Área responsável da conta."
}

variable "environment_slave_security_group" {
  type        = string
  description = "Área responsável da conta."
}

variable "environment_service_access_security_group" {
  type        = string
  description = "Área responsável da conta."
}

variable "environment_job_flow_role" {
  type        = string
  description = "Área responsável da conta."
}

variable "environment_service_role" {
  type        = string
  description = "Área responsável da conta."
}

variable "environment_artifactory_aws_bucket" {
  type        = string
  description = "Área responsável da conta."
}

variable "environment_airflow_aws_bucket" {
  type        = string
  description = "Área responsável da conta."
}

variable "environment_path_bucket_log" {
  type        = string
  description = "Área responsável da conta."
}

variable "environment_path_artifactory" {
  type        = string
  description = "Área responsável da conta."
}

variable "environment_arn_datasync_negative" {
  type        = string
  description = "Arn do DataSync negativo."
}

variable "environment_arn_datasync_positive" {
  type        = string
  description = "Arn do DataSync positivo."
}


variable "environment_arn_task_cdc_dms_consulta_realizada" {
  type        = string
  description = "Arn da task CDC do DMS da consulta realizada."
}

variable "environment_arn_task_full_dms_consulta_realizada" {
  type        = string
  description = "Arn da task full do DMS da consulta realizada."
}

variable "environment_sysops_arn_sns" {
  type        = string
  description = "Arn do sns referente ao envio de e-mails para o SysOps do projeto lending."
}

variable "environment_engineering_arn_sns" {
  type        = string
  description = "Arn do sns referente ao envio de e-mails para a engenharia do projeto lending."
}

variable "environment_sales_group_arn_sns" {
  type        = string
  description = "Arn do sns referente ao envio de e-mails para o grupo de vendas do projeto lending."
}

variable "environment" {
  type        = string
  description = "Ambiente"
}

##Informações tags
variable "tag_service" {
  type        = string
  description = "Nome do recursos ou serviço AWS"
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

variable "tag_create_date" {
  type        = string
  description = "Data criação do ambiente e/ou a data da última atualização do ambiente"
}