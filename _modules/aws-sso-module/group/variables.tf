variable "values" {
    description = ""
    type = object({
        name = string
        account_assignments = map(list(string))
        organization_accounts = map(string)
    })
}

locals {
    values = defaults(var.values, {
    })
}