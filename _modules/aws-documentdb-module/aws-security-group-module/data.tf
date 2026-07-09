data "aws_vpc" "selected_vpc" {
  cidr_block = local.values.vpc_selector.cidr_block
  tags = {
    Moniker = local.values.vpc_selector.moniker
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
