terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  create_sg = length(lookup(local.values, "vpc_security_group_rules", "")) > 0 ? true: false
  vpc_security_group_rules = yamldecode(local.create_sg ? lookup(local.values, "vpc_security_group_rules", "") : "{}")
  subnet_cidr_blocks = local.values.subnet_selector.cidr_blocks
  routes = flatten([
    for destination_cidr_block in local.values.destination_cidr_blocks : [ 
      for subnet_index, subnet_cidr_block in local.subnet_cidr_blocks: {
        destination_cidr_block = destination_cidr_block
        subnet_cidr_block           = subnet_cidr_block
      }
    ]
  ])
  routes_map = { 
    for route in local.routes: format("%s-via-%s", route.destination_cidr_block, route.subnet_cidr_block) => {
        destination_cidr_block = route.destination_cidr_block
        subnet_cidr_block      = route.subnet_cidr_block 
    }
   }
}

data "aws_vpc" "selected_vpc" {
  cidr_block = local.values.vpc_selector.cidr_block
  tags = {
    Moniker = local.values.vpc_selector.moniker
  }
}

data "aws_subnet" "selected_subnet" {
  for_each = toset(local.values.subnet_selector.cidr_blocks)
  vpc_id = data.aws_vpc.selected_vpc.id
  cidr_block = each.key
}

resource "aws_ec2_client_vpn_endpoint" "this" {
  description            = ""
  server_certificate_arn = local.values.server_certificate_arn
  self_service_portal    = local.values.self_service_portal
  split_tunnel           = local.values.split_tunnel
  client_cidr_block      = local.values.client_cidr_block
  transport_protocol     = local.values.transport_protocol

  authentication_options {
    type                            = "federated-authentication"
    saml_provider_arn               = local.values.saml_provider_arn
    self_service_saml_provider_arn  = local.values.self_service_saml_provider_arn
  }

  connection_log_options {
    enabled = false
  }

  tags = {
      Terraform = "true"
      Name      = format("%s-%s-%s",local.values.env, local.values.project, local.values.app)
  }
}

resource "aws_ec2_client_vpn_network_association" "this" {
  for_each               = toset(local.values.subnet_selector.cidr_blocks)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = data.aws_subnet.selected_subnet[each.key].id
  security_groups        = [module.vpn_endpoint_security_group[0].security_group_id]
}

resource "aws_ec2_client_vpn_authorization_rule" "this" {
  for_each               = local.values.authorize_rules
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = each.key
  authorize_all_groups   = each.value.authorize_all_groups
  access_group_id        = each.value.access_group_id
  description            = each.value.description
}

resource "aws_ec2_client_vpn_route" "this" {
  for_each               = local.routes_map
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  destination_cidr_block = each.value.destination_cidr_block
  target_vpc_subnet_id   = data.aws_subnet.selected_subnet[each.value.subnet_cidr_block].id
  description            = each.key
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

module "vpn_endpoint_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.4.0"

  count = local.create_sg ? 1 : 0
  name = "${local.values.env}-${local.values.project}-${local.values.app}-sg"
  description = "Security group for Client VPN"
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
    for i,r in lookup(local.vpc_security_group_rules, "ingress_with_source_security_group_id", []): 
    merge({
      source_security_group_id = data.aws_security_group.ingress_source_security_groups[i].id
    }, {
      for k, v in r : k => v if k != "source_security_group_tags"
    })
  ]

  tags = {
    Terraform   = "true"
    Project     = local.values.project
    App         = local.values.app
    Env         = local.values.env
    Owners      = local.values.owners
  }
}