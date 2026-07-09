terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
}

resource "aws_ecr_repository" "ecr_repo" {

  for_each             = local.values.repos

  name                 = each.key
  image_tag_mutability = local.values.image_tag_mutability

  image_scanning_configuration {
    scan_on_push       = true
  }

  tags = {
    Project  = local.values.project
    App      = each.key
    Owners   = local.values.owners
  }
}

resource "aws_ecr_repository_policy" "repo_policy" {
  for_each   = local.values.repos
  repository = aws_ecr_repository.ecr_repo[each.key].name
  policy     = jsonencode(yamldecode(
                  format(file("${path.module}/repository_policy.yaml"), 
                    trimspace(lookup(each.value, "policy_principal")) == "*" ? "'*'" :
                    jsonencode(yamldecode(lookup(each.value, "policy_principal", "{}")))
                  )
                ))
}

resource "aws_ecr_lifecycle_policy" "life_cycle_policy" {
  for_each   = local.values.repos
  repository = aws_ecr_repository.ecr_repo[each.key].name
  policy     = jsonencode(yamldecode(
                  format(file("${path.module}/life_cycle_policy.yaml"), 
                  lookup(each.value, "keep_last", 10))
                ))
}