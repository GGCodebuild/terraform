resource "aws_secretsmanager_secret" "this" {
  name                           = var.name
  recovery_window_in_days        = 0
  force_overwrite_replica_secret = true

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = var.name
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }

}

resource "aws_secretsmanager_secret_version" "secret-version" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.secret_string

}

resource "aws_secretsmanager_secret_policy" "secret-policy" {
  secret_arn = aws_secretsmanager_secret.this.arn
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "EnableAllPermissions",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "*"
          },
          "Action" : ["secretsmanager:GetSecretValue", "secretsmanager:ListSecrets"],
          "Resource" : "*"
        }
      ]
    }
  )
}