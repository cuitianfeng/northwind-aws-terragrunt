variable "values" {
    description = ""
    type = object({
        project          = string
        app              = string
        owners           = string
        env              = string
        // role_policy_arns = optional(list(string))
        inline_role_policies          = optional(map(string))
        oidc_fully_qualified_subjects = optional(list(string))
        // oidc_subjects_with_wildcards  = optional(list(string))
    })
}

locals {
    values = merge({
    },var.values)
}