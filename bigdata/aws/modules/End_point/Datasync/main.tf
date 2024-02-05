resource "aws_vpc_endpoint" "datasync" {
  vpc_id            = var.id_vpc
  service_name      = "com.amazonaws.sa-east-1.datasync"
  vpc_endpoint_type = "Interface"

  security_group_ids = var.ids_security_group
  private_dns_enabled = true

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = "com.amazonaws.sa-east-1.datasync"
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }
}

resource "aws_vpc_endpoint_subnet_association" "datasync_assoc" {
  subnet_id       = var.id_subnet
  vpc_endpoint_id = aws_vpc_endpoint.datasync.id
}

data "aws_network_interface" "private_link_endpoint" {
  id = tolist(aws_vpc_endpoint.datasync.network_interface_ids)[0]
}
