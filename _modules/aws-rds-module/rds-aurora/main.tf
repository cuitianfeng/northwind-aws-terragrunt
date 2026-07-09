terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  name_prefix = format("%s-%s-%s", local.values.env, local.values.project, local.values.app)
  tags = merge(
    {
      Terraform   = "true"
      Project     = local.values.project
      Owners      = local.values.owners
      Env         = local.values.env
    },
    { for tagname, tagvalue in local.values.custom_tags:  tagname => tagvalue if tagvalue != null && tagvalue != ""}
  )
}

module "security_group" {
  source = "./aws-security-group-module"
  values = local.values
}

resource "aws_cloudwatch_log_group" "example" {
  for_each = length(local.values.enabled_cloudwatch_logs_exports) > 0 ? toset(local.values.enabled_cloudwatch_logs_exports) : toset([])
  name = "/aws/rds/cluster/${format("%s-rds", local.name_prefix)}/${each.key}"
  retention_in_days = local.values.cloudwatch_logs_retention_in_days
  tags = local.tags
}

module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "6.1.4"

  name           = format("%s-rds", local.name_prefix)
  engine         = local.values.engine
  engine_version = local.values.engine_version
  instance_class = local.values.instance_class
  instances = {
    1 = {}
    2 = {}
  }
  endpoints = {}

  autoscaling_enabled = false

  vpc_id                 = data.aws_vpc.selected_vpc.id
  subnets                = [for subnet in data.aws_subnet.selected_subnet: subnet.id]
  create_db_subnet_group = true
  create_security_group  = false

  vpc_security_group_ids = [module.security_group.security_group_id]

  iam_database_authentication_enabled = true
  master_username                     = local.values.master_username
  master_password                     = local.values.master_password
  create_random_password              = false

  apply_immediately   = true
  skip_final_snapshot = true

  db_parameter_group_name         = aws_db_parameter_group.this.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.id
  enabled_cloudwatch_logs_exports = local.values.enabled_cloudwatch_logs_exports

  tags = local.tags
}

resource "aws_db_parameter_group" "this" {
  name        = "${local.name_prefix}-${replace(local.values.family, ".", "")}-db-pg"
  family      = local.values.family
  description = "${local.name_prefix}-${replace(local.values.family, ".", "")}-db-pg"
  tags        = local.tags
  dynamic "parameter" {
    for_each  = local.values.aws_db_pg_parameters 
    content {
      name         = parameter.key
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "immediate")
    }
  }
}

resource "aws_rds_cluster_parameter_group" "this" {
  name        = "${local.name_prefix}-${replace(local.values.family, ".", "")}-cluster-pg"
  family      = local.values.family
  description = "${local.name_prefix}-${replace(local.values.family, ".", "")}-cluster-pg"
  tags        = local.tags
  dynamic "parameter" {
    for_each  = local.values.aws_cluster_pg_parameters 
    content {
      name         = parameter.key
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "immediate")
    }
  }
}