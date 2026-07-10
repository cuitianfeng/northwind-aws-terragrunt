resource "aws_iam_policy" "policy" {
  count = var.create_policy ? 1 : 0

  name        = var.name
  name_prefix = var.name_prefix
  path        = var.path
  description = var.description

  policy = jsonencode(yamldecode(var.policy))

  tags = var.tags
}
