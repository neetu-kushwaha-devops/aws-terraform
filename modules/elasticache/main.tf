# ElastiCache Module

# Parameter Group Configuration
resource "aws_elasticache_parameter_group" "this" {
  count = var.create_parameter_group ? 1 : 0

  name        = "${var.name}-params"
  family      = var.parameter_group_family
  description = "Parameter group for ElastiCache cluster ${var.name}"

  dynamic "parameter" {
    for_each = var.parameter_group_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge({ Name = "${var.name}-params" }, var.tags)
}

# Subnet Group Configuration
resource "aws_elasticache_subnet_group" "this" {
  count = var.create_subnet_group ? 1 : 0

  name        = "${var.name}-subnet-group"
  subnet_ids  = var.subnet_ids
  description = "Subnet group for ElastiCache cluster ${var.name}"

  tags = merge({ Name = "${var.name}-subnet-group" }, var.tags)
}

# Redis Replication Group Configuration
resource "aws_elasticache_replication_group" "this" {
  count = var.engine == "redis" ? 1 : 0

  replication_group_id       = var.name
  description                = var.description != null ? var.description : "ElastiCache Redis replication group for ${var.name}"
  node_type                  = var.node_type
  num_cache_clusters         = var.node_count
  port                       = var.port != null ? var.port : 6379
  parameter_group_name       = var.create_parameter_group ? aws_elasticache_parameter_group.this[0].name : var.parameter_group_name
  subnet_group_name          = var.create_subnet_group ? aws_elasticache_subnet_group.this[0].name : var.subnet_group_name
  security_group_ids         = var.security_group_ids
  automatic_failover_enabled = var.node_count > 1 ? var.automatic_failover_enabled : false
  multi_az_enabled           = var.node_count > 1 && var.automatic_failover_enabled ? var.multi_az_enabled : false
  transit_encryption_enabled = var.transit_encryption_enabled
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  kms_key_id                 = var.at_rest_encryption_enabled ? var.kms_key_id : null
  auth_token                 = var.transit_encryption_enabled ? var.auth_token : null
  engine_version             = var.engine_version
  maintenance_window         = var.maintenance_window
  snapshot_window            = var.snapshot_window
  snapshot_retention_limit   = var.snapshot_retention_limit
  notification_topic_arn     = var.notification_topic_arn
  apply_immediately          = var.apply_immediately

  tags = merge({ Name = var.name }, var.tags)
}

# Memcached Cluster Configuration
resource "aws_elasticache_cluster" "this" {
  count = var.engine == "memcached" ? 1 : 0

  cluster_id           = var.name
  engine               = "memcached"
  node_type            = var.node_type
  num_cache_nodes      = var.node_count
  port                 = var.port != null ? var.port : 11211
  parameter_group_name = var.create_parameter_group ? aws_elasticache_parameter_group.this[0].name : var.parameter_group_name
  subnet_group_name    = var.create_subnet_group ? aws_elasticache_subnet_group.this[0].name : var.subnet_group_name
  security_group_ids   = var.security_group_ids
  engine_version       = var.engine_version
  az_mode              = var.node_count > 1 ? "cross-az" : "single-az"
  apply_immediately    = var.apply_immediately

  tags = merge({ Name = var.name }, var.tags)
}
