# AWS Security Hub Terraform Module

This module enables AWS Security Hub and configures subscriptions to common compliance standards, such as CIS AWS Foundations Benchmark, AWS Foundational Security Best Practices, and PCI DSS.

## Features

- **Security Hub Enablement**: Automates enabling AWS Security Hub.
- **Auto-enable controls**: Configures Security Hub to automatically enable new controls for standard subscriptions.
- **Compliance Standard Subscriptions**: Configures standards subscriptions for AWS Foundational Security Best Practices, CIS AWS Foundations Benchmark, and PCI DSS.

## Usage

### Simple Security Hub Enablement

```hcl
module "security_hub" {
  source = "./modules/security_hub"

  enable                           = true
  enable_aws_foundational_standard = true
  enable_cis_standard              = true
  cis_standard_version             = "1.4.0"
}
```

### Security Hub with PCI DSS Enablement

```hcl
module "security_hub_pci" {
  source = "./modules/security_hub"

  enable                           = true
  enable_aws_foundational_standard = true
  enable_cis_standard              = true
  enable_pci_dss_standard          = true
  pci_dss_standard_version         = "3.2.1"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `enable` | Whether to enable AWS Security Hub. | `bool` | `true` | no |
| `enable_default_standards` | Whether to enable default standards. Set to false if managing standards explicitly via `aws_securityhub_standards_subscription`. | `bool` | `false` | no |
| `control_finding_generator` | Updates whether Security Hub is online or offline. Valid values are `STANDARD_CONTROL` or `SECURITY_CONTROL`. | `string` | `"SECURITY_CONTROL"` | no |
| `auto_enable_controls` | Whether to auto-enable new controls when they are added to standards that are enabled. | `bool` | `true` | no |
| `enable_aws_foundational_standard` | Whether to subscribe to the AWS Foundational Security Best Practices standard. | `bool` | `true` | no |
| `enable_cis_standard` | Whether to subscribe to the CIS AWS Foundations Benchmark standard. | `bool` | `true` | no |
| `cis_standard_version` | Version of the CIS AWS Foundations Benchmark to subscribe to. | `string` | `"1.4.0"` | no |
| `enable_pci_dss_standard` | Whether to subscribe to the PCI DSS standard. | `bool` | `false` | no |
| `pci_dss_standard_version` | Version of the PCI DSS standard. | `string` | `"3.2.1"` | no |
| `tags` | A mapping of tags to assign to resources (where supported). | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `security_hub_id` | The ID of the Security Hub account. |
| `aws_foundational_subscription_arn` | The ARN of the AWS Foundational Security Best Practices standard subscription. |
| `cis_subscription_arn` | The ARN of the CIS AWS Foundations Benchmark standard subscription. |
| `pci_dss_subscription_arn` | The ARN of the PCI DSS standard subscription. |
