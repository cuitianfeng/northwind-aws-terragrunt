variable "values" {
    description = ""
    type = object({
        cluster_id           = string
        custom_helm_releases = optional(map(object({
            namespace        = string
            create_namespace = optional(bool)
            chart            = string
            version          = string
            repository       = string
            values           = string
        })))
        custom_kubernetes_manifests = optional(map(string))
    })
}

locals {
    values = defaults(var.values, {
    })
}