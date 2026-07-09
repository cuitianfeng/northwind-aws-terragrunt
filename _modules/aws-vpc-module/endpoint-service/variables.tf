variable "values" {
    description = ""
    type = object({
        project                    = string
        app                        = string
        owners                     = string
        env                        = string
        acceptance_required        = optional(bool)
        allowed_principals         = list(string)
        network_load_balancer_arns = list(string)
        private_dns_name           = string
    })
}

locals {
    values = defaults(var.values, {
        acceptance_required        = false
    })
}