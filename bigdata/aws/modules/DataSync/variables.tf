variable "name" {
  type        = string
  description = "Nome do datasync e recursos"
}

variable "access_key" {
  type        = string
  description = "ACCESS KEY AWS"
}

variable "secret_key" {
  type        = string
  description = "SECRET KEY AWS"
}

variable "token" {
  type        = string
  description = "TOKEN AWS"
}

variable "ip_agent" {
  type        = string
  description = "IP do agent configurado no ambiente on premises"
}

variable "subnet_arns" {
  type        = list(string)
  description = "Lista do arns subnets"
}

variable "security_group_arns" {
  type        = list(string)
  description = "Lista do arns security group"
}

variable "aws_cloudwatch_log_group_arn" {
  type        = string
  description = "Arn do cloudwatch group"
}

variable "qop_configuration_rpc_protection" {
  type        = string
  description = "Parametros utilizados: PRIVACY ou AUTHENTICATION"
  default     = "PRIVACY"
}

variable "qop_configuration_data_transfer_protection" {
  type        = string
  description = "Parametros utilizados: PRIVACY ou AUTHENTICATION"
  default     = "PRIVACY"
}


variable "s3_bucket_arn" {
  type        = string
  description = "Arn do bucket S3"
}

variable "bucket_access_role_arn" {
  type        = string
  description = "Arn access role (Permissão de acesso ao bucket S3)"
}

variable "authentication_type" {
  type        = string
  description = "Tipo de autenticação."
  default     = "KERBEROS"
}

variable "hostname_location" {
  type        = string
  description = "Hostname do cluster hadoop."
  default     = "10.10"
}

variable "port_location" {
  type        = number
  description = "Porta do cluster hadoop."
}


variable "replication_factor" {
  type        = string
  description = "Fator de replicação."
}

variable "path_kerberos_keytab" {
  type        = string
  description = "Caminho do arquivo keytab conf."
}

variable "path_kerberos_krb5_conf" {
  type        = string
  description = "Caminho do arquivo krb5 conf."
}

variable "kerberos_principal" {
  type        = string
  description = "string para comunicação do Kerberos principal."
}

variable "subdirectory_hadoop" {
  type        = string
  description = "path do diretório dos arquivos parquet no haddop."
}

variable "subdirectory_s3" {
  type        = string
  description = "path do bucket S3."
}

variable "vpc_endpoint_id" {
  type        = string
  description = "ID da endpoint da vpc."
}

variable "private_link_endpoint" {
  type        = string
  description = "IP private link endpoint."
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
