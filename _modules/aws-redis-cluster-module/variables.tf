variable "values" {
    description = ""
    type = object({
        project                       = string
        app                           = string
        owners                        = string
        env                           = string
        custom_tags                   = optional(map(string))
        engine_version                = optional(string)
        replication_group_description = optional(string)
        node_type                     = string
        port                          = optional(number)
        parameter_group_name          = optional(string)
        automatic_failover_enabled    = optional(bool)
        replicas_per_node_group       = optional(number)
        num_node_groups               = optional(number)
        apply_immediately             = optional(bool)

        vpc_selector = object({
            cidr_block = string
            moniker    = string
        })
        subnet_selector = object({
            cidr_blocks = list(string)
        })

        vpc_security_group_rules = string
    })
}

locals {
    values = defaults(var.values, {
        engine_version                = "5.0.6"
        replication_group_description = ""
        port                          = 6379
        parameter_group_name          = ""
        automatic_failover_enabled    = true
        replicas_per_node_group       = 1
        num_node_groups               = 2
        apply_immediately             = false
    })
}