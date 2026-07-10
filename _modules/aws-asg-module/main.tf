terraform {
  experiments = [module_variable_optional_attrs]
}

data "aws_vpc" "selected_vpc" {
  cidr_block = var.values.vpc_selector.cidr_block
  tags = {
    Moniker = var.values.vpc_selector.moniker
  }
}
data "aws_subnet" "selected_subnet" {
  for_each = toset(
    var.values.subnet_selector.cidr_blocks
  )
  vpc_id     = data.aws_vpc.selected_vpc.id
  cidr_block = each.value
}

locals {
  subnet_ids = [
    for subnet in data.aws_subnet.selected_subnet :
    subnet.id
  ]
}

resource "aws_autoscaling_group" "this" {
  name                      = format("%s-%s-%s-asg", local.values.env, local.values.project, local.values.app)
  min_size                  = local.values.min_size
  max_size                  = local.values.max_size
  desired_capacity          = local.values.desired_capacity
  vpc_zone_identifier       = local.subnet_ids
  health_check_type         = local.values.health_check_type
  health_check_grace_period = local.values.health_check_grace_period
  default_cooldown          = local.values.default_cooldown
  target_group_arns         = var.target_group_arns
  termination_policies      = local.values.termination_policies
  enabled_metrics           = local.values.enabled_metrics
  protect_from_scale_in     = local.values.protect_from_scale_in
  force_delete              = local.values.force_delete
  wait_for_capacity_timeout = local.values.wait_for_capacity_timeout

  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(
      {
        Name      = format("%s-%s-%s", local.values.env, local.values.project, local.values.app)
        Terraform = "true"
        Project   = local.values.project
        App       = local.values.app
        Env       = local.values.env
        Owners    = local.values.owners
      },
      local.values.custom_tags
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
    }
    triggers = [
      "launch_template"
    ]
  }
}