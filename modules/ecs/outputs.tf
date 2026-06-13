output "cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.this.id
}

output "cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = aws_ecs_cluster.this.arn
}

output "cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "task_definition_arn" {
  description = "The ARN of the task definition"
  value       = try(aws_ecs_task_definition.this[0].arn, var.task_definition_arn)
}

output "task_definition_family" {
  description = "The family of the task definition"
  value       = try(aws_ecs_task_definition.this[0].family, null)
}

output "service_id" {
  description = "The ID of the ECS service"
  value       = try(aws_ecs_service.this[0].id, null)
}

output "service_name" {
  description = "The name of the ECS service"
  value       = try(aws_ecs_service.this[0].name, null)
}

output "execution_role_arn" {
  description = "The ARN of the ECS task execution IAM role"
  value       = try(aws_iam_role.ecs_execution[0].arn, var.execution_role_arn)
}

output "task_role_arn" {
  description = "The ARN of the ECS task IAM role"
  value       = try(aws_iam_role.ecs_task[0].arn, var.task_role_arn)
}

output "log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = try(aws_cloudwatch_log_group.this[0].name, null)
}
