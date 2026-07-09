terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  tags = {
    Name      = format("%s-%s-%s-vpce-svc", local.values.env, local.values.project, local.values.app)
    Terraform = "true"
    Env       = local.values.env
    Project   = local.values.project
    App       = local.values.app
    Owners    = local.values.owners
  }
}

resource "aws_vpc_endpoint_service" "this" {
  acceptance_required        = local.values.acceptance_required
  allowed_principals         = local.values.allowed_principals
  network_load_balancer_arns = local.values.network_load_balancer_arns
  private_dns_name           = local.values.private_dns_name
  tags                       = local.tags
}