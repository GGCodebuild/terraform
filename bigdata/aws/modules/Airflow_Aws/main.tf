resource "aws_mwaa_environment" "orchestrator" {

  dag_s3_path          = "airflow/dags"
  requirements_s3_path = "airflow/requirements.txt"

  execution_role_arn = var.execution_role_arn
  name               = var.airflow_aws_name

  network_configuration {
    security_group_ids = var.security_group_ids
    subnet_ids         = var.subnet_ids
  }

  airflow_configuration_options = {
    "core.enable_xcom_pickling"= "True"
    "webserver.default_ui_timezone" = "America/Sao_Paulo"
    "secrets.backend" : "airflow.providers.amazon.aws.secrets.secrets_manager.SecretsManagerBackend"
    "secrets.backend_kwargs" : "{\"connections_prefix\" : \"airflow/connections\", \"variables_prefix\" : \"airflow/variables\"}"
    "custom.environment" : var.environment
    "custom.sub_net" : var.environment_sub_net
    "custom.pem_key" : var.environment_pem_key
    "custom.master_security_group" : var.environment_master_security_group
    "custom.slave_security_group" : var.environment_slave_security_group
    "custom.service_access_security_group" : var.environment_service_access_security_group
    "custom.job_flow_role" : var.environment_job_flow_role
    "custom.service_role" : var.environment_service_role
    "custom.artifactory_aws_bucket" : var.environment_artifactory_aws_bucket
    "custom.log_path" : var.environment_path_bucket_log
    "custom.path_artifactory" : var.environment_path_artifactory
    "custom.airflow_aws_bucket" : var.environment_airflow_aws_bucket
    "custom.arn_datasync_negative" : var.environment_arn_datasync_negative
    "custom.arn_datasync_positive" : var.environment_arn_datasync_positive
    "custom.arn_task_cdc_dms_consulta_realizada" = var.environment_arn_task_cdc_dms_consulta_realizada
    "custom.arn_task_full_dms_consulta_realizada" = var.environment_arn_task_full_dms_consulta_realizada
    "custom.sysops_arn_sns" : var.environment_sysops_arn_sns
    "custom.engineering_arn_sns" : var.environment_engineering_arn_sns
    "custom.sales_group_arn_sns" : var.environment_sales_group_arn_sns
  }

  source_bucket_arn = var.source_bucket_arn

  environment_class = var.environment_class

  webserver_access_mode = var.webserver_access_mode
  max_workers           = var.max_workers

  airflow_version = var.airflow_version

  logging_configuration {

    dag_processing_logs {
      enabled   = true
      log_level = "INFO"
    }

    scheduler_logs {
      enabled   = true
      log_level = "INFO"
    }

    task_logs {
      enabled   = true
      log_level = "INFO"
    }

    webserver_logs {
      enabled   = true
      log_level = "INFO"
    }

    worker_logs {
      enabled   = true
      log_level = "INFO"
    }

  }

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = var.airflow_aws_name
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }

}