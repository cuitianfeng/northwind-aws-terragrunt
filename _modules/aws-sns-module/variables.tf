variable "values" {
  description = "Control whether or not to verify SES options."
  type = object({
      topicname               = string,
      other_account_ids       = list(string),
      email_subscriptions     = list(string)
  })
}

locals {
  values = defaults(var.values,{
  })
}


