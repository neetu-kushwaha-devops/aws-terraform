# Module: network_acl

This Terraform module implements an AWS Network ACL (NACL) with subnet associations and custom rules generated dynamically via inputs.

## Features

- Custom Network ACL creation.
- Subnet associations support.
- Dynamically created ingress/egress NACL rules.
- Proper rule indexing via dynamic `for_each` mapping.
- Standardized tags support.

## Usage Example

```hcl
module "public_nacl" {
  source     = "./modules/network_acl"
  name       = "public-nacl"
  vpc_id     = "vpc-12345678"
  subnet_ids = ["subnet-11111111", "subnet-22222222"]

  entries = [
    {
      rule_number = "100"
      egress      = "false"
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = "80"
      to_port     = "80"
    },
    {
      rule_number = "110"
      egress      = "false"
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = "443"
      to_port     = "443"
    },
    {
      rule_number = "120"
      egress      = "false"
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = "1024"
      to_port     = "65535"
    },
    {
      rule_number = "100"
      egress      = "true"
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = "1024"
      to_port     = "65535"
    }
  ]

  tags = {
    Environment = "production"
    SubnetType  = "public"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the network ACL | `string` | n/a | yes |
| `vpc_id` | The VPC ID where the network ACL will be created | `string` | n/a | yes |
| `subnet_ids` | A list of subnet IDs to associate with the network ACL | `list(string)` | `[]` | no |
| `entries` | List of Network ACL rules. Map keys: `rule_number`, `egress`, `protocol`, `rule_action`, `cidr_block`, `ipv6_cidr_block`, `from_port`, `to_port`, `icmp_type`, `icmp_code` | `list(map(string))` | `[]` | no |
| `tags` | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description | Value |
|------|-------------|-------|
| `network_acl_id` | The ID of the network ACL | `aws_network_acl.this.id` |
| `network_acl_arn` | The ARN of the network ACL | `aws_network_acl.this.arn` |
