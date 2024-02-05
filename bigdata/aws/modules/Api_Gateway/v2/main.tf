resource "aws_apigatewayv2_api" "api_gateway_v2" {
  name          = var.name
  protocol_type = "HTTP"

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

resource "aws_apigatewayv2_stage" "api_gateway_v2_stage" {
  api_id = aws_apigatewayv2_api.api_gateway_v2.id

  name        = "${var.name}-stage"
  auto_deploy = true

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

resource "aws_apigatewayv2_integration" "api_gateway_v2_integration" {
  api_id = aws_apigatewayv2_api.api_gateway_v2.id

  integration_uri    = var.lambda_uri
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "api_gateway_v2_integration_route" {
  api_id = aws_apigatewayv2_api.api_gateway_v2.id

  route_key = "POST /"
  target    = "integrations/${aws_apigatewayv2_integration.api_gateway_v2_integration.id}"
}

resource "aws_lambda_permission" "api_gateway_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api_gateway_v2.execution_arn}/*/*"
}

##Como utilizar este módulo no terraform
#module "api_gateway" {
#  source        = "../../modules/Api_Gateway/v2"
#  name          = "invoke-dag-lending"
#  lambda_uri    = module.lambda.invoke_arn
#  function_name = module.lambda.function_name
#
#  tag_vn          = var.tag_vn
#  tag_cost_center = var.tag_cost_center
#  tag_project     = var.tag_project
#  tag_service     = "API_GATEWAY"
#  tag_create_date = var.tag_create_date
#  environment     = local.environment
#}


