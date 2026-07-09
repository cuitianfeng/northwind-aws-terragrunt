
terraform {
  experiments = [module_variable_optional_attrs]
}


resource "aws_sqs_queue" "cloudtrail_s3_queue" {
  name                      = local.values.sqs_name
  delay_seconds             = 0
  max_message_size          = local.values.max_message_size
  message_retention_seconds = local.values.message_retention_seconds
  visibility_timeout_seconds = 30

  policy = jsonencode(yamldecode(local.values.sqs_policy))
}

