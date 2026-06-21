# AWS Transfer Family Terraform Module

This module provisions an AWS Transfer Family server (SFTP, FTP, or FTPS) with custom users and SSH public keys.

## Features
- Support identity providers (`SERVICE_MANAGED` or `API_GATEWAY`)
- Support SFTP, FTP, and FTPS protocols
- Support Public or VPC endpoints
- Dynamic Transfer User creation and SSH key association
- Merged Name tags matching the workspace convention

## Usage

```hcl
module "transfer_family" {
  source = "../transfer_family"
  name   = "my-transfer-server"

  users = {
    "john-doe" = {
      role_arn       = "arn:aws:iam::123456789012:role/sftp-user-role"
      s3_bucket_name = "my-sftp-storage-bucket"
      ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."
    }
  }

  tags = {
    Environment = "production"
  }
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The prefix to apply to resource names | string | n/a | yes |
| identity_provider_type | Auth type (`SERVICE_MANAGED` or `API_GATEWAY`) | string | `SERVICE_MANAGED` | no |
| protocols | Transfer protocols (`SFTP`, `FTP`, `FTPS`) | list(string) | `["SFTP"]` | no |
| endpoint_type | Endpoint type (`PUBLIC`, `VPC`, or `VPC_ENDPOINT`) | string | `PUBLIC` | no |
| vpc_id | VPC ID for VPC endpoints | string | `null` | no |
| subnet_ids | Subnets for VPC endpoints | list(string) | `[]` | no |
| security_group_ids | Security Groups for VPC endpoints | list(string) | `[]` | no |
| users | Map of user configurations | map(object) | `{}` | no |
| tags | Tags to assign to resources | map(string) | `{}` | no |

## Outputs
| Name | Description |
|------|-------------|
| server_id | The ID of the transfer server |
| server_arn | The ARN of the transfer server |
| server_endpoint | The endpoint URL of the transfer server |
| user_arns | Map of user ARNs |
