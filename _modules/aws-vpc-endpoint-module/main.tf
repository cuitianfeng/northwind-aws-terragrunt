terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  create_sg = length(lookup(local.values, "vpc_security_group_rules", "")) > 0 ? true: false
  vpc_security_group_rules = yamldecode(local.create_sg ? lookup(local.values, "vpc_security_group_rules", "") : "{}")
}

data "aws_vpc" "selected_vpc" {
  cidr_block = local.values.vpc_selector.cidr_block
  tags = {
    Moniker = local.values.vpc_selector.moniker
  }
}

data "aws_subnet" "selected_subnet" {
  for_each   = toset(local.values.subnet_selector.cidr_blocks)
  vpc_id     = data.aws_vpc.selected_vpc.id
  cidr_block = each.key
}

module "vpc-endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "3.11.0"

  vpc_id = data.aws_vpc.selected_vpc.id
  security_group_ids = concat(
    [ for sg in module.ec2_security_group: sg.security_group_id ],
    local.values.security_group_ids
  )
  subnet_ids = [for subnet in data.aws_subnet.selected_subnet: subnet.id]

  endpoints = local.values.endpoints

  tags = {
    Terraform   = "true"
    Name        = format("%s-%s-%s-vpce", local.values.env, local.values.project, local.values.app)
    Project     = local.values.project
    App         = local.values.app
    Owners      = local.values.owners
    Env         = local.values.env
  }

}

data "aws_security_group" "ingress_source_security_groups" {
  for_each = { for i, r in lookup(local.vpc_security_group_rules, "ingress_with_source_security_group_id", []): i => r }
  vpc_id = data.aws_vpc.selected_vpc.id
  id = lookup(each.value, "source_security_group_id", null)
  tags = merge(
    { for k, v in { Env = local.values.env }: k => v if length(each.value.source_security_group_tags) > 0 },
    { for k, v in each.value.source_security_group_tags: k => v if v != null && v != "" }
  )
}

data "aws_security_group" "egress_source_security_groups" {
  for_each = { for i, r in lookup(local.vpc_security_group_rules, "egress_with_source_security_group_id", []): i => r }
  vpc_id = data.aws_vpc.selected_vpc.id
  id = lookup(each.value, "source_security_group_id", null)
  tags = merge(
    { for k, v in { Env = local.values.env }: k => v if length(each.value.source_security_group_tags) > 0 },
    { for k, v in each.value.source_security_group_tags: k => v if v != null && v != "" }
  )
}

module "ec2_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.4.0"

  count = local.create_sg ? 1 : 0

  name = "${local.values.env}-${local.values.project}-${local.values.app}-sg"
  description = "Security group for EC2 "
  vpc_id = data.aws_vpc.selected_vpc.id
  use_name_prefix = true

  ingress_with_cidr_blocks = lookup(local.vpc_security_group_rules, "ingress_with_cidr_blocks", [])
  ingress_with_self = lookup(local.vpc_security_group_rules, "ingress_with_self", [])
  ingress_with_source_security_group_id = [
    for i,r in lookup(local.vpc_security_group_rules, "ingress_with_source_security_group_id", []): 
    merge({
      source_security_group_id = data.aws_security_group.ingress_source_security_groups[i].id
    }, {
      for k, v in r : k => v if k != "source_security_group_tags"
    })
  ]

  egress_with_cidr_blocks = lookup(local.vpc_security_group_rules, "egress_with_cidr_blocks", [])
  egress_with_self = lookup(local.vpc_security_group_rules, "egress_with_self", [])
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
