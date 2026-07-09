terraform {
  experiments = [module_variable_optional_attrs]
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.4.0"

  count = local.create_sg ? 1 : 0

  name            = "${local.values.env}-${local.values.project}-${local.values.app}-sg"
  description     = local.values.description
  vpc_id          = data.aws_vpc.selected_vpc.id
  use_name_prefix = true

  ingress_with_cidr_blocks = lookup(local.vpc_security_group_rules, "ingress_with_cidr_blocks", [])
  ingress_with_self        = lookup(local.vpc_security_group_rules, "ingress_with_self", [])
  ingress_with_source_security_group_id = [
    for i,r in lookup(local.vpc_security_group_rules, "ingress_with_source_security_group_id", []): 
    merge({
      source_security_group_id = data.aws_security_group.ingress_source_security_groups[i].id
    }, {
      for k, v in r : k => v if k != "source_security_group_tags"
    })
  ]

  egress_with_cidr_blocks = lookup(local.vpc_security_group_rules, "egress_with_cidr_blocks", [])
  egress_with_self        = lookup(local.vpc_security_group_rules, "egress_with_self", [])
  egress_with_source_security_group_id = [
    for i,r in lookup(local.vpc_security_group_rules, "egress_with_source_security_group_id", []): 
    merge({
      source_security_group_id = data.aws_security_group.egress_source_security_groups[i].id
    }, {
      for k, v in r : k => v if k != "source_security_group_tags"
    })
  ]

  tags = {
    Terraform   = "true"
    Project     = local.values.project
    App         = local.values.app
    Owners      = local.values.owners
    Env         = local.values.env
  }
}
