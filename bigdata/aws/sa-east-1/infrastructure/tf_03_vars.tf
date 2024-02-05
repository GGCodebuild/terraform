variable "access_key" {}
variable "secret_key" {}

variable "token" {
  type    = string
  default = ""
}

variable "iam_lambda_role_name" {
  type = string
  default = "lambda_role"
}

variable "iam_glue_crawler_role_name" {
  type = string
  default = "AWSGlueServiceRoleDefault"
}

variable "iam_glue_job_role_name" {
  type = string
  default = "glue-job-role"
}

variable "aws_nome_conta" {
  type        = string
  default     = "SPC-LAKEHOUSE"
  description = "Nome da conta. Certificar que nao existem espacos em branco entre as palavras."
}

variable "workspace_to_environment" {
  type = map(string)
  default = {
    dev = "dev"
    prd = "prd"
  }
}

variable "aws_regiao_conta" {
  type = map(string)
  default = {
    dev = "sa-east-1"
    prd = "sa-east-1"
  }
  description = "Regiao onde os recursos serao alocados."
}

variable "aws_id_conta" {
  type = map(string)
  default = {
    dev = "568178045040"
    prd = "449379208884"
  }
  description = "Account ID para provisionamento dos recursos AWS."
}

variable "network" {

  type = map(object({
    vpc_id                              = string
    private_subnet_id_resources_az_a    = string
    private_subnet_id_resources_az_b    = string
    private_subnet_id_process_az_a      = string
    private_subnet_id_process_az_b      = string
    route_table_id                      = string
    default_security_group_landing_zone = string
    security_group_emr_master           = string
    security_group_emr_slave            = string
    security_group_emr_access           = string
    security_group_airflow              = string
    availability_zone                   = string
  }))

  default = {

    dev = {
      vpc_id                              = "vpc-09a004cc3adf05a93"
      private_subnet_id_resources_az_a    = "subnet-05d6ef06be01bcff2"
      private_subnet_id_resources_az_b    = "subnet-08ea19caf03891ea3"
      private_subnet_id_process_az_a      = "subnet-0a6a2defbc6ea3ab2"
      private_subnet_id_process_az_b      = "subnet-0713ead1357335901"
      route_table_id                      = "rtb-09b2fe21d636daf56"
      default_security_group_landing_zone = "sg-0979f445b096b22c2"
      security_group_emr_master           = "sg-0bfedf18209943a26"
      security_group_emr_slave            = "sg-01246272a84172720"
      security_group_emr_access           = "sg-026484ba29acc56ee"
      security_group_airflow              = "sg-08b1a4dc04cf89636"
      availability_zone                   = "sa-east-1a"

    }

    prd = {
      vpc_id                              = "vpc-0ff02a5efa26fd9e7"
      private_subnet_id_resources_az_a    = "subnet-0eb76248737d1ac2c"
      private_subnet_id_resources_az_b    = "subnet-0805ef0f80f660726"
      private_subnet_id_process_az_a      = "subnet-033847f771dc3efe0"
      private_subnet_id_process_az_b      = "subnet-00500b779c48a4462"
      route_table_id                      = "rtb-0c8fbc469a4e4948d"
      default_security_group_landing_zone = "sg-0ee45b4db85adb57b"
      security_group_emr_master           = "sg-0675136a4e0e6224c"
      security_group_emr_slave            = "sg-04d7cab70317c2b54"
      security_group_emr_access           = "sg-03a99feed5a503823"
      security_group_airflow              = "sg-02325f096b03d3021"
      availability_zone                   = "sa-east-1a"
    }

  }

  description = "Mapeamento de recursos de rede, obtido pelo AWS Foudation."
}

##Variáveis referente aos buckets
variable "bucket_lading_zone" {
  type        = string
  default     = "lakehouse-landing-zone-spc"
  description = "Nome do bucket utilizado para armazenar armazenamos de todos os dados brutos."
}

