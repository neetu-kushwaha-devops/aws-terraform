variable "enable" {
  description = "Whether to enable AWS Security Hub"
  type        = bool
  default     = true
}

variable "enable_default_standards" {
  description = "Whether to enable default standards. Set to false if managing standards explicitly via aws_securityhub_standards_subscription."
  type        = bool
  default     = false
}

variable "control_finding_generator" {
  description = "Updates whether Security Hub is online or offline. Valid values are STANDARD_CONTROL or SECURITY_CONTROL."
  type        = string
  default     = "SECURITY_CONTROL"
}

variable "auto_enable_controls" {
  description = "Whether to auto-enable new controls when they are added to standards that are enabled"
  type        = bool
  default     = true
}

variable "enable_aws_foundational_standard" {
  description = "Whether to subscribe to the AWS Foundational Security Best Practices standard"
  type        = bool
  default     = true
}

variable "enable_cis_standard" {
  description = "Whether to subscribe to the CIS AWS Foundations Benchmark standard"
  type        = bool
  default     = true
}

variable "cis_standard_version" {
  description = "Version of the CIS AWS Foundations Benchmark to subscribe to (e.g., 1.2.0, 1.4.0, 3.0.0)"
  type        = string
  default     = "1.4.0"
}

variable "enable_pci_dss_standard" {
  description = "Whether to subscribe to the PCI DSS standard"
  type        = bool
  default     = false
}

variable "pci_dss_standard_version" {
  description = "Version of the PCI DSS standard (e.g., 3.2.1)"
  type        = string
  default     = "3.2.1"
}

variable "tags" {
  description = "A mapping of tags to assign to resources (where supported)"
  type        = map(string)
  default     = {}
}

