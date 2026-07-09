locals {
  create_sg = length(lookup(local.values, "vpc_security_group_rules", "")) > 0 ? true: false
  vpc_security_group_rules = yamldecode(local.create_sg ? lookup(local.values, "vpc_security_group_rules", "") : "{}")
}