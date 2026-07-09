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

data "aws_availability_zones" "all_azs" { }