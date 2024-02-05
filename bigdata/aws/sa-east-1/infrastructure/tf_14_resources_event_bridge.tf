#module "event_bridge_bcen_scr" {
#  source          = "../../modules/Event_Bridge"
#  name            = "invoke_lambda_bcen_scr_trigger"
#  lambda_uri      = module.lambda_bcen_scr_trigger.arn
#  function_name   = module.lambda_bcen_scr_trigger.function_name
#  description     = "Executa função trigger todo dia 02"
#  schedule_expression = "cron(0 12 2 * ? *)"
#
#  depends_on = [module.lambda_bcen_scr_trigger]
#}

