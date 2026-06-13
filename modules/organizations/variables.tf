variable "organization_name" {
  description = "The name of the organization (used primarily for tagging and documentation purposes)"
  type        = string
}

variable "create_organization" {
  description = "Whether to create the AWS Organization. If false, references an existing organization."
  type        = bool
  default     = true
}

variable "feature_set" {
  description = "The feature set of the organization. Must be ALL or CONSOLIDATED_BILLING."
  type        = string
  default     = "ALL"
}

variable "aws_service_access_principals" {
  description = "List of AWS service principal names to enable integration with your organization"
  type        = list(string)
  default     = []
}

variable "enabled_policy_types" {
  description = "List of Organizations policy types to enable. E.g. SERVICE_CONTROL_POLICY, TAG_POLICY, BACKUP_POLICY"
  type        = list(string)
  default     = ["SERVICE_CONTROL_POLICY"]
}

variable "organizational_units" {
  description = "Map of Organizational Units to create. Key is a logical name, and value is the name of the OU."
  type = map(object({
    name      = string
    parent_id = optional(string)
  }))
  default = {
    sandbox = { name = "Sandbox" }
    dev     = { name = "Development" }
    prod    = { name = "Production" }
  }
}

variable "accounts" {
  description = "Map of member accounts to create under the organization. The ou_key must refer to a key in organizational_units or 'root'."
  type = map(object({
    name                       = string
    email                      = string
    ou_key                     = string
    iam_user_access_to_billing = optional(string, "ALLOW")
    role_name                  = optional(string, "OrganizationAccountAccessRole")
  }))
  default = {}
}

variable "enable_deny_root_scp" {
  description = "If true, creates an SCP to deny root user access in member accounts."
  type        = bool
  default     = false
}

variable "deny_root_scp_targets" {
  description = "List of OU keys or 'root' where the Deny Root SCP should be attached."
  type        = list(string)
  default     = []
}

variable "enable_prevent_leave_org_scp" {
  description = "If true, creates an SCP to prevent member accounts from leaving the organization."
  type        = bool
  default     = false
}

variable "prevent_leave_org_scp_targets" {
  description = "List of OU keys or 'root' where the Prevent Leave Org SCP should be attached."
  type        = list(string)
  default     = []
}

variable "enable_region_restriction_scp" {
  description = "If true, creates an SCP to restrict operations to approved AWS regions."
  type        = bool
  default     = false
}

variable "allowed_regions" {
  description = "List of AWS regions allowed under the region restriction SCP."
  type        = list(string)
  default     = ["us-east-1", "us-west-2"]
}

variable "restrict_regions_scp_targets" {
  description = "List of OU keys or 'root' where the Restrict Regions SCP should be attached."
  type        = list(string)
  default     = []
}

variable "service_control_policies" {
  description = "Map of custom Service Control Policies (SCPs) to create. Key is a logical name, value details name, description, and JSON content."
  type = map(object({
    name        = string
    description = optional(string, "Managed by Terraform")
    content     = string
  }))
  default = {}
}

variable "custom_policy_attachments" {
  description = "Map of custom policy attachments. Key is logical name, value contains policy_key and target_key (OU logical key, account logical key, or 'root')."
  type = map(object({
    policy_key = string
    target_key = string
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to assign to resources that support tagging"
  type        = map(string)
  default     = {}
}
