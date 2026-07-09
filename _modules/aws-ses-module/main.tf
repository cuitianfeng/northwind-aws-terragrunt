terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  stripped_domain_name = var.values.domain_name
  mail_from_domain = var.values.from_mail_stmp
  policy_name = var.values.policy_name

  folders = [for file in fileset(var.values.template_folder, "*/*.html") : dirname(file)]

  templates = length(local.folders) > 0 ? {for folder in local.folders :
    folder => {
      "name" : format("%s-%s-%s", var.values.stage, replace(local.stripped_domain_name, ".", "-"), folder)
      "subject" : "${var.values.template_folder}/${folder}/subject.txt"
      "html" : "${var.values.template_folder}/${folder}/main.html"
    }
  } : {}
}

resource "aws_ses_domain_identity" "main" {
  domain = local.stripped_domain_name
}

resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

resource "aws_ses_domain_mail_from" "email" {
  domain           = aws_ses_domain_identity.main.domain
  mail_from_domain = local.mail_from_domain
}

data "aws_iam_policy_document" "this" {
  statement {
    actions   = [
      "ses:SendEmail", 
      "ses:SendRawEmail",
      "ses:SendTemplatedEmail",
      "ses:SendBulkTemplatedEmail"
    ]

    resources = [aws_ses_domain_identity.main.arn]

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }
}

resource "aws_ses_identity_policy" "policy" {
  identity = aws_ses_domain_identity.main.arn
  name     = local.policy_name
  policy   = data.aws_iam_policy_document.this.json
}

resource "aws_ses_template" "templates" {
  for_each = local.templates
  name    = each.value.name
  subject = file(each.value.subject)
  html    = file(each.value.html)
}
