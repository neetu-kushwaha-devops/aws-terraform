# ElastiCache Module

This module provisions an AWS ElastiCache cluster or replication group. It supports both Redis (with Replication Groups, Transit/At-Rest Encryption, Auth Token, multi-AZ, and Auto-Failover) and Memcached (with Multi-node clustering). It also includes support for creating custom cache subnet groups and cache parameter groups.

## Features

- **Multi-Engine Support**: Provisions either a Redis replication group or a Memcached cluster based on configuration.
- **Failover & Multi-AZ**: High-availability configuration for Redis with automatic failover and Multi-AZ support.
- **Security**: Encryption-at-rest (using custom KMS Keys or AWS-managed keys) and Encryption-in-Transit with Auth Token authentication support.
- **Custom Parameters**: Provisions custom Parameter Groups to configure Redis or Memcached variables.
- **Subnet Group**: Provisions custom Subnet Groups to isolate cache instances.

## Usage Example (Redis Replication Group)

```hcl
module "redis_cache" {
  source = "../modules/elasticache"

  name           = "app-redis-cache"
  engine         = "redis"
  engine_version = "7.0"
  node_type      = "cache.t3.medium"
  node_count     = 2

  create_subnet_group = true
  subnet_ids          = ["subnet-12345678", "subnet-87654321"]
  security_group_ids  = ["sg-123456789"]

  create_parameter_group = true
  parameter_group_family = "redis7"
  parameter_group_parameters = [
    {
      name  = "maxmemory-policy"
      value = "allkeys-lru"
    }
  ]

  automatic_failover_enabled = true
  multi_az_enabled           = true
  transit_encryption_enabled = true
  at_rest_encryption_enabled = true
  kms_key_id                 = "arn:aws:kms:us-west-2:123456789012:key/your-custom-kms-key-arn"
  auth_token                 = "SuperSecretPassword123" # Must be sensitive and complex

  tags = {
    Environment = "production"
    Service     = "caching"
  }
}
```

## Usage Example (Memcached Cluster)

```hcl
module "memcached_cache" {
  source = "../modules/elasticache"

  name           = "app-memcached"
  engine         = "memcached"
  engine_version = "1.6"
  node_type      = "cache.t3.micro"
  node_count     = 2

  create_subnet_group = true
  subnet_ids          = ["subnet-12345678", "subnet-87654321"]
  security_group_ids  = ["sg-123456789"]

  create_parameter_group = true
  parameter_group_family = "memcached1.6"

  tags = {
    Environment = "staging"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name identifier for the ElastiCache cluster/replication group | `string` | n/a | yes |
| `engine` | The engine to use. Supported values are `redis` and `memcached` | `string` | `"redis"` | no |
| `engine_version` | The version number of the cache engine to use | `string` | `"7.0"` | no |
| `node_type` | The compute and memory capacity of the nodes | `string` | `"cache.t3.micro"` | no |
| `node_count` | The number of cache nodes (for Memcached) or cache clusters in the replication group (for Redis) | `number` | `1` | no |
| `port` | The port number on which each of the cache nodes will accept connections. If null, default is 6379 for redis, 11211 for memcached | `number` | `null` | no |
| `description` | Description of the replication group | `string` | `null` | no |
| `create_parameter_group` | Whether to create a new parameter group | `bool` | `true` | no |
| `parameter_group_family` | The family of the ElastiCache parameter group | `string` | `"redis7"` | no |
| `parameter_group_name` | Existing parameter group name. Ignored if create_parameter_group is true | `string` | `null` | no |
| `parameter_group_parameters` | A list of parameter maps to apply to the parameter group | `list(object)` | `[]` | no |
| `create_subnet_group` | Whether to create a new subnet group | `bool` | `false` | no |
| `subnet_ids` | List of VPC Subnet IDs for the subnet group | `list(string)` | `[]` | no |
| `subnet_group_name` | Existing subnet group name. Ignored if create_subnet_group is true | `string` | `null` | no |
| `security_group_ids` | One or more VPC security groups associated with the cache cluster | `list(string)` | `[]` | no |
| `automatic_failover_enabled` | Specifies whether a read-only replica will be automatically promoted to read/write primary if the existing primary fails. Only valid for Redis with node_count > 1 | `bool` | `true` | no |
| `multi_az_enabled` | Specifies whether Multi-AZ is enabled. Requires automatic_failover_enabled to be true | `bool` | `true` | no |
| `transit_encryption_enabled` | Whether to enable encryption in transit. Only valid for Redis engine | `bool` | `true` | no |
| `at_rest_encryption_enabled` | Whether to enable encryption at rest. Only valid for Redis engine | `bool` | `true` | no |
| `kms_key_id` | The ARN of the KMS key that you want to use to encrypt data at rest | `string` | `null` | no |
| `auth_token` | The password used to access a protected Redis server. Must be sensitive. Only valid if transit_encryption_enabled is true | `string` | `null` | no |
| `maintenance_window` | Specifies the weekly time range for cluster maintenance | `string` | `null` | no |
| `snapshot_window` | The daily time range during which automated backups are created. Only valid for Redis engine | `string` | `null` | no |
| `snapshot_retention_limit` | The number of days for which ElastiCache will retain automatic snapshots. Only valid for Redis engine | `number` | `0` | no |
| `notification_topic_arn` | An Amazon Resource Name (ARN) of an SNS topic to send ElastiCache notifications to | `string` | `null` | no |
| `apply_immediately` | Specifies whether any modifications are applied immediately, or during the next maintenance window | `bool` | `false` | no |
| `tags` | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `elasticache_id` | The ID of the replication group (Redis) or cluster (Memcached) |
| `primary_endpoint_address` | The endpoint address of the Redis primary or Memcached configuration endpoint |
| `reader_endpoint_address` | The reader endpoint address (Redis replication group only) |
| `port` | The port of the ElastiCache cluster |
| `parameter_group_id` | The ID of the parameter group used |
| `subnet_group_id` | The ID of the subnet group used |
