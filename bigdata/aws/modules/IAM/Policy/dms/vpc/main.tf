resource "aws_iam_role_policy_attachment" "dms-vpc-role-AmazonDMSVPCManagementRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = aws_iam_role.dms-vpc-role.name
}

resource "aws_iam_role" "dms-vpc-role" {
  name               = "dms-vpc-role"
  assume_role_policy = data.aws_iam_policy_document.dms-vpc-role-policy.json

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = "dms-vpc-role"
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }

}

data "aws_iam_policy_document" "dms-vpc-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["dms.amazonaws.com"]
    }
  }

}

