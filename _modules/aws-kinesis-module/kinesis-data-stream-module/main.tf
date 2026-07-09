terraform {
  experiments = [module_variable_optional_attrs]
}

module "kinesis-stream" {
  source  = "rodrigodelmonte/kinesis-stream/aws"
  version = "v2.0.3"

  name                      = local.values.name
  shard_count               = local.values.shard_count
  retention_period          = local.values.retention_period
  shard_level_metrics       = local.values.shard_level_metrics
  enforce_consumer_deletion = local.values.enforce_consumer_deletion
  encryption_type           = local.values.encryption_type
  kms_key_id                = local.values.kms_key_id
  tags = merge(
    {
      Terraform = "true"
      Project     = local.values.project
      App         = local.values.app
      Owners      = local.values.owners
      Env         = local.values.env
    },
    { for tagname, tagvalue in local.values.custom_tags:  tagname => tagvalue if tagvalue != null && tagvalue != ""}
  )  
}