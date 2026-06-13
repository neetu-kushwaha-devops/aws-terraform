# AWS FSx for Lustre Terraform Module

This module provisions an AWS FSx for Lustre file system, designed for high-performance computing, machine learning, and MLOps workloads. It supports scratch and persistent deployment types, security group associations, subnet placement, and native Amazon S3 integration.

## Features

- **High Performance**: Native FSx for Lustre designed for high-throughput and sub-millisecond latencies.
- **Flexible Deployments**: Supports both ephemeral/scratch storage (`SCRATCH_1`, `SCRATCH_2`) and long-term storage (`PERSISTENT_1`, `PERSISTENT_2`).
- **Encryption-at-Rest**: Encrypted automatically, optionally using a KMS key.
- **S3 Integration**: Native bi-directional sync with Amazon S3. Automatically loads S3 metadata and writes back updates.

## Usage

### Ephemeral/Scratch FSx for Lustre File System

```hcl
module "fsx_lustre_scratch" {
  source = "./modules/fsx"

  name               = "fsx-scratch"
  subnet_ids         = ["subnet-12345678"]
  security_group_ids = ["sg-0123456789abcdef0"]
  storage_capacity   = 1200
  deployment_type    = "SCRATCH_2"

  tags = {
    Environment = "dev"
    Purpose     = "ml-training-scratch"
  }
}
```

### Persistent FSx for Lustre with S3 Data Repo Integration

```hcl
module "fsx_lustre_persistent" {
  source = "./modules/fsx"

  name                        = "fsx-persistent"
  subnet_ids                  = ["subnet-12345678"]
  security_group_ids          = ["sg-0123456789abcdef0"]
  storage_capacity            = 2400
  deployment_type             = "PERSISTENT_1"
  per_unit_storage_throughput = 200 # MB/s/TiB
  storage_type                = "SSD"
  kms_key_id                  = "arn:aws:kms:us-west-2:111122223333:key/your-custom-kms-key"

  # Sync with S3 Training Bucket
  import_path        = "s3://ml-training-dataset-bucket"
  export_path        = "s3://ml-training-dataset-bucket/results"
  auto_import_policy = "NEW_CHANGED"

  tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the FSx file system and Name tag. | `string` | n/a | yes |
| `subnet_ids` | A list of subnet IDs. FSx for Lustre supports exactly one subnet ID. | `list(string)` | n/a | yes |
| `security_group_ids` | Security groups to attach to the FSx ENI. | `list(string)` | `[]` | no |
| `storage_capacity` | Storage capacity in GiB (e.g. 1200, 2400, 3600, etc.). | `number` | `1200` | no |
| `deployment_type` | Deployment type (`SCRATCH_1`, `SCRATCH_2`, `PERSISTENT_1`, `PERSISTENT_2`). | `string` | `"SCRATCH_2"` | no |
| `per_unit_storage_throughput` | Storage throughput MB/s/TiB (for `PERSISTENT_*` deployments). | `number` | `null` | no |
| `storage_type` | Storage type (`SSD` or `HDD`). | `string` | `"SSD"` | no |
| `kms_key_id` | KMS Key ARN to encrypt the system at rest. | `string` | `null` | no |
| `import_path` | S3 URI to import data from. | `string` | `null` | no |
| `export_path` | S3 URI to export data to. | `string` | `null` | no |
| `imported_file_chunk_size` | Size of imported chunks in MiB. | `number` | `null` | no |
| `auto_import_policy` | Auto-import policy (`NONE`, `NEW`, `NEW_CHANGED`, `NEW_CHANGED_DELETED`). | `string` | `null` | no |
| `tags` | Map of resource tags. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `file_system_id` | The ID of the FSx file system. |
| `file_system_arn` | The ARN of the FSx file system. |
| `file_system_dns_name` | The DNS name for the FSx file system. |
| `mount_name` | The mount name of the FSx file system. |
| `network_interface_ids` | A list of network interface IDs on the file system. |
