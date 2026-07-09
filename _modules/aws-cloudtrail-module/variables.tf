
variable "values" {
    description = ""
    type = object({
        s3_bucket_name    = optional(string)
        project                  = string
        owners                   = string
        env                      = string
        aws_region               = string 
        aws_account_id           = string 

    })
}

locals {
    values = defaults(var.values, {
        s3_bucket_name = "centrallogging-infra-northwind-cloudtrail"
    })
}
