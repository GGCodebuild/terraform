resource "aws_iam_role" "datasync-s3-access-role" {
  name               = "datasync-s3-access-role-${var.name_data_sync}-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.datasync_assume_role.json

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = "datasync-s3-access-role-${var.name_data_sync}-${var.environment}"
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }

}

resource "aws_iam_role_policy" "datasync-s3-access-policy" {
  name   = "datasync-s3-access-policy-${var.name_data_sync}-${var.environment}"
  role   = aws_iam_role.datasync-s3-access-role.name
  policy = data.aws_iam_policy_document.bucket_access.json
}

data "aws_iam_policy_document" "datasync_assume_role" {
  statement {
    actions = ["sts:AssumeRole", ]
    principals {
      identifiers = ["datasync.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "bucket_access" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObjectTagging",
      "s3:GetObjectTagging",
      "s3:PutObject"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

}