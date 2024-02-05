output "stage_name" {
  value = aws_api_gateway_deployment.main.stage_name
}

output "rest_api_id" {
  value = aws_api_gateway_resource.resource.rest_api_id
}

output "path" {
  value = aws_api_gateway_resource.resource.path
}








