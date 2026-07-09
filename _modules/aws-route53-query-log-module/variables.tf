variable "values" {
    description = ""
    type = object({
        name = string
    })
}

locals {
    values = defaults(var.values, {
    })
}
