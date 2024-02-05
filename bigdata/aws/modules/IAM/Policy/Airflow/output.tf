output "airflow_role_arn" {
  value = aws_iam_role.mwaa-execution.arn
}