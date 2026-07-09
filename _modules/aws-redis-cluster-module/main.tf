terraform {
  experiments = [module_variable_optional_attrs]
}

module "security_group" {
  source = "./aws-security-group-module"
  values = merge(
    local.values, {
      app = "${local.values.app}-redis"
    }
  )
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = format("%s-%s-%s-subnet-group", local.values.env, local.values.project, local.values.app)
  subnet_ids = [for subnet in data.aws_subnet.selected_subnet: subnet.id]
}

resource "aws_elasticache_replication_group" "redis_cluster" {
  engine                        = "redis"
  engine_version                = local.values.engine_version
  replication_group_id          = format("%s-%s-%s-redis-cluster", local.values.env, local.values.project, local.values.app)
  replication_group_description = local.values.replication_group_description
  node_type                     = local.values.node_type
  port                          = local.values.port
  parameter_group_name          = local.values.parameter_group_name
  automatic_failover_enabled    = local.values.automatic_failover_enabled
  subnet_group_name             = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids            = [module.security_group.security_group_id]

  cluster_mode {
    replicas_per_node_group = local.values.replicas_per_node_group
    num_node_groups         = local.values.num_node_groups
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