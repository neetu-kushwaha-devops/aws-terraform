output "api_id" {
  description = "The ID of the API Gateway (REST or HTTP)"
  value       = var.api_type == "HTTP" ? try(aws_apigatewayv2_api.this[0].id, null) : try(aws_api_gateway_rest_api.this[0].id, null)
}

output "api_arn" {
  description = "The ARN of the API Gateway (REST or HTTP)"
  value       = var.api_type == "HTTP" ? try(aws_apigatewayv2_api.this[0].arn, null) : try(aws_api_gateway_rest_api.this[0].arn, null)
}

output "api_endpoint" {
  description = "The HTTP/REST Endpoint of the API Gateway"
  value       = var.api_type == "HTTP" ? try(aws_apigatewayv2_api.this[0].api_endpoint, null) : try(aws_api_gateway_rest_api.this[0].execution_arn, null)
}

output "stage_name" {
  description = "The name of the API Gateway stage"
  value       = var.stage_name
}

output "stage_arn" {
  description = "The ARN of the API Gateway Stage"
  value       = var.api_type == "HTTP" ? try(aws_apigatewayv2_stage.this[0].arn, null) : try(aws_api_gateway_stage.this[0].arn, null)
}

output "custom_domain_target_domain_name" {
  description = "The target domain name to point DNS to"
  value       = var.api_type == "HTTP" ? try(aws_apigatewayv2_domain_name.http[0].domain_name_configuration[0].target_domain_name, null) : try(aws_api_gateway_domain_name.rest[0].cloudfront_domain_name, null)
}

output "custom_domain_hosted_zone_id" {
  description = "The hosted zone ID of the custom domain"
  value       = var.api_type == "HTTP" ? try(aws_apigatewayv2_domain_name.http[0].domain_name_configuration[0].hosted_zone_id, null) : try(aws_api_gateway_domain_name.rest[0].cloudfront_zone_id, null)
}
