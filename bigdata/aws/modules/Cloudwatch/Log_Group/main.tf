resource "aws_cloudwatch_log_group" "this" {
  name              = var.name
  retention_in_days = var.retention_in_days

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = var.name
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }

}