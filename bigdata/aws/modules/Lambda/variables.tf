variable "path_filename" {
  type = string
}

variable "path_file_requirements" {
  type = string
}

variable "path_file_package" {
  type = string
}

variable "environment_variables" {
  type = map(string)
}


variable "function_name" {
  type = string
}

variable "arn_role" {
  type = string
}

variable "source_dir_lambda_zip" {
  type = string
}

variable "output_path_lambda_zip" {
  type = string
}

variable "bucket_name_artifactory" {
  type = string
}

variable "key_lambda_to_s3" {
  type = string
}

variable "subnets_id" {
  type = list(string)
}

variable "security_groups_id" {
  type = list(string)
}

variable "environment" {
  type        = string
  description = "Ambiente."
}

variable "runtime" {
  type = string
  default = "python3.9"
}

variable "timeout" {
  type = number
  default = 30
}

variable "layers" {
  type = list(string)
  default = []
  description = "Lista de layer's a serem aplicadas na função."
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
