variable "values" {
    description = ""
    type = object({
        project                 = string
        app                     = string
        owners                  = string
        env                     = string
        custom_tags             = optional(map(string))
        engine                  = string
        engine_version          = string
        family                  = string
        instance_class          = string
        username                = optional(string)
        maintenance_window      = optional(string)
        backup_window           = optional(string)
        backup_retention_period = optional(number)
        master_username         = optional(string)
        master_password         = optional(string)
        enabled_cloudwatch_logs_exports = optional(list(string))
        cloudwatch_logs_retention_in_days = optional(number)
        aws_db_pg_parameters      = optional(map(object({
            value        = string
            apply_method = string
        })))
        aws_cluster_pg_parameters = optional(map(object({
            value        = string
            apply_method = string
        })))
        vpc_selector            = object({
            cidr_block = string
            moniker    = string
        })
        subnet_selector         = object({
            cidr_blocks = list(string)
        })
        vpc_security_group_rules = string
    })
}

locals {
    values = defaults(var.values, {
        project               = ""
        app                   = ""
        owners                = ""
        master_username       = "dbadmin"
        master_password       = "changeme"
        maintenance_window    = "Mon:00:00-Mon:03:00"
        backup_window         = "03:00-06:00"
        backup_retention_period = 7
    })
}