output "parameters" {
  description = "A map of all created SSM parameters and their attributes (arn, name, type)."
  value = {
    for k, v in aws_ssm_parameter.this : k => {
      arn  = v.arn
      name = v.name
      type = v.type
    }
  }
}

output "parameter_names" {
  description = "A map of parameter keys to parameter names"
  value       = { for k, v in aws_ssm_parameter.this : k => v.name }
}

output "parameter_arns" {
  description = "A map of parameter keys to parameter ARNs"
  value       = { for k, v in aws_ssm_parameter.this : k => v.arn }
}
