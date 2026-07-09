variable "values" {
    description = ""
    type = object({
        name = string
        bucket_prefix = optional(string)
        project = optional(string)
        app = optional(string)
        owners = optional(string)
        env = string
        custom_tags = optional(map(string))
        acl = optional(string)
        policy = optional(string)
        sqs_arn = optional(string)
        logging_bucket = optional(string)
        static_website_enabled = optional(bool)
        block_public_acls = optional(bool)
        block_public_policy = optional(bool)
        bucket_notification = optional(bool)
        attach_deny_insecure_transport_policy = optional(bool)
        website = optional(object({
            index_document = optional(string)
            error_document = optional(string)
            routing_rules = optional(string)
        }))
    })
}

locals {
    values = defaults(var.values, {
        bucket_prefix = "northwind"
        project = ""
        app = ""
        owners = ""
        acl = "private"
        policy = ""
        logging_bucket = ""
        static_website_enabled = false
        bucket_notification = false
        block_public_acls = false
        block_public_policy = false
        attach_deny_insecure_transport_policy = false
        website = {
            index_document = "index.html"
            error_document = "index.html"
            routing_rules  = ""
        }
    })
}