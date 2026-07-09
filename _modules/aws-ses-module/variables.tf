variable "values" {
  description = "Control whether or not to verify SES options."
  type = object({
      domain_name=string
      from_mail_stmp=string
      policy_name=string
      stage=string
      template_folder=string
  })
}

locals {
  values = defaults(var.values,{
  })
}
