terraform {
  experiments = [module_variable_optional_attrs]
}

module "security_group" {
  source = "./aws-security-group-module"
  values = local.values
}

module "rds_master" {
  source  = "terraform-aws-modules/rds/aws"
  version = "3.4.1"

  identifier = format("%s-%s-%s-master", local.values.env, local.values.project, local.values.app)

  engine                 = local.values.engine
  engine_version         = local.values.engine_version
  family                 = local.values.family
  major_engine_version   = local.values.major_engine_version
  instance_class         = local.values.instance_class
  publicly_accessible    = local.values.publicly_accessible
  allocated_storage      = local.values.allocated_storage
  max_allocated_storage  = local.values.max_allocated_storage

  storage_type           = (local.values.storage_type != null && local.values.storage_type != "") ? local.values.storage_type : null
  iops                   = (
    contains(["gp3", "io1", "io2"], local.values.storage_type) &&
    local.values.allocated_storage >= 400
) ? local.values.iops : null

  username               = local.values.username
  create_random_password = true
  random_password_length = 18

  performance_insights_enabled = local.values.performance_insights_enabled
  performance_insights_kms_key_id	= local.values.performance_insights_kms_key_id
  performance_insights_retention_period = local.values.performance_insights_retention_period

  subnet_ids             = [for subnet in data.aws_subnet.selected_subnet: subnet.id]
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window     = local.values.maintenance_window
  backup_window          = local.values.backup_window

  backup_retention_period = local.values.backup_retention_period
  parameters              = local.values.parameters
  tags = {
    Name        = format("%s-%s-%s-rds", local.values.env, local.values.project, local.values.app)
    Terraform   = "true"
    Project     = local.values.project
    Owners      = local.values.owners
    Env         = local.values.env
  }
}


module "rds_slave" {
  count = local.values.create_rds_slave ? 1 : 0
  source  = "terraform-aws-modules/rds/aws"
  version = "3.4.1"

  identifier = format("%s-%s-%s-replica", local.values.env, local.values.project, local.values.app)

  replicate_source_db    = module.rds_master.db_instance_id

  engine                 = local.values.engine
  engine_version         = local.values.engine_version
  family                 = local.values.family
  major_engine_version   = local.values.major_engine_version
  instance_class         = local.values.instance_class
  allocated_storage      = local.values.allocated_storage
  max_allocated_storage  = local.values.max_allocated_storage

  storage_type           = (local.values.storage_type != null && local.values.storage_type != "") ? local.values.storage_type : null
  iops                   = (
    contains(["gp3", "io1", "io2"], local.values.storage_type) &&
    local.values.allocated_storage >= 400
) ? local.values.iops : null

  username               = null
  password               = null

  performance_insights_enabled = local.values.performance_insights_enabled
  performance_insights_kms_key_id	= local.values.performance_insights_kms_key_id
  performance_insights_retention_period = local.values.performance_insights_retention_period
  
  subnet_ids             = [for subnet in data.aws_subnet.selected_subnet: subnet.id]
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window     = local.values.maintenance_window
  backup_window          = local.values.backup_window

  backup_retention_period = 0
  skip_final_snapshot    = true
  final_snapshot_identifier = null
  create_db_subnet_group = false

  tags = {
    Name        = format("%s-%s-%s-rds", local.values.env, local.values.project, local.values.app)
    Terraform   = "true"
    Project     = local.values.project
    Owners      = local.values.owners
    Env         = local.values.env
  }
}
