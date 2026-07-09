terraform {
  experiments = [module_variable_optional_attrs]
}

module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "4.7.0"

  create_role           = local.values.create_role
  role_name             = local.values.role_name !="" ? local.values.role_name : "${local.values.env}-${local.values.project}-${local.values.app}-role"
  trusted_role_arns     = local.values.trusted_role_arns
  trusted_role_services = local.values.trusted_role_services
  trusted_role_actions  = local.values.trusted_role_actions
  role_requires_mfa     = local.values.role_requires_mfa
  custom_role_policy_arns = local.values.custom_role_policy_arns
  max_session_duration = local.values.max_session_duration

  tags = {
    Terraform   = "true"
    Project     = local.values.project
    App         = local.values.app
    Owners      = local.values.owners
    Env         = local.values.env
  }
}

resource "aws_iam_role_policy" "inline_policy" {
  for_each = local.values.inline_role_policies
  name     = each.key
  role     = module.iam_assumable_role.iam_role_name
  policy   = jsonencode(yamldecode(each.value))
}