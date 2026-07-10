include "root" {
  path = find_in_parent_folders()
}

terraform {
    source = "${dirname(find_in_parent_folders())}/_modules/aws-asg-module"
}

dependency "launch_template" {
    config_path="../launch-template"
}

dependency "alb" {
    config_path="../../../alb/nginx-alb"
}

inputs = {
  launch_template_id = dependency.launch_template.outputs.launch_template_id
  target_group_arns = [ dependency.alb.outputs.target_group_arn ]
  values = merge(
    yamldecode(file(find_in_parent_folders("env.yaml"))),
    yamldecode(file("${get_terragrunt_dir()}/values.yaml")),
  )
}