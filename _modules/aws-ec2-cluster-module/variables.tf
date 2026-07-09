variable "values" {
    description = ""
    type = object({
        project = string
        app = string
        env = string
        owners = string
        custom_tags   = optional(map(string))
        instance_type = string
        AllowReboot = optional(bool)
        ami_id = optional(string)
        ami_most_recent = optional(bool)
        ami_name_regex = optional(string)
        iam_instance_profile = optional(string)
        snapshort_enabled = optional(bool)
        vpc_selector = object({
            cidr_block = string
            moniker = string
        })
        subnet_selector = object({
            cidr_block = string
        })
        subnet_id = optional(string)
        associate_public_ip_address = optional(bool)
        vpc_security_group_rules = optional(string)
        vpc_security_group_ids = optional(list(string))
        private_ip = optional(string)
        private_ips = optional(list(string))
        node_indices = optional(list(string))
        key_name = optional(string)
        root_block_device = optional(object({
            encrypted   = optional(bool)
            volume_type = optional(string)
            throughput  = optional(number)
            iops        = optional(number)
            volume_size = optional(number)
        }))

        ebs_block_device = optional(map(object({
            device_name = string
            encrypted   = optional(bool)
            volume_type = optional(string)
            throughput  = optional(number)
            iops        = optional(number)
            volume_size = optional(number)
        })))
        custom_userdata = optional(string)
        role_name_suffix     = optional(string)
        custom_role_policies = optional(list(string))
        inline_role_policies = optional(list(object({
            policy_name = string
            document = string
        })))
    })
}

locals {
    values = defaults(var.values, {
        AllowReboot = false
        ami_id = ""
        ami_most_recent = true
        ami_name_regex = "amzn2-ami-hvm-2.0.*-x86_64-gp2"
        iam_instance_profile = ""
        subnet_id = ""
        associate_public_ip_address = false
        snapshort_enabled = false
        vpc_security_group_rules = ""
        vpc_security_group_ids = ""
        private_ip = ""
        private_ips = ""
        node_indices = ""
        key_name = ""
        root_block_device = {
            encrypted   = true
            volume_type = "gp3"
            throughput  = 200
            volume_size = 50
        }
        ebs_block_device = {}
        custom_userdata  = ""
        role_name_suffix     = ""
        custom_role_policies = ""
        inline_role_policies = {}
    })
}