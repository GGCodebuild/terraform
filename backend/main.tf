provider "aws" {
  region = "us-east-1"
  access_key = "AKIARNUDVN3IH5PO2YBX"
  secret_key = "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"
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "terraform-state-eduardo"
    lifecycle {
      prevent_destroy = true
    }
}
resource "aws_s3_bucket_versioning" "enabled" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
      status = "Enabled"
    }
  
}
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
    bucket = aws_s3_bucket.terraform_state.id
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  
}
resource "aws_s3_bucket_public_access_block" "public_access" {
    bucket = aws_s3_bucket.terraform_state.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
  
}
resource "aws_dynamodb_table" "terraform_locks" {
    name = "terraform-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    attribute {
      name = "LockID"
      type = "S"
    }

}