resource "aws_security_group" "security-group" {
  name        = var.security_name
  description = var.description
  vpc_id      = var.aws_vpc_id


  ingress {
    protocol         = var.ingress_protocol
    from_port        = var.ingress_port
    to_port          = var.ingress_port
    cidr_blocks      = [var.ingress_cidr_blocks]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                     = var.security_name
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = var.security_name
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }

}


