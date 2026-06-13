output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.this.address
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.this.id
}

output "db_instance_resource_id" {
  description = "The RDS instance resource ID"
  value       = aws_db_instance.this.resource_id
}

output "db_instance_status" {
  description = "The status of the RDS instance"
  value       = aws_db_instance.this.status
}

output "db_instance_port" {
  description = "The database port"
  value       = aws_db_instance.this.port
}

output "db_subnet_group_name" {
  description = "The subnet group name"
  value       = var.db_subnet_group_name != null ? var.db_subnet_group_name : (length(aws_db_subnet_group.this) > 0 ? aws_db_subnet_group.this[0].name : null)
}

output "db_parameter_group_name" {
  description = "The parameter group name"
  value       = var.create_parameter_group ? aws_db_parameter_group.this[0].name : var.parameter_group_name
}
