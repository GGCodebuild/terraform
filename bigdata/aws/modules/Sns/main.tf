resource "aws_sns_topic" "airflow-topic" {
  name = var.topic_name
}

resource "aws_sns_topic_subscription" "user-airflow" {
  count     = length(var.email_list)
  topic_arn = aws_sns_topic.airflow-topic.arn
  protocol  = "email"
  endpoint  = var.email_list[count.index]
}