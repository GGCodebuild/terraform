resource "aws_s3_object" "object" {
  for_each = fileset(var.local_path, "*")
  bucket   = var.bucket_id
  key      = "${var.remote_path}/${each.value}"
  source   = "${var.local_path}/${each.value}"
  etag     = filemd5("${var.local_path}/${each.value}")
}
