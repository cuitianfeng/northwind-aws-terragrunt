variable "values" {
  type = object({
    cluster_name = optional(string)
    instance_type = string
    kafka_version = string
    number_of_nodes = number
    volume_size = number
    client_subnets = optional(list(string))
    prometheus_node_exporter = optional(bool)
    prometheus_jmx_exporter = optional(bool)
    cloudwatch_logs = optional(bool)
    server_properties = optional(map(string))

    project                       = string
    app                           = string
    owners                        = string
    env                           = string
    custom_tags                   = optional(map(string))
    vpc_selector = object({
        cidr_block = string
        moniker    = string
    })
    subnet_selector = object({
        cidr_blocks = list(string)
    })
    vpc_security_group_rules = string
  })
}

locals {
  values = defaults(var.values,{
    cluster_name = "${var.values.env}-${var.values.project}-${var.values.app}-msk"
    prometheus_jmx_exporter = false
    prometheus_node_exporter = false
    cloudwatch_logs         = false
  })
}

/*
variable "client_subnets" {
  description = "A list of subnets to connect to in client VPC"
  type        = list(string)
  default = ["subnet-01d6235fb6bd06507","subnet-0d9c30c9b617700b2","subnet-0d3dd2b8b02113789"]
}
*/

variable "extra_security_groups" {
  description = "A list of extra security groups to associate with the elastic network interfaces to control who can communicate with the cluster."
  type        = list(string)
  default     = []
}

variable "enhanced_monitoring" {
  description = "Specify the desired enhanced MSK CloudWatch monitoring level to one of three monitoring levels: DEFAULT, PER_BROKER, PER_TOPIC_PER_BROKER or PER_TOPIC_PER_PARTITION. See [Monitoring Amazon MSK with Amazon CloudWatch](https://docs.aws.amazon.com/msk/latest/developerguide/monitoring.html)."
  type        = string
  default     = "DEFAULT"
}

variable "prometheus_jmx_exporter" {
  description = "Indicates whether you want to enable or disable the JMX Exporter."
  type        = bool
  default     = false
}

variable "prometheus_node_exporter" {
  description = "Indicates whether you want to enable or disable the Node Exporter."
  type        = bool
  default     = false
}

variable "server_properties" {
  description = "A map of the contents of the server.properties file. Supported properties are documented in the [MSK Developer Guide](https://docs.aws.amazon.com/msk/latest/developerguide/msk-configuration-properties.html)."
  type        = map(string)
  default     = {}
}

variable "encryption_at_rest_kms_key_arn" {
  description = "You may specify a KMS key short ID or ARN (it will always output an ARN) to use for encrypting your data at rest. If no key is specified, an AWS managed KMS ('aws/msk' managed service) key will be used for encrypting the data at rest."
  type        = string
  default     = ""
}

variable "encryption_in_transit_client_broker" {
  description = "Encryption setting for data in transit between clients and brokers. Valid values: TLS, TLS_PLAINTEXT, and PLAINTEXT. Default value is TLS_PLAINTEXT."
  type        = string
  default     = "TLS_PLAINTEXT"
}

variable "encryption_in_transit_in_cluster" {
  description = "Whether data communication among broker nodes is encrypted. Default value: true."
  type        = bool
  default     = true
}

variable "cloudwatch_logs_group" {
  description = "Name of the Cloudwatch Log Group to deliver logs to."
  type        = string
  default     = ""
}

variable "firehose_logs_delivery_stream" {
  description = "Name of the Kinesis Data Firehose delivery stream to deliver logs to."
  type        = string
  default     = ""
}
