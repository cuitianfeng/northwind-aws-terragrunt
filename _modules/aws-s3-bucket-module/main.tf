terraform {
  experiments = [module_variable_optional_attrs]
}

resource "aws_s3_bucket_notification" "cloudtrail_s3_notification" {
  count = local.values.bucket_notification ? 1 : 0
  bucket = module.s3_bucket.s3_bucket_id
  queue {
    queue_arn     = local.values.sqs_arn
    events        = ["s3:ObjectCreated:*"]  # 
  }
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.11.1"

  bucket = local.values.static_website_enabled ? local.values.name : "${local.values.bucket_prefix}-${local.values.env}-${local.values.project}-${local.values.name}"

  acl = local.values.acl

  block_public_acls = local.values.block_public_acls
  block_public_policy = local.values.block_public_policy

  attach_policy = local.values.policy != ""

  policy = local.values.policy !="" ? jsonencode(yamldecode(local.values.policy)) : null

  attach_deny_insecure_transport_policy = local.values.attach_deny_insecure_transport_policy

  website = local.values.static_website_enabled ? {
    index_document = local.values.website.index_document
    error_document = local.values.website.error_document
    routing_rules  = length(local.values.website.routing_rules) > 1 ? jsonencode(yamldecode(local.values.website.routing_rules)) : null
  } : tomap({})

  // logging = {
  //   target_bucket = 
  //   target_prefix = "s3/"
  // }

  tags = merge(
    {
      Terraform   = "true"
      Project     = local.values.project
      Owners      = local.values.owners
      Env         = local.values.env
    },
    { for tagname, tagvalue in local.values.custom_tags:  tagname => tagvalue if tagvalue != null && tagvalue != ""}
  )
}