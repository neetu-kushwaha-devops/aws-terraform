output "aurora_cluster_id" {
  description = "The ID of the Aurora cluster"
  value       = aws_rds_cluster.this.id
}

output "aurora_cluster_arn" {
  description = "The ARN of the Aurora cluster"
  value       = aws_rds_cluster.this.arn
}

output "aurora_cluster_endpoint" {
  description = "The writer endpoint for the Aurora cluster"
  value       = aws_rds_cluster.this.endpoint
}

output "aurora_cluster_reader_endpoint" {
  description = "The reader endpoint for the Aurora cluster"
  value       = aws_rds_cluster.this.reader_endpoint
}

output "aurora_cluster_port" {
  description = "The port of the Aurora cluster"
  value       = aws_rds_cluster.this.port
}

output "aurora_cluster_database_name" {
  description = "The name of the database created"
  value       = aws_rds_cluster.this.database_name
}

output "aurora_cluster_master_username" {
  description = "The master username for the database"
  value       = aws_rds_cluster.this.master_username
}

output "aurora_cluster_members" {
  description = "List of RDS Instances that are members of the cluster"
  value       = aws_rds_cluster_instance.this[*].id
}

output "db_subnet_group_name" {
  description = "The subnet group name used by the cluster"
  value       = var.db_subnet_group_name != null ? var.db_subnet_group_name : (length(aws_db_subnet_group.this) > 0 ? aws_db_subnet_group.this[0].name : null)
}
