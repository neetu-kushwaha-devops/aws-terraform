# AWS EFS (Elastic File System) Terraform Module

This module provisions an AWS EFS (Elastic File System) with encryption-at-rest, automatic backups, lifecycle policies, and multiple mount targets.

## Features

- **Encryption-at-Rest**: Enabled by default, optionally specifying a KMS key.
- **Automatic Backups**: Integrated with AWS Backup policies.
- **Lifecycle Management**: Auto-transitions files to Infrequent Access (IA) and back to primary storage upon access.
- **VPC Integration**: Creates EFS Mount Targets across multiple subnets.

## Usage

### Simple Encrypted EFS with Automatic Backups

```hcl
module "efs" {
  source = "./modules/efs"

  name            = "application-shared-storage"
  subnet_ids      = ["subnet-12345678", "subnet-87654321"]
  security_groups = ["sg-0123456789abcdef0"]

  tags = {
    Environment = "production"
  }
}
```

### Advanced Configured EFS (MaxIO, Provisioned Throughput)

```hcl
module "efs_advanced" {
  source = "./modules/efs"

  name                            = "application-shared-storage-adv"
  performance_mode                = "maxIO"
  throughput_mode                 = "provisioned"
  provisioned_throughput_in_mibps = 100
  encrypted                       = true
  kms_key_id                      = "arn:aws:kms:us-west-2:111122223333:key/your-kms-key"
  
  transition_to_ia                    = "AFTER_14_DAYS"
  transition_to_primary_storage_class = "AFTER_1_ACCESS"

  subnet_ids      = ["subnet-12345678", "subnet-87654321"]
  security_groups = ["sg-0123456789abcdef0"]

  tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the EFS file system and Name tag. | `string` | n/a | yes |
| `performance_mode` | Performance mode (`generalPurpose` or `maxIO`). | `string` | `"generalPurpose"` | no |
| `throughput_mode` | Throughput mode (`bursting`, `provisioned`, or `elastic`). | `string` | `"bursting"` | no |
| `provisioned_throughput_in_mibps` | Provisioned throughput in MiB/s. | `number` | `null` | no |
| `encrypted` | Whether the disk is encrypted at rest. | `bool` | `true` | no |
| `kms_key_id` | KMS Key ARN to encrypt the system. | `string` | `null` | no |
| `transition_to_ia` | Transition to IA policy (`AFTER_7_DAYS`, etc.). | `string` | `"AFTER_30_DAYS"` | no |
| `transition_to_primary_storage_class` | Transition back to Standard storage class (`AFTER_1_ACCESS` or `null`). | `string` | `"AFTER_1_ACCESS"` | no |
| `enable_backup_policy` | Enable automatic AWS Backups. | `bool` | `true` | no |
| `subnet_ids` | List of subnets to launch mount targets in. | `list(string)` | `[]` | no |
| `security_groups` | Security groups to attach to mount targets. | `list(string)` | `[]` | no |
| `tags` | Map of resource tags. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `file_system_id` | The ID of the EFS file system. |
| `file_system_arn` | The ARN of the EFS file system. |
| `file_system_dns_name` | The DNS name for the EFS file system. |
| `mount_targets` | A map of created mount targets. |
