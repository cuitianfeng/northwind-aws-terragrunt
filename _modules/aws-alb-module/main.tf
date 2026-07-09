terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  name = format("%s-%s-%s-%s", local.values.env, local.values.project, local.values.app, local.values.load_balancer_type == "application" ? "alb" : "nlb")
  target_groups      = yamldecode(local.values.target_groups)
  http_tcp_listeners = yamldecode(local.values.http_tcp_listeners)
  https_listeners    = yamldecode(local.values.https_listeners)
  http_tcp_listener_rules = yamldecode(local.values.http_tcp_listener_rules)
  https_listener_rules     = yamldecode(local.values.https_listener_rules)
  extra_ssl_certs     = yamldecode(local.values.extra_ssl_certs)
  tags = {
    Terraform = "true"
    Name      = local.name
    App       = local.values.app 
    Project   = local.values.project
    Env       = local.values.env
    Owners    = local.values.owners
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "6.4.0"

  load_balancer_type = local.values.load_balancer_type

  name               = local.name
  vpc_id             = data.aws_vpc.selected_vpc.id
  subnets            = [for subnet in data.aws_subnet.selected_subnet: subnet.id]
  security_groups    = local.values.security_groups
  https_listeners    = local.https_listeners
  target_groups      = local.target_groups
  http_tcp_listeners = local.http_tcp_listeners
  internal           = local.values.internal
  extra_ssl_certs    = local.extra_ssl_certs

  https_listener_rules    = local.https_listener_rules
  http_tcp_listener_rules = local.http_tcp_listener_rules

  access_logs = {}

  tags = merge( 
    local.tags,
    { for tagname, tagvalue in local.values.custom_tags:  tagname => tagvalue if tagvalue != null && tagvalue != ""}
  )
}