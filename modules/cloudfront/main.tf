# CloudFront Origin Access Control (OAC) for S3 origins
resource "aws_cloudfront_origin_access_control" "this" {
  count                             = var.create_origin_access_control ? 1 : 0
  name                              = var.origin_access_control_name != "" ? var.origin_access_control_name : "${var.name}-oac"
  description                       = "Origin Access Control for S3 origins of ${var.name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "this" {
  enabled             = var.enabled
  aliases             = var.aliases
  comment             = var.comment != "" ? var.comment : "CloudFront distribution for ${var.name}"
  default_root_object = var.default_root_object
  price_class         = var.price_class
  web_acl_id          = var.web_acl_id != "" ? var.web_acl_id : null
  http_version        = var.http_version
  is_ipv6_enabled     = var.is_ipv6_enabled
  tags                = merge({ Name = var.name }, var.tags)

  # Dynamic Origins (supports S3 and custom endpoints like ALB)
  dynamic "origin" {
    for_each = var.origins
    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.origin_id
      origin_path = origin.value.origin_path

      # Associates the generated OAC if use_origin_access_control is true, or uses passed ID
      origin_access_control_id = origin.value.use_origin_access_control ? (
        var.create_origin_access_control ? aws_cloudfront_origin_access_control.this[0].id : null
      ) : origin.value.origin_access_control_id

      # S3 Legacy Origin config (OAI)
      dynamic "s3_origin_config" {
        for_each = origin.value.s3_origin_config != null && !origin.value.use_origin_access_control && origin.value.origin_access_control_id == null ? [origin.value.s3_origin_config] : []
        content {
          origin_access_identity = s3_origin_config.value.origin_access_identity
        }
      }

      # Custom Origin config (ALB, API Gateway, etc.)
      dynamic "custom_origin_config" {
        for_each = origin.value.custom_origin_config != null ? [origin.value.custom_origin_config] : []
        content {
          http_port                = custom_origin_config.value.http_port
          https_port               = custom_origin_config.value.https_port
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
          origin_keepalive_timeout = custom_origin_config.value.origin_keepalive_timeout
          origin_read_timeout      = custom_origin_config.value.origin_read_timeout
        }
      }

      # Custom Origin headers
      dynamic "custom_header" {
        for_each = origin.value.custom_headers
        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }
    }
  }

  # Default Cache Behavior
  default_cache_behavior {
    target_origin_id       = var.default_cache_behavior.target_origin_id
    viewer_protocol_policy = var.default_cache_behavior.viewer_protocol_policy
    allowed_methods        = var.default_cache_behavior.allowed_methods
    cached_methods         = var.default_cache_behavior.cached_methods
    compress               = var.default_cache_behavior.compress

    # Policy attachments
    cache_policy_id            = var.default_cache_behavior.cache_policy_id
    origin_request_policy_id   = var.default_cache_behavior.origin_request_policy_id
    response_headers_policy_id = var.default_cache_behavior.response_headers_policy_id

    # Legacy attributes only set if cache policy is not used
    min_ttl     = var.default_cache_behavior.cache_policy_id == null ? var.default_cache_behavior.min_ttl : null
    default_ttl = var.default_cache_behavior.cache_policy_id == null ? var.default_cache_behavior.default_ttl : null
    max_ttl     = var.default_cache_behavior.cache_policy_id == null ? var.default_cache_behavior.max_ttl : null

    dynamic "forwarded_values" {
      for_each = var.default_cache_behavior.cache_policy_id == null ? [1] : []
      content {
        query_string = var.default_cache_behavior.query_string
        headers      = var.default_cache_behavior.headers
        cookies {
          forward           = var.default_cache_behavior.cookies_forward
          whitelisted_names = var.default_cache_behavior.cookies_whitelisted_names
        }
      }
    }
  }

  # Ordered Cache Behaviors (Precedence Rules)
  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors
    content {
      path_pattern           = ordered_cache_behavior.value.path_pattern
      target_origin_id       = ordered_cache_behavior.value.target_origin_id
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy
      allowed_methods        = ordered_cache_behavior.value.allowed_methods
      cached_methods         = ordered_cache_behavior.value.cached_methods
      compress               = ordered_cache_behavior.value.compress

      cache_policy_id            = ordered_cache_behavior.value.cache_policy_id
      origin_request_policy_id   = ordered_cache_behavior.value.origin_request_policy_id
      response_headers_policy_id = ordered_cache_behavior.value.response_headers_policy_id

      min_ttl     = ordered_cache_behavior.value.cache_policy_id == null ? ordered_cache_behavior.value.min_ttl : null
      default_ttl = ordered_cache_behavior.value.cache_policy_id == null ? ordered_cache_behavior.value.default_ttl : null
      max_ttl     = ordered_cache_behavior.value.cache_policy_id == null ? ordered_cache_behavior.value.max_ttl : null

      dynamic "forwarded_values" {
        for_each = ordered_cache_behavior.value.cache_policy_id == null ? [1] : []
        content {
          query_string = ordered_cache_behavior.value.query_string
          headers      = ordered_cache_behavior.value.headers
          cookies {
            forward           = ordered_cache_behavior.value.cookies_forward
            whitelisted_names = ordered_cache_behavior.value.cookies_whitelisted_names
          }
        }
      }
    }
  }

  # Viewer SSL/TLS Certificate configuration
  viewer_certificate {
    cloudfront_default_certificate = var.acm_certificate_arn == "" ? true : false
    acm_certificate_arn            = var.acm_certificate_arn != "" ? var.acm_certificate_arn : null
    ssl_support_method             = var.acm_certificate_arn != "" ? var.ssl_support_method : null
    minimum_protocol_version       = var.acm_certificate_arn != "" ? var.minimum_protocol_version : "TLSv1.1_2016"
  }

  # Geo Restrictions
  restrictions {
    geo_restriction {
      restriction_type = var.restriction_type
      locations        = var.restriction_type != "none" ? var.restriction_locations : null
    }
  }

  # Custom Error Responses
  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }
}
