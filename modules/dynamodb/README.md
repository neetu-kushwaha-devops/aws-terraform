# DynamoDB Module

This module provisions a production-ready AWS DynamoDB table with support for capacity billing modes (PROVISIONED / PAY_PER_REQUEST), global and local secondary indexes, point-in-time recovery (PITR), time-to-live (TTL), encryption-at-rest using custom KMS keys, and DynamoDB streams.

## Features

- **Billing Modes**: Supports both `PAY_PER_REQUEST` (On-Demand) and `PROVISIONED` billing modes.
- **Dynamic GSI & LSI**: Declarative definition of Global and Local Secondary Indexes.
- **Data Protection**: Points-in-Time Recovery (PITR) is enabled by default.
- **Security**: Server-Side Encryption (SSE) support using AWS-owned CMK or custom customer-managed KMS Keys.
- **TTL Support**: Optional TTL attribute configuration.
- **Streams**: Supports stream capture of item changes with custom stream view settings.

## Usage Example

```hcl
module "dynamodb_table" {
  source = "../modules/dynamodb"

  name         = "app-users-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "UserId"
  range_key    = "RegistrationDate"

  attributes = [
    {
      name = "UserId"
      type = "S"
    },
    {
      name = "RegistrationDate"
      type = "S"
    },
    {
      name = "Email"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name               = "EmailIndex"
      hash_key           = "Email"
      projection_type    = "ALL"
      read_capacity      = null # Ignored if PAY_PER_REQUEST
      write_capacity     = null
    }
  ]

  point_in_time_recovery_enabled = true
  server_side_encryption_enabled = true
  kms_key_arn                    = "arn:aws:kms:us-west-2:123456789012:key/your-custom-kms-key-arn"

  ttl_enabled        = true
  ttl_attribute_name = "expires_at"

  tags = {
    Environment = "production"
    Team        = "mlops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name of the DynamoDB table | `string` | n/a | yes |
| `billing_mode` | Controls how you are charged for read and write throughput and how you manage capacity. Can be `PROVISIONED` or `PAY_PER_REQUEST` | `string` | `"PAY_PER_REQUEST"` | no |
| `hash_key` | The attribute to use as the hash (partition) key. Must also be defined in `attributes` | `string` | n/a | yes |
| `range_key` | The attribute to use as the range (sort) key. Must also be defined in `attributes` | `string` | `null` | no |
| `read_capacity` | The number of read units for this table. Value is ignored if billing_mode is PAY_PER_REQUEST | `number` | `null` | no |
| `write_capacity` | The number of write units for this table. Value is ignored if billing_mode is PAY_PER_REQUEST | `number` | `null` | no |
| `attributes` | List of nested attribute definitions. Only required for attributes that will be used as hash or range keys in the table or its indexes | `list(object)` | n/a | yes |
| `global_secondary_indexes` | Describe GSI configurations for the DynamoDB table | `any` | `[]` | no |
| `local_secondary_indexes` | Describe LSI configurations for the DynamoDB table | `any` | `[]` | no |
| `stream_enabled` | Indicates whether Streams are enabled (true) or disabled (false) | `bool` | `false` | no |
| `stream_view_type` | When an item in the table is modified, StreamViewType determines what information is written to the table's stream. Valid values are `KEYS_ONLY`, `NEW_IMAGE`, `OLD_IMAGE`, `NEW_AND_OLD_IMAGES` | `string` | `null` | no |
| `point_in_time_recovery_enabled` | Enable DynamoDB point-in-time recovery | `bool` | `true` | no |
| `server_side_encryption_enabled` | Whether server-side encryption is enabled | `bool` | `true` | no |
| `kms_key_arn` | The ARN of the CMK that should be used for the AWS KMS encryption for this table | `string` | `null` | no |
| `ttl_enabled` | Indicates whether TTL is enabled | `bool` | `false` | no |
| `ttl_attribute_name` | The name of the table attribute to store the TTL timestamp in | `string` | `"ttl"` | no |
| `tags` | A map of tags to populate on the created table | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `table_id` | The name of the table |
| `table_arn` | The ARN of the table |
| `table_stream_arn` | The ARN of the Table Stream. Only available when `stream_enabled = true` |
| `table_stream_label` | A timestamp, in ISO 8601 format, for this stream |
