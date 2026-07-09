variable "values" {
    description = ""
    type = object({
        project = string
        app     = string
        owners  = string
        env     = string
        custom_tags            = optional(map(string))
        load_balancer_type = optional(string)
        internal           = optional(bool)
        force_301_to_https = optional(bool)
        security_groups    = optional(list(string))
        target_groups      = optional(string)
        https_listeners    = optional(string)
        http_tcp_listeners = optional(string)
        https_listener_rules    = optional(string)
        http_tcp_listener_rules = optional(string)
        #extra_ssl_certs = optional(list(map(string)))
        extra_ssl_certs = optional(string)
        vpc_selector    = object({
            cidr_block  = string
            moniker     = string
        })
        subnet_selector = object({
            cidr_blocks = list(string)
        })
    })
}

locals {
    values = defaults(var.values, {
        load_balancer_type = "application"
        internal           = false
        force_301_to_https = true
        security_groups    = ""
        https_listeners    = "[]"
        http_tcp_listeners = "[]"
        target_groups      = "[]"
        https_listener_rules    = "[]"
        http_tcp_listener_rules = "[]"
        extra_ssl_certs = "[]"
    })
}