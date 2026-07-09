variable "values" {
    description = ""
    type = object({
        project = string
        owners  = optional(string)
        image_tag_mutability = optional(string)
        repos   = optional(map(object({
            policy_principal  = optional(string)
            keep_last         = optional(number)
        })))
    })
}

locals {
    values = defaults(var.values, {
        owners = ""
        repos  = {}
        image_tag_mutability = "MUTABLE"
    })
}