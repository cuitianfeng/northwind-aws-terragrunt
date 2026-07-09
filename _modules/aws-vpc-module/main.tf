terraform {
  experiments = [module_variable_optional_attrs]
}

data "aws_availability_zones" "all_azs" { }

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "3.11.0"

    name = "${local.values.env}-${local.values.moniker}-vpc"
    cidr = local.values.cidr
    azs  = length(local.values.azs) > 0 ? local.values.azs : data.aws_availability_zones.all_azs.names
    private_subnets         = local.values.private_subnets
    public_subnets          = local.values.public_subnets
    database_subnets        = local.values.database_subnets
    elasticache_subnets     = local.values.elasticache_subnets
    redshift_subnets        = local.values.redshift_subnets
    redshift_subnet_suffix  = local.values.redshift_subnet_suffix
    create_redshift_subnet_route_table = local.values.create_redshift_subnet_route_table
    intra_subnets           = local.values.intra_subnets
    intra_subnet_suffix     = local.values.intra_subnet_suffix
    private_subnet_tags     = local.values.private_subnet_tags
    public_subnet_tags      = local.values.public_subnet_tags
    database_subnet_tags    = local.values.database_subnet_tags
    redshift_subnet_tags    = local.values.redshift_subnet_tags
    elasticache_subnet_tags = local.values.elasticache_subnet_tags
    intra_subnet_tags       = local.values.intra_subnet_tags    
    enable_nat_gateway      = local.values.enable_nat_gateway
    single_nat_gateway      = local.values.single_nat_gateway
    one_nat_gateway_per_az  = local.values.one_nat_gateway_per_az
    enable_dns_hostnames    = local.values.enable_dns_hostnames
    enable_dns_support      = local.values.enable_dns_support

    tags = {
        Terraform = "true"
        Env       = local.values.env
        Owners    = local.values.owners
        Moniker   = local.values.moniker
    }
}