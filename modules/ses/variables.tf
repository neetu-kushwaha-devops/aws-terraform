variable "name" {
  description = "The base name for the SES resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources that support tagging"
  type        = map(string)
  default     = {}
}

variable "domain" {
  description = "The domain name to verify with SES"
  type        = string
  default     = null
}

variable "zone_id" {
  description = "The Route53 hosted zone ID to create verification and DKIM records in"
  type        = string
  default     = null
}

variable "emails" {
  description = "A list of individual email addresses to verify with SES"
  type        = list(string)
  default     = []
}

variable "enable_incoming_email" {
  description = "Whether to enable incoming email processing by creating a receipt rule set and active rule set"
  type        = bool
  default     = false
}

variable "receipt_rules" {
  description = "List of receipt rules configuration for processing incoming emails"
  type = list(object({
    name         = string
    recipients   = optional(list(string))
    enabled      = optional(bool, true)
    scan_enabled = optional(bool, false)
    tls_policy   = optional(string)
    after        = optional(string)

    add_header_actions = optional(list(object({
      header_name  = string
      header_value = string
      position     = number
    })), [])

    bounce_actions = optional(list(object({
      message         = string
      sender          = string
      smtp_reply_code = string
      status_code     = optional(string)
      topic_arn       = optional(string)
      position        = number
    })), [])

    lambda_actions = optional(list(object({
      function_arn    = string
      invocation_type = optional(string)
      topic_arn       = optional(string)
      position        = number
    })), [])

    s3_actions = optional(list(object({
      bucket_name       = string
      object_key_prefix = optional(string)
      topic_arn         = optional(string)
      position          = number
      kms_key_arn       = optional(string)
    })), [])

    sns_actions = optional(list(object({
      topic_arn = string
      position  = number
      encoding  = optional(string)
    })), [])

    stop_actions = optional(list(object({
      scope     = string
      topic_arn = optional(string)
      position  = number
    })), [])

    workmail_actions = optional(list(object({
      organization_arn = string
      topic_arn        = optional(string)
      position         = number
    })), [])
  }))
  default = []
}

variable "enable_configuration_set" {
  description = "Whether to create the SES configuration set and event destinations"
  type        = bool
  default     = true
}

variable "configuration_set_reputation_metrics_enabled" {
  description = "Whether or not to enable reputation metrics for the configuration set"
  type        = bool
  default     = false
}

variable "configuration_set_sending_enabled" {
  description = "Whether or not to enable sending for the configuration set"
  type        = bool
  default     = true
}

variable "configuration_set_tls_policy" {
  description = "Specifies whether messages that use the configuration set are required to use TLS. Can be REQUIRE or OPTIONAL."
  type        = string
  default     = null
}

variable "configuration_set_custom_redirect_domain" {
  description = "The custom redirect domain for tracking open/click events"
  type        = string
  default     = null
}

variable "event_destinations" {
  description = "List of event destinations to create for the configuration set"
  type = list(object({
    name           = string
    enabled        = optional(bool, true)
    matching_types = list(string)

    sns_destination = optional(object({
      topic_arn = string
    }))

    cloudwatch_destination = optional(object({
      default_value  = string
      dimension_name = string
      value_source   = string
    }))

    kinesis_destination = optional(object({
      stream_arn = string
      role_arn   = string
    }))
  }))
  default = []
}
