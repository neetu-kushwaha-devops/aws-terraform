output "stack_id" {
  description = "The unique identifier of the CloudFormation Stack"
  value       = try(aws_cloudformation_stack.this[0].id, null)
}

output "stack_outputs" {
  description = "A map of outputs from the CloudFormation Stack"
  value       = try(aws_cloudformation_stack.this[0].outputs, {})
}

output "stack_set_id" {
  description = "The ID of the CloudFormation StackSet"
  value       = try(aws_cloudformation_stack_set.this[0].id, null)
}

output "stack_set_arn" {
  description = "The ARN of the CloudFormation StackSet"
  value       = try(aws_cloudformation_stack_set.this[0].arn, null)
}

output "stack_set_instances" {
  description = "A map of stack set instances created, keyed by a generated unique key"
  value       = aws_cloudformation_stack_set_instance.this
}
