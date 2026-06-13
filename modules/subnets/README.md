# Subnets Module

This module dynamically provisions public, private, and database subnets across multiple availability zones using loops. It also creates a database subnet group if database subnets are requested.

## Features
- Dynamic subnet creation for public, private, and database layers
- Automatic mapping of public IP on launch for public subnets
- Wrap-around logic to map subnets to availability zones safely
- Optional database subnet group creation for RDS/Aurora
- Customizable tags for each subnet category

## Usage Example

```hcl
module "subnets" {
  source = "../modules/subnets"

  name               = "prod"
  vpc_id             = module.vpc.vpc_id
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  database_subnets   = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

  tags = {
    Environment = "production"
    Team        = "mlops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name prefix for the subnet resources | `string` | n/a | yes |
| `vpc_id` | The VPC ID where subnets will be created | `string` | n/a | yes |
| `availability_zones` | List of availability zones for subnets | `list(string)` | `[]` | no |
| `public_subnets` | List of CIDR blocks for public subnets | `list(string)` | `[]` | no |
| `private_subnets` | List of CIDR blocks for private subnets | `list(string)` | `[]` | no |
| `database_subnets` | List of CIDR blocks for database subnets | `list(string)` | `[]` | no |
| `public_subnet_tags` | Additional tags for public subnets | `map(string)` | `{}` | no |
| `private_subnet_tags` | Additional tags for private subnets | `map(string)` | `{}` | no |
| `database_subnet_tags` | Additional tags for database subnets | `map(string)` | `{}` | no |
| `tags` | Common tags to apply to all subnet resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `public_subnet_ids` | List of IDs of public subnets |
| `public_subnet_cidrs` | List of CIDR blocks of public subnets |
| `public_subnet_arns` | List of ARNs of public subnets |
| `private_subnet_ids` | List of IDs of private subnets |
| `private_subnet_cidrs` | List of CIDR blocks of private subnets |
| `private_subnet_arns` | List of ARNs of private subnets |
| `database_subnet_ids` | List of IDs of database subnets |
| `database_subnet_cidrs` | List of CIDR blocks of database subnets |
| `database_subnet_arns` | List of ARNs of database subnets |
| `database_subnet_group_id` | ID of the database subnet group (if created) |
| `database_subnet_group_arn` | ARN of the database subnet group (if created) |
