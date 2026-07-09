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
  name_regex = local.values.ami_name_regex
}

locals {
  node_indices = length(local.values.node_indices) > 0 ? local.values.node_indices : ["-1"]
  private_ips = length(local.values.node_indices) > 0 ? local.values.private_ips : [local.values.private_ip]
  instance_profile = local.values.iam_instance_profile == "" ? "AmazonSSMRoleForInstancesQuickSetup" : local.values.iam_instance_profile
  root_block_device = lookup(local.values, "root_block_device", {})
  ebs_block_device = lookup(local.values, "ebs_block_device", {})
  create_role = length(local.values.custom_role_policies) > 0 || length(local.values.inline_role_policies) > 0 ? true : false
  create_sg = length(lookup(local.values, "vpc_security_group_rules", "")) > 0 ? true: false
  vpc_security_group_rules = yamldecode(local.create_sg ? lookup(local.values, "vpc_security_group_rules", "") : "{}")
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.2.0"

  for_each = toset(local.node_indices)

  name = "${local.values.env}-${local.values.project}-${local.values.app}${each.key=="-1" ? "": format("-%s",each.key)}"
  ami = local.values.ami_id == "" ? data.aws_ami.ami.image_id : local.values.ami_id
  instance_type = local.values.instance_type
  associate_public_ip_address = local.values.associate_public_ip_address
  iam_instance_profile = local.create_role ? module.ec2_role[0].iam_instance_profile_name : local.instance_profile
  subnet_id = data.aws_subnet.selected_subnet.id
  vpc_security_group_ids = concat(
    [ for sg in module.ec2_security_group: sg.security_group_id ],
    local.values.vpc_security_group_ids
  )
  private_ip = local.private_ips[index(local.node_indices, each.key)]
  key_name = local.values.key_name
  user_data = "${file("${path.module}/default-userdata.tpl")}${local.values.custom_userdata}"
  root_block_device = [
    {
      encrypted   = lookup(local.root_block_device, "encrypted", true)
      volume_type = lookup(local.root_block_device, "volume_type", "gp3")
      throughput  = lookup(local.root_block_device, "throughput", "200")
      iops        = lookup(local.root_block_device, "iops", null)
      volume_size = lookup(local.root_block_device, "volume_size", "50")
    }
  ]

  ebs_block_device = [
    for name, device in local.ebs_block_device: {
      device_name = lookup(device, "device_name")
      encrypted   = lookup(device, "encrypted", true)
      volume_type = lookup(device, "volume_type", "gp3")
      throughput  = lookup(device, "throughput", "200")
      iops        = lookup(device, "iops", null)
      volume_size = lookup(device, "volume_size", "100")
    }
  ]
  
  volume_tags = merge(
    {
      Terraform   = "true"
      Project     = local.values.project
      App         = local.values.app
      Owners      = local.values.owners
      Env         = local.values.env
    },
    { for tagname, tagvalue in local.values.custom_tags:  tagname => tagvalue if tagvalue != null && tagvalue != ""}
  )

  tags = merge(
    {
      Terraform   = "true"
      Project     = local.values.project
      App         = local.values.app
      Owners      = local.values.owners
      Env         = local.values.env
      snapshort_enabled = local.values.snapshort_enabled
      AllowReboot = local.values.AllowReboot
    },
    { for tagname, tagvalue in local.values.custom_tags:  tagname => tagvalue if tagvalue != null && tagvalue != ""}
  )
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


// module "elb" {
//   source  = "terraform-aws-modules/alb/aws"
//   version = "3.0.0"
//   # insert the 6 required variables here
// }

// module "alb-security-group" {
//   source  = "terraform-aws-modules/security-group/aws"
//   version = "4.4.0"
// }

// module "nlb" {
//   source  = "terraform-aws-modules/alb/aws"
//   version = "3.0.0"
//   # insert the 6 required variables here
// }

// output "instance_profile" {
//   value = local.instance_profile
// }