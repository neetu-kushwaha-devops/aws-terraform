variable "name" {
  description = "The name of the MSK cluster and name prefix for related resources."
  type        = string
}

variable "kafka_version" {
  description = "The version of Kafka to deploy."
  type        = string
  default     = "3.4.0"
}

variable "number_of_broker_nodes" {
  description = "The number of broker nodes in the MSK cluster. Must be a multiple of the number of subnets specified in broker_node_client_subnets."
  type        = number
  default     = 3
}

variable "broker_node_client_subnets" {
  description = "A list of subnets to connect to the MSK brokers."
  type        = list(string)
}

variable "broker_node_security_groups" {
  description = "A list of security groups to associate with the elastic network interfaces (ENIs) for the MSK brokers."
  type        = list(string)
}

variable "broker_node_instance_type" {
  description = "The instance type to use for the MSK brokers."
  type        = string
  default     = "kafka.m5.large"
}

variable "broker_node_ebs_volume_size" {
  description = "The size in GiB of the EBS volume for the data drive on each broker node."
  type        = number
  default     = 100
}

variable "broker_node_ebs_provisioned_throughput" {
  description = "The provisioned throughput settings for the EBS storage."
  type = object({
    enabled           = bool
    volume_throughput = number
  })
  default = null
}

variable "client_authentication" {
  description = "Configuration block for client authentication. Enforces secure defaults with IAM enabled by default."
  type = object({
    sasl = optional(object({
      iam   = optional(bool, true)
      scram = optional(bool, false)
    }), { iam = true, scram = false })
    tls = optional(object({
      certificate_authority_arns = optional(list(string), [])
    }), null)
  })
  default = {
    sasl = {
      iam   = true
      scram = false
    }
    tls = null
  }
}

variable "scram_secret_arn_list" {
  description = "List of Secrets Manager ARNs for SASL/SCRAM authentication."
  type        = list(string)
  default     = []
}

variable "encryption_info" {
  description = "Configuration for encryption at rest and in transit. Enforces secure defaults: KMS encryption-at-rest and client-to-broker TLS in-transit enabled."
  type = object({
    encryption_at_rest_kms_key_arn = optional(string, null)
    encryption_in_transit = optional(object({
      client_broker = optional(string, "TLS")
      in_cluster    = optional(bool, true)
    }), { client_broker = "TLS", in_cluster = true })
  })
  default = {
    encryption_at_rest_kms_key_arn = null
    encryption_in_transit = {
      client_broker = "TLS"
      in_cluster    = true
    }
  }
}

variable "logging_info" {
  description = "Configuration block for broker logging. Supports CloudWatch, S3, and Firehose."
  type = object({
    cloudwatch_logs = optional(object({
      enabled   = optional(bool, false)
      log_group = optional(string, null)
    }), { enabled = false, log_group = null })
    firehose = optional(object({
      enabled         = optional(bool, false)
      delivery_stream = optional(string, null)
    }), { enabled = false, delivery_stream = null })
    s3 = optional(object({
      enabled = optional(bool, false)
      bucket  = optional(string, null)
      prefix  = optional(string, null)
    }), { enabled = false, bucket = null, prefix = null })
  })
  default = {
    cloudwatch_logs = { enabled = false, log_group = null }
    firehose        = { enabled = false, delivery_stream = null }
    s3              = { enabled = false, bucket = null, prefix = null }
  }
}

variable "server_properties" {
  description = "A map of server properties to create the MSK configuration. Overrides default properties if specified."
  type        = map(string)
  default     = {}
}

variable "broker_node_connectivity_info" {
  description = "Connectivity settings for broker nodes. Used to configure public access or VPC connectivity."
  type = object({
    public_access = optional(object({
      type = optional(string, "DISABLED")
    }), { type = "DISABLED" })
  })
  default = {
    public_access = { type = "DISABLED" }
  }
}

variable "enhanced_monitoring" {
  description = "The level of monitoring for the MSK cluster. Valid values: DEFAULT, PER_BROKER, PER_TOPIC_PER_BROKER, PER_TOPIC_PER_PARTITION."
  type        = string
  default     = "DEFAULT"
}

variable "jmx_exporter_enabled" {
  description = "Enable Prometheus JMX Exporter open monitoring."
  type        = bool
  default     = false
}

variable "node_exporter_enabled" {
  description = "Enable Prometheus Node Exporter open monitoring."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A mapping of tags to assign to all resources."
  type        = map(string)
  default     = {}
}
