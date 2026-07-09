terraform {
  experiments = [module_variable_optional_attrs]
}

resource "aws_sns_topic" "devops" {
  name = local.values.topicname  
}


locals {
  principal = [
    for account in local.values.other_account_ids : "arn:aws:iam::${account}:root"
    
  ]
}

resource "aws_sns_topic_policy" "devops_monitor" {

  arn = aws_sns_topic.devops.arn

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudWatchAlarmAccess"
        Effect    = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action    = ["sns:Publish"]
        Resource  = aws_sns_topic.devops.arn
      },
      {
        Sid       = "AllowLambdaAccess"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action    = ["sns:Publish"]
        Resource  = aws_sns_topic.devops.arn
      },
      {
        Sid       = "AllowCrossAccountAccess"
        Effect    = "Allow"
        Principal = {
          "AWS"   = local.principal
        }
        Action    = ["sns:Publish"]
        Resource  = aws_sns_topic.devops.arn
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "email_subscription" {
  count         = length(local.values.email_subscriptions)
  topic_arn     = aws_sns_topic.devops.arn
  protocol      = "email"
  endpoint      = element(local.values.email_subscriptions, count.index)
}
