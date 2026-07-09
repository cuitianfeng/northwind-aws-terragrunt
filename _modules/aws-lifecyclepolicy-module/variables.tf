
variable "values" {
    description = ""
    type = object({
        project                  = string
        owners                   = string
        env                      = string
        aws_region               = string 
        aws_account_id           = string 
        retain_days              = optional(number)
        interval                 = optional(number) 
        times                    = optional(list(string))
        interval_unit            = optional(string) 
        custom_tags   = optional(map(string))
        name = string

    })
}

locals {
    values = defaults(var.values, {
       retain_days = 14 
       interval    = 24
       interval_unit = "HOURS"
    })
}
