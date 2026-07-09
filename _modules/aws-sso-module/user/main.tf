terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  permission_sets = flatten([for account, ps in local.values.account_assignments: ps])
  account_assignments = flatten([for account, permission_sets in local.values.account_assignments: [
                          for permission_set in permission_sets: {
                            account        = account
                            permission_set = permission_set
                          } 
                       ]])
}

data "aws_ssoadmin_instances" "this" {}

data "aws_ssoadmin_permission_set" "this" {
  for_each           = toset(local.permission_sets)
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  name               = each.key
}

data "aws_identitystore_user" "this" {
  identity_store_id  = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  filter {
    attribute_path   = "UserName"
    attribute_value  = local.values.name
  }
}

resource "aws_ssoadmin_account_assignment" "this" {
  for_each           = { for i,as in local.account_assignments: i => as }
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = data.aws_ssoadmin_permission_set.this[each.value.permission_set].arn

  principal_id       = data.aws_identitystore_user.this.user_id
  principal_type     = "USER"

  target_id          = lookup(local.values.organization_accounts, each.value.account)
  target_type        = "AWS_ACCOUNT"
}