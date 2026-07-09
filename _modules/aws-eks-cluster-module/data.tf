data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "selected_vpc" {
  cidr_block = local.values.vpc_selector.cidr_block
  tags       = {
    Moniker = local.values.vpc_selector.moniker
  }
}

data "aws_subnet" "selected_private_subnet" {
  for_each   = toset(local.values.private_subnet_selector.cidr_blocks)
  vpc_id     = data.aws_vpc.selected_vpc.id
  cidr_block = each.key
}

data "aws_subnet" "selected_public_subnet" {
  for_each   = toset(local.values.public_subnet_selector.cidr_blocks)
  vpc_id     = data.aws_vpc.selected_vpc.id
  cidr_block = each.key
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

data "external" "thumbprint" {
  program = ["${path.module}/get_thumbprint.sh", data.aws_region.current.name]
}