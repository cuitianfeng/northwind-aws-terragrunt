terraform {
  experiments = [module_variable_optional_attrs]
}

data "aws_vpc" "selected_vpc" {
  cidr_block = local.values.vpc_selector.cidr_block
  tags = {
    Moniker = local.values.vpc_selector.moniker
  }
}

data "aws_subnet" "selected_subnet" {
  vpc_id = data.aws_vpc.selected_vpc.id
  cidr_block = local.values.subnet_selector.cidr_block
  tags = {
  }
}

data "aws_availability_zones" "all_azs" { }

data "aws_ami" "ami" {
  owners      = ["amazon"]
  most_recent = local.values.ami_most_recent
  name_regex  = local.values.ami_name_regex
}

locals {
  instance_profile         = local.values.iam_instance_profile == "" ? "AmazonSSMRoleForInstancesQuickSetup" : local.values.iam_instance_profile
  root_block_device        = lookup(local.values, "root_block_device", {})
  create_role              = length(local.values.custom_role_policies) > 0 || length(local.values.inline_role_policies) > 0
  create_sg                = length(lookup(local.values, "vpc_security_group_rules", "")) > 0
  vpc_security_group_rules = yamldecode(local.create_sg ? lookup(local.values, "vpc_security_group_rules", "") : "{}")

}

##################################
# Launch Template
##################################

resource "aws_launch_template" "this" {
  name_prefix   = "${local.values.env}-${local.values.project}-${local.values.app}-"
  image_id      = local.values.ami_id == "" ? data.aws_ami.ami.image_id : local.values.ami_id
  instance_type = local.values.instance_type
  key_name      = local.values.key_name
  iam_instance_profile {
    name = local.create_role ? module.ec2_role[0].iam_instance_profile_name : local.instance_profile
  }
  vpc_security_group_ids = concat(
    [for sg in module.ec2_security_group : sg.security_group_id],
    local.values.vpc_security_group_ids
  )
  user_data = base64encode("${file("${path.module}/default-userdata.tpl")}${local.values.custom_userdata}")
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      encrypted   = lookup(local.root_block_device, "encrypted", true)
      volume_type = lookup(local.root_block_device, "volume_type", "gp3")
      volume_size = lookup(local.root_block_device, "volume_size", 50)
      iops        = lookup(local.root_block_device, "iops", null)
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Terraform = "true"
        Project   = local.values.project
        App       = local.values.app
        Owners    = local.values.owners
        Env       = local.values.env
      },
      {
        for tagname, tagvalue in local.values.custom_tags :
        tagname => tagvalue
        if tagvalue != null && tagvalue != ""
      }
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

## iam role

module "ec2_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "4.7.0"

  count = local.create_role ? 1 : 0

  role_name = "${local.values.env}-${local.values.project}-${local.values.app}${local.values.role_name_suffix}-ec2-role"

  create_role             = local.create_role
  create_instance_profile = true
  role_requires_mfa       = false

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  custom_role_policy_arns = concat(
    [ "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" ],
    [ for s in local.values.custom_role_policies : substr(s, 0, 12) == "arn:aws:iam:" ? s : format("arn:aws:iam::aws:policy/%s", s) ]
  )

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

resource "aws_iam_role_policy" "inline_policy" {
  role = module.ec2_role[0].iam_role_name
  for_each = { for policy in local.values.inline_role_policies: policy.policy_name => policy.document }
  name = each.key
  policy = jsonencode(yamldecode(each.value))
}

## security groups

data "aws_security_group" "ingress_source_security_groups" {
  for_each = { for i, r in lookup(local.vpc_security_group_rules, "ingress_with_source_security_group_id", []): i => r }
  vpc_id = data.aws_vpc.selected_vpc.id
  id = lookup(each.value, "source_security_group_id", null)
  tags = merge(
    { for k, v in { Env = local.values.env }: k => v if length(lookup(each.value,"source_security_group_tags",{})) > 0 },
    { for k, v in lookup(each.value,"source_security_group_tags",{}): k => v if v != null && v != "" }
  )
}

data "aws_security_group" "egress_source_security_groups" {
  for_each = { for i, r in lookup(local.vpc_security_group_rules, "egress_with_source_security_group_id", []): i => r }
  vpc_id = data.aws_vpc.selected_vpc.id
  id = lookup(each.value, "source_security_group_id", null)
  tags = merge(
    { for k, v in { Env = local.values.env }: k => v if length(lookup(each.value,"source_security_group_tags",{})) > 0 },
    { for k, v in lookup(each.value,"source_security_group_tags",{}): k => v if v != null && v != "" }
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