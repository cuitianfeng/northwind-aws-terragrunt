variable "values" {
    description = ""
    type = object({
        env = string
        app = string
        project = string
        owners = string
    })
}

locals {
    values = defaults(var.values, {
    })
}