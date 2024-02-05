module "glue_crawler_bcen_scr_garbage" {
  for_each              = var.map_crawler_bcen_scr_garbage
  source                = "../../modules/Glue/crawler_generic_type"
  database_name         = "db_garbage"
  aws_iam_glue_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.iam_glue_crawler_role_name}"
  path_s3               = "s3://${var.bucket_garbage}-${local.environment}/${each.value}/"
  name_crawler          = "${each.key}_garbage"
  table_prefix          = "bcen_scr_"

  tag_vn          = var.tag_vn_bacen_scr
  tag_cost_center = var.tag_cost_center_bacen_scr
  tag_project     = var.tag_project_bacen_scr
  tag_service     = "GLUE_CRAWLER"
  tag_create_date = var.tag_create_date
  environment     = local.environment
}

module "glue_crawler_bcen_scr_raw" {
  for_each              = var.map_crawler_bcen_scr_raw
  source                = "../../modules/Glue/crawler_generic_type"
  database_name         = "db_raw"
  aws_iam_glue_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.iam_glue_crawler_role_name}"
  path_s3               = "s3://${var.bucket_raw}-${local.environment}/${each.value}/"
  name_crawler          = "${each.key}_raw"
  table_prefix          = "bcen_scr_"

  tag_vn          = var.tag_vn_bacen_scr
  tag_cost_center = var.tag_cost_center_bacen_scr
  tag_project     = var.tag_project_bacen_scr
  tag_service     = "GLUE_CRAWLER"
  tag_create_date = var.tag_create_date
  environment     = local.environment
}

module "glue_crawler_bcen_scr_trusted" {
  for_each              = var.map_crawler_bcen_scr_trusted
  source                = "../../modules/Glue/crawler_generic_type"
  database_name         = "db_trusted"
  aws_iam_glue_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.iam_glue_crawler_role_name}"
  path_s3               = "s3://${var.bucket_trusted}-${local.environment}/${each.value}/"
  name_crawler          = "${each.key}_trusted"
  table_prefix          = "bcen_scr_"

  tag_vn          = var.tag_vn_bacen_scr
  tag_cost_center = var.tag_cost_center_bacen_scr
  tag_project     = var.tag_project_bacen_scr
  tag_service     = "GLUE_CRAWLER"
  tag_create_date = var.tag_create_date
  environment     = local.environment
}

module "glue_crawler_bcen_scr_refined_delta" {
  for_each                  = var.map_crawler_bcen_scr_refined_delta
  source                    = "../../modules/Glue/crawler_delta_format"
  database_name             = "db_refined"
  aws_iam_glue_role_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.iam_glue_crawler_role_name}"
  path_s3                   = "s3://${var.bucket_refined}-${local.environment}/${each.value}/"
  name_crawler              = "${each.key}_refined_delta"

  tag_vn          = var.tag_vn_bacen_scr
  tag_cost_center = var.tag_cost_center_bacen_scr
  tag_project     = var.tag_project_bacen_scr
  tag_service     = "GLUE_CRAWLER"
  tag_create_date = var.tag_create_date
  environment     = local.environment
}