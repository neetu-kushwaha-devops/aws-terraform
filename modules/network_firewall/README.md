# AWS Network Firewall Terraform Module

This module provisions an AWS Network Firewall, Firewall Policy, and custom Logging Configurations.

## Features
- Provision Firewall and Firewall Policy in a VPC
- Connect stateless and stateful rule groups dynamically
- Enforce logging destination configurations (CloudWatch, S3, or Kinesis Firehose)
- Merged Name tags matching the workspace convention

## Usage

```hcl
module "network_firewall" {
  source = "../network_firewall"
  name   = "my-firewall"
  vpc_id = "vpc-12345678"

  subnet_mappings = [
    { subnet_id = "subnet-11111111" },
    { subnet_id = "subnet-22222222" }
  ]

  logging_destinations = [{
    log_type             = "FLOW"
    log_destination_type = "CloudWatchLogs"
    log_destination = {
      logGroup = "/aws/network-firewall/my-firewall-flow"
    }
  }]

  tags = {
    Environment = "production"
  }
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The prefix to apply to resource names | string | n/a | yes |
| vpc_id | VPC ID where firewall is deployed | string | n/a | yes |
| subnet_mappings | Subnets where firewall endpoints reside | set(object) | n/a | yes |
| stateless_rule_groups | List of stateless rule group ARNs | list(object) | `[]` | no |
| stateful_rule_groups | List of stateful rule group ARNs | list(object) | `[]` | no |
| logging_destinations | Log configurations | list(object) | `[]` | no |
| tags | Tags to assign to the resources | map(string) | `{}` | no |

## Outputs
| Name | Description |
|------|-------------|
| firewall_id | The ID of the firewall |
| firewall_arn | The ARN of the firewall |
| firewall_status | Status of firewall endpoints |
| firewall_policy_id | The ID of the firewall policy |
| firewall_policy_arn | The ARN of the firewall policy |
