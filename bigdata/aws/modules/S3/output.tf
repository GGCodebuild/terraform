output "bucket_arn" {
  value = aws_s3_bucket.service_bucket.arn
}

output "location_arn" {
  value = aws_s3_bucket.service_bucket.arn
}

output "bucket_id" {
  value = aws_s3_bucket.service_bucket.id
}

output "bucket" {
  value = aws_s3_bucket.service_bucket.bucket
}
