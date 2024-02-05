module "secrets_bcen_scr_orcl" {
  source        = "../../modules/SecretsManager"
  name          = "bcen_scr_orcl/oracle/credential"
  secret_string = lookup(var.secret_oracle_key[terraform.workspace], "credential", null)

  tag_vn          = var.tag_vn_bacen_scr
  tag_cost_center = var.tag_cost_center_bacen_scr
  tag_project     = var.tag_project_bacen_scr
  tag_service     = "SECRET_MANAGER"
  tag_create_date = var.tag_create_date
  environment     = local.environment
}