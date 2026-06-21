# AWS Placement Groups Terraform Module

This module provisions an AWS Placement Group with a configurable strategy (`cluster`, `partition`, or `spread`).

## Features
- Dynamic strategy selection
- Configurable partition count (when strategy is `partition`)
- Merged Name tags matching the workspace convention

## Usage

```hcl
module "placement_group" {
  source    = "../placement_groups"
  name      = "my-app-placement-group"
  strategy  = "partition"
  partition_count = 3
  tags = {
    Environment = "production"
  }
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the placement group | string | n/a | yes |
| strategy | The placement strategy (cluster, partition, spread) | string | `partition` | no |
| partition_count | Number of partitions | number | `3` | no |
| tags | Tags to assign to the resource | map(string) | `{}` | no |

## Outputs
| Name | Description |
|------|-------------|
| placement_group_id | The ID of the placement group |
| placement_group_arn | The ARN of the placement group |
