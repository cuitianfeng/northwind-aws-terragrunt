variable "values" {
    description = ""
    type = object({
        env                           = string
        project                       = string
        app                           = string
        owners                        = string
        custom_tags                   = optional(map(string))

        name                          = optional(string)
        shard_count                   = number
        retention_period              = number

        shard_level_metrics           = optional(list(string))     
        enforce_consumer_deletion     = bool
        encryption_type               = optional(string)
        kms_key_id                    = optional(string) 
    })
}

locals {
    values = defaults(var.values, {
          name = "${var.values.env}-${var.values.project}-${var.values.app}-kiness-stream"
    })
}
