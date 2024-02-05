resource "aws_glue_crawler" "this" {
  database_name = var.database_name
  name          = var.name_crawler
  role          = var.aws_iam_glue_role_arn
  table_prefix  = var.table_prefix

  s3_target {
    path = var.path_s3
  }

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = var.name_crawler
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }

}