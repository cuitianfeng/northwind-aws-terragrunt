variable "values" {
  description = ""
  type = object({
    project                 = string
    app                     = string
    owners                  = string
    env                     = string
    create_role             = optional(bool)
    trusted_role_arns       = optional(list(string))
    trusted_role_services   = optional(list(string))
    trusted_role_actions    = optional(list(string))
    role_description        = optional(string)
    role_name               = optional(string)
    inline_role_policies    = optional(map(string))
    role_requires_mfa       = optional(bool)
    custom_role_policy_arns = optional(list(string))
    max_session_duration    = optional(number)
  })
}

locals {
  values = merge({
   # create_role           = true
    trusted_role_arns     = ""
    trusted_role_services = []
    role_name             = ""
    role_description      = ""
    inline_role_policies  = ""
   # role_requires_mfa     = true
  }, var.values)
}