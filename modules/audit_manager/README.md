# AWS Audit Manager Assessment Terraform Module

This module provisions an AWS Audit Manager Assessment linking to standard or custom frameworks, scopes, and target report locations.

## Features
- Create Audit Manager Assessment
- Dedicated S3 evidence/report storage link
- Dynamic assessment roles definition
- Multi-account / multi-service scoping support
- Tagging support

## Usage

```hcl
module "audit_manager" {
  source       = "../audit_manager"
  name         = "my-compliance-assessment"
  framework_id = "a1b2c3d4-5678-90ab-cdef-111111111111"
  s3_destination = "s3://my-audit-evidence-bucket"

  roles = [{
    role_arn  = "arn:aws:iam::123456789012:role/AuditOwnerRole"
    role_type = "PROCESS_OWNER"
  }]

  scope = {
    aws_accounts = [{ id = "123456789012" }]
    aws_services = [{ name = "s3" }]
  }

  tags = {
    Environment = "production"
  }
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Assessment name | string | n/a | yes |
| framework_id | Custom or standard framework ID | string | n/a | yes |
| description | Assessment description | string | `null` | no |
| s3_destination | Destination S3 URI | string | n/a | yes |
| roles | IAM roles associated | list(object) | n/a | yes |
| scope | Audited accounts / services | object | n/a | yes |
| tags | Tags to assign to resources | map(string) | `{}` | no |

## Outputs
| Name | Description |
|------|-------------|
| assessment_id | Assessment ID |
| assessment_arn | Assessment ARN |
| assessment_status | Assessment status |
