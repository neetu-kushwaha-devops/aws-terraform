# AWS Managed Microsoft AD Terraform Module

This module provisions an AWS Managed Microsoft Active Directory (AD) with dual-AZ deployments.

## Features
- Standard or Enterprise Active Directory editions
- Dedicated VPC settings configuration
- Name and tags alignment
- Sensitive administrator password protection

## Usage

```hcl
module "managed_ad" {
  source     = "../managed_ad_microsoft_ad"
  name       = "corp.example.com"
  short_name = "CORP"
  password   = "SuperSecurePassword123!"
  edition    = "Standard"
  vpc_id     = "vpc-12345678"
  subnet_ids = ["subnet-11111111", "subnet-22222222"]

  tags = {
    Environment = "production"
  }
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | FQDN of the directory | string | n/a | yes |
| short_name | NetBIOS name | string | `null` | no |
| password | Admin password | string | n/a | yes |
| edition | Microsoft AD edition (`Standard` or `Enterprise`) | string | `Standard` | no |
| vpc_id | VPC ID | string | n/a | yes |
| subnet_ids | Subnet IDs (in at least two different AZs) | list(string) | n/a | yes |
| tags | Tags to assign to resources | map(string) | `{}` | no |

## Outputs
| Name | Description |
|------|-------------|
| directory_id | The ID of the directory |
| directory_dns_ips | IP addresses of the DNS servers |
| directory_security_group_id | Security group ID for controllers |
