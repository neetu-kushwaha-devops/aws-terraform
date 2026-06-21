output "service_id" {
  description = "The unique ID of the App Runner service"
  value       = aws_apprunner_service.this.service_id
}

output "service_arn" {
  description = "The Amazon Resource Name (ARN) of the App Runner service"
  value       = aws_apprunner_service.this.arn
}

output "service_url" {
  description = "The subdomain URL that App Runner associates with this service"
  value       = aws_apprunner_service.this.service_url
}

output "status" {
  description = "The current status of the App Runner service"
  value       = aws_apprunner_service.this.status
}

output "connection_arn" {
  description = "The ARN of the App Runner connection"
  value       = try(aws_apprunner_connection.this[0].arn, null)
}

output "vpc_connector_arn" {
  description = "The ARN of the App Runner VPC connector"
  value       = try(aws_apprunner_vpc_connector.this[0].arn, null)
}

output "auto_scaling_configuration_arn" {
  description = "The ARN of the App Runner auto-scaling configuration"
  value       = try(aws_apprunner_auto_scaling_configuration_version.this[0].arn, null)
}

output "access_role_arn" {
  description = "The ARN of the IAM role used by App Runner to access ECR"
  value       = try(aws_iam_role.access_role[0].arn, null)
}

output "instance_role_arn" {
  description = "The ARN of the IAM role used by the App Runner instances to access other AWS services"
  value       = try(aws_iam_role.instance_role[0].arn, null)
}
