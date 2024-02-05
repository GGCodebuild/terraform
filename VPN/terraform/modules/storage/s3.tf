###
# File: s3.tf
# File Created: Tuesday, 7th February 2023 3:24:11 pm
# -----
# Last Modified: Friday February 10th 2023 2:49:09 pm
# Modified By: Jordan Craven <jordan.craven@windriver.com>
# -----
# Copyright (c) 2023 Wind River Systems, Inc.
# 
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###
resource "aws_s3_bucket" "logs_bucket" {
  bucket        = "${var.region}-wr-studio-logs-${lower(var.k8s_cluster_name)}"
  acl           = "private"
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "logs_bucket" {
  bucket = aws_s3_bucket.logs_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
