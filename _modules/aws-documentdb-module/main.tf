terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  engine       = "docdb"
  cluster_name = format("%s-%s-%s-docdb", local.values.env, local.values.project, local.values.app)
  subnet_group_name = format("%s-%s-%s-docdb-subnetgroup", local.values.env, local.values.project, local.values.app)
  tags = {
    Terraform = "true"
    Env       = local.values.env
    App       = local.values.app
    Project   = local.values.project
  }
}

resource "aws_docdb_cluster" "this" {
  cluster_identifier      = local.cluster_name
  engine                  = local.engine
  engine_version          = local.values.engine_version
  master_username         = "dbadmin"
  master_password         = "changeme"
  backup_retention_period = local.values.backup_retention_period
  preferred_backup_window = local.values.preferred_backup_window
  skip_final_snapshot     = true
  vpc_security_group_ids  = [module.security_group.security_group_id]
  db_subnet_group_name    = join("", aws_docdb_subnet_group.this.*.name)
  db_cluster_parameter_group_name = join("", aws_docdb_cluster_parameter_group.this.*.name)
  tags = merge({
    Name = local.cluster_name
  }, local.tags)
}

resource "aws_docdb_cluster_instance" "default" {
  count                      = local.values.cluster_size
  identifier                 = "${local.cluster_name}-${count.index + 1}"
  cluster_identifier         = join("", aws_docdb_cluster.this.*.id)
  apply_immediately          = local.values.apply_immediately
  instance_class             = local.values.instance_class
  engine                     = local.engine
  auto_minor_version_upgrade = local.values.auto_minor_version_upgrade
  tags                       = local.tags
}

resource "aws_docdb_subnet_group" "this" {
  name = local.subnet_group_name
  subnet_ids = [for subnet in data.aws_subnet.selected_subnet: subnet.id]

  tags = merge({
    Name = local.subnet_group_name
  }, local.tags)
}

resource "aws_docdb_cluster_parameter_group" "this" {
  name        = "${local.cluster_name}-pg"
  description = "${local.cluster_name} parameter group"
  family      = local.values.family

  dynamic "parameter" {
    for_each = local.values.cluster_parameters
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }

  tags = local.tags
}

module "security_group" {
  source = "./aws-security-group-module"
  values = merge(
    local.values, {
      app = "${local.values.app}-docdb"
    }
  )
}