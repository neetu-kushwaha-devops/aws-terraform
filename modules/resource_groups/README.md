# AWS Resource Groups Terraform Module

This module provisions an AWS Resource Group to organize your AWS resources into logical collections. It supports grouping resources by tags, CloudFormation stacks, or using service-linked configurations (such as EC2 Capacity Reservation Pools).

## Features

- **Tag-Based Grouping**: Dynamically groups resources that match specific tag keys and values.
- **CloudFormation Stack Grouping**: Groups resources associated with a specific CloudFormation stack ARN.
- **Service-Linked Configuration**: Configures service-linked groups (e.g., Capacity Reservation Pools).
- **Name Tag Merging**: Automatically merges the `Name` tag with custom tags.

## Usage

### Tag-Based Resource Group

```hcl
module "resource_group_tags" {
  source = "./modules/resource_groups"

  name        = "production-web-resources"
  description = "All production web application resources"

  query_type            = "TAG_FILTERS_1_0"
  resource_type_filters = ["AWS::AllSupported"]

  query_tags = {
    Environment = ["Production"]
    Project     = ["Webapp"]
  }

  tags = {
    Owner = "DevOps"
  }
}
```

### CloudFormation Stack-Based Resource Group

```hcl
module "resource_group_stack" {
  source = "./modules/resource_groups"

  name        = "my-cfn-stack-resources"
  description = "Resources created by CloudFormation Stack"

  query_type             = "CLOUDFORMATION_STACK_1_0"
  query_stack_identifier = "arn:aws:cloudformation:us-east-1:123456789012:stack/my-stack-name/a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d"

  tags = {
    Environment = "Staging"
  }
}
```

### Capacity Reservation Pool Resource Group (Configuration-Based)

```hcl
module "resource_group_config" {
  source = "./modules/resource_groups"

  name        = "capacity-reservation-pool"
  description = "Capacity Reservation Pool Resource Group"

  configuration = [
    {
      type = "AWS::EC2::CapacityReservationPool"
      parameters = [
        {
          name   = "allowed-resource-types"
          values = ["AWS::EC2::CapacityReservation"]
        }
      ]
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the resource group. | `string` | n/a | yes |
| `description` | A description of the resource group. | `string` | `null` | no |
| `query_type` | The type of the resource query. Valid values are `TAG_FILTERS_1_0` or `CLOUDFORMATION_STACK_1_0`. | `string` | `"TAG_FILTERS_1_0"` | no |
| `resource_type_filters` | A list of resource types to include in the resource group. | `list(string)` | `["AWS::AllSupported"]` | no |
| `query_tags` | A map of tag keys and list of values to filter resources by. Used when `query_type` is `TAG_FILTERS_1_0`. | `map(list(string))` | `{}` | no |
| `query_stack_identifier` | The CloudFormation stack ARN to filter resources by. Required if `query_type` is `CLOUDFORMATION_STACK_1_0`. | `string` | `null` | no |
| `configuration` | A list of configuration blocks for service-linked resource groups. If specified, `resource_query` will be disabled. | `list(object)` | `[]` | no |
| `tags` | A mapping of tags to assign to the resource group itself. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `group_name` | The name of the resource group. |
| `group_arn` | The ARN of the resource group. |
