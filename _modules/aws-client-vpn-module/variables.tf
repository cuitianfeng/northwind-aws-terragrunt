variable "values" {
    description = ""
    type = object({
        env = string
        app = string
        project = string
        owners = string
        vpc_selector = object({
            cidr_block = string
            moniker =string
        })
        subnet_selector = object({
            cidr_blocks = list(string)
        })
        vpc_security_group_rules = string
        server_certificate_arn = string
        split_tunnel = optional(bool)
        self_service_portal = optional(string)
        client_cidr_block = string
        transport_protocol = optional(string)
        saml_provider_arn = string
        self_service_saml_provider_arn = string
        authorize_rules = map(object({
            access_group_id      = optional(string)
            authorize_all_groups = optional(bool)
            description          = optional(string)
        }))
        destination_cidr_blocks = list(string)
    })
}

locals {
    values = defaults(var.values, {
        split_tunnel = false
        self_service_portal = "enabled"
        transport_protocol = "udp"
    })
}