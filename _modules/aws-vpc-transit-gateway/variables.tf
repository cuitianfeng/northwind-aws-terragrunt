variable "values" {
    description = ""
    type = object({
        project         = string
        owners          = string
        env             = string
        description     = optional(string)
        amazon_side_asn = optional(string)
        share_tgw       = optional(bool)
        create_tgw      = optional(bool)
        enable_auto_accept_shared_attachments = optional(bool)
        ram_allow_external_principals         = optional(bool)
        ram_principals  = list(string)
        vpc_attachments = map(object({
            tgw_id = string
            vpc_id = string
            subnet_ids   = list(string)
            dns_support  = optional(bool)
            ipv6_support = optional(bool)
            transit_gateway_default_route_table_association = optional(bool)
            transit_gateway_default_route_table_propagation = optional(bool)
            transit_gateway_route_table_id                  = string
            tgw_routes: list(map(string))
        }))
    })
}

locals {
    values = defaults(var.values, {
    })
}