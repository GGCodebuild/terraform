#Replication instance
variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Security groups utilizados no instance replication."
}

variable "apply_immediately" {
  type        = bool
  default     = true
  description = "Habilita o aplly imediatamente."
}

variable "auto_minor_version_upgrade" {
  type        = bool
  default     = true
  description = "Habilita o upgrade de versões antigas."
}

variable "multi_az" {
  type        = bool
  default     = false
  description = "Habilita a funcionalidade de multi AZ."
}

variable "publicly_accessible" {
  type        = bool
  default     = false
  description = "Habilita ou desabilita o acesso publico."
}

variable "allocated_storage" {
  type        = number
  description = "Tamanho disponivel do armazenamento."
}

variable "availability_zone" {
  type        = string
  description = "Zona de disponibilidade."
}

variable "engine_version" {
  type        = string
  description = "Versão da engine da instancia de replicação."
}

variable "replication_instance_id" {
  type        = string
  description = "Id da instancia de replicação."
}

variable "preferred_maintenance_window" {
  type        = string
  description = "Janela de manutenção."
}

variable "replication_instance_class" {
  type        = string
  description = "Tipo de instância de replicação."
}



#Subnet Group
variable "subnet_ids" {
  type        = list(string)
  description = "id do endpoint no DMS."
}

variable "replication_subnet_group_id" {
  type        = string
  description = "id do subnet group."
}

variable "replication_subnet_group_description" {
  type        = string
  description = "descrição referente ao gupo de subnet utilizado na instancia de replicação do DMS."
  default     = "Grupo de subnet utilizar "
}



#S3 Target
variable "bucket_name_target" {
  type        = string
  description = "Nome do bucket."
}

variable "service_access_role_arn_target" {
  type        = string
  description = "Arn da role de permissão para o S3."
}

variable "endpoint_id_target" {
  type        = string
  description = "id do endpoint no DMS."
}

variable "data_format_target" {
  type        = string
  default     = "parquet"
  description = "formato de armazenamento de dados."
}

variable "parquet_version_target" {
  type        = string
  default     = "parquet-2-0"
  description = "versão do parquet."
}

variable "date_partition_enabled_target" {
  type        = bool
  default     = false
  description = "habilitando data no particionamento."
}

variable "timestamp_column_name_target" {
  type        = string
  description = "Coluna que possue o formato timestamp para controle do processo."
}

variable "cdc_path_s3" {
  type        = string
  default     = "NONE"
  description = "caminho de diretório adicional para o armazenamento dos arquivos gerados no s3."
}





#Source database
variable "endpoint_id_source" {
  type        = string
  description = "id do endpoint do endpoint source."
}

variable "secrets_manager_access_role_arn" {
  type        = string
  description = "id do endpoint do endpoint source."
}

variable "secrets_manager_arn" {
  type        = string
  description = "id do endpoint do endpoint source."
}

variable "database_name_source" {
  type        = string
  description = "nome do banco de dados."
}

variable "engine_name_source" {
  type        = string
  description = "Engine referente ao endpoint de source. Engine Suportadas: aurora, aurora-postgresql, azuredb, db2, docdb, dynamodb, elasticsearch, kafka, kinesis, mariadb, mongodb, mysql, opensearch, oracle, postgres, redshift, s3, sqlserver, sybase"
}

variable "extra_connection_attributes_source" {
  type        = string
  default     = ""
  description = "Configurações extras para o banco de dados."
}

variable "ssl_mode_source" {
  type        = string
  default     = "none"
  description = "Configurações extras para o banco de dados."
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