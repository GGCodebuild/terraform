output "dag_s3_path" {
  value = aws_mwaa_environment.orchestrator.dag_s3_path
}

output "webserver_access_mode" {
  value = aws_mwaa_environment.orchestrator.webserver_access_mode
}

output "arn" {
  value = aws_mwaa_environment.orchestrator.arn
}

output "name" {
  value = aws_mwaa_environment.orchestrator.name
}
