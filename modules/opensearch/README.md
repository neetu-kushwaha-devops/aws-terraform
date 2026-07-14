# AWS OpenSearch (formerly Elasticsearch) Terraform Module

This module provisions an AWS OpenSearch Service domain with best practices for enterprise security, scalability, and performance.

## Features

- **Cluster Provisioning**: Set up OpenSearch/Elasticsearch clusters with configurable engines, instance counts, types, and sizing.
- **Multi-AZ Deployments**: High Availability configured with Zone Awareness (up to 3 AZs).
- **Dedicated Master Nodes**: Provision dedicated master nodes to offload management tasks and improve cluster stability.
- **UltraWarm Nodes**: Enable warm tier storage nodes for cost-effective log storage.
- **Enterprise-Grade Security**:
  - **Encryption at Rest**: KMS key encryption support.
  - **Node-to-Node Encryption**: Encrypt communication channels between nodes inside the cluster.
  - **HTTPS Enforcement**: Block insecure HTTP access and set minimum TLS versions (e.g. TLS 1.2).
  - **Fine-Grained Access Control (FGAC)**: Advanced security features with internal user databases or IAM role master users.
- **VPC Deployment**: Optional private deployments inside specified subnets and security groups.
- **EBS Volume Optimization**: Supports gp3 volumes with configurable IOPS and throughput metrics.
- **Log Publishing**: Publish search, index, application, or audit logs directly to AWS CloudWatch Log Groups.

## Usage Example

### Private VPC Deployment with Fine-Grained Access Control

```hcl
module "opensearch" {
  source = "./modules/opensearch"

  domain_name    = "enterprise-search"
  engine_version = "OpenSearch_2.11"

  instance_type  = "r6g.large.search"
  instance_count = 3

  dedicated_master_enabled = true
  dedicated_master_type    = "c6g.large.search"
  dedicated_master_count   = 3

  zone_awareness_enabled  = true
  availability_zone_count = 3

  ebs_enabled       = true
  ebs_volume_type   = "gp3"
  ebs_volume_size   = 100
  ebs_iops          = 3000
  ebs_throughput    = 125

  # Private VPC deployment
  vpc_enabled        = true
  subnet_ids         = ["subnet-12345abc", "subnet-67890def", "subnet-11121ghi"]
  security_group_ids = ["sg-0123456789abcdef0"]

  # Security configurations
  kms_key_id                          = "arn:aws:kms:us-east-1:123456789012:key/some-key-uuid"
  fine_grained_access_control_enabled = true
  master_user_username                = "admin"
  master_user_password                = "SuperSecretSecurePassword123!"

  tags = {
    Environment = "Production"
    Application = "Logging"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `domain_name` | Name of the OpenSearch domain | `string` | n/a | yes |
| `engine_version` | The engine version for the OpenSearch domain | `string` | `"OpenSearch_2.11"` | no |
| `instance_type` | The instance type for the OpenSearch cluster data nodes | `string` | `"t3.small.search"` | no |
| `instance_count` | Number of instances in the cluster | `number` | `2` | no |
| `dedicated_master_enabled` | Indicates whether dedicated master nodes are enabled | `bool` | `false` | no |
| `dedicated_master_type` | Instance type for the dedicated master nodes | `string` | `"t3.small.search"` | no |
| `dedicated_master_count` | Number of dedicated master nodes in the cluster | `number` | `3` | no |
| `zone_awareness_enabled` | Indicates whether zone awareness is enabled | `bool` | `true` | no |
| `availability_zone_count` | Number of Availability Zones for the domain (2 or 3) | `number` | `2` | no |
| `cluster_config` | Map of cluster configurations to override (for compatibility) | `object({...})` | `{}` | no |
| `warm_enabled` | Indicates whether UltraWarm nodes are enabled | `bool` | `false` | no |
| `warm_type` | Instance type for the UltraWarm nodes | `string` | `"warm1.medium.search"` | no |
| `warm_count` | Number of UltraWarm nodes in the cluster | `number` | `2` | no |
| `ebs_enabled` | Whether EBS volumes are attached to data nodes | `bool` | `true` | no |
| `ebs_volume_type` | The type of EBS volumes (e.g. `gp3`, `gp2`) | `string` | `"gp3"` | no |
| `ebs_volume_size` | The size of EBS volumes attached to data nodes (in GiB) | `number` | `20` | no |
| `ebs_iops` | Baseline IOPS for gp3 volumes (minimum 3000) | `number` | `3000` | no |
| `ebs_throughput` | Baseline throughput for gp3 volumes (minimum 125 MB/s) | `number` | `125` | no |
| `vpc_enabled` | Whether to deploy the OpenSearch domain inside a VPC | `bool` | `false` | no |
| `subnet_ids` | List of subnet IDs to deploy the domain endpoints | `list(string)` | `[]` | no |
| `security_group_ids` | List of security group IDs to associate with VPC endpoints | `list(string)` | `[]` | no |
| `kms_key_id` | KMS key ID for data at rest. If omitted, default AWS key is used | `string` | `null` | no |
| `tls_security_policy` | TLS security policy applied to HTTPS endpoint | `string` | `"Policy-Min-TLS-1-2-2019-07"` | no |
| `fine_grained_access_control_enabled` | Whether to enable fine-grained access control | `bool` | `false` | no |
| `master_user_arn` | The IAM ARN of the master user | `string` | `null` | no |
| `master_user_username` | Master username for internal database | `string` | `null` | no |
| `master_user_password` | Master password for internal database | `string` | `null` | no |
| `custom_access_policy` | Custom JSON access policy string | `string` | `null` | no |
| `advanced_options` | Map of key-value configurations for advanced settings | `map(string)` | `{}` | no |
| `log_publishing_options` | Configures log publishing options to CloudWatch | `list(object)` | `[]` | no |
| `tags` | A map of tags to assign to the OpenSearch domain | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `domain_id` | Unique identifier for the OpenSearch domain |
| `domain_name` | Name of the OpenSearch domain |
| `domain_arn` | ARN of the OpenSearch domain |
| `opensearch_endpoint` | Domain-specific endpoint used to submit requests |
| `dashboard_endpoint` | Domain-specific endpoint for OpenSearch Dashboards |
| `vpc_options` | VPC options details if deployed inside a VPC |
