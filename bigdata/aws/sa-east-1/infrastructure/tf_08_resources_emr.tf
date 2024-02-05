#Descomentar quando necessário subir um cluster EMR para realizar atividade temporária
#module "emr-cluster-ec2" {
#  source                     = "../../modules/Emr"
#  emr_name_cluster           = "${var.emr_name_cluster}-${local.environment}"
#  num_instance_executors     = lookup(var.emr_config[terraform.workspace], "emr_num_instance_executors", null)
#  ec2_type_master_instance   = lookup(var.emr_config[terraform.workspace], "emr_type_executor_instance", null)
#  ec2_type_executor_instance = lookup(var.emr_config[terraform.workspace], "emr_type_master_instance", null)
#  num_instance_master        = lookup(var.emr_config[terraform.workspace], "emr_num_instance_core", null)
#  ec2_key_name               = var.ec2_key_name
#  size_storage               = lookup(var.emr_config[terraform.workspace], "emr_size_storage", null)
#  security_group_master_id   = lookup(var.network[terraform.workspace], "security_group_emr_master", null)
#  security_group_slave_id    = lookup(var.network[terraform.workspace], "security_group_emr_slave", null)
#  security_access_slave_id   = lookup(var.network[terraform.workspace], "security_group_emr_access", null)
#  public_subnet_id           = lookup(var.network[terraform.workspace], "private_subnet_id_resources_az_a", null)
#  aws_vpc_id                 = lookup(var.network[terraform.workspace], "vpc_id", null)
#  emr_release                = lookup(var.emr_config[terraform.workspace], "emr_release", null)
#  s3_bootstrap               = module.bucket_lake_artifactory.bucket
#  s3_log                     = module.bucket_lake_logs.bucket
#  emr_profile_arn            = module.policy_emr.emr_profile_arn
#  iam_emr_service_role_arn   = module.policy_emr.iam_emr_service_role_arn
#  idle_timeout_emr           = lookup(var.emr_config[terraform.workspace], "idle_timeout_emr", null)
#  depends_on                 = [module.bucket_lake_artifactory, module.object_bucket_emr_bootstrap, module.object_bucket_emr_lib, module.policy_emr]
#
#  tag_vn          = var.tag_vn
#  tag_cost_center = var.tag_cost_center
#  tag_project     = var.tag_project
#  tag_service     = "EMR"
#  tag_create_date = var.tag_create_date
#  environment     = local.environment
#}