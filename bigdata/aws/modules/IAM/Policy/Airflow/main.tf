resource "aws_iam_role" "mwaa-execution" {
  name = "AmazonMWAA-Role-lakeHouse"

  assume_role_policy = jsonencode(
    {
      Version : "2012-10-17",
      Statement : [
        {
          Action : "sts:AssumeRole",
          Principal : {
            "Service" : [
              "airflow.amazonaws.com",
              "airflow-env.amazonaws.com"
            ]
          },
          Effect : "Allow",
          Sid : ""
        }
      ]
    }
  )

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = "AmazonMWAA-Role-lakeHouse"
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }

}

resource "aws_iam_role_policy" "mwaa-exec-policy" {
  name = "MWAA-Execution-Policy-lakeHouse"
  role = aws_iam_role.mwaa-execution.id

  policy = jsonencode(

    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          Effect : "Allow",
          Action : "airflow:PublishMetrics",
          Resource : "arn:aws:airflow:${var.region}:${var.account_id}:environment/${var.air_flow_name}"
        },
        {
          Effect : "Deny",
          Action : "s3:ListAllMyBuckets",
          Resource : [
            "arn:aws:s3:::${var.bucket_name}",
            "arn:aws:s3:::${var.bucket_name}/*"
          ]
        },
        {
          Effect : "Allow",
          Action : [
            "s3:*"
          ],
          Resource : ["*"]
        },
        {
          Effect : "Allow",
          Action : [
            "logs:CreateLogStream",
            "logs:CreateLogGroup",
            "logs:PutLogEvents",
            "logs:GetLogEvents",
            "logs:GetLogRecord",
            "logs:GetLogGroupFields",
            "logs:GetQueryResults"
          ],
          Resource : [
            "arn:aws:logs:${var.region}:${var.account_id}:log-group:airflow-${var.air_flow_name}-*"
          ]
        },
        {
          Effect : "Allow",
          Action : [
            "logs:DescribeLogGroups"
          ],
          Resource : ["*"]
        },
        {
          Effect : "Allow",
          Action : "cloudwatch:PutMetricData",
          Resource : "*"
        },
        {
          Effect : "Allow",
          Action : [
            "sqs:ChangeMessageVisibility",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes",
            "sqs:GetQueueUrl",
            "sqs:ReceiveMessage",
            "sqs:SendMessage"
          ],
          Resource : "arn:aws:sqs:${var.region}:*:airflow-celery-*"
        },
        {
          Effect : "Allow",
          Action : [
            "elasticmapreduce:DescribeCluster",
            "elasticmapreduce:ListSteps",
            "elasticmapreduce:TerminateJobFlows",
            "elasticmapreduce:SetTerminationProtection",
            "elasticmapreduce:ListInstances",
            "elasticmapreduce:ListInstanceGroups",
            "elasticmapreduce:ListBootstrapActions",
            "elasticmapreduce:DescribeStep",
            "elasticmapreduce:RunJobFlow",
            "elasticmapreduce:AddJobFlowSteps"
          ],
          Resource : ["arn:aws:elasticmapreduce:${var.region}:*:cluster/*"],
        },
        {
          Effect : "Allow",
          Action : [
            "iam:*"
          ],
          Resource : ["arn:aws:iam::${var.account_id}:role/*"]
        },
        {
          Effect : "Allow",
          Action : [
            "secretsmanager:ListSecrets",
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "secretsmanager:ListSecretVersionIds"
          ],
          Resource : ["*"]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "glue:*"
          ],
          "Resource" : ["*"]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "dms:StartReplicationTask",
            "dms:StopReplicationTask",
            "dms:DescribeReplicationTasks",
          ],
          "Resource" : ["*"]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "sns:*"
          ],
          "Resource" : ["*"]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "datasync:*",
            "ec2:CreateNetworkInterface",
            "ec2:CreateNetworkInterfacePermission",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "ec2:ModifyNetworkInterfaceAttribute",
            "fsx:DescribeFileSystems",
            "elasticfilesystem:DescribeFileSystems",
            "elasticfilesystem:DescribeMountTargets",
            "iam:GetRole",
            "iam:ListRoles",
            "logs:CreateLogGroup",
            "logs:DescribeLogGroups",
            "logs:DescribeResourcePolicies",
            "s3:ListAllMyBuckets",
            "s3:ListBucket"
          ],
          "Resource" : ["*"]
        },
        {
          Effect : "Allow",
          Action : [
            "kms:Decrypt",
            "kms:DescribeKey",
            "kms:GenerateDataKey*",
            "kms:Encrypt"
          ],
          NotResource : "arn:aws:kms:*:${var.account_id}:key/*",
          Condition : {
            "StringLike" : {
              "kms:ViaService" : [
                "sqs.${var.region}.amazonaws.com"
              ]
            }
          }
        }
      ]
    }
  )
}

