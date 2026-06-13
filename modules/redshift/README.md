# Redshift Module

This module provisions an AWS Redshift cluster for data warehousing, analytical queries, and MLOps metrics aggregation. It supports single/multi-node clusters, database settings, encryption-at-rest with custom KMS keys, subnet groups, IAM roles, logging/auditing to S3, and VPC networking configurations.

## Features

- **Flexible Sizing**: Single-node or multi-node scale-out configurations.
- **Data Protection**: Encryption-at-rest enabled by default using KMS, with option for custom customer-managed keys.
- **Enhanced Networking**: Support for Enhanced VPC routing and security groups.
- **Subnet Isolation**: Automated provision of Redshift Subnet Groups.
- **IAM Integration**: Simple association of IAM Roles for Redshift integrations (S3 COPY/UNLOAD, SageMaker, etc.).
- **Audit Logging**: Native configuration of cluster auditing logs to S3.

## Usage Example

```hcl
module "redshift_warehouse" {
  source = "../modules/redshift"

  name            = "mlops-warehouse"
  node_type       = "dc2.large"
  cluster_type    = "multi-node"
  number_of_nodes = 2

  database_name   = "ml_metrics"
  master_username = "dbadmin"
  master_password = "SecurePassword2026!" # Must be secure & sensitive

  create_subnet_group = true
  subnet_ids          = ["subnet-12345678", "subnet-87654321"]
  vpc_security_group_ids = ["sg-123456789"]

  encrypted   = true
  kms_key_arn = "arn:aws:kms:us-west-2:123456789012:key/your-custom-kms-key-arn"

  iam_roles = ["arn:aws:iam::123456789012:role/RedshiftS3AccessRole"]

  logging_enabled     = true
  logging_bucket_name = "mlops-redshift-logs-bucket"
  logging_s3_key_prefix = "redshift-audit/"

  skip_final_snapshot = true

  tags = {
    Environment = "production"
    Department  = "data-science"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The Redshift cluster identifier | `string` | n/a | yes |
| `node_type` | The node type to be provisioned for the cluster (e.g. `dc2.large`, `ra3.xlplus`) | `string` | `"dc2.large"` | no |
| `cluster_type` | The cluster type. Must be `single-node` or `multi-node` | `string` | `"single-node"` | no |
| `number_of_nodes` | The number of nodes in the cluster. Required if cluster_type is multi-node | `number` | `1` | no |
| `database_name` | The name of the first database to be created when the cluster is created | `string` | `"dev"` | no |
| `master_username` | Username for the master DB user. Must be alphanumeric and start with a letter | `string` | `"awsuser"` | no |
| `master_password` | Password for the master DB user. Must satisfy strength requirements and be marked sensitive | `string` | n/a | yes |
| `port` | The port number on which the cluster accepts incoming connections | `number` | `5439` | no |
| `vpc_security_group_ids` | A list of VPC security groups to be associated with the cluster | `list(string)` | `[]` | no |
| `create_subnet_group` | Whether to create a new Redshift subnet group | `bool` | `false` | no |
| `subnet_ids` | A list of VPC subnet IDs to create the subnet group from | `list(string)` | `[]` | no |
| `cluster_subnet_group_name` | Existing Redshift subnet group name. Ignored if create_subnet_group is true | `string` | `null` | no |
| `publicly_accessible` | If true, the cluster can be accessed from a public network | `bool` | `false` | no |
| `enhanced_vpc_routing` | If true, enhanced VPC routing is enabled | `bool` | `false` | no |
| `encrypted` | If true, the data in the cluster is encrypted at rest | `bool` | `true` | no |
| `kms_key_arn` | The ARN of the AWS Key Management Service (AWS KMS) key for encrypting data at rest | `string` | `null` | no |
| `iam_roles` | A list of IAM Role ARNs to associate with the cluster | `list(string)` | `[]` | no |
| `logging_enabled` | Whether to enable logging for the cluster | `bool` | `false` | no |
| `logging_bucket_name` | The name of an existing S3 bucket where you want to store auditing logs | `string` | `null` | no |
| `logging_s3_key_prefix` | The prefix applied to the log file names | `string` | `null` | no |
| `preferred_maintenance_window` | The weekly time range during system upgrades. Format: `ddd:hh24:mi-ddd:hh24:mi` | `string` | `"sat:10:00-sat:10:30"` | no |
| `automated_snapshot_retention_period` | The number of days that automated snapshots are retained | `number` | `7` | no |
| `skip_final_snapshot` | Determines whether a final snapshot is created before the cluster is deleted | `bool` | `true` | no |
| `final_snapshot_identifier` | The identifier of the final snapshot created before deleting the cluster | `string` | `null` | no |
| `tags` | A map of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `redshift_cluster_id` | The Redshift cluster identifier |
| `redshift_cluster_arn` | The Amazon Resource Name (ARN) of the Redshift cluster |
| `endpoint` | The connection endpoint, in format `host:port` |
| `dns_name` | The DNS name of the cluster endpoint |
| `database_name` | The database name |
| `port` | The port the cluster responds on |
| `subnet_group_id` | The ID of the Redshift subnet group |
