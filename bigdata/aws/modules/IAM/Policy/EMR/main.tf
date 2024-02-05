resource "aws_iam_role" "iam_emr_service_role" {
  name               = "iam_emr_service_role"
  assume_role_policy = data.aws_iam_policy_document.iam_emr_profile_role.json

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = "iam_emr_service_role"
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }

}

resource "aws_iam_role_policy" "iam_emr_service_policy" {
  name   = "iam_emr_service_policy"
  role   = aws_iam_role.iam_emr_service_role.id
  policy = file("../../modules/IAM/Policy/EMR/templates/ElasticMapReduceRole.json")
}

resource "aws_iam_role" "iam_ec2_profile_role" {
  name               = "iam_ec2_profile_role"
  assume_role_policy = data.aws_iam_policy_document.iam_ec2_profile_role.json

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = "iam_ec2_profile_role"
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }
}

resource "aws_iam_role_policy" "iam_ec2_service_policy" {
  name   = "iam_ec2_service_policy"
  role   = aws_iam_role.iam_ec2_profile_role.id
  policy = file("../../modules/IAM/Policy/EMR/templates/ElasticEC2Role.json")
}

resource "aws_iam_instance_profile" "emr_profile" {
  name = "emr_profile"
  role = aws_iam_role.iam_ec2_profile_role.name

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = "iam_emr_service_role"
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }
}

##Configuração das profile roles
data "aws_iam_policy_document" "iam_ec2_profile_role" {

  statement {

    sid    = ""
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }

}

data "aws_iam_policy_document" "iam_emr_profile_role" {

  statement {

    sid    = ""
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["elasticmapreduce.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }

}



