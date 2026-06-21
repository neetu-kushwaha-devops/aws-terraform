output "app_name" {
  description = "The name of the Elastic Beanstalk Application."
  value       = aws_elastic_beanstalk_application.this.name
}

output "app_arn" {
  description = "The ARN of the Elastic Beanstalk Application."
  value       = aws_elastic_beanstalk_application.this.arn
}

output "environment_id" {
  description = "The ID of the Elastic Beanstalk Environment."
  value       = aws_elastic_beanstalk_environment.this.id
}

output "environment_name" {
  description = "The name of the Elastic Beanstalk Environment."
  value       = aws_elastic_beanstalk_environment.this.name
}

output "environment_endpoint_url" {
  description = "The URL to the Load Balancer for this Environment."
  value       = aws_elastic_beanstalk_environment.this.endpoint_url
}

output "environment_cname" {
  description = "The fully qualified DNS name for this Environment."
  value       = aws_elastic_beanstalk_environment.this.cname
}

output "environment_tier" {
  description = "The environment tier."
  value       = aws_elastic_beanstalk_environment.this.tier
}

output "ec2_role_name" {
  description = "The name of the EC2 IAM Role created (or null if not created)."
  value       = var.create_iam_resources ? aws_iam_role.ec2[0].name : null
}

output "ec2_role_arn" {
  description = "The ARN of the EC2 IAM Role created (or null if not created)."
  value       = var.create_iam_resources ? aws_iam_role.ec2[0].arn : null
}

output "service_role_name" {
  description = "The name of the Beanstalk Service IAM Role created (or null if not created)."
  value       = var.create_iam_resources ? aws_iam_role.service[0].name : null
}

output "service_role_arn" {
  description = "The ARN of the Beanstalk Service IAM Role created (or null if not created)."
  value       = var.create_iam_resources ? aws_iam_role.service[0].arn : null
}

output "instance_profile_name" {
  description = "The name of the EC2 Instance Profile."
  value       = local.instance_profile_name
}
