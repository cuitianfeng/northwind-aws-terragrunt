locals {
    tags = {
        Terraform = "true"
        Project   = local.values.project
        Env       = local.values.env
        Owners    = local.values.owners
    }
}