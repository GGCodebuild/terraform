resource "aws_dms_endpoint" "source" {

  database_name               = var.database_name_source
  endpoint_id                 = var.endpoint_id_source
  endpoint_type               = "source"
  engine_name                 = var.engine_name_source
  secrets_manager_access_role_arn = var.secrets_manager_access_role_arn
  secrets_manager_arn = var.secrets_manager_arn
  extra_connection_attributes = var.extra_connection_attributes_source
  ssl_mode                    = var.ssl_mode_source

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = var.endpoint_id_source
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = "DMS-Endpoint-Source"
  }

}

resource "null_resource" "update-endpoint" {
  triggers = {
    always_run   = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "aws dms modify-endpoint --endpoint-arn ${aws_dms_endpoint.source.endpoint_arn} --oracle-settings ${data.template_file.settings-oracle.rendered}"
  }

  depends_on = [aws_dms_endpoint.source]
}

data "template_file" "settings-oracle" {
  template = jsonencode(file("../../templates/dms/config-oracle-settings-endpoint.json"))

  vars = {
    roleArn  = "${var.secrets_manager_access_role_arn}"
    secretId = "${var.secrets_manager_arn}"
  }
}

