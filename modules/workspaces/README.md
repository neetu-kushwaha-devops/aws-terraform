# AWS WorkSpaces Terraform Module

This module registers an existing Directory Service (Simple AD, AD Connector, or Managed Microsoft AD) for AWS WorkSpaces, configures self-service permissions and device access properties, defines an IP access control group to restrict client access, and provisions encrypted WorkSpaces for users.

## Features
- **Directory Registration**: Seamlessly registers directories with customization of self-service permissions, client device types, and network parameters.
- **Client Security**: Enforces IP-based whitelist rules via `aws_workspaces_ip_group` for client connection security.
- **Default Encryption**: OS and User volumes are encrypted by default, allowing custom KMS keys or default AWS managed KMS keys (`aws/workspaces`).
- **Flexible Management**: Disables credential caching and manages diagnostic log uploads using AWS CLI (optional/customizable).
- **Flexible WorkSpaces Provisioning**: Easily define users, bundles, volumes, running modes (AUTO_STOP/ALWAYS_ON), compute types, and specific tags per workspace.

## Usage

```hcl
module "workspaces" {
  source = "./modules/workspaces"

  name         = "corp-workspaces"
  directory_id = "d-906732a342"
  subnet_ids   = ["subnet-0c9f1a2b3c4d5e6f7", "subnet-0a8b7c6d5e4f3g2h1"]

  # IP rules whitelist
  ip_rules = [
    {
      source      = "203.0.113.50/32"
      description = "HQ Gateway"
    },
    {
      source      = "198.51.100.0/24"
      description = "Engineering VPN"
    }
  ]

  # Self-Service permissions for users
  self_service_restart_workspace    = true
  self_service_increase_volume_size = false
  self_service_change_compute_type  = false

  # Device type access control
  device_type_web     = "DENY"
  device_type_android = "DENY"

  # Provision WorkSpaces
  workspaces = [
    {
      username           = "alice"
      bundle_id          = "wsb-8v15vzt3g" # Standard Windows Bundle ID
      volume_encryption  = true
      custom_kms_key_arn = null # Uses default AWS-managed aws/workspaces key
      running_mode       = "AUTO_STOP"
      compute_type       = "STANDARD"
      tags = {
        Department = "DevOps"
      }
    },
    {
      username           = "bob"
      bundle_id          = "wsb-8v15vzt3g"
      volume_encryption  = true
      custom_kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-abcd-1234-abcd-1234abcd5678"
      running_mode       = "ALWAYS_ON"
      compute_type       = "PERFORMANCE"
      tags = {
        Department = "DataScience"
      }
    }
  ]

  tags = {
    Environment = "production"
    Project     = "mlops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Base name to be used for resources in this module | `string` | n/a | yes |
| `tags` | A map of tags to assign to the resources | `map(string)` | `{}` | no |
| `directory_id` | The Directory Service ID to register for WorkSpaces | `string` | n/a | yes |
| `subnet_ids` | The subnets where the WorkSpaces directory will be registered | `list(string)` | `[]` | no |
| `register_directory` | Whether to register the directory. Set to false if already registered | `bool` | `true` | no |
| `self_service_change_compute_type` | Whether users can change the compute type (bundle) for their WorkSpace | `bool` | `false` | no |
| `self_service_increase_volume_size` | Whether users can increase the volume size of their WorkSpace | `bool` | `false` | no |
| `self_service_rebuild_workspace` | Whether users can rebuild the operating system of their WorkSpace | `bool` | `false` | no |
| `self_service_restart_workspace` | Whether users can restart their WorkSpace | `bool` | `true` | no |
| `self_service_switch_running_mode` | Whether users can switch the running mode of their WorkSpace | `bool` | `false` | no |
| `device_type_android` | Whether Android devices can access WorkSpaces (`ALLOW` or `DENY`) | `string` | `"ALLOW"` | no |
| `device_type_chromeos` | Whether ChromeOS devices can access WorkSpaces (`ALLOW` or `DENY`) | `string` | `"ALLOW"` | no |
| `device_type_ios` | Whether iOS devices can access WorkSpaces (`ALLOW` or `DENY`) | `string` | `"ALLOW"` | no |
| `device_type_linux` | Whether Linux devices can access WorkSpaces (`ALLOW` or `DENY`) | `string` | `"ALLOW"` | no |
| `device_type_osx` | Whether macOS devices can access WorkSpaces (`ALLOW` or `DENY`) | `string` | `"ALLOW"` | no |
| `device_type_web` | Whether web browser clients can access WorkSpaces (`ALLOW` or `DENY`) | `string` | `"ALLOW"` | no |
| `device_type_windows` | Whether Windows devices can access WorkSpaces (`ALLOW` or `DENY`) | `string` | `"ALLOW"` | no |
| `device_type_zeroclient` | Whether Zero Client devices can access WorkSpaces (`ALLOW` or `DENY`) | `string` | `"ALLOW"` | no |
| `enable_internet_access` | Whether to enable automatic internet access for WorkSpaces | `bool` | `true` | no |
| `enable_maintenance_mode` | Whether to enable maintenance mode for WorkSpaces | `bool` | `true` | no |
| `user_enabled_as_local_administrator` | Whether users are granted local administrator privileges on their WorkSpaces | `bool` | `false` | no |
| `default_ou` | The default organizational unit (OU) for your WorkSpace directories | `string` | `null` | no |
| `custom_security_group_id` | The identifier of your custom security group to associate with WorkSpaces | `string` | `null` | no |
| `reconnect_enabled` | Whether users can cache credentials to auto reconnect (`ENABLED`/`DISABLED`) | `string` | `"DISABLED"` | no |
| `log_upload_enabled` | Whether users are permitted to upload diagnostic logs (`ENABLED`/`DISABLED`) | `string` | `"ENABLED"` | no |
| `enable_client_properties_management` | Whether to manage client properties (like credential caching) via AWS CLI local-exec | `bool` | `false` | no |
| `workspaces` | List of workspaces to create (containing username, bundle_id, volume_encryption, custom_kms_key_arn, running_mode, compute_type, etc.) | `list(object)` | `[]` | no |
| `ip_rules` | List of IP rules allowed to access workspaces (containing source and optional description) | `list(object)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| `workspaces_details` | A map of created WorkSpaces with their details (id, ip_address, state, computer_name, user_name) |
| `directory_id` | The ID of the registered WorkSpaces directory |
| `ip_group_id` | The ID of the IP access control group, if created |
