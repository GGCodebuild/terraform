output "vpc_endpoint_id" {
  value = aws_vpc_endpoint.this.id
}

output "endpoint" {
  value = aws_vpc_endpoint.this.service_name
}



