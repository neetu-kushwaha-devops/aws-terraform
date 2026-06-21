# AWS Private Certificate Authority (Private CA) Terraform Module

This Terraform module simplifies the creation, configuration, and activation of an AWS Private Certificate Authority (AWS Private CA). It supports setting up Root and Subordinate CAs, configuring CRL (Certificate Revocation List) and OCSP (Online Certificate Status Protocol) revocation, and managing production-grade security defaults.

## Features

- **Root or Subordinate CAs**: Supports both ROOT and SUBORDINATE CA types.
- **Automated CA Activation**: Automatically issues and installs the CA activation certificate (self-signed for ROOT, or signed by a parent CA for SUBORDINATE).
- **Custom Subject Configuration**: Supports standard distinguished name attributes (Common Name, Organization, Country, State, Locality, etc.).
- **Revocation Configurations**:
  - **CRL**: Conditional S3 bucket creation with production-grade configuration (Server-Side Encryption, Block Public Access, Versioning, and Bucket Ownership Controls). Includes automatic attachment of appropriate bucket policies allowing AWS Private CA to write CRLs.
  - **OCSP**: Easily enable OCSP responder with support for custom CNAME.
- **CloudWatch Logging**: Automatically creates a CloudWatch Log Group for CA/OCSP activity monitoring with configurable retention and KMS encryption.
- **Security Defaults**: Follows best practices like zero AWS Account or Region hardcoding, dynamic partition lookup, and merged tags.

---

## Usage Examples

### 1. Root Certificate Authority (Self-Signed)

```hcl
module "root_ca" {
  source = "./modules/private_ca"

  name = "corp-root-ca"
  type = "ROOT"

  subject = {
    common_name  = "Corp Root CA"
    organization = "Corporation"
    country      = "US"
  }

  key_algorithm     = "RSA_4096"
  signing_algorithm = "SHA512WITHRSA"

  validity = {
    type  = "YEARS"
    value = "10"
  }

  tags = {
    Environment = "production"
  }
}
```

### 2. Subordinate Certificate Authority (Signed by Parent Root CA)

```hcl
module "subordinate_ca" {
  source = "./modules/private_ca"

  name = "corp-subordinate-ca"
  type = "SUBORDINATE"

  parent_certificate_authority_arn = module.root_ca.certificate_authority_arn

  subject = {
    common_name  = "Corp Issuing CA"
    organization = "Corporation"
    country      = "US"
  }

  key_algorithm     = "RSA_2048"
  signing_algorithm = "SHA256WITHRSA"

  validity = {
    type  = "YEARS"
    value = "5"
  }

  tags = {
    Environment = "production"
  }
}
```

### 3. CA with CRL (New S3 Bucket) and OCSP Logging Enabled

```hcl
module "ca_with_revocation" {
  source = "./modules/private_ca"

  name = "secure-ca"
  type = "ROOT"

  subject = {
    common_name  = "Secure Enterprise CA"
    organization = "Enterprise"
    country      = "US"
  }

  # Revocation Settings
  enable_crl = true # Creates a secure S3 bucket for CRL storage and sets permissions
  enable_ocsp = true # Enables OCSP responder

  create_ocsp_log_group      = true
  ocsp_log_retention_in_days = 90

  tags = {
    Compliance = "high-security"
  }
}
```

### 4. CA with CRL (Using Existing S3 Bucket)

```hcl
module "ca_with_existing_crl" {
  source = "./modules/private_ca"

  name = "existing-crl-ca"
  type = "ROOT"

  subject = {
    common_name  = "Existing S3 CRL CA"
    organization = "Enterprise"
    country      = "US"
  }

  enable_crl         = true
  crl_s3_bucket_name = "my-preconfigured-crl-bucket" # Uses this bucket without attempting to create/modify it

  tags = {
    Compliance = "legacy"
  }
}
```

---

## Requirements

