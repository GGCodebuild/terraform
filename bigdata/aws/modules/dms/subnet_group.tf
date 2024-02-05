resource "aws_dms_replication_subnet_group" "subnet_group" {
  replication_subnet_group_id          = var.replication_subnet_group_id
  replication_subnet_group_description = var.replication_subnet_group_description
  subnet_ids                           = var.subnet_ids


  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = var.replication_subnet_group_id
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = "DMS-Subnet-group"
  }
}