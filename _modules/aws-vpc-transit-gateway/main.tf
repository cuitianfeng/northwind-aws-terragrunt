terraform {
  experiments = [module_variable_optional_attrs]
}

module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "2.5.1"

  name            = "${local.values.env}-${local.values.project}-tgw"
  description     = local.values.description
  amazon_side_asn = local.values.amazon_side_asn
  share_tgw       = local.values.share_tgw
  create_tgw      = local.values.create_tgw
  enable_auto_accept_shared_attachments = true
  ram_allow_external_principals         = true
  ram_principals                        = local.values.ram_principals

  vpc_attachments = local.values.vpc_attachments

  tags = local.tags
}