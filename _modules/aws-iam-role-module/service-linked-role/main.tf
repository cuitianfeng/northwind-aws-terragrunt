terraform {
  experiments = [module_variable_optional_attrs]
}

resource "aws_iam_service_linked_role" "this" {
  aws_service_name = "${local.values.aws_service_name}"
  custom_suffix = "${local.values.custom_suffix}"
  description = "${local.values.description}"
  tags = {
    Terraform   = "true"
    Project     = local.values.project
    App         = local.values.app
    Owners      = local.values.owners
    Env         = local.values.env
  }
}
