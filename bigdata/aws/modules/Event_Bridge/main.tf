resource "aws_cloudwatch_event_rule" "event_bridge_lambda" {
  name = var.name
  description = var.description
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "profile_generator_lambda_target" {
  arn = var.lambda_uri
  rule = aws_cloudwatch_event_rule.event_bridge_lambda.name
}

resource "aws_lambda_permission" "allow_execution_from_cloudWatch" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = var.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.event_bridge_lambda.arn
}