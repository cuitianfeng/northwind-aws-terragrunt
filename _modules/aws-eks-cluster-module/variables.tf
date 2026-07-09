variable "values" {
    description = ""
    type = object({
        env             = string
        project         = string
        owners          = string
        custom_tags            = optional(map(string))
        cluster_version = optional(string)
        vpc_selector    = object({
            cidr_block  = string
            moniker     = string
        })
        private_subnet_selector = object({
            cidr_blocks = list(string)
        })
        public_subnet_selector = object({
            cidr_blocks = list(string)
        })
        node_groups     = string
        map_roles       = string
        map_users       = optional(string)

        cluster_endpoint_public_access        = optional(bool)
        cluster_endpoint_private_access_sg    = optional(list(string))
        cluster_endpoint_private_access_cidrs = optional(list(string))
        iam_role_additional_policies          = optional(list(string))

        cluster_security_group_additional_rules = optional(map(object({
            description                = string
            protocol                   = string
            from_port                  = number
            to_port                    = number
            type                       = string
            cidr_blocks                = list(string)
        })))

        node_security_group_additional_rules = optional(map(object({
            description                = string
            protocol                   = string
            from_port                  = number
            to_port                    = number
            type                       = string
            cidr_blocks                = list(string)
        })))

        acm_certificate_arn  = string
        aws_cluster_autoscaler_policy_name = string 
        aws_eks_autoscaler_policy_json_default_name = string

        ingress_controller_replica_count = optional(number)
        custom_helm_releases = optional(map(object({
            namespace        = string
            create_namespace = optional(bool)
            chart            = string
            version          = string
            repository       = string
            values           = string
        })))
        helm_api_version = optional(string)
        disable_helm_resource = optional(bool) 
        disable_k8s_resource = optional(bool) 
    })
}

locals {
    values = defaults(var.values, {
        cluster_version = "1.21"
        cluster_endpoint_public_access        = false
        cluster_endpoint_private_access_sg    = ""
        cluster_endpoint_private_access_cidrs = ""
        ingress_controller_replica_count      = 2
        disable_helm_resource                 = false
        disable_k8s_resource                  = false
        map_users                             = "[]"
        aws_cluster_autoscaler_policy_name    = "AWSClusterAutoscalerIAMPolicy"
        aws_eks_autoscaler_policy_json_default_name = "aws-cluster-autoscaler-iam-policy.json"
        helm_api_version                      = "client.authentication.k8s.io/v1alpha1"
    })
}
