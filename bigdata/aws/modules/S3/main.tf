resource "aws_s3_bucket" "service_bucket" {
  bucket        = var.aws_bucket_name
  force_destroy = var.aws_force_destroy_bucket

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = var.aws_bucket_name
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }
}


resource "aws_s3_bucket_public_access_block" "acl" {
  bucket                  = aws_s3_bucket.service_bucket.id
  block_public_acls       = var.flag_acl
  block_public_policy     = var.flag_acl
  restrict_public_buckets = var.flag_acl
  ignore_public_acls      = var.flag_acl
}