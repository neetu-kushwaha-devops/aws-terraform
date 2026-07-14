# AWS API Gateway Terraform Module

This module deploys a production-ready, highly configurable AWS API Gateway with support for:
- HTTP API Gateway (v2) routes and integration configurations
- REST API Gateway (v1) routes, OpenAPI (Swagger) definition ingestion, and resource configurations
- Lambda execution permissions association automatically
- Custom domain mapping with ACM Certificate Integration (both HTTP and REST APIs)
- CloudWatch logs integration and customizable Access Logging formatting
- Full custom tags and metadata propagation

## Usage Example

### HTTP API Gateway with Multiple Lambda Routes and Access Logging

```hcl
module "my_http_api" {
  source                = "./modules/api_gateway"
  name                  = "prediction-service-api"
  description           = "Public Gateway for Machine Learning Inference API"
  api_type              = "HTTP"
  stage_name            = "v1"
  enable_access_logging = true

  routes = {
    "predict" = {
      route_key          = "POST /predict"
      lambda_arn         = "arn:aws:lambda:us-east-1:123456789012:function:ml-predict"
      integration_type   = "AWS_PROXY"
      payload_format_version = "2.0"
    }
    "status" = {
      route_key          = "GET /status"
      lambda_arn         = "arn:aws:lambda:us-east-1:123456789012:function:ml-status"
      integration_type   = "AWS_PROXY"
      payload_format_version = "2.0"
    }
  }

  tags = {
    Environment = "production"
    System      = "mlops"
  }
}
```

### REST API Gateway using OpenAPI Schema

```hcl
module "my_rest_api" {
  source                = "./modules/api_gateway"
  name                  = "customer-rest-api"
  description           = "REST Gateway configured via OpenAPI spec"
  api_type              = "REST"
  stage_name            = "prod"
  enable_access_logging = true
  openapi_body          = file("${path.module}/openapi.yaml")
  openapi_lambda_arns   = [
    "arn:aws:lambda:us-east-1:123456789012:function:customer-get",
    "arn:aws:lambda:us-east-1:123456789012:function:customer-post"
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the API Gateway | `string` | n/a | yes |
| `description` | The description of the API Gateway | `string` | `"API Gateway managed by Terraform"` | no |
| `api_type` | The type of API Gateway. Valid values: HTTP, REST | `string` | `"HTTP"` | no |
| `stage_name` | The name of the API Gateway Stage | `string` | `"$default"` | no |
| `routes` | A map of routes configuration. Each route contains properties based on api_type (HTTP or REST) | `map(object({...}))` | `{}` | no |
| `openapi_body` | An OpenAPI definition string (only for REST API Gateway) | `string` | `null` | no |
| `openapi_lambda_arns` | List of Lambda ARNs to grant API Gateway invoke execution access to (only if using openapi_body) | `list(string)` | `[]` | no |
| `rest_endpoint_type` | The type of endpoint for REST API. Valid values: EDGE, REGIONAL, PRIVATE | `string` | `"REGIONAL"` | no |
| `enable_access_logging` | Whether to enable access logging for the API Stage | `bool` | `false` | no |
| `access_log_retention_in_days` | Specifies the number of days to retain access log events in CloudWatch | `number` | `14` | no |
| `access_log_format` | The format of the access log statement | `string` | *JSON block details* | no |
| `custom_domain_name` | Custom domain name to associate with the API Gateway | `string` | `null` | no |
| `acm_certificate_arn` | The ARN of an ACM certificate for the custom domain | `string` | `null` | no |
| `security_policy` | The Transport Layer Security (TLS) version to use for custom domain | `string` | `"TLS_1_2"` | no |
| `tags` | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `api_id` | The ID of the API Gateway (REST or HTTP) |
| `api_arn` | The ARN of the API Gateway (REST or HTTP) |
| `api_endpoint` | The HTTP/REST Endpoint of the API Gateway |
| `stage_name` | The name of the API Gateway stage |
| `stage_arn` | The ARN of the API Gateway Stage |
| `custom_domain_target_domain_name` | The target domain name to point DNS to |
| `custom_domain_hosted_zone_id` | The hosted zone ID of the custom domain |
