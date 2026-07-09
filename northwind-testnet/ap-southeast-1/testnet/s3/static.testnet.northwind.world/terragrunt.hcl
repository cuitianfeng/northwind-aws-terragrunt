include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${dirname(find_in_parent_folders())}/_modules/aws-s3-bucket-module"
}

inputs = {
  values = merge(
    yamldecode(file(find_in_parent_folders("env.yaml"))),
    yamldecode(file("${get_terragrunt_dir()}/values.yaml")),
  )
}