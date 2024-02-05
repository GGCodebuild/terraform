resource "spc_location_hdfs" "this" {
  access_key = var.access_key
  secret_key = var.secret_key
  token      = var.token

  agent_arns         = aws_datasync_agent.agent.arn
  auth               = var.authentication_type
  keytab_path        = var.path_kerberos_keytab
  krb5_path          = var.path_kerberos_krb5_conf
  kerberos_principal = var.kerberos_principal
  sub_directory      = var.subdirectory_hadoop
  name_node_host     = var.hostname_location
  name_node_port     = var.port_location

  replication_factor = var.replication_factor

  qop_configuration {
    rpc_protection           = var.qop_configuration_rpc_protection
    data_transfer_protection = var.qop_configuration_data_transfer_protection
  }

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = "Hadoop-location-${var.tag_project}"
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }

  depends_on = [aws_datasync_agent.agent]

}
