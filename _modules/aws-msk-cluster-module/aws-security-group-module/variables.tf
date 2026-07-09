variable "values" {
    description = ""
    type = object({
        project      = string
        app          = string
        owners       = string
        env          = string
        vpc_selector = object({
            cidr_block = string
            moniker = string
        })
        description  = optional(string)
        vpc_security_group_rules = string
    })
}

locals {
    values = defaults(var.values, {
        description  = "Security Group"
    })
}