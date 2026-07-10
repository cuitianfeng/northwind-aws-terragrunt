output "values" {
  value = local.values
}
output "launch_template_id" {
  value = aws_launch_template.this.id
}
output "launch_template_name" {
  value = aws_launch_template.this.name
}