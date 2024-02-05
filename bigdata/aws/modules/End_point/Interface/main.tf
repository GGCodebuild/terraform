resource "aws_vpc_endpoint" "this" {
  vpc_id             = var.id_vpc
  service_name       = var.service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [var.id_subnet_1, var.id_subnet_2]
  security_group_ids = [var.id_security_group]

  private_dns_enabled = true

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = var.service_name
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }

}