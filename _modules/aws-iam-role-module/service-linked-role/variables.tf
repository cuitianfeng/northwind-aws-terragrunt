variable "values" {
    description = ""
    type = object({
        project               = string
        app                   = string
        owners                = string
        env                   = string
        aws_service_name      = string
        custom_suffix  = optional(string)
        description    = optional(string)
    })
}

locals {
    values = defaults(var.values, {
    })
}