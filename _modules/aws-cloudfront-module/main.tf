terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  domain = trimsuffix(local.values.domain, ".")
}

module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "2.9.1"

  aliases                       = concat(["${local.values.subdomain}.${local.domain}"], local.values.aliases)
  enabled                       = true

  create_origin_access_identity = local.values.create_origin_access_identity
  origin_access_identities      = local.values.origin_access_identities
  origin                        = yamldecode(local.values.origin)
  default_cache_behavior        = yamldecode(local.values.default_cache_behavior)
  ordered_cache_behavior        = yamldecode(local.values.ordered_cache_behavior)
  default_root_object           = local.values.default_root_object
  viewer_certificate = {
    acm_certificate_arn         = local.values.acm_certificate_arn
    ssl_support_method          = "sni-only"
  }
  custom_error_response         = local.values.custom_error_response
  comment                       = local.values.comment
}
