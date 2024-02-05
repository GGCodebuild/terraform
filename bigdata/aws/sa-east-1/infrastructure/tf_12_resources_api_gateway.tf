module "api_gateway_lambda_mntr_flxo" {
  source          = "../../modules/Api_Gateway/rest_api"
  name            = "invoke-dag-bcen-mntr-flxo-private"
  lambda_uri      = module.lambda_bcen_scr_mntr_flxo.invoke_arn
  function_name   = module.lambda_bcen_scr_mntr_flxo.function_name
  vpc_endpoint_id = data.aws_vpc_endpoint.lambda_interface.id
  stage_name      = "airflow"
  path_part       = "dag"
  tag_vn          = var.tag_vn_bacen_scr
  tag_cost_center = var.tag_cost_center_bacen_scr
  tag_project     = var.tag_project_bacen_scr
  tag_service     = "API_GATEWAY"
  http_method     = "POST"
  tag_create_date = var.tag_create_date
  environment     = local.environment

  depends_on = []

}

module "api_gateway_lambda_trgr" {
  source          = "../../modules/Api_Gateway/rest_api"
  name            = "invoke-dag-bcen-trgr-private"
  lambda_uri      = module.lambda_bcen_scr_trigger.invoke_arn
  function_name   = module.lambda_bcen_scr_trigger.function_name
  vpc_endpoint_id = data.aws_vpc_endpoint.lambda_interface.id
  stage_name      = "airflow"
  path_part       = "dag"
  tag_vn          = var.tag_vn_bacen_scr
  tag_cost_center = var.tag_cost_center_bacen_scr
  tag_project     = var.tag_project_bacen_scr
  tag_service     = "API_GATEWAY"
  http_method     = "POST"
  tag_create_date = var.tag_create_date
  environment     = local.environment

  depends_on = []

}