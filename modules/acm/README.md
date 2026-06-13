# AWS ACM Certificate Terraform Module

This module manages the creation, DNS validation, and status tracking of AWS Certificate Manager (ACM) SSL/TLS certificates.

## Features

- Creates an ACM certificate with optional Subject Alternative Names (SANs).
- Automates DNS validation record injection into Amazon Route53.
- Supports multi-domain DNS validation targeting multiple Route53 hosted zones.
- Optional certificate validation waiter resource to ensure certificates are ready for consumption before downstream resources are created.

## Usage Example

```hcl
module "acm" {
  source = "./modules/acm"

  domain_name = "example.com"
  subject_alternative_names = [
    "www.example.com",
    "api.example.com"
  ]

  zone_id = "Z0123456789ABCDEF" # Route53 Zone ID for example.com

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `domain_name` | The primary domain name for the certificate | `string` | n/a | yes |
| `subject_alternative_names` | A list of subject alternative names (SANs) for the certificate | `list(string)` | `[]` | no |
| `validation_method` | Which method to use for validation (DNS or EMAIL) | `string` | `"DNS"` | no |
| `zone_id` | The default Route53 zone ID to use for DNS validation records | `string` | `""` | no |
| `domain_to_zone_map` | A map of domain names to Route53 zone IDs. Lookups fallback to `zone_id` | `map(string)` | `{}` | no |
| `validate_certificate` | Whether to create the aws_acm_certificate_validation resource | `bool` | `true` | no |
| `tags` | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `certificate_arn` | The ARN of the ACM certificate |
| `certificate_id` | The ID of the ACM certificate |
| `domain_validation_options` | A list of domain validation options for the certificate |
| `validated_certificate_arn` | The ARN of the validated ACM certificate (waits for validation if enabled) |
