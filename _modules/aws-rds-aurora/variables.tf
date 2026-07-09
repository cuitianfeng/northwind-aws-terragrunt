variable "values" {
    description = ""
    type = object({
        project                 = string
        app                     = string
        owners                  = string
        env                     = string
        engine                  = string
        cluster_family          = string
        cluster_size            = string
        instance_type           = string
        vpc_id                  = string
        deletion_protection     = string
        autoscaling_enabled     = string
        storage_encrypted       = string
        username                = optional(string)
        maintenance_window      = optional(string)
        backup_window           = optional(string)
        backup_retention_period = optional(number)
        subnets         = list(string)
        security_groups = list(string)
    })
}

locals {
    values = defaults(var.values, {
        project               = ""
        app                   = ""
        owners                = ""
        maintenance_window    = "Mon:00:00-Mon:03:00"
        backup_window         = "03:00-06:00"
        backup_retention_period = 7
    })
}
