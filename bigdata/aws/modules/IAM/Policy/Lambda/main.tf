resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = file("../../modules/IAM/Policy/Lambda/templates/Role_Lambda.json")

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = "lambda_role"
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }

}

resource "aws_iam_policy" "lambda_policy" {
  name   = "lambda_policy"
  path   = "/"
  policy = file("../../modules/IAM/Policy/Lambda/templates/Policy_Lambda.json")
}

resource "aws_iam_role_policy_attachment" "lambda_policy_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}