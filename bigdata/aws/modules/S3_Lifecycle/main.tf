resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_s3" {
  bucket = var.bucket_arn

  rule {

    id = var.filter_path

    expiration {
      days = var.expiration_days
    }

    filter {
      prefix = "${var.filter_path}/"
    }

    status = "Enabled"

  }

}