terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  server_properties = join("\n", [for k, v in var.values.server_properties : format("%s = %s", k, v)])
  cluster_name = var.values.cluster_name
  instance_type = var.values.instance_type
  kafka_version = var.values.kafka_version
  number_of_nodes = var.values.number_of_nodes
  volume_size = var.values.volume_size
  client_subnets = var.values.client_subnets
}
/*
data "aws_subnet" "this" {
  id = local.client_subnets[0] 
}
*/

/*
data "aws_subnet" "this" {
  id = can(length(local.client_subnets[0]) >0) ? local.client_subnets[0] : [for subnet in data.aws_subnet.selected_subnet: subnet.id][0]
}
*/


module "security_group" {
  source = "./aws-security-group-module"
  values = merge(
    local.values, {
      app = "${local.values.app}-msk"
    }
  ) 
}

resource "aws_security_group" "this" {
   name_prefix = "${local.values.cluster_name}-"
#  name_prefix = can(length(local.cluster_name) > 0) ? "local.cluster_name" : "${local.values.env}-${local.values.project}-${local.values.app}-msk"
 # vpc_id      = data.aws_subnet.this.vpc_id
 # vpc_id      = can(length(local.client_subnets[0]) >0) ? data.aws_subnet.this.vpc_id : data.aws_vpc.selected_vpc.id
   vpc_id      = data.aws_vpc.selected_vpc.id
}

resource "aws_security_group_rule" "msk-plain" {
  from_port         = 9092
  to_port           = 9092
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "msk-tls" {
  from_port         = 9094
  to_port           = 9094
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "zookeeper-plain" {
  from_port         = 2181
  to_port           = 2181
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "zookeeper-tls" {
  from_port         = 2182
  to_port           = 2182
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "jmx-exporter" {
  count = local.values.prometheus_jmx_exporter ? 1 : 0

  from_port         = 11001
  to_port           = 11001
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "node_exporter" {
  count = local.values.prometheus_node_exporter ? 1 : 0

  from_port         = 11002
  to_port           = 11002
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  self              = true
}

resource "aws_cloudwatch_log_group" "test" {
  count = local.values.cloudwatch_logs ? 1 : 0
  name = "/aws/msk/${local.values.cluster_name}-logs"
  retention_in_days = 90
}

resource "random_id" "configuration" {
  prefix      = "${local.values.cluster_name}-"
#  prefix      = can(length(local.cluster_name) > 0) ? "local.cluster_name" : "${local.values.env}-${local.values.project}-${local.values.app}-msk"
  byte_length = 8

  keepers = {
    server_properties = local.server_properties
    kafka_version     = local.kafka_version 
  }
}

resource "aws_msk_configuration" "this" {
  kafka_versions    = [random_id.configuration.keepers.kafka_version]
  name              = random_id.configuration.dec
  server_properties = random_id.configuration.keepers.server_properties

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_msk_cluster" "this" {
  depends_on = [aws_msk_configuration.this]
  cluster_name           = local.values.cluster_name
#  cluster_name           = can(length(local.cluster_name) > 0) ? "local.cluster_name" : "${local.values.env}-${local.values.project}-${local.values.app}-msk"
  kafka_version          = local.kafka_version
  number_of_broker_nodes = local.number_of_nodes
  enhanced_monitoring    = var.enhanced_monitoring

  broker_node_group_info {
    #    client_subnets = local.client_subnets
    #client_subnets = can(length(local.client_subnets) > 0) ? local.client_subnets : [for subnet in data.aws_subnet.selected_subnet: subnet.id]
    client_subnets  = [for subnet in data.aws_subnet.selected_subnet: subnet.id]
    ebs_volume_size = local.volume_size
    instance_type   = local.instance_type 
    security_groups = concat(aws_security_group.this.*.id, split(",",module.security_group.security_group_id), var.extra_security_groups)
  }

  configuration_info {
    arn      = aws_msk_configuration.this.arn
    revision = aws_msk_configuration.this.latest_revision
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = var.encryption_at_rest_kms_key_arn
    encryption_in_transit {
      client_broker = var.encryption_in_transit_client_broker
      in_cluster    = var.encryption_in_transit_in_cluster
    }
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = local.values.prometheus_jmx_exporter
      }
      node_exporter {
        enabled_in_broker = local.values.prometheus_node_exporter
      }
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = local.values.cloudwatch_logs
        log_group = join("",aws_cloudwatch_log_group.test[*].name)
      }
    }
  }

  tags = merge(
    {
      Terraform   = "true"
      Project     = local.values.project
      App         = local.values.app
      Owners      = local.values.owners
      Env         = local.values.env
    },
    { for tagname, tagvalue in local.values.custom_tags:  tagname => tagvalue if tagvalue != null && tagvalue != ""}
  )

}