resource "aws_iam_user" "networking_flow_logs_user" {
  name  = "${var.region}-networking-flow-logs-${var.cluster_name}"
}

resource "aws_iam_access_key" "networking_flow_logs_access_key" {
  user  = aws_iam_user.networking_flow_logs_user.name
}

resource "aws_iam_policy" "networking_flow_logs_policy" {
  name= "${var.region}-networking-flow-logs-${var.cluster_name}"
  path        = "/"
  description = "Permissions needed to pull logs from the networking flow logs in the corresponding S3 bucket."

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3-object-lambda:Get*",
                "s3-object-lambda:List*"
            ],
            "Resource": "arn:aws:s3:::${var.region}-network-flow-logs-${lower(var.cluster_name)}/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::${var.region}-network-flow-logs-${lower(var.cluster_name)}"
        }
    ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "networking_flow_logs_user_policy_attach" {
  user       = aws_iam_user.networking_flow_logs_user.name
  policy_arn = aws_iam_policy.networking_flow_logs_policy.arn
}
