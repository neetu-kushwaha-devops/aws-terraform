output "elasticache_id" {
  description = "The ID of the replication group (Redis) or cluster (Memcached)"
  value       = var.engine == "redis" ? try(aws_elasticache_replication_group.this[0].id, "") : try(aws_elasticache_cluster.this[0].id, "")
}

output "primary_endpoint_address" {
  description = "The endpoint address of the Redis primary or Memcached configuration endpoint"
  value       = var.engine == "redis" ? try(aws_elasticache_replication_group.this[0].primary_endpoint_address, "") : try(aws_elasticache_cluster.this[0].cluster_address, "")
}

output "reader_endpoint_address" {
  description = "The reader endpoint address (Redis replication group only)"
  value       = var.engine == "redis" ? try(aws_elasticache_replication_group.this[0].reader_endpoint_address, "") : ""
}

output "port" {
  description = "The port of the ElastiCache cluster"
  value       = var.engine == "redis" ? try(aws_elasticache_replication_group.this[0].port, null) : try(aws_elasticache_cluster.this[0].port, null)
}

output "parameter_group_id" {
  description = "The ID of the parameter group used"
  value       = var.create_parameter_group ? try(aws_elasticache_parameter_group.this[0].id, "") : var.parameter_group_name
}

output "subnet_group_id" {
  description = "The ID of the subnet group used"
  value       = var.create_subnet_group ? try(aws_elasticache_subnet_group.this[0].id, "") : var.subnet_group_name
}
