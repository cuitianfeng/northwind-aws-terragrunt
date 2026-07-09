
terraform {
  experiments = [module_variable_optional_attrs]
}


resource "aws_cloudtrail" "account-cloudtrail" {
  name                          = "cloudtrail"
  s3_bucket_name                = local.values.s3_bucket_name
  s3_key_prefix                 = local.values.aws_account_id
}