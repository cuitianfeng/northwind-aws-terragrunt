terraform {
  experiments = [module_variable_optional_attrs]
}

module "rds_cluster" {

  source              = "git::https://github.com/cloudposse/terraform-aws-rds-cluster.git?ref=tags/0.50.0"


  enabled             = true
  name                = local.values.app
  engine              = local.values.engine
  cluster_family      = local.values.cluster_family
  cluster_size        = local.values.cluster_size
  vpc_id              = local.values.vpc_id
  db_name             = local.values.project
  instance_type       = local.values.instance_type
  subnets             = local.values.subnets
  security_groups     = local.values.security_groups
  deletion_protection = local.values.deletion_protection
  autoscaling_enabled = local.values.autoscaling_enabled
  admin_user          = "admin"
  admin_password      = "adminpaswordyyy"
  storage_encrypted   = local.values.storage_encrypted

  tags = {
    Name        = format("%s-%s-%s-rds", local.values.env, local.values.project, local.values.app)
    Terraform   = "true"
    Project     = local.values.project
    Owners      = local.values.owners
    Env         = local.values.env
  }
  maintenance_window     = local.values.maintenance_window
  backup_window          = local.values.backup_window

  cluster_parameters = [
    {
      name         = "character_set_client"
      value        = "utf8"
      apply_method = "pending-reboot"
    },
    {
      name         = "character_set_connection"
      value        = "utf8"
      apply_method = "pending-reboot"
    },
    {
      name         = "character_set_database"
      value        = "utf8"
      apply_method = "pending-reboot"
    },
    {
      name         = "character_set_results"
      value        = "utf8"
      apply_method = "pending-reboot"
    },
    {
      name         = "character_set_server"
      value        = "utf8mb4"
      apply_method = "pending-reboot"
    },
    {
      name         = "collation_connection"
      value        = "utf8_bin"
      apply_method = "pending-reboot"
    },
    {
      name         = "collation_server"
      value        = "utf8mb4_unicode_ci"
      apply_method = "pending-reboot"
    },
    {
      name         = "lower_case_table_names"
      value        = "1"
      apply_method = "pending-reboot"
    },
    {
      name         = "skip-character-set-client-handshake"
      value        = "1"
      apply_method = "pending-reboot"
    }
  ]
}
