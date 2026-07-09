terraform {
  experiments = [module_variable_optional_attrs]
}

module "iam_assumable_role_with_oidc" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  role_name        = "${local.values.env}-${local.values.project}-${local.values.app}-role"

  create_role      = true
  role_policy_arns = local.values.role_policy_arns
  provider_url     = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
  oidc_fully_qualified_subjects = local.values.oidc_fully_qualified_subjects 
  oidc_subjects_with_wildcards = local.values.oidc_subjects_with_wildcards
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
  role     = module.iam_assumable_role_with_oidc.iam_role_name
  policy   = jsonencode(yamldecode(each.value))
}