variable "bucket_raw" {
  type        = string
  default     = "lakehouse-raw-spc"
  description = "Nome do bucket utilizado para armazenar armazenamos dados estruturados."
}

variable "bucket_trusted" {
  type        = string
  default     = "lakehouse-trusted-spc"
  description = "Nome do bucket utilizado para armazenar dados após a aplicação de regras e qualidade de dados nos dados brutos. Nessa camada temos o primeiro step de processamento transformando os dados de sistemas para uma visão de negócio."
}

variable "bucket_refined" {
  type        = string
  default     = "lakehouse-refined-spc"
  description = "Nome do bucket utilizado para armazenar os dados prontos para consumo por parte das áreas de negócio."
}

variable "bucket_garbage" {
  type        = string
  default     = "lakehouse-garbage-spc"
  description = "Nome do bucket utilizado para armazenar os dados prontos para consumo por parte das áreas de negócio."
}

variable "bucket_stage" {
  type        = string
  default     = "lakehouse-stage-spc"
  description = "Nome do bucket utilizado para armazenar os dados prontos para consumo por parte das áreas de negócio."
}

variable "bucket_output" {
  type        = string
  default     = "lakehouse-output-spc"
  description = "Nome do bucket utilizado para armazenar os dados prontos para consumo por parte das áreas de negócio."
}

variable "bucket_logs" {
  type        = string
  default     = "lakehouse-logs-spc"
  description = "Nome do bucket utilizado para armazenar todos os logs de cluster EMR, Athena, glue."
}

variable "bucket_dags" {
  type        = string
  default     = "lakehouse-dags-spc"
  description = "Nome do bucket utilizado para disponibilizar as dags do airflow."
}

variable "bucket_artifactory" {
  type        = string
  default     = "lakehouse-artifactory-spc"
  description = "Nome do bucket utilizado para disponibilizar bibliotecas e scripts de processo."
}


###Key pem
variable "ec2_key_name" {
  type        = string
  default     = "KeylabPem"
  description = "chave de acesso as máquina ec2/emr do ambiente aws"
}

variable "PATH_TO_PUBLIC_KEY" {
  type        = string
  default     = "key/KeylabPem.pub"
  description = "chave de acesso as máquina ec2/emr do ambiente aws"
}


###CLUSTER EMR
##Versões SPC
## EMR: emr-5.23.1
## Spark - 2.4.1
## 3 Processos
## 2 Processos Spark / Scala
## 1 Processo PySpark
## uber / fat jar
variable "emr_name_cluster" {
  type        = string
  default     = "cluster-spc-engenharia"
  description = "Nome do cluster dedicado EMR."
}

variable "emr_config" {

  type = map(object({
    emr_release                = string
    emr_num_instance_core      = number
    emr_num_instance_executors = number
    emr_type_master_instance   = string
    emr_type_executor_instance = string
    emr_size_storage           = number
    idle_timeout_emr           = number
  }))

  default = {

    dev = {
      emr_release                = "emr-5.23.1"
      emr_num_instance_core      = 1
      emr_num_instance_executors = 3
      emr_type_master_instance   = "m5.xlarge"
      emr_type_executor_instance = "m5.xlarge"
      emr_size_storage           = 200
      idle_timeout_emr           = 3600
    }

    prd = {
      emr_release                = "emr-5.23.1"
      emr_num_instance_core      = 1
      emr_num_instance_executors = 3
      emr_type_master_instance   = "m5.xlarge"
      emr_type_executor_instance = "m5.xlarge"
      emr_size_storage           = 200
      idle_timeout_emr           = 3600
    }

  }

  description = "Configurações cluster EMR"
}

####AIRFLOW FOR AWS
variable "airflow_aws_name" {
  type        = string
  default     = "airflow-lakeHouse"
  description = "Nome do bucket utilizado para versionar o código terraform"
}

####Mapeamento crawler
variable "map_crawler_raw" {
  type = map(string)
  default = {
    "consulta_realizada" = "consulta_realizada"
    "bcen_scr_htrc" = "parquet/cadpos/bcen/scr/htrc"
    "bcen_scr_cltn" = "parquet/cadpos/bcen/scr/cltn"
    "bcen_scr_oprc" = "parquet/cadpos/bcen/scr/oprc"
    "bcen_scr_grnt" = "parquet/cadpos/bcen/scr/grnt"
  }
}

variable "map_crawler_bcen_scr_garbage" {
  type = map(string)
  default = {
    "bcen_scr_htrc" = "parquet/cadpos/bcen/scr/htrc"
    "bcen_scr_cltn" = "parquet/cadpos/bcen/scr/cltn"
    "bcen_scr_oprc" = "parquet/cadpos/bcen/scr/oprc"
    "bcen_scr_grnt" = "parquet/cadpos/bcen/scr/grnt"
  }
}

variable "map_crawler_bcen_scr_raw" {
  type = map(string)
  default = {
    "bcen_scr_htrc" = "parquet/cadpos/bcen/scr/htrc"
    "bcen_scr_cltn" = "parquet/cadpos/bcen/scr/cltn"
    "bcen_scr_oprc" = "parquet/cadpos/bcen/scr/oprc"
    "bcen_scr_grnt" = "parquet/cadpos/bcen/scr/grnt"
  }
}

variable "map_crawler_bcen_scr_trusted" {
  type = map(string)
  default = {
    "bcen_scr_htrc" = "parquet/cadpos/bcen/scr/htrc"
    "bcen_scr_cltn" = "parquet/cadpos/bcen/scr/cltn"
    "bcen_scr_oprc" = "parquet/cadpos/bcen/scr/oprc"
    "bcen_scr_grnt" = "parquet/cadpos/bcen/scr/grnt"
    "bcen_scr_erro" = "parquet/cadpos/bcen/scr/erro"
  }
}

variable "map_crawler_bcen_scr_refined_delta" {
  type = map(string)
  default = {
    "ctle_crga_bcen" = "delta_lake/ctle_crga_bcen"
  }
}

##SNS
variable "topic_name_sns" {
  type        = string
  default     = "topic-lakehouse"
  description = "Nome do topico sns para comunicação de alertas no ambiente Lakehouse"
}

variable "tag_create_date" {
  type        = string
  default     = "2022-12-09"
  description = "data criação do ambiente e/ou a data da ultima atualização do ambiente."
}


/* TAG'S BACEN */

variable "tag_vn_bacen_scr" {
  type        = string
  default     = "BUREAU SPC"
  description = "Área responsável."
}

variable "tag_project_bacen_scr" {
  type        = string
  default     = "PARCERIA_BCSCR"
  description = "Nome do projeto."
}

variable "tag_cost_center_bacen_scr" {
  type        = string
  default     = "D00306001"
  description = "Centro de custo da conta."
}

variable "secret_oracle_key" {

  type = map(object({
    credential = string
  }))

  default = {

    dev = {
      credential = "{\"username\":\"TU9IK1lLVk9wV1Q1OC9WWTZOa2JaUT09\",\"password\":\"am04RWZaUWJVQS9kendIUkU4bHUyUT09\"}"
    }
    prd = {
      credential = "{\"username\":\"MDJtcVRxQVFrWVJ5NEd5eGRQTU1Idz09\",\"password\":\"ZXFHclFRK05wTWh6akFyelNFbzZpWCt3SzFaZlZGWGdLb3JnSEwzZkhyVT0=\"}"
    }
  }

  description = "Credencial de acesso Oracle"
}

data "aws_caller_identity" "current" {}

data "aws_security_group" "security_group_endpoint" {
  name = "security-group-endpoint-lakehouse-${terraform.workspace}"
}

data "aws_vpc_endpoint" "lambda_interface" {
  vpc_id       = lookup(var.network[terraform.workspace], "vpc_id", null)
  service_name = "com.amazonaws.sa-east-1.execute-api"
}