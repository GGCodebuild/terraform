resource "aws_datasync_agent" "agent" {

  name                = "${var.name}-agent"
  ip_address          = var.ip_agent
  vpc_endpoint_id     = var.vpc_endpoint_id
  subnet_arns         = var.subnet_arns
  security_group_arns = var.security_group_arns
  private_link_endpoint = var.private_link_endpoint

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = "Agent-${var.tag_project}"
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }

}