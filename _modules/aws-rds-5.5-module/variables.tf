variable "values" {
    description = ""
    type = object({
        project                 = string
        app                     = string
        owners                  = string
        env                     = string
        engine                  = string
        engine_version          = string
        family                  = string
        major_engine_version    = string
        allocated_storage       = optional(number)
        max_allocated_storage   = optional(number)
        storage_type            = optional(string)
        instance_class          = string
        username                = optional(string)
        performance_insights_enabled = optional(bool)
        performance_insights_kms_key_id = optional(string)
        performance_insights_retention_period = optional(number)
        maintenance_window      = optional(string)
        backup_window           = optional(string)
        backup_retention_period = optional(number)
        vpc_selector            = object({
            cidr_block = string
            moniker    = string
        })
        subnet_selector         = object({
            cidr_blocks = list(string)
        })
        vpc_security_group_rules = string
        parameters               = optional(list(object({
            name = string
            value = string
            apply_method = string
        })))
    })
}

locals {
    values = defaults(var.values, {
        project               = ""
        app                   = ""
        owners                = ""
        allocated_storage     = 100
        max_allocated_storage = 1000
        storage_type          = "gp2"
        username              = "dbadmin"
        performance_insights_enabled = false
        performance_insights_kms_key_id = ""
        performance_insights_retention_period = 7
        maintenance_window    = "Mon:00:00-Mon:03:00"
        backup_window         = "03:00-06:00"
        backup_retention_period = 7
    })
}