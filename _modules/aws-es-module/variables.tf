variable "values" {
    description = ""
    type = object({
        app = string
        env = string
        project = string
        owners = string
        custom_tags = optional(map(string))
        domain_name = string
        elasticsearch_version = string
        Resource = optional(string)
        cloudwatch_logs_enabled = optional(bool)  
        create_iam_service_linked_role = optional(bool)   

        cluster_config = object({
            instance_count = string
            instance_type = string
            zone_awareness_enabled = string
        })
        ebs_options = object({
            ebs_enabled = string
            volume_size = string
            volume_type = optional(string)
            iops = optional(string)
            throughput = optional(string)
        })
        snapshot_options =object({
           automated_snapshot_start_hour = string
        })
        domain_endpoint_options = object({
            enforce_https = optional(bool)
            tls_security_policy = optional(string)
        })

        vpc_selector = object({
            cidr_block = string
            moniker    = string
        })
        subnet_selector = object({
            cidr_blocks = list(string)
        })
        vpc_security_group_rules = string
    })
}

variable "extra_security_group_ids" {
  description = "A list of extra security groups to associate with the elastic network interfaces to control who can communicate with the cluster."
  type        = list(string)
  default     = []
}

locals {
    values = defaults(var.values, {
        create_iam_service_linked_role = true
        domain_endpoint_options = {
            enforce_https = true
            tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
        }
        cloudwatch_logs_enabled = false
        ebs_options = {
            iops = 3000
            throughput = 250
        }
    })
}
