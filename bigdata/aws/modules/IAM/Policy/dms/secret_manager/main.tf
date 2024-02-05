resource "aws_iam_role" "dms-secret-manager-access-role" {
  name               = "dms-secret-manager-access-key-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.datasync_assume_role.json

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = "dms-secret-manager-access-key-${var.environment}"
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }

}

resource "aws_iam_role_policy" "dms-secret-manager-access-policy" {
  name   = "dms-secret-manager-access-key-policy--${var.environment}"
  role   = aws_iam_role.dms-secret-manager-access-role.name
  policy = data.aws_iam_policy_document.dms_secret_access.json
}

data "aws_iam_policy_document" "datasync_assume_role" {
  statement {
    actions = ["sts:AssumeRole", ]
    principals {
      identifiers = ["dms.${var.region}.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "dms_secret_access" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = ["arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:*"]
    effect    = "Allow"
  }
  statement {
    actions   = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [var.arn_kms]
    effect = "Allow"
  }

}