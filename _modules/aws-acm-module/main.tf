terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  # Removing trailing dot from domain - just to be sure :)
  domain = trimsuffix(local.values.domain, ".")
}

data "aws_route53_zone" "this" {
  name         = local.domain
}

module "acm" {

  source  = "terraform-aws-modules/acm/aws"
  version = "3.2.1"

  domain_name = local.domain
  zone_id     = coalescelist(data.aws_route53_zone.this.*.zone_id)[0]

  subject_alternative_names = [ for prefix in local.values.san_prefixes: "${prefix}.${local.domain}"]
  wait_for_validation = true

  tags = {
    Terraform = "true"
    Name = local.values.name
    Domain = local.domain
    Owners = local.values.owners
  }

}