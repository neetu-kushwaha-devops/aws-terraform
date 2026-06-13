# -----------------------------------------------------------------------------
# CloudWatch Log Group for Access Logs
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "api_gw" {
  count             = var.enable_access_logging ? 1 : 0
  name              = "/aws/apigateway/${var.name}"
  retention_in_days = var.access_log_retention_in_days
  tags              = merge({ Name = "${var.name}-logs" }, var.tags)
}

# -----------------------------------------------------------------------------
# HTTP API Gateway (v2) Configuration
# -----------------------------------------------------------------------------
resource "aws_apigatewayv2_api" "this" {
  count         = var.api_type == "HTTP" ? 1 : 0
  name          = var.name
  description   = var.description
  protocol_type = "HTTP"
  tags          = merge({ Name = var.name }, var.tags)
}

resource "aws_apigatewayv2_integration" "this" {
  for_each               = var.api_type == "HTTP" ? var.routes : {}
  api_id                 = aws_apigatewayv2_api.this[0].id
  integration_type       = lookup(each.value, "integration_type", "AWS_PROXY")
  integration_uri        = each.value.lambda_arn
  integration_method     = lookup(each.value, "integration_method", "POST")
  payload_format_version = lookup(each.value, "payload_format_version", "2.0")
}

resource "aws_apigatewayv2_route" "this" {
  for_each  = var.api_type == "HTTP" ? var.routes : {}
  api_id    = aws_apigatewayv2_api.this[0].id
  route_key = lookup(each.value, "route_key", each.key)
  target    = "integrations/${aws_apigatewayv2_integration.this[each.key].id}"
}

resource "aws_apigatewayv2_stage" "this" {
  count       = var.api_type == "HTTP" ? 1 : 0
  api_id      = aws_apigatewayv2_api.this[0].id
  name        = var.stage_name == "$default" ? "$default" : var.stage_name
  auto_deploy = true

  dynamic "access_log_settings" {
    for_each = var.enable_access_logging ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.api_gw[0].arn
      format          = var.access_log_format
    }
  }

  tags = merge({ Name = "${var.name}-http-stage" }, var.tags)
}

resource "aws_lambda_permission" "apigw_http" {
  for_each      = var.api_type == "HTTP" ? var.routes : {}
  statement_id  = "AllowAPIGatewayInvoke-${replace(each.key, "/[^a-zA-Z0-9-_]/", "")}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this[0].execution_arn}/*/*"
}

# -----------------------------------------------------------------------------
# REST API Gateway (v1) Configuration
# -----------------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "this" {
  count       = var.api_type == "REST" ? 1 : 0
  name        = var.name
  description = var.description
  body        = var.openapi_body

  endpoint_configuration {
    types = [var.rest_endpoint_type]
  }

  tags = merge({ Name = var.name }, var.tags)
}

resource "aws_api_gateway_resource" "this" {
  for_each    = (var.api_type == "REST" && var.openapi_body == null) ? var.routes : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  parent_id   = aws_api_gateway_rest_api.this[0].root_resource_id
  path_part   = lookup(each.value, "path_part", each.key)
}

resource "aws_api_gateway_method" "this" {
  for_each      = (var.api_type == "REST" && var.openapi_body == null) ? var.routes : {}
  rest_api_id   = aws_api_gateway_rest_api.this[0].id
  resource_id   = aws_api_gateway_resource.this[each.key].id
  http_method   = lookup(each.value, "http_method", "ANY")
  authorization = lookup(each.value, "authorization", "NONE")
}

resource "aws_api_gateway_integration" "this" {
  for_each                = (var.api_type == "REST" && var.openapi_body == null) ? var.routes : {}
  rest_api_id             = aws_api_gateway_rest_api.this[0].id
  resource_id             = aws_api_gateway_resource.this[each.key].id
  http_method             = aws_api_gateway_method.this[each.key].http_method
  integration_http_method = lookup(each.value, "integration_http_method", "POST")
  type                    = lookup(each.value, "integration_type", "AWS_PROXY")
  uri                     = each.value.lambda_arn
}

resource "aws_api_gateway_deployment" "this" {
  count       = var.api_type == "REST" ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.this[0].id

  triggers = {
    redeployment = var.openapi_body != null ? sha256(var.openapi_body) : sha256(jsonencode(var.routes))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.this,
    aws_api_gateway_method.this,
    aws_api_gateway_resource.this
  ]
}

resource "aws_api_gateway_stage" "this" {
  count         = var.api_type == "REST" ? 1 : 0
  deployment_id = aws_api_gateway_deployment.this[0].id
  rest_api_id   = aws_api_gateway_rest_api.this[0].id
  stage_name    = var.stage_name == "$default" ? "default" : var.stage_name

  dynamic "access_log_settings" {
    for_each = var.enable_access_logging ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.api_gw[0].arn
      format          = var.access_log_format
    }
  }

  tags = merge({ Name = "${var.name}-rest-stage" }, var.tags)
}

resource "aws_lambda_permission" "apigw_rest" {
  for_each      = (var.api_type == "REST" && var.openapi_body == null) ? var.routes : {}
  statement_id  = "AllowAPIGatewayInvokeREST-${replace(each.key, "/[^a-zA-Z0-9-_]/", "")}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this[0].execution_arn}/*/${aws_api_gateway_method.this[each.key].http_method}/${aws_api_gateway_resource.this[each.key].path_part}"
}

resource "aws_lambda_permission" "apigw_rest_openapi" {
  count         = (var.api_type == "REST" && var.openapi_body != null) ? length(var.openapi_lambda_arns) : 0
  statement_id  = "AllowAPIGatewayInvokeRESTOpenAPI-${count.index}"
  action        = "lambda:InvokeFunction"
  function_name = var.openapi_lambda_arns[count.index]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this[0].execution_arn}/*/*"
}

# -----------------------------------------------------------------------------
# Custom Domain Configuration
# -----------------------------------------------------------------------------

# REST API Custom Domain
resource "aws_api_gateway_domain_name" "rest" {
  count           = (var.api_type == "REST" && var.custom_domain_name != null) ? 1 : 0
  domain_name     = var.custom_domain_name
  certificate_arn = var.acm_certificate_arn
  security_policy = var.security_policy
  tags            = merge({ Name = "${var.name}-rest-domain" }, var.tags)
}

resource "aws_api_gateway_base_path_mapping" "rest" {
  count       = (var.api_type == "REST" && var.custom_domain_name != null) ? 1 : 0
  api_id      = aws_api_gateway_rest_api.this[0].id
  stage_name  = aws_api_gateway_stage.this[0].stage_name
  domain_name = aws_api_gateway_domain_name.rest[0].domain_name
}

# HTTP API Custom Domain
resource "aws_apigatewayv2_domain_name" "http" {
  count       = (var.api_type == "HTTP" && var.custom_domain_name != null) ? 1 : 0
  domain_name = var.custom_domain_name
  domain_name_configuration {
    certificate_arn = var.acm_certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = var.security_policy
  }
  tags = merge({ Name = "${var.name}-http-domain" }, var.tags)
}

resource "aws_apigatewayv2_api_mapping" "http" {
  count       = (var.api_type == "HTTP" && var.custom_domain_name != null) ? 1 : 0
  api_id      = aws_apigatewayv2_api.this[0].id
  domain_name = aws_apigatewayv2_domain_name.http[0].id
  stage       = aws_apigatewayv2_stage.this[0].id
}
