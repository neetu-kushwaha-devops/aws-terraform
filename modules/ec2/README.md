# EC2 Module

This module provisions an Amazon EC2 instance with support for:
- Root and additional EBS block device configurations
- Conditional key pair generation
- Conditional Elastic IP (EIP) allocation and association
- IAM instance profile association
- Startup scripting via standard or base64 user data
- Toggles for detailed CloudWatch monitoring
- Flexible tagging across resources

## Features
- Full root block device volume customization (gp3 defaults with encryption enabled by default)
- Dynamic additional EBS block devices configuration
- Automatic key pair creation option (`create_key_pair = true` with `public_key` input)
- Elastic IP optional association (`associate_eip = true`)
- Detailed monitoring toggle (`monitoring = true`)

## Usage Example

```hcl
module "ec2" {
  source = "../modules/ec2"

  name          = "mlops-web-server"
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
  instance_type = "t3.medium"
  subnet_id     = "subnet-0bb1c79de3EXAMPLE"
  
  vpc_security_group_ids = ["sg-0123456789abcdef0"]
  
  # Create a new key pair
  create_key_pair = true
  key_name        = "mlops-deployer-key"
  public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6ty..."
  
  # IAM Instance Profile
  iam_instance_profile = "EC2-Read-S3-Role"

  # Detailed monitoring
  monitoring = true

  # Root block device setup
  root_volume_size = 40
  root_volume_type = "gp3"
  root_encrypted   = true

  # Additional block devices
  ebs_block_device = [
    {
      device_name           = "/dev/sdb"
      volume_size           = 100
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  ]

  # EIP association
  associate_eip = true

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello from user data!" > /tmp/hello.txt
              EOF

  tags = {
    Environment = "production"
    Team        = "mlops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name for the EC2 instance and associated resources | `string` | n/a | yes |
| `ami` | AMI ID to use for the EC2 instance | `string` | n/a | yes |
| `instance_type` | The instance type to use for the instance | `string` | `"t3.micro"` | no |
| `subnet_id` | The VPC Subnet ID to launch the instance in | `string` | n/a | yes |
| `vpc_security_group_ids` | A list of security group IDs to associate with the instance | `list(string)` | `[]` | no |
| `key_name` | The key name to use for the instance. If create_key_pair is true, this is the name of the key pair to create. | `string` | `null` | no |
| `create_key_pair` | Whether to create an aws_key_pair resource using the provided public_key | `bool` | `false` | no |
| `public_key` | The public key material to use for the created key pair. Required if create_key_pair is true. | `string` | `null` | no |
| `iam_instance_profile` | The IAM Instance Profile name to associate with the instance | `string` | `null` | no |
| `user_data` | The user data to provide when launching the instance | `string` | `null` | no |
| `user_data_base64` | The base64-encoded user data to provide when launching the instance | `string` | `null` | no |
| `associate_public_ip_address` | Whether to associate a public IP address with an instance in a VPC | `bool` | `null` | no |
| `associate_eip` | Whether to allocate and associate an Elastic IP (EIP) to the EC2 instance | `bool` | `false` | no |
| `monitoring` | If true, the launched EC2 instance will have detailed monitoring enabled | `bool` | `false` | no |
| `root_volume_size` | Size of the root volume in gigabytes | `number` | `20` | no |
| `root_volume_type` | Type of the root volume (e.g. gp2, gp3, io1, io2) | `string` | `"gp3"` | no |
| `root_delete_on_termination` | Whether the root volume should be destroyed on instance termination | `bool` | `true` | no |
| `root_encrypted` | Whether the root volume should be encrypted | `bool` | `true` | no |
| `root_kms_key_id` | The ARN of the KMS Key to use for root volume encryption. root_encrypted must be true. | `string` | `null` | no |
| `root_iops` | Amount of provisioned IOPS. Only valid for gp3, io1, and io2 volumes. | `number` | `null` | no |
| `root_throughput` | Throughput to provision for a gp3 volume in MiB/s | `number` | `null` | no |
| `ebs_block_device` | List of maps containing additional EBS block device configurations to attach to the instance | `list(any)` | `[]` | no |
| `metadata_http_endpoint` | Whether the metadata service is available (enabled or disabled) | `string` | `"enabled"` | no |
| `metadata_http_tokens` | Whether or not IMDSv2 is mandatory (required) or optional (optional) | `string` | `"required"` | no |
| `metadata_http_put_response_hop_limit` | The desired HTTP PUT response hop limit for instance metadata requests | `number` | `1` | no |
| `metadata_instance_metadata_tags` | Whether to enable access to instance tags from the metadata service (enabled or disabled) | `string` | `"disabled"` | no |
| `tags` | A map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `instance_id` | The ID of the EC2 instance |
| `arn` | The ARN of the EC2 instance |
| `public_ip` | The public IP address assigned to the instance, or EIP if associated |
| `private_ip` | The private IP address assigned to the instance |
| `key_pair_name` | The name of the key pair |
| `key_pair_arn` | The ARN of the key pair |
| `eip_public_ip` | The Elastic IP address associated with the instance |
| `eip_allocation_id` | The Allocation ID of the Elastic IP |
