variable "values" {
    description = ""
    type = object({
        env                           = string
        project                       = string
        app                           = string
        owners                        = string
        custom_tags                   = optional(map(string))

        cluster_identifier            = optional(string)
        cluster_node_type             = string
        cluster_number_of_nodes       = number
        cluster_database_name         = string     
        cluster_master_username       = string
        cluster_master_password       = string
        automated_snapshot_retention_period = optional(number) 
        cluster_iam_roles             = optional(list(string))
        wlm_json_configuration        = optional(string)

        vpc_selector = object({
            cidr_block = string
            moniker    = string
        })
        subnet_selector = object({
            cidr_blocks = list(string)
        })

        vpc_security_group_rules = string
        extra_security_group_ids = optional(list(string))
    })
}

locals {
    values = defaults(var.values, {
          cluster_identifier = "${var.values.env}-${var.values.project}-${var.values.app}-redshift"
    })
}
