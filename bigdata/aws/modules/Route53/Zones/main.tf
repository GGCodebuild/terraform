resource "aws_route53_zone" "zona" {
  name = var.name
  vpc {
    vpc_id     = var.vpc_id_associate_zone
    vpc_region = var.vpc_region_associate_zone
  }
}

#module "lakehouse_zone" {
#  source                    = "../../modules/Route53/Zones"
#  name                      = "lakehouse.${local.environment}.interno.spcbrasil.org.br"
#  vpc_id_associate_zone     = var.vpc_lakehouse_id
#  vpc_region_associate_zone = var.aws_regiao_conta
#}
#
#module "certificado_record" {
#  source      = "../../modules/ACM_Certificate_DNS"
#  domain_name = "lending.airflow.${module.lakehouse_zone.zona_name}"
#  zone_id     = module.lakehouse_zone.zone_id
#}
#
#module "api_gateway_domain_name" {
#  source                      = "../../modules/Api_Gateway/Domain_name"
#  domain_name                 = "lending.airflow.${module.lakehouse_zone.zona_name}"
#  aws_acm_certificate_api_arn = module.certificado_record.aws_acm_certificate_arn
#}
#
#
#module "airflow_api" {
#  source                 = "../../modules/Route53/Records"
#  name                   = "lending.airflow.${module.lakehouse_zone.zona_name}"
#  type                   = "A"
#  depends_on             = [module.lakehouse_zone, module.api_gateway_domain_name]
#  zone_id                = module.lakehouse_zone.zone_id
#  alias_name             = module.api_gateway_domain_name.target_domain_name
#  alias_zone_id          = module.api_gateway_domain_name.hosted_zone_id
#  evaluate_target_health = true
#}