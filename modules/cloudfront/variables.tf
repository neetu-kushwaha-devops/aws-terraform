variable "name" {
  description = "A unique identifier prefix or suffix name for the distribution"
  type        = string
}

variable "enabled" {
  description = "Whether the distribution is enabled to accept end-user requests for content"
  type        = bool
  default     = true
}

variable "aliases" {
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution"
  type        = list(string)
  default     = []
}

variable "comment" {
  description = "Any comments you want to include about the distribution"
  type        = string
  default     = ""
}

variable "default_root_object" {
  description = "The object that you want CloudFront to return when an end-user requests the root URL"
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "The price class for this distribution. Can be PriceClass_All, PriceClass_200, or PriceClass_100"
  type        = string
  default     = "PriceClass_100"
}

variable "web_acl_id" {
  description = "The ARN of the WAFv2 Web ACL to associate with this distribution. Must be in us-east-1"
  type        = string
  default     = ""
}

variable "http_version" {
  description = "The maximum HTTP version that you want viewers to use to communicate with CloudFront"
  type        = string
  default     = "http2and3"
}

variable "is_ipv6_enabled" {
  description = "Whether IPv6 is enabled for the distribution"
  type        = bool
  default     = true
}

variable "create_origin_access_control" {
  description = "Whether to create an Origin Access Control (OAC) for S3 origins"
  type        = bool
  default     = true
}

variable "origin_access_control_name" {
  description = "The name of the Origin Access Control. Defaults to var.name-oac if left blank"
  type        = string
  default     = ""
}

variable "origins" {
  description = "A list of origins to configure for the distribution. Supports custom_origin_config and s3_origin_config"
  type = list(object({
    origin_id   = string
    domain_name = string
    origin_path = optional(string)
    custom_origin_config = optional(object({
      http_port                = number
      https_port               = number
      origin_protocol_policy   = string # "http-only", "https-only", "match-viewer"
      origin_ssl_protocols     = list(string)
      origin_keepalive_timeout = optional(number)
      origin_read_timeout      = optional(number)
    }))
    s3_origin_config = optional(object({
      origin_access_identity = optional(string)
    }))
    use_origin_access_control = optional(bool, false)
    origin_access_control_id  = optional(string)
    custom_headers = optional(list(object({
      name  = string
      value = string
    })), [])
  }))
}

variable "default_cache_behavior" {
  description = "The default cache behavior configuration"
  type = object({
    target_origin_id       = string
    viewer_protocol_policy = string # "allow-all", "redirect-to-https", "https-only"
    allowed_methods        = optional(list(string), ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"])
    cached_methods         = optional(list(string), ["GET", "HEAD"])
    compress               = optional(bool, true)

    # Modern Cache/Origin Request Policies
    cache_policy_id            = optional(string)
    origin_request_policy_id   = optional(string)
    response_headers_policy_id = optional(string)

    # Legacy Forwarded Values (Ignored if cache_policy_id is provided)
    query_string              = optional(bool, false)
    headers                   = optional(list(string), [])
    cookies_forward           = optional(string, "none") # "none", "all", "whitelist"
    cookies_whitelisted_names = optional(list(string), [])

    min_ttl     = optional(number)
    default_ttl = optional(number)
    max_ttl     = optional(number)
  })
}

variable "ordered_cache_behaviors" {
  description = "An ordered list of cache behaviors (from highest to lowest priority)"
  type = list(object({
    path_pattern           = string
    target_origin_id       = string
    viewer_protocol_policy = string
    allowed_methods        = optional(list(string), ["GET", "HEAD", "OPTIONS"])
    cached_methods         = optional(list(string), ["GET", "HEAD"])
    compress               = optional(bool, true)

    cache_policy_id            = optional(string)
    origin_request_policy_id   = optional(string)
    response_headers_policy_id = optional(string)

    query_string              = optional(bool, false)
    headers                   = optional(list(string), [])
    cookies_forward           = optional(string, "none")
    cookies_whitelisted_names = optional(list(string), [])

    min_ttl     = optional(number)
    default_ttl = optional(number)
    max_ttl     = optional(number)
  }))
  default = []
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate to use. Must be in us-east-1 for CloudFront"
  type        = string
  default     = ""
}

variable "ssl_support_method" {
  description = "The SSL support method (sni-only or vip)"
  type        = string
  default     = "sni-only"
}

variable "minimum_protocol_version" {
  description = "The minimum SSL/TLS protocol version to use"
  type        = string
  default     = "TLSv1.2_2021"
}

variable "restriction_type" {
  description = "Method for geo-restrictions: none, whitelist, blacklist"
  type        = string
  default     = "none"
}

variable "restriction_locations" {
  description = "ISO 3166-1-alpha-2 country codes for geo-restrictions"
  type        = list(string)
  default     = []
}

variable "custom_error_responses" {
  description = "A list of custom error response configurations"
  type = list(object({
    error_code            = number
    response_code         = optional(number)
    response_page_path    = optional(string)
    error_caching_min_ttl = optional(number)
  }))
  default = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
