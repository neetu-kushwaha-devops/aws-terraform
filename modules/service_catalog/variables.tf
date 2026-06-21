variable "name" {
  description = "The name of the Service Catalog Portfolio."
  type        = string
}

variable "provider_name" {
  description = "The provider name of the portfolio."
  type        = string
  default     = "IT Team"
}

variable "description" {
  description = "The description of the portfolio."
  type        = string
  default     = "Service Catalog Portfolio"
}

variable "products" {
  description = "A map of products to create and associate with the portfolio. The keys are logical identifiers."
  type = map(object({
    name                = string
    owner               = string
    description         = optional(string)
    distributor         = optional(string)
    support_email       = optional(string)
    support_description = optional(string)
    support_url         = optional(string)
    type                = optional(string, "CLOUD_FORMATION_TEMPLATE")
    provisioning_artifacts = list(object({
      name                        = string
      description                 = optional(string)
      template_url                = optional(string)
      template_physical_id        = optional(string)
      type                        = optional(string, "CLOUD_FORMATION_TEMPLATE")
      disable_template_validation = optional(bool, false)
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "additional_product_ids" {
  description = "A list of existing Service Catalog Product IDs to associate with the portfolio."
  type        = list(string)
  default     = []
}

variable "principal_arns" {
  description = "A list of IAM Principal ARNs to associate with the portfolio."
  type        = list(string)
  default     = []
}

variable "launch_constraints" {
  description = "Map of launch constraints to apply. Keys can be the same keys as `products` map or external product IDs."
  type = map(object({
    product_key = string
    role_arn    = string
    description = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
