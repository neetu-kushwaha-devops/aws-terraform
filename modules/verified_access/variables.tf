variable "name" {
  description = "The prefix to apply to resource names"
  type        = string
}

variable "description" {
  description = "Description for the Verified Access instance"
  type        = string
  default     = null
}

variable "trust_providers" {
  description = "Map of trust providers to create"
  type = map(object({
    policy_reference_name = string
    trust_provider_type   = string # oidc or user-trust-provider
    user_trust_provider_type = optional(string) # iam-identity-center or oidc
    oidc_options = optional(object({
      authorization_endpoint              = string
      client_id                           = string
      client_secret                       = string
      issuer                              = string
      scope                               = string
      token_endpoint                      = string
      user_info_endpoint                  = string
    }))
  }))
  default = {}
}

variable "groups" {
  description = "Map of verified access groups to create"
  type = map(object({
    description = optional(string)
    policy_document = optional(string)
  }))
  default = {}
}

variable "endpoints" {
  description = "Map of verified access endpoints to create"
  type = map(object({
    group_key              = string
    application_domain     = string
    endpoint_domain_prefix = string
    endpoint_type          = string # load-balancer or network-interface
    load_balancer_options = optional(object({
      load_balancer_arn = string
      port              = number
      protocol          = string
      subnet_ids        = list(string)
    }))
    network_interface_options = optional(object({
      network_interface_id = string
      port                 = number
      protocol             = string
    }))
    domain_certificate_arn = string
    security_group_ids     = list(string)
  }))
  default = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
