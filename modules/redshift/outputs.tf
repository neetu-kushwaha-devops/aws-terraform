output "redshift_cluster_id" {
  description = "The Redshift cluster identifier"
  value       = aws_redshift_cluster.this.id
}

output "redshift_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the Redshift cluster"
  value       = aws_redshift_cluster.this.arn
}

output "endpoint" {
  description = "The connection endpoint, in format host:port"
  value       = aws_redshift_cluster.this.endpoint
}

output "dns_name" {
  description = "The DNS name of the cluster endpoint"
  value       = aws_redshift_cluster.this.dns_name
}

output "database_name" {
  description = "The database name"
  value       = aws_redshift_cluster.this.database_name
}

output "port" {
  description = "The port the cluster responds on"
  value       = aws_redshift_cluster.this.port
}

output "subnet_group_id" {
  description = "The ID of the Redshift subnet group"
  value       = var.create_subnet_group ? try(aws_redshift_subnet_group.this[0].id, "") : var.cluster_subnet_group_name
}
