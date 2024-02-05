resource "aws_datasync_location_s3" "s3_location" {
  s3_bucket_arn = var.s3_bucket_arn
  subdirectory  = var.subdirectory_s3

  s3_config {
    bucket_access_role_arn = var.bucket_access_role_arn
  }

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = "S3-location-${var.tag_project}"
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }
}