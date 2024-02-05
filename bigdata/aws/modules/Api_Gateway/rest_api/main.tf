resource "aws_api_gateway_rest_api" "api_lambda" {
  name = var.name

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : "execute-api:Invoke",
          "Resource" : ["*"]
        },
        {
          "Effect" : "Deny",
          "Principal" : "*",
          "Action" : "execute-api:Invoke",
          "Resource" : ["*"],
          "Condition" : {
            "StringNotEquals" : {
              "aws:SourceVpce" : "${var.vpc_endpoint_id}"
            }
          }
        }
      ]
    }
  )

  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = [var.vpc_endpoint_id]
  }
}

resource "aws_api_gateway_resource" "resource" {
  parent_id   = aws_api_gateway_rest_api.api_lambda.root_resource_id
  path_part   = var.path_part
  rest_api_id = aws_api_gateway_rest_api.api_lambda.id
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api_lambda.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = var.http_method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_lambda.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  type                    = "AWS_PROXY"
  uri                     = var.lambda_uri
  integration_http_method = "POST"
}


resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.api_lambda.id
  stage_name  = var.stage_name
  depends_on = [
    aws_api_gateway_resource.resource,
    aws_api_gateway_method.method,
    aws_api_gateway_integration.integration,
  ]
}



resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_lambda.execution_arn}/*/*"
}
