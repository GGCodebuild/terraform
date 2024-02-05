resource "aws_datasync_task" "this" {
  destination_location_arn = aws_datasync_location_s3.s3_location.arn
  name                     = "${var.name}-${var.environment}"
  source_location_arn      = spc_location_hdfs.this.id
  cloudwatch_log_group_arn = var.aws_cloudwatch_log_group_arn

  options {
    bytes_per_second       = -1
    verify_mode            = "POINT_IN_TIME_CONSISTENT"
    preserve_deleted_files = "REMOVE"
    log_level              = "TRANSFER"
    overwrite_mode         = "ALWAYS"
  }

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = "${var.name}-${var.environment}"
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }

  depends_on = [spc_location_hdfs.this]

}
