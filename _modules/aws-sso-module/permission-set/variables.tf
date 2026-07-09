variable "values" {
    description = ""
    type = object({
        name             = string
        description      = optional(string)
        managed_policies = optional(list(string))
        inline_policies  = optional(list(string))
        session_duration = optional(string)
        relay_state      = optional(string)
    })
}

locals {
    values = defaults(var.values, {
        description      = "no description"
        managed_policies = ""
        inline_policies  = ""
        session_duration = "PT4H"
        relay_state      = "https://us-east-2.console.aws.amazon.com/ec2/v2/home"
    })
}