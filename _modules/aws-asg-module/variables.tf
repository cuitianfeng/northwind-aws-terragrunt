variable "values" {
  description = "ASG configuration"
  type = object({
    project = string
    app     = string
    env     = string
    owners  = string
    vpc_selector = object({
      cidr_block = string
      moniker    = string
    })
    subnet_selector = object({
      cidr_blocks = list(string)
    })
    min_size                  = optional(number)
    max_size                  = optional(number)
    desired_capacity          = optional(number)
    health_check_type         = optional(string)
    health_check_grace_period = optional(number)
    default_cooldown          = optional(number)
    termination_policies      = optional(list(string))
    enabled_metrics           = optional(list(string))
    protect_from_scale_in     = optional(bool)
    force_delete              = optional(bool)
    wait_for_capacity_timeout = optional(string)
    custom_tags               = optional(map(string))
  })
}

variable "launch_template_id" {
  description = "Launch template id"
  type        = string
}

variable "target_group_arns" {
  description = "ALB target group arns"
  type        = list(string)
  default     = []
}

locals {
  values = defaults(var.values, {
    min_size                  = 1
    max_size                  = 3
    desired_capacity          = 1
    health_check_type         = "EC2"
    health_check_grace_period = 300
    termination_policies = [
      "OldestInstance"
    ]
    enabled_metrics           = []
    protect_from_scale_in     = false
    force_delete              = false
    default_cooldown          = 300
    wait_for_capacity_timeout = "10m"
    custom_tags               = {}
  })
}