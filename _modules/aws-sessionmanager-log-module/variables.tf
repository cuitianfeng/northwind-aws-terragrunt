
variable "values" {
    description = ""
    type = object({
        project                  = string
        owners                   = string
        env                      = string
    })
}

locals {
    values = defaults(var.values, {
    })
}
