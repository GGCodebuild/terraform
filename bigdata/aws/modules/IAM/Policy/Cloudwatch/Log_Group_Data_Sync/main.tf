resource "aws_cloudwatch_log_resource_policy" "this" {
  policy_name = "aws-cloudwatch-log-${var.name}-${var.environment}"
  policy_document = jsonencode(

    {
      "Statement" : [
        {
          "Sid" : "DataSyncLogsToCloudWatchLogs",
          "Effect" : "Allow",
          "Action" : [
            "logs:PutLogEvents",
            "logs:PutLogEvents",
            "logs:CreateLogStream"
          ],
          "Principal" : {
            "Service" : "datasync.amazonaws.com"
          },
          "Condition" : {
            "ArnLike" : {
              "aws:SourceArn" : [
                "arn:aws:datasync:${var.region}:${var.account_id}:task/*"
              ]
            },
            "StringEquals" : {
              "aws:SourceAccount" : var.account_id
            }
          },
          "Resource" : "${var.resource_arn}:*"
        }
      ],
      "Version" : "2012-10-17"
    }

  )
}