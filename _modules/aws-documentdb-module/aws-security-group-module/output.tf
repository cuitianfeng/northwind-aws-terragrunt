output "values" {
  value = local.values
}

output "security_group_id" {
  value = module.security_group.0.security_group_id
}