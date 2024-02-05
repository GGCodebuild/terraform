
resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name                = var.alarm_name
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "DAGDurationFailed"
  namespace                 = "AmazonMWAA"
  alarm_actions             = var.arn_sns_topics
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "Problemas no processamento da DAG ${var.dag_name}, entrar em contato com o responsável do airflow"
  actions_enabled           = "true"
  insufficient_data_actions = []
  dimensions = {
    "Environment" = var.airflow_environment_name
    "DAG"         = var.dag_name
  }

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = var.alarm_name
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }

}