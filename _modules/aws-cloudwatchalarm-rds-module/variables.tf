variable "values" {
  description = "Control whether or not to verify SES options."
  type = object({
      threshold               = optional(string),
      period                  = optional(string),
      db_instances            = list(string)
      topic_arn               = optional(string)
  })
}

locals {
  values = defaults(var.values,{
    threshold              = 10,
    period                = 300,
    topic_arn = "arn:aws:sns:us-east-2:927701870438:devops-monitor"
  })
}


