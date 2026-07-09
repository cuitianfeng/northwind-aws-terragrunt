terraform {
  experiments = [module_variable_optional_attrs]
}
module "security_group" {
  source = "./aws-security-group-module"
  values = merge(
    local.values, {
      app = "${local.values.app}-es"
    }
  )   
}
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_iam_service_linked_role" "this" {
  count = "${local.values.create_iam_service_linked_role ? 1 : 0}"
  aws_service_name = "es.amazonaws.com"
}

resource "aws_cloudwatch_log_group" "example" {
  for_each = local.values.cloudwatch_logs_enabled ? toset(["INDEX_SLOW_LOGS", "SEARCH_SLOW_LOGS", "ES_APPLICATION_LOGS"]) : toset([])
  name = "/aws/elasticsearch/${local.values.domain_name}/${each.key}"
  retention_in_days = 90
}

resource "aws_cloudwatch_log_resource_policy" "example" {
  count = local.values.cloudwatch_logs_enabled ? 1 : 0
  policy_name = "opensearch_cloudwatch_log_policy"

  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}
resource "aws_elasticsearch_domain" "this" {
  domain_name = local.values.domain_name
  elasticsearch_version = local.values.elasticsearch_version
  cluster_config {
      instance_count = local.values.cluster_config.instance_count
      instance_type = local.values.cluster_config.instance_type
#    Set this parameter to false when you want to create a single-availability single-node cluster   
      zone_awareness_enabled = local.values.cluster_config.zone_awareness_enabled

      zone_awareness_config {
        availability_zone_count = 3
      }
  }
  vpc_options {
 #     subnet_ids = local.values.vpc_options.subnet_ids
      subnet_ids         = [for subnet in data.aws_subnet.selected_subnet: subnet.id]
      security_group_ids = concat(split(",",module.security_group.security_group_id), var.extra_security_group_ids)
  }

  ebs_options {
      ebs_enabled = local.values.ebs_options.ebs_enabled
      volume_size = local.values.ebs_options.volume_size
      volume_type = local.values.ebs_options.volume_type
      iops = local.values.ebs_options.volume_type == "gp3" ? local.values.ebs_options.iops : null
      throughput = local.values.ebs_options.volume_type == "gp3" ? local.values.ebs_options.throughput : null
  }
  snapshot_options {
      automated_snapshot_start_hour = local.values.snapshot_options.automated_snapshot_start_hour
  }
  domain_endpoint_options {
      enforce_https = local.values.domain_endpoint_options.enforce_https
      tls_security_policy = local.values.domain_endpoint_options.tls_security_policy
  }

  access_policies = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "es:*",
      "Principal": {
        "AWS": "*"
      },
      "Effect": "Allow",
      "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${local.values.domain_name}/*"
    }
  ]
}
POLICY

  dynamic log_publishing_options {
    for_each = local.values.cloudwatch_logs_enabled ? toset(["INDEX_SLOW_LOGS", "SEARCH_SLOW_LOGS", "ES_APPLICATION_LOGS"]) : toset([])
    content {
      enabled = local.values.cloudwatch_logs_enabled
      cloudwatch_log_group_arn = aws_cloudwatch_log_group.example[log_publishing_options.key].arn
      log_type                 = "${log_publishing_options.key}"
    }
  }

  tags = merge(
    {
      Terraform = "true"
      Project     = local.values.project
      Owners      = local.values.owners
      Env         = local.values.env
    },
    { for tagname, tagvalue in local.values.custom_tags:  tagname => tagvalue if tagvalue != null && tagvalue != ""}
  )   
}
