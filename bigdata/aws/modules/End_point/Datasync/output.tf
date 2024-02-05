output "vpc_endpoint_id" {
  value = aws_vpc_endpoint.datasync.id
}

output "private_link_endpoint" {
  value = data.aws_network_interface.private_link_endpoint.private_ip
}



