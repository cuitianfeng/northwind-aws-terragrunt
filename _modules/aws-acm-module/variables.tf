variable "values" {
    description = ""
    type = object({
        name = string
        domain = string
        owners = string
        san_prefixes = list(string)
    })
}

locals {
    values = defaults(var.values, {

    })
}