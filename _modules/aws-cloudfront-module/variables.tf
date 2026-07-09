variable "values" {
    description = ""
    type = object({
        project                  = string
        owners                   = string
        env                      = string
        origin                   = string
        default_cache_behavior   = string
        ordered_cache_behavior   = optional(string)
        default_root_object      = optional(string)
        domain                   = string
        subdomain                = string
        aliases                  = optional(list(string))
        acm_certificate_arn      = string
        create_origin_access_identity = optional(bool)
        origin_access_identities = optional(map(string))
        custom_error_response    = optional(list(map(string)))
        comment                  = optional(string)
    })
}

locals {
    values = defaults(var.values, {
        aliases             = ""
        default_root_object = ""
        create_origin_access_identity = false
        origin_access_identities = ""
        custom_error_response = ""
        ordered_cache_behavior = "[]"
    })
}