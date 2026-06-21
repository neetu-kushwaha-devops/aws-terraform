# AWS WorkSpaces Terraform Module - variables.tf
# Variable declarations for the WorkSpaces module.

variable "name" {
  description = "Base name to be used for resources in this module"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "directory_id" {
  description = "The Directory Service ID to register for WorkSpaces"
  type        = string
}

variable "subnet_ids" {
  description = "The subnets where the WorkSpaces directory will be registered"
  type        = list(string)
  default     = []
}

variable "register_directory" {
  description = "Whether to register the directory. Set to false if the directory is already registered."
  type        = bool
  default     = true
}

# Self-Service Permissions
variable "self_service_change_compute_type" {
  description = "Whether users can change the compute type (bundle) for their WorkSpace"
  type        = bool
  default     = false
}

variable "self_service_increase_volume_size" {
  description = "Whether users can increase the volume size of their WorkSpace"
  type        = bool
  default     = false
}

variable "self_service_rebuild_workspace" {
  description = "Whether users can rebuild the operating system of their WorkSpace"
  type        = bool
  default     = false
}

variable "self_service_restart_workspace" {
  description = "Whether users can restart their WorkSpace"
  type        = bool
  default     = true
}

variable "self_service_switch_running_mode" {
  description = "Whether users can switch the running mode of their WorkSpace"
  type        = bool
  default     = false
}

# Workspace Access Properties (Client Settings)
variable "device_type_android" {
  description = "Whether Android devices can access WorkSpaces (ALLOW or DENY)"
  type        = string
  default     = "ALLOW"
  validation {
    condition     = contains(["ALLOW", "DENY"], var.device_type_android)
    error_message = "Device type access must be either ALLOW or DENY."
  }
}

variable "device_type_chromeos" {
  description = "Whether ChromeOS devices can access WorkSpaces (ALLOW or DENY)"
  type        = string
  default     = "ALLOW"
  validation {
    condition     = contains(["ALLOW", "DENY"], var.device_type_chromeos)
    error_message = "Device type access must be either ALLOW or DENY."
  }
}

variable "device_type_ios" {
  description = "Whether iOS devices can access WorkSpaces (ALLOW or DENY)"
  type        = string
  default     = "ALLOW"
  validation {
    condition     = contains(["ALLOW", "DENY"], var.device_type_ios)
    error_message = "Device type access must be either ALLOW or DENY."
  }
}

variable "device_type_linux" {
  description = "Whether Linux devices can access WorkSpaces (ALLOW or DENY)"
  type        = string
  default     = "ALLOW"
  validation {
    condition     = contains(["ALLOW", "DENY"], var.device_type_linux)
    error_message = "Device type access must be either ALLOW or DENY."
  }
}

variable "device_type_osx" {
  description = "Whether macOS devices can access WorkSpaces (ALLOW or DENY)"
  type        = string
  default     = "ALLOW"
  validation {
    condition     = contains(["ALLOW", "DENY"], var.device_type_osx)
    error_message = "Device type access must be either ALLOW or DENY."
  }
}

variable "device_type_web" {
  description = "Whether web browser clients can access WorkSpaces (ALLOW or DENY)"
  type        = string
  default     = "ALLOW"
  validation {
    condition     = contains(["ALLOW", "DENY"], var.device_type_web)
    error_message = "Device type access must be either ALLOW or DENY."
  }
}

variable "device_type_windows" {
  description = "Whether Windows devices can access WorkSpaces (ALLOW or DENY)"
  type        = string
  default     = "ALLOW"
  validation {
    condition     = contains(["ALLOW", "DENY"], var.device_type_windows)
    error_message = "Device type access must be either ALLOW or DENY."
  }
}

variable "device_type_zeroclient" {
  description = "Whether Zero Client devices can access WorkSpaces (ALLOW or DENY)"
  type        = string
  default     = "ALLOW"
  validation {
    condition     = contains(["ALLOW", "DENY"], var.device_type_zeroclient)
    error_message = "Device type access must be either ALLOW or DENY."
  }
}

# Workspace Creation Properties
variable "enable_internet_access" {
  description = "Whether to enable automatic internet access for WorkSpaces"
  type        = bool
  default     = true
}

variable "enable_maintenance_mode" {
  description = "Whether to enable maintenance mode for WorkSpaces"
  type        = bool
  default     = true
}

variable "user_enabled_as_local_administrator" {
  description = "Whether users are granted local administrator privileges on their WorkSpaces"
  type        = bool
  default     = false
}

variable "default_ou" {
  description = "The default organizational unit (OU) for your WorkSpace directories"
  type        = string
  default     = null
}

variable "custom_security_group_id" {
  description = "The identifier of your custom security group to associate with WorkSpaces"
  type        = string
  default     = null
}

# Client Properties (caching)
variable "reconnect_enabled" {
  description = "Whether users can cache their credentials to automatically reconnect (ENABLED or DISABLED)"
  type        = string
  default     = "DISABLED"
  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.reconnect_enabled)
    error_message = "reconnect_enabled must be either ENABLED or DISABLED."
  }
}

variable "log_upload_enabled" {
  description = "Whether users are permitted to upload diagnostic logs directly to Amazon (ENABLED or DISABLED)"
  type        = string
  default     = "ENABLED"
  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.log_upload_enabled)
    error_message = "log_upload_enabled must be either ENABLED or DISABLED."
  }
}

variable "enable_client_properties_management" {
  description = "Whether to manage client properties (like credential caching) via AWS CLI local-exec. Requires AWS CLI to be configured."
  type        = bool
  default     = false
}

# Workspaces configuration
variable "workspaces" {
  description = "List of workspaces to create"
  type = list(object({
    username                                  = string
    bundle_id                                 = string
    volume_encryption                         = optional(bool, true)
    custom_kms_key_arn                        = optional(string, null)
    running_mode                              = optional(string, "AUTO_STOP")
    compute_type                              = optional(string, "STANDARD")
    root_volume_size_gib                      = optional(number, 80)
    user_volume_size_gib                      = optional(number, 10)
    running_mode_auto_stop_timeout_in_minutes = optional(number, 60)
    tags                                      = optional(map(string), {})
  }))
  default = []
}

# IP access rules
variable "ip_rules" {
  description = "List of IP rules allowed to access workspaces. Each rule is an object with source (CIDR) and optional description."
  type = list(object({
    source      = string
    description = optional(string, "Allowed CIDR block")
  }))
  default = []
}
