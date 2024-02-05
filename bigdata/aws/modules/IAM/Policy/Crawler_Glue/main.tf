resource "aws_iam_role" "aws_iam_glue_role" {
  name = "AWSGlueServiceRoleDefault"

  assume_role_policy = jsonencode(
    {
      Version : "2012-10-17",
      Statement : [
        {
          Action : "sts:AssumeRole",
          Principal : {
            Service : "glue.amazonaws.com"
          },
          Effect : "Allow",
          Sid : ""
        }
      ]
    }
  )

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = "AWSGlueServiceRoleDefault"
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }
}

resource "aws_iam_role_policy" "s3_policy" {
  name = "s3_policy_crawler"
  role = aws_iam_role.aws_iam_glue_role.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          Effect : "Allow",
          Action : ["s3:*"],
          Resource : ["*"]
        }
      ]
  })

}

resource "aws_iam_role_policy_attachment" "glue_service_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  role       = aws_iam_role.aws_iam_glue_role.id
}

resource "aws_iam_role_policy" "glue_service_s3" {
  name   = "glue_service_s3"
  role   = aws_iam_role.aws_iam_glue_role.id
  policy = aws_iam_role_policy.s3_policy.policy
}




