variable "values" {
    description = ""
    type = object({
        env                           = string
        project                       = string
        app                           = string
        owners                        = string
        custom_tags                   = optional(map(string))
        region                        = string     
        allowed_security_group_ids    = optional(list(string))
        allowed_cidr_blocks           = list(string)
        performance_mode              = optional(string)
        throughput_mode               = optional(string)
        efs_backup_policy_enabled     = optional(bool)
        encrypted                     = optional(bool)
        transition_to_ia              = optional(list(string))
        transition_to_primary_storage_class = optional(list(string))

        vpc_selector = object({
            cidr_block = string
            moniker    = string
        })
        subnet_selector = object({
            cidr_blocks = list(string)
        })
    })
}

locals {
    values = defaults(var.values, {
    })
}
