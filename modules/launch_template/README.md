# Launch Template Module

This module provisions an AWS EC2 Launch Template with support for:
- Image (AMI) and instance type configuration
- Custom EBS block device mappings
- Network interface specifications
- IAM instance profile association
- Detailed monitoring toggle
- Instance Metadata Service (IMDSv2) security options
- Base64 user data injection
- Tag specifications for generated instances and volumes

## Features
- Robust block device mappings configuration
- Network interface configuration supporting public IP association and security groups
- Strict IMDSv2 configuration by default (`metadata_http_tokens = "required"`)
- Instance and volume automatic tagging via `tag_specifications`

## Usage Example

```hcl
module "launch_template" {
  source = "../modules/launch_template"

  name            = "mlops-app-template"
  use_name_prefix = true
  
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
  instance_type = "c5.xlarge"
  key_name      = "mlops-deployer-key"

  # Base64-encoded user data
  user_data_base64 = base64encode(<<-EOF
                     #!/bin/bash
                     echo "Launching from template!" > /tmp/template.txt
                     EOF
  )

  # IAM Profile details
  iam_instance_profile_name = "AppInstanceProfile"

  enable_monitoring = true

  # Block device configurations (e.g. root and data volume)
  block_device_mappings = [
    {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = 30
        volume_type           = "gp3"
        delete_on_termination = true
        encrypted             = true
      }
    },
    {
      device_name = "/dev/sdb"
      ebs = {
        volume_size           = 100
        volume_type           = "gp3"
        delete_on_termination = true
        encrypted             = true
      }
    }
  ]

  # Network interface configuration
  network_interfaces = [
    {
      device_index                = 0
      associate_public_ip_address = true
      delete_on_termination       = true
      security_groups             = ["sg-0123456789abcdef0"]
    }
  ]

  # Enforce IMDSv2 (Secure defaults)
  metadata_http_endpoint = "enabled"
  metadata_http_tokens   = "required" # IMDSv2 Mandatory

  tags = {
    Environment = "production"
    Team        = "mlops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name or name prefix of the launch template | `string` | n/a | yes |
| `use_name_prefix` | Whether to use name prefix or exact name for the launch template | `bool` | `true` | no |
| `ami` | The AMI ID (image_id) to use for the launch template | `string` | n/a | yes |
| `instance_type` | The instance type to use for the launch template | `string` | `"t3.micro"` | no |
| `key_name` | The key name to use for the launch template | `string` | `null` | no |
| `user_data_base64` | The base64-encoded user data to provide when launching the instance | `string` | `null` | no |
| `iam_instance_profile_name` | The name of the IAM instance profile to associate | `string` | `null` | no |
| `iam_instance_profile_arn` | The ARN of the IAM instance profile to associate | `string` | `null` | no |
| `enable_monitoring` | Whether to enable detailed monitoring for the launched instances | `bool` | `false` | no |
| `block_device_mappings` | List of block device mappings configuration maps for the launch template | `list(any)` | `[]` | no |
| `network_interfaces` | List of network interface configurations to attach to the instances | `list(any)` | `[]` | no |
| `metadata_http_endpoint` | Whether the metadata service is available (enabled or disabled) | `string` | `"enabled"` | no |
| `metadata_http_tokens` | Whether or not IMDSv2 is mandatory (required) or optional (optional) | `string` | `"required"` | no |
| `metadata_http_put_response_hop_limit` | The desired HTTP PUT response hop limit for instance metadata requests | `number` | `1` | no |
| `metadata_instance_metadata_tags` | Whether to enable access to instance tags from the metadata service (enabled or disabled) | `string` | `"disabled"` | no |
| `tags` | A map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `launch_template_id` | The ID of the launch template |
| `launch_template_arn` | The ARN of the launch template |
| `latest_version` | The latest version of the launch template |
| `default_version` | The default version of the launch template |
