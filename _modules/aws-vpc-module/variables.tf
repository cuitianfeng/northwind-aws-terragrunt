variable "values" {
    description = ""
    type = object({
        moniker                 = string
        owners                  = string
        env                     = string
        cidr                    = string
        private_subnets         = list(string)
        public_subnets          = list(string)
        database_subnets        = optional(list(string))
        elasticache_subnets     = optional(list(string))
        redshift_subnets        = optional(list(string))
        redshift_subnet_suffix  = optional(string)
        create_redshift_subnet_route_table = optional(bool)
        intra_subnets           = optional(list(string))
        intra_subnet_suffix     = optional(string)
        private_subnet_tags     = optional(map(string))
        public_subnet_tags      = optional(map(string))
        database_subnet_tags    = optional(map(string))
        redshift_subnet_tags    = optional(map(string))
        elasticache_subnet_tags = optional(map(string))
        intra_subnet_tags       = optional(map(string))
        enable_nat_gateway      = optional(bool)
        single_nat_gateway      = optional(bool)
        one_nat_gateway_per_az  = optional(bool)
        enable_dns_hostnames    = optional(bool)
        enable_dns_support      = optional(bool)
        azs                     = optional(list(string))
    })
}

locals {
    values = defaults(var.values, {
        enable_nat_gateway      = true
        single_nat_gateway      = false
        one_nat_gateway_per_az  = false
        enable_dns_hostnames    = false
        enable_dns_support      = true
        database_subnets        = ""
        elasticache_subnets     = ""
        create_redshift_subnet_route_table = false
    })
}