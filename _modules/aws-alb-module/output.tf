output "values" {
  value = local.values
}


output "target_group_arn" {
  value = values(module.alb.target_groups)[0].arn
}