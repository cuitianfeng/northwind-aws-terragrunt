
variable "values" {
    description = ""
    type = object({
        iam_user_name = string
        iam_policy = string
        project                  = string
        owners                   = string
        env                      = string
        aws_region               = string 
        aws_account_id           = string
    })
}

locals {
    values = defaults(var.values, {

        
    })
}
