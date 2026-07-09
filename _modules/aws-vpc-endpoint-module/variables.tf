variable "values" {
    description = ""
    type = object({
        project = string
        app     = string
        owners  = string
        env     = string
        vpc_selector = object({
            cidr_block = string
            moniker    = string
        })
        subnet_selector = object({
            cidr_blocks = list(string)
        })
        vpc_security_group_rules = optional(string)
        security_group_ids       = optional(list(string))
        endpoints = map(object({
            service             = optional(string)
            service_name        = optional(string)
            service_type        = optional(string)
            route_table_ids     = optional(list(string))
            subnet_ids          = optional(list(string))
            private_dns_enabled = optional(bool)
        }))
    })
}

locals {
    values = defaults(var.values, {
        vpc_security_group_rules = ""
        security_group_ids = ""
    })
}