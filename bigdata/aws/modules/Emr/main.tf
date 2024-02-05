resource "aws_emr_cluster" "cluster" {
  name          = var.emr_name_cluster
  release_label = var.emr_release
  applications  = ["Spark"]

  termination_protection            = false
  keep_job_flow_alive_when_no_steps = true
  step_concurrency_level            = 1

  #  auto_termination_policy {
  #    idle_timeout = var.idle_timeout_emr
  #  }

  ec2_attributes {
    subnet_id                         = var.public_subnet_id
    emr_managed_master_security_group = var.security_group_master_id
    emr_managed_slave_security_group  = var.security_group_slave_id
    service_access_security_group     = var.security_access_slave_id
    key_name                          = var.ec2_key_name
    instance_profile                  = var.emr_profile_arn
  }

  bootstrap_action {
    name = "Bootstrap setup."
    path = "s3://${var.s3_bootstrap}/emr/bootstrap_install_dependencies.sh"
    args = [var.s3_bootstrap]
  }

  master_instance_group {
    instance_type  = var.ec2_type_master_instance
    instance_count = var.num_instance_master
    name           = "EMR-MASTER"
  }

  core_instance_group {
    instance_type  = var.ec2_type_executor_instance
    instance_count = var.num_instance_executors
    name           = "EMR-CORE"

    ebs_config {
      size                 = var.size_storage
      type                 = "gp2"
      volumes_per_instance = 1
    }
  }

  log_uri = "s3://${var.s3_log}/EMR/"


  service_role = var.iam_emr_service_role_arn

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = var.emr_name_cluster
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }

}





