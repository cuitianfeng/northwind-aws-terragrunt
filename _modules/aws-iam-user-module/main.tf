
terraform {
  experiments = [module_variable_optional_attrs]
}

resource "aws_iam_user" "iam_user" {
  name = local.values.iam_user_name
}

# 创建IAM策略
resource "aws_iam_policy" "iam_policy" {
  name        = local.values.iam_user_name
  description = "iam policy for ${local.values.iam_user_name}"

  policy = jsonencode(yamldecode(local.values.iam_policy))
}

# 将IAM策略与用户关联
resource "aws_iam_user_policy_attachment" "example_attachment" {
  user       = aws_iam_user.iam_user.name
  policy_arn = aws_iam_policy.iam_policy.arn
}