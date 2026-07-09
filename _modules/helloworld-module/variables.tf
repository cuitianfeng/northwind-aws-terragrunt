variable "values" {
    description = ""
    type = object({
        name = optional(string)
        custome_kubernetes_manifests = optional(map(string))
        custome_helm_releases = optional(map(object({
            chart      = optional(string)
            name       = optional(string)
            namespace  = optional(string)
            version    = optional(string)
            repository = optional(string)
            values     = optional(string)
        })))
    })
}

locals {
    values = defaults(var.values, {
        name = "default_name"
    })
}