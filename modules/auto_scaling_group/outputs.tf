output "asg_id" {
  description = "The Auto Scaling Group ID"
  value       = aws_autoscaling_group.this.id
}

output "asg_arn" {
  description = "The Auto Scaling Group ARN"
  value       = aws_autoscaling_group.this.arn
}

output "asg_name" {
  description = "The Auto Scaling Group name"
  value       = aws_autoscaling_group.this.name
}

output "cpu_scaling_policy_arn" {
  description = "The ARN of the CPU target tracking scaling policy"
  value       = length(aws_autoscaling_policy.cpu_target_tracking) > 0 ? aws_autoscaling_policy.cpu_target_tracking[0].arn : null
}

output "alb_request_scaling_policy_arn" {
  description = "The ARN of the ALB request count target tracking scaling policy"
  value       = length(aws_autoscaling_policy.alb_request_tracking) > 0 ? aws_autoscaling_policy.alb_request_tracking[0].arn : null
}
