resource "aws_iam_role" "dms_target" {
  name = "role_dms_target_s3_execution"

  assume_role_policy = file("../../modules/IAM/Policy/dms/s3_target/templates/policy_s3_target_execution.json")
}

resource "aws_iam_policy" "dms_target" {
  name   = "dms_target_s3_policy"
  path   = "/"
  policy = file("../../modules/IAM/Policy/dms/s3_target/templates/policy_s3_target_permission.json")
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.dms_target.name
  policy_arn = aws_iam_policy.dms_target.arn
}