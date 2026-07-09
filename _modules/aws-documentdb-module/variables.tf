variable "values" {
    description = ""
    type = object({
        app     = string
        env     = string
        project = string
        owners  = string
        engine_version          = optional(string)
        family                  = optional(string)
        backup_retention_period = optional(number)
        preferred_backup_window = optional(string)
        skip_final_snapshot     = optional(bool)
        vpc_selector    = object({
            cidr_block  = string
            moniker     = string
        })
        subnet_selector = object({
            cidr_blocks = list(string)
        })
        vpc_security_group_rules   = string
        apply_immediately          = optional(bool)
        instance_class             = string
        cluster_size               = number
        auto_minor_version_upgrade = optional(bool)
        cluster_parameters         = list(object({
          apply_method = optional(string)
          name         = string
          value        = string
        }))
    })
}

locals {
    values = defaults(var.values, {
        backup_retention_period = 3
        preferred_backup_window = "07:00-09:00"
        skip_final_snapshot     = true
        apply_immediately       = true
        auto_minor_version_upgrade = false
        engine_version          = "4.0.0"
        family                  = "docdb4.0"
    })
}