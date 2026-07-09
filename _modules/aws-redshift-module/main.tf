terraform {
  experiments = [module_variable_optional_attrs]
}

module "security_group" {
  source = "./aws-security-group-module"
  values = merge(
    local.values, {
      app = "${local.values.app}-redshift"
    }
  )
}

module "redshift" {
  source  = "terraform-aws-modules/redshift/aws"
  version = "v3.4.1"

  cluster_identifier      = local.values.cluster_identifier
  cluster_node_type       = local.values.cluster_node_type
  cluster_number_of_nodes = local.values.cluster_number_of_nodes

  cluster_database_name   = local.values.cluster_database_name
  cluster_master_username = local.values.cluster_master_username
  cluster_master_password = local.values.cluster_master_password

  # Snapshots and backups
     ##(1-35 days)
  automated_snapshot_retention_period = local.values.automated_snapshot_retention_period  

  # Group parameters
  wlm_json_configuration = local.values.wlm_json_configuration

  # DB Subnet Group Inputs
  subnets = [for subnet in data.aws_subnet.selected_subnet: subnet.id]
  vpc_security_group_ids = concat([module.security_group.security_group_id], local.values.extra_security_group_ids)

  # IAM Roles
  cluster_iam_roles = local.values.cluster_iam_roles

  tags = merge(
    {
      Terraform   = "true"
      Project     = local.values.project
      App         = local.values.app
      Owners      = local.values.owners
      Env         = local.values.env
    },
    { for tagname, tagvalue in local.values.custom_tags:  tagname => tagvalue if tagvalue != null && tagvalue != "" }
  )
}