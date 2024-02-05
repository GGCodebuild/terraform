resource "aws_apigatewayv2_domain_name" "api" {
  domain_name = var.domain_name

  domain_name_configuration {
    certificate_arn = var.aws_acm_certificate_api_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

}