| Name | Version |
|------|---------|
| [terraform](#requirement\_terraform) | >= 1.3 |
| [aws](#requirement\_aws) | >= 4.0 |

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The prefix name for all resources created by this module. | `string` | n/a | **yes** |
| `subject` | Distinguished Name (DN) configuration for the CA subject. | <pre>object({<br>  common_name                  = string<br>  organization                 = optional(string)<br>  organizational_unit          = optional(string)<br>  country                      = optional(string)<br>  state                        = optional(string)<br>  locality                     = optional(string)<br>  distinguished_name_qualifier = optional(string)<br>  generation_qualifier         = optional(string)<br>  given_name                   = optional(string)<br>  initials                     = optional(string)<br>  pseudonym                    = optional(string)<br>  surname                      = optional(string)<br>  title                        = optional(string)<br>})</pre> | n/a | **yes** |
| `tags` | A map of tags to assign to the resources. | `map(string)` | `{}` | no |
| `type` | Type of Certificate Authority. Valid values: `ROOT`, `SUBORDINATE`. | `string` | `"ROOT"` | no |
| `key_algorithm` | Type of key algorithm. Valid values: `RSA_2048`, `RSA_4096`, `ECDSA_P256`, `ECDSA_P384`, etc. | `string` | `"RSA_2048"` | no |
| `signing_algorithm` | Algorithm to sign certificates. Valid values: `SHA256WITHRSA`, `SHA384WITHRSA`, `SHA512WITHRSA`, `SHA256WITHECDSA`, etc. | `string` | `"SHA256WITHRSA"` | no |
| `enable_crl` | Whether to enable Certificate Revocation List (CRL) generation. | `bool` | `false` | no |
| `crl_s3_bucket_name` | The name of the S3 bucket to store CRLs. If `enable_crl` is true and this is null, an S3 bucket will be created automatically. | `string` | `null` | no |
| `crl_custom_cname` | Custom CNAME for the CRL. E.g., `crl.example.com` | `string` | `null` | no |
| `crl_expiration_in_days` | Number of days before a CRL expires. | `number` | `7` | no |
| `enable_ocsp` | Whether to enable Online Certificate Status Protocol (OCSP) responder. | `bool` | `false` | no |
| `ocsp_custom_cname` | Custom CNAME for the OCSP responder. | `string` | `null` | no |
| `parent_certificate_authority_arn` | The ARN of the parent CA to sign this CA certificate. Required if type is `SUBORDINATE`. | `string` | `null` | no |
| `template_arn` | Custom template ARN for the certificate. If null, a default template based on type (ROOT/SUBORDINATE) is used. | `string` | `null` | no |
| `validity` | The validity period of the Certificate Authority certificate. | <pre>object({<br>  type  = string<br>  value = string<br>})</pre> | <pre>{<br>  type  = "YEARS"<br>  value = "10"<br>}</pre> | no |
| `create_ocsp_log_group` | Whether to create a CloudWatch Log Group for OCSP/CA logging. | `bool` | `true` | no |
| `ocsp_log_retention_in_days` | The retention period in days for the CloudWatch Log Group. | `number` | `30` | no |
| `ocsp_log_group_kms_key_arn` | The ARN of the KMS Key to encrypt the CloudWatch Log Group. | `string` | `null` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| `certificate_authority_arn` | The Amazon Resource Name (ARN) of the Certificate Authority. |
| `certificate` | The PEM-encoded Certificate Authority certificate. |
| `certificate_chain` | The PEM-encoded Certificate Authority certificate chain. |
| `certificate_signing_request` | The PEM-encoded Certificate Signing Request (CSR) generated by the CA. |
| `crl_s3_bucket_name` | The name of the S3 bucket used to store CRLs. |
| `crl_s3_bucket_arn` | The ARN of the S3 bucket used to store CRLs (if created by this module). |
| `ocsp_log_group_arn` | The ARN of the CloudWatch Log Group created for OCSP logging. |
