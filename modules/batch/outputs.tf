output "compute_environments_details" {
  description = "Details of the created AWS Batch compute environments"
  value = {
    for k, v in aws_batch_compute_environment.this : k => {
      arn    = v.arn
      id     = v.id
      name   = v.name
      type   = v.type
      state  = v.state
      status = v.status
    }
  }
}

output "job_queues_details" {
  description = "Details of the created AWS Batch job queues"
  value = {
    for k, v in aws_batch_job_queue.this : k => {
      arn      = v.arn
      id       = v.id
      name     = v.name
      state    = v.state
      priority = v.priority
    }
  }
}

output "job_definitions_details" {
  description = "Details of the created AWS Batch job definitions"
  value = {
    for k, v in aws_batch_job_definition.this : k => {
      arn      = v.arn
      id       = v.id
      name     = v.name
      revision = v.revision
      type     = v.type
    }
  }
}

output "batch_service_role_arn" {
  description = "ARN of the IAM role used by AWS Batch service"
  value       = try(aws_iam_role.batch_service_role[0].arn, var.service_role_arn)
}

output "ecs_instance_role_arn" {
  description = "ARN of the IAM role used by EC2 instances in Batch compute environments"
  value       = try(aws_iam_role.ecs_instance_role[0].arn, var.instance_role_arn)
}

output "ecs_instance_profile_arn" {
  description = "ARN of the IAM instance profile used by EC2 instances in Batch compute environments"
  value       = try(aws_iam_instance_profile.ecs_instance_profile[0].arn, null)
}

output "security_group_id" {
  description = "ID of the security group created for Batch EC2 instances"
  value       = try(aws_security_group.this[0].id, null)
}

output "batch_job_execution_role_arn" {
  description = "ARN of the default job execution role"
  value       = try(aws_iam_role.batch_job_execution_role[0].arn, null)
}

output "batch_job_role_arn" {
  description = "ARN of the default job role"
  value       = try(aws_iam_role.batch_job_role[0].arn, null)
}
