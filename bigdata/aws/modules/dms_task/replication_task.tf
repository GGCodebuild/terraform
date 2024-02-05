resource "aws_dms_replication_task" "this" {
  migration_type            = var.migration_type_task
  replication_task_id       = var.replication_task_id
  replication_task_settings = file(var.replication_task_settings)
  table_mappings            = file(var.table_mappings_task)

  replication_instance_arn = var.replication_instance_arn
  source_endpoint_arn      = var.source_endpoint_arn
  target_endpoint_arn      = var.target_endpoint_arn

  #Utilizar somente no caso de setar uma data específica de inicio para a sincronização CDC
  cdc_start_time            = var.cdc_start_time_task


  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = var.replication_task_id
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = "DMS-Replication-Task"
  }
}