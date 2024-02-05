output "eventbridge_rule_arns" {
  value = aws_cloudwatch_event_rule.event_bridge_lambda.arn
}