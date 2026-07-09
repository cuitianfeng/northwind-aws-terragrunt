
variable "values" {
    description = ""
    type = object({
        max_message_size    = optional(string)
        message_retention_seconds = optional(string)
        sqs_name = string
        sqs_policy = string
        project                  = string
        owners                   = string
        env                      = string
        aws_region               = string 
        aws_account_id           = string
        sqs_policy               = string 
    })
}

locals {
    values = defaults(var.values, {
        max_message_size = 262144
        message_retention_seconds = 345600
        
    })
}
