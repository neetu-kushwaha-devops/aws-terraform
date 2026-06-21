# AWS MSK (Managed Streaming for Kafka) Terraform Module

This module provisions an AWS Managed Streaming for Kafka (MSK) cluster configured with security best-practices by default, including IAM client authentication, in-transit encryption, KMS at-rest encryption, and broker logging.

## Features

- **IAM Client Authentication**: Enabled by default (secure recommendation) alongside options for SCRAM and Mutual TLS.
- **Encryption by Default**:
  - Enforces client-to-broker TLS in-transit encryption.
  - Enforces AWS KMS encryption-at-rest (using default AWS-managed MSK KMS key or a custom key).
- **Flexible Logging**: Supports logging broker activities to Amazon CloudWatch, S3, or Kinesis Firehose.
- **Prometheus Monitoring**: Exposes JMX and Node exporter metrics for Open Monitoring.
- **MSK Configuration**: Supports custom Kafka configuration properties.

## Usage

### Simple Cluster with IAM Authentication and CloudWatch Logging

This is the recommended setup using IAM client authentication and CloudWatch logs for brokers.

```hcl
module "msk_cluster" {
  source = "./modules/msk"

  name                         = "production-kafka"
  kafka_version                = "3.4.0"
  number_of_broker_nodes       = 3
  broker_node_client_subnets  = ["subnet-12345678", "subnet-87654321", "subnet-11223344"]
  broker_node_security_groups = ["sg-987654321"]
  broker_node_instance_type    = "kafka.m5.large"
  broker_node_ebs_volume_size  = 100

  client_authentication = {
    sasl = {
      iam   = true
      scram = false
    }
    tls = null
  }

  logging_info = {
    cloudwatch_logs = {
      enabled   = true
      log_group = "/aws/msk/production-kafka"
    }
    firehose = { enabled = false }
    s3       = { enabled = false }
  }

  server_properties = {
    "auto.create.topics.enable"  = "false"
    "default.replication.factor" = "3"
    "min.insync.replicas"        = "2"
    "num.partitions"             = "3"
  }

  tags = {
    Environment = "production"
    Team        = "mlops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the MSK cluster and name prefix for related resources. | `string` | n/a | yes |
| `kafka_version` | The version of Kafka to deploy. | `string` | `"3.4.0"` | no |
| `number_of_broker_nodes` | The number of broker nodes in the cluster. Must be a multiple of the number of subnets. | `number` | `3` | no |
| `broker_node_client_subnets` | A list of subnets to connect to the MSK brokers. | `list(string)` | n/a | yes |
| `broker_node_security_groups` | A list of security groups to associate with the ENIs of MSK brokers. | `list(string)` | n/a | yes |
| `broker_node_instance_type` | The instance type to use for the MSK brokers. | `string` | `"kafka.m5.large"` | no |
| `broker_node_ebs_volume_size` | The size in GiB of the EBS volume for the data drive on each broker node. | `number` | `100` | no |
| `broker_node_ebs_provisioned_throughput` | The provisioned throughput settings for the EBS storage. | `object` | `null` | no |
| `client_authentication` | Configuration block for client authentication. Enforces secure defaults: IAM SASL enabled. | `object` | *See default in variables* | no |
| `scram_secret_arn_list` | List of Secrets Manager ARNs for SASL/SCRAM authentication. | `list(string)` | `[]` | no |
| `encryption_info` | Configuration for encryption at rest and in transit. | `object` | *See default in variables* | no |
| `logging_info` | Configuration block for broker logging. Supports CloudWatch, S3, and Firehose. | `object` | *See default in variables* | no |
| `server_properties` | A map of server properties to create the MSK configuration. | `map(string)` | `{}` | no |
| `broker_node_connectivity_info` | Connectivity settings for broker nodes. Used to configure public access or VPC connectivity. | `object` | *See default in variables* | no |
| `enhanced_monitoring` | The level of monitoring for the MSK cluster (e.g. `DEFAULT`, `PER_BROKER`). | `string` | `"DEFAULT"` | no |
| `jmx_exporter_enabled` | Enable Prometheus JMX Exporter open monitoring. | `bool` | `false` | no |
| `node_exporter_enabled` | Enable Prometheus Node Exporter open monitoring. | `bool` | `false` | no |
| `tags` | A mapping of tags to assign to the resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_arn` | The ARN of the MSK cluster. |
| `cluster_name` | The name of the MSK cluster. |
| `bootstrap_brokers` | Comma separated list of one or more plaintext broker endpoint connection strings. |
| `bootstrap_brokers_tls` | Comma separated list of one or more TLS broker endpoint connection strings. |
| `bootstrap_brokers_sasl_iam` | Comma separated list of one or more SASL/IAM broker endpoint connection strings. |
| `bootstrap_brokers_sasl_scram` | Comma separated list of one or more SASL/SCRAM broker endpoint connection strings. |
| `configuration_arn` | The ARN of the MSK configuration (if created). |
| `configuration_latest_revision` | The latest revision of the MSK configuration (if created). |
