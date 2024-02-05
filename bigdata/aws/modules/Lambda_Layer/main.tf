
resource "aws_lambda_layer_version" "lambda_layer" {
  s3_key = var.key_lambda_to_s3
  s3_bucket = var.bucket_name_artifactory
  layer_name = var.layer_name

  compatible_runtimes = var.compatible_runtimes

  depends_on = [aws_s3_object.lambda_to_s3]
}


resource "aws_s3_object" "lambda_to_s3" {
  bucket = var.bucket_name_artifactory
  source = var.source_package
  etag   = md5(var.source_package)
  key    = var.key_lambda_to_s3
}