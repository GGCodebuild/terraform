resource "aws_glue_job" "glue_job" {
  name              = var.glue_job_name
  role_arn          = var.role_glue_arn
  glue_version      = var.glue_version
  worker_type       = var.worker_type
  number_of_workers = var.number_of_workers
  timeout           = var.timeout

  command {
    script_location = var.path_script_execute
    python_version  = var.python_version
  }

  connections = var.connections

  default_arguments = {
    "--extra-py-files"                   = var.py-files
    "--continuous-log-logGroup"          = var.aws_cloudwatch_log_group
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-metrics"                   = ""
    "--bucket_artifactory"               = var.bucket_artifactory
    "--url_config"                       = var.url_config
    "--url_processes_history"            = var.url_processes_history
    "--process_name"                     = var.process_name
    "--layer_process"                    = var.layer_process
    "--datalake-formats"                 = "delta"
  }

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = var.glue_job_name
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }
}