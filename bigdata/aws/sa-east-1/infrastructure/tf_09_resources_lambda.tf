module "lambda_bcen_scr_trigger" {
  source                  = "../../modules/Lambda"
  path_filename           = "../../script/lambda/bcen_scr_trgr/bcen_scr_trgr.py"
  path_file_requirements  = "../../script/lambda/bcen_scr_trgr/requirements.txt"
  path_file_package       = "../../script/lambda/bcen_scr_trgr/package/"
  function_name           = "bcen_scr_trgr"
  arn_role                = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.iam_lambda_role_name}"
  bucket_name_artifactory = "${var.bucket_artifactory}-${local.environment}"
  source_dir_lambda_zip   = "../../script/lambda/bcen_scr_trgr"
  output_path_lambda_zip  = "../../script/lambda/bcen_scr_trgr.zip"
  key_lambda_to_s3        = "lambda/bcen_scr_trgr.zip"
  layers = ["arn:aws:lambda:sa-east-1:336392948345:layer:AWSSDKPandas-Python39:10", module.lambda_layer_deltalake_smart_open.arn]
  timeout = 900

  security_groups_id = [lookup(var.network[terraform.workspace], "security_group_airflow", null)]

  subnets_id = [lookup(var.network[terraform.workspace], "private_subnet_id_resources_az_a", null),
    lookup(var.network[terraform.workspace], "private_subnet_id_resources_az_b", null)]

  environment_variables = {
    "LAMBDA_ENV" = local.environment
  }

  tag_vn          = "CI"
  tag_cost_center = "D00306001"
  tag_project     = "PARCERIA_BCSCR"
  tag_service     = "LAMBDA"
  tag_create_date = var.tag_create_date
  environment     = local.environment

}

module "lambda_bcen_scr_alrr_ctle_crga" {
  source                  = "../../modules/Lambda"
  path_filename           = "../../script/lambda/bcen_scr_alrr_ctle_crga/bcen_scr_alrr_ctle_crga.py"
  path_file_requirements  = "../../script/lambda/bcen_scr_alrr_ctle_crga/requirements.txt"
  path_file_package       = "../../script/lambda/bcen_scr_alrr_ctle_crga/package/"
  function_name           = "bcen_scr_alrr_ctle_crga"
  arn_role                = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.iam_lambda_role_name}"
  bucket_name_artifactory = "${var.bucket_artifactory}-${local.environment}"
  source_dir_lambda_zip   = "../../script/lambda/bcen_scr_alrr_ctle_crga"
  output_path_lambda_zip  = "../../script/lambda/bcen_scr_alrr_ctle_crga.zip"
  key_lambda_to_s3        = "lambda/bcen_scr_alrr_ctle_crga.zip"
  layers = ["arn:aws:lambda:sa-east-1:336392948345:layer:AWSSDKPandas-Python39:10", module.lambda_layer_deltalake_smart_open.arn]
  timeout = 900

  security_groups_id = [lookup(var.network[terraform.workspace], "security_group_airflow", null)]

  subnets_id = [lookup(var.network[terraform.workspace], "private_subnet_id_resources_az_a", null),
    lookup(var.network[terraform.workspace], "private_subnet_id_resources_az_b", null)]

  environment_variables = {
    "LAMBDA_ENV" = local.environment
  }

  tag_vn          = "CI"
  tag_cost_center = "D00306001"
  tag_project     = "PARCERIA_BCSCR"
  tag_service     = "LAMBDA"
  tag_create_date = var.tag_create_date
  environment     = local.environment

}

module "lambda_bcen_scr_gerd_rltr" {
  source                  = "../../modules/Lambda"
  path_filename           = "../../script/lambda/bcen_scr_gerd_rltr/bcen_scr_gerd_rltr.py"
  path_file_requirements  = "../../script/lambda/bcen_scr_gerd_rltr/requirements.txt"
  path_file_package       = "../../script/lambda/bcen_scr_gerd_rltr/package/"
  function_name           = "bcen_scr_gerd_rltr"
  arn_role                = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.iam_lambda_role_name}"
  bucket_name_artifactory = "${var.bucket_artifactory}-${local.environment}"
  source_dir_lambda_zip   = "../../script/lambda/bcen_scr_gerd_rltr"
  output_path_lambda_zip  = "../../script/lambda/bcen_scr_gerd_rltr.zip"
  key_lambda_to_s3        = "lambda/bcen_scr_gerd_rltr.zip"
  layers = ["arn:aws:lambda:sa-east-1:336392948345:layer:AWSSDKPandas-Python39:10", module.lambda_layer_deltalake_smart_open.arn]
  timeout = 900

  security_groups_id = [lookup(var.network[terraform.workspace], "security_group_airflow", null)]

  subnets_id = [lookup(var.network[terraform.workspace], "private_subnet_id_resources_az_a", null),
    lookup(var.network[terraform.workspace], "private_subnet_id_resources_az_b", null)]

  environment_variables = {
    "LAMBDA_ENV" = local.environment
  }

  tag_vn          = "CI"
  tag_cost_center = "D00306001"
  tag_project     = "PARCERIA_BCSCR"
  tag_service     = "LAMBDA"
  tag_create_date = var.tag_create_date
  environment     = local.environment

}

module "lambda_bcen_scr_mntr_flxo" {
  source                  = "../../modules/Lambda"
  path_filename           = "../../script/lambda/bcen_scr_mntr_flxo/bcen_scr_mntr_flxo.py"
  path_file_requirements  = "../../script/lambda/bcen_scr_mntr_flxo/requirements.txt"
  path_file_package       = "../../script/lambda/bcen_scr_mntr_flxo/package/"
  function_name           = "bcen_scr_mntr_flxo"
  arn_role                = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.iam_lambda_role_name}"
  bucket_name_artifactory = "${var.bucket_artifactory}-${local.environment}"
  source_dir_lambda_zip   = "../../script/lambda/bcen_scr_mntr_flxo"
  output_path_lambda_zip  = "../../script/lambda/bcen_scr_mntr_flxo.zip"
  key_lambda_to_s3        = "lambda/bcen_scr_mntr_flxo.zip"
  timeout = 900

  security_groups_id = [lookup(var.network[terraform.workspace], "security_group_airflow", null)]

  subnets_id = [lookup(var.network[terraform.workspace], "private_subnet_id_resources_az_a", null),
    lookup(var.network[terraform.workspace], "private_subnet_id_resources_az_b", null)]

  environment_variables = {
    "MWAA_NAME" = "${var.airflow_aws_name}-${local.environment}",
    "LAMBDA_ENV" = local.environment
  }

  tag_vn          = "CI"
  tag_cost_center = "D00306001"
  tag_project     = "PARCERIA_BCSCR"
  tag_service     = "LAMBDA"
  tag_create_date = var.tag_create_date
  environment     = local.environment

}