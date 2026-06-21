variable "name" {
  description = "The name of the resource group."
  type        = string
}

variable "description" {
  description = "A description of the resource group."
  type        = string
  default     = null
}

variable "query_type" {
  description = "The type of the resource query. Valid values are 'TAG_FILTERS_1_0' or 'CLOUDFORMATION_STACK_1_0'."
  type        = string
  default     = "TAG_FILTERS_1_0"
}

variable "resource_type_filters" {
  description = "A list of resource types to include in the resource group. Defaults to AWS::AllSupported."
  type        = list(string)
  default     = ["AWS::AllSupported"]
}

variable "query_tags" {
  description = "A map of tag keys and list of values to filter resources by. Used when query_type is 'TAG_FILTERS_1_0'."
  type        = map(list(string))
  default     = {}
}

variable "query_stack_identifier" {
  description = "The CloudFormation stack ARN to filter resources by. Required if query_type is 'CLOUDFORMATION_STACK_1_0'."
  type        = string
  default     = null
}

variable "configuration" {
  description = "A list of configuration blocks for service-linked resource groups. If specified, resource_query will be disabled."
  type = list(object({
    type = string
    parameters = list(object({
      name   = string
      values = list(string)
    }))
  }))
  default = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource group itself."
  type        = map(string)
  default     = {}
}
