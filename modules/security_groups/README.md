# Module: security_groups

This Terraform module implements an AWS Security Group with dynamic blocks for ingress and egress rules, enabling highly flexible rule specifications via inputs.

## Features

- Dynamic ingress rules based on lists of maps.
- Dynamic egress rules based on lists of maps.
- Supports CIDR blocks, IPv6 CIDR blocks, Prefix Lists, Source Security Groups, and self-references.
- Strict tagging support.

## Usage Example

```hcl
module "web_sg" {
  source      = "./modules/security_groups"
  name        = "web-server-sg"
  description = "Security group for web servers"
  vpc_id      = "vpc-12345678"

  ingress = [
    {
      description = "Allow HTTP from anywhere"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow HTTPS from corporate subnet"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["192.168.1.0/24", "192.168.2.0/24"]
    },
    {
      description     = "Allow custom app port from application load balancer"
      from_port       = 8080
      to_port         = 8080
      protocol        = "tcp"
      security_groups = ["sg-87654321"]
    }
  ]

  egress = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Environment = "production"
    Owner       = "devops-team"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the security group | `string` | n/a | yes |
| `description` | The description of the security group | `string` | `"Managed by Terraform"` | no |
| `vpc_id` | The VPC ID where the security group will be created | `string` | n/a | yes |
| `ingress` | List of ingress rule objects. Use `list(string)` for `cidr_blocks`, `ipv6_cidr_blocks`, `prefix_list_ids`, and `security_groups`. | `list(object({...}))` | `[]` | no |
| `egress` | List of egress rule objects. Use `list(string)` for `cidr_blocks`, `ipv6_cidr_blocks`, `prefix_list_ids`, and `security_groups`. | `list(object({...}))` | `[]` | no |
| `tags` | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description | Value |
|------|-------------|-------|
| `security_group_id` | The ID of the security group | `aws_security_group.this.id` |
| `security_group_arn` | The ARN of the security group | `aws_security_group.this.arn` |
| `security_group_name` | The name of the security group | `aws_security_group.this.name` |
