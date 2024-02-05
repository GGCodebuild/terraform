resource "aws_iam_user" "logs_user" {
  name  = "${var.region}-wr-studio-logs-${var.cluster_name}"
}

resource "aws_iam_access_key" "logs_access_key" {
  user = aws_iam_user.logs_user.name
}

resource "aws_iam_policy" "logs_policy" {
  name = "${var.region}-wr-studio-logs-${var.cluster_name}"
  path        = "/"
  description = "Permissions needed for Logs signing proxy."

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${var.region}-wr-studio-logs-${lower(var.cluster_name)}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${var.region}-wr-studio-logs-${lower(var.cluster_name)}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "logs_user_policy_attach" {
  user       = aws_iam_user.logs_user.name
  policy_arn = aws_iam_policy.logs_policy.arn
}
