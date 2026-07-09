terraform {
  experiments = [module_variable_optional_attrs]
}

data "aws_ssoadmin_instances" "this" {}

resource "aws_ssoadmin_permission_set" "this" {
  name             = local.values.name
  description      = local.values.description
  instance_arn     = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  relay_state      = local.values.relay_state
  session_duration = local.values.session_duration
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each           = toset(lookup(local.values, "managed_policies", []))
  managed_policy_arn = format("arn:aws:iam::aws:policy/%s", each.key)
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
}

resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each           = toset(lookup(local.values, "inline_policies", []))
  inline_policy      = jsonencode(yamldecode(each.key))
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
}