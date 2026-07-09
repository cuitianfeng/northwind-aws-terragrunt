terraform {
  experiments = [module_variable_optional_attrs]
}

module "efs" {
  source  = "cloudposse/efs/aws"
  version = "0.32.7"

  name      = format("%s-%s-%s-efs", local.values.env, local.values.project, local.values.app)
  region    = local.values.region
  vpc_id    = data.aws_vpc.selected_vpc.id
  subnets   = [for subnet in data.aws_subnet.selected_subnet: subnet.id]

  create_security_group = true
  security_group_create_before_destroy = false
  allowed_security_group_ids = local.values.allowed_security_group_ids
  allowed_cidr_blocks        = local.values.allowed_cidr_blocks

  performance_mode          = local.values.performance_mode
  throughput_mode           = local.values.throughput_mode
  efs_backup_policy_enabled = local.values.efs_backup_policy_enabled
  encrypted                 = local.values.encrypted
  transition_to_ia                    = local.values.transition_to_ia
  transition_to_primary_storage_class = local.values.transition_to_primary_storage_class
  
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