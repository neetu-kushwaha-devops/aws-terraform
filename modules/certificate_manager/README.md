# AWS ACM Certificate Manager Terraform Module

This module manages the lifecycle, validation, and DNS integration of AWS Certificate Manager (ACM) SSL/TLS certificates. It supports public certificate creation with Route53 DNS validation as well as private certificates issued by an AWS Private Certificate Authority (Private CA).

## Features

- **Flexible Issuance Modes**: Supports public certificates with DNS or EMAIL validation, and private certificates issued via Private CA.
- **Automated Route53 Integration**: Automatically creates DNS validation records in Amazon Route53 if `validation_method` is set to `DNS` and a `zone_id` is supplied.
- **Intelligent Configuration**: Automatically detects if `certificate_authority_arn` is set and adjusts the certificate properties to comply with AWS API rules for private certificates.
- **Validation Waiting**: Features a validation waiter resource (`aws_acm_certificate_validation`) to block downstream resources until validation succeeds, preventing race conditions.
- **Tag Integration**: Consistent tag merging, ensuring all created resources contain the base `Name` tag alongside custom tags.

---

## Usage Examples

### 1. Public Certificate with Route53 DNS Validation

Creates a public SSL/TLS certificate for a domain and its wildcards, automatically generating DNS validation records in Route53.

```hcl
module "acm_public" {
  source = "./modules/certificate_manager"

  name        = "production-web-cert"
  domain_name = "example.com"
  
  subject_alternative_names = [
    "www.example.com",
    "*.example.com"
  ]

  validation_method = "DNS"
  zone_id           = "Z0123456789ABCDEF" # Route53 hosted zone ID for example.com

  tags = {
    Environment = "production"
    Department  = "operations"
  }
}
```

### 2. Private Certificate Issued by a Private CA

Requests a private certificate from an internal Private CA (e.g. AWS PCA). Since private certificates do not require external validation, validation method is set to `NONE`.

```hcl
module "acm_private" {
  source = "./modules/certificate_manager"

  name        = "internal-service-cert"
  domain_name = "service.internal.local"
  
  subject_alternative_names = [
    "api.service.internal.local"
  ]

  validation_method         = "NONE"
  certificate_authority_arn = "arn:aws:acm-pca:us-east-1:123456789012:certificate-authority/12345678-1234-1234-1234-123456789012"

  tags = {
    Environment = "staging"
    Privacy     = "private"
  }
}
```

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The base name used to construct resource tags (specifically the Name tag) | `string` | n/a | **yes** |
| `domain_name` | The primary domain name for the certificate | `string` | n/a | **yes** |
| `subject_alternative_names` | A list of subject alternative names (SANs) for the certificate | `list(string)` | `[]` | no |
| `validation_method` | The validation method to use (DNS, EMAIL, or NONE for Private CA certificates) | `string` | `"DNS"` | no |
| `certificate_authority_arn` | The ARN of the Private Certificate Authority (Private CA) to use for private certificates | `string` | `null` | no |
| `zone_id` | The Route53 hosted zone ID to use for DNS validation records | `string` | `null` | no |
| `validate_certificate` | A boolean flag to enable certificate validation resource to wait for validation completion | `bool` | `true` | no |
| `tags` | A mapping of tags to assign to the resources. These will be merged with the Name tag | `map(string)` | `{}` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| `certificate_arn` | The ARN of the ACM certificate |
| `certificate_domain` | The primary domain name of the certificate |
| `domain_validation_options` | A list of domain validation options for the certificate, containing resource record details |
| `validation_records` | A map of Route53 validation records created for DNS validation |
| `validated_certificate_arn` | The ARN of the validated ACM certificate (waits for validation to complete if validation is enabled) |
