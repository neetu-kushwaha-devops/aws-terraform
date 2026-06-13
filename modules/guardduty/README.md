# AWS GuardDuty Terraform Module

This module provisions an AWS GuardDuty detector and configures essential features like S3 Data Events scanning, EBS Malware Protection, and publishing destinations for findings.

## Features

- **GuardDuty Detector**: Enables GuardDuty threat detection in the region.
- **S3 Data Events Protection**: Monitours S3 access logs and object activities for security threat indicators.
- **EBS Malware Protection**: Enables scanning of EBS volumes attached to EC2 instances for malware.
- **Publishing Destinations**: Supports exporting GuardDuty findings to a designated S3 bucket encrypted with an AWS KMS key.

## Usage

### Simple GuardDuty Enablement

```hcl
module "guardduty" {
  source = "./modules/guardduty"

  enable                    = true
  enable_s3_protection      = true
  enable_malware_protection = true

  tags = {
    Environment = "production"
    Owner       = "security-team"
  }
}
```

### Advanced GuardDuty with S3 Export

```hcl
module "guardduty_advanced" {
  source = "./modules/guardduty"

  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  enable_s3_protection         = true
  enable_malware_protection    = true
  
  publishing_destination_arn   = "arn:aws:s3:::my-guardduty-findings-bucket"
  kms_key_arn                  = "arn:aws:kms:us-west-2:111122223333:key/my-findings-encryption-key"

  tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `enable` | Whether to enable the GuardDuty detector. | `bool` | `true` | no |
| `finding_publishing_frequency` | The frequency of notification about findings (`FIFTEEN_MINUTES`, `ONE_HOUR`, `SIX_HOURS`). | `string` | `"SIX_HOURS"` | no |
| `enable_s3_protection` | Whether to enable S3 protection (S3 data events scanning). | `bool` | `true` | no |
| `enable_malware_protection` | Whether to enable EBS malware protection. | `bool` | `true` | no |
| `publishing_destination_arn` | The ARN of the S3 bucket where findings will be published. | `string` | `null` | no |
| `kms_key_arn` | The ARN of the KMS key used to encrypt GuardDuty findings at the destination. | `string` | `null` | no |
| `tags` | A mapping of tags to assign to the resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `guardduty_detector_id` | The ID of the GuardDuty detector. |
| `guardduty_detector_arn` | The ARN of the GuardDuty detector. |
| `publishing_destination_id` | The ID of the GuardDuty publishing destination. |
