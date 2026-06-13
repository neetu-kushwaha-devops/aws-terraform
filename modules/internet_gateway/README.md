# Internet Gateway Module

This module provisions an AWS Internet Gateway and associates it with the specified VPC.

## Features
- Standard AWS Internet Gateway creation
- VPC association
- Customizable resource tagging

## Usage Example

```hcl
module "internet_gateway" {
  source = "../modules/internet_gateway"

  name   = "prod-igw"
  vpc_id = module.vpc.vpc_id

  tags = {
    Environment = "production"
    Team        = "mlops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `vpc_id` | The VPC ID where the Internet Gateway will be created | `string` | n/a | yes |
| `name` | Name tag for the Internet Gateway resource | `string` | n/a | yes |
| `tags` | A map of tags to assign to the Internet Gateway | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `internet_gateway_id` | The ID of the Internet Gateway |
| `internet_gateway_arn` | The ARN of the Internet Gateway |
