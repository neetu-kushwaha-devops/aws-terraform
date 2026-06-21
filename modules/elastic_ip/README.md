# AWS Elastic IP (EIP) Module

This Terraform module creates and manages AWS Elastic IP (EIP) addresses, supporting optional association with EC2 instances or Network Interfaces.

## Features

- **Flexible Allocation**: Supports allocating single or multiple Elastic IPs.
- **Resource Association**: Dynamically associates Elastic IPs with EC2 instances or Network Interfaces if IDs are provided.
- **VPC and Standard Domain Support**: Supports both modern VPC-based EIPs and older EC2-Classic (Standard) EIPs via the `vpc` boolean flag.
- **Tag Integration**: Seamlessly merges custom tags with a standard name convention.

## Usage

### Simple EIP Allocation (No Association)

```hcl
module "eip" {
  source = "../modules/elastic_ip"
  name   = "my-app-eip"

  tags = {
    Environment = "prod"
    Project     = "mlops"
  }
}
```

### EIP with EC2 Instance Association

```hcl
module "eip_instance" {
  source      = "../modules/elastic_ip"
  name        = "my-instance-eip"
  instance_id = "i-0123456789abcdef0"

  tags = {
    Environment = "dev"
  }
}
```

### Multiple EIPs with Custom Name Tags

```hcl
module "eip_multiple" {
  source    = "../modules/elastic_ip"
  name      = "my-service-eip"
  count_eip = 3

  tags = {
    Environment = "staging"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name prefix or base name for the Elastic IP resources | `string` | n/a | yes |
| `count_eip` | Number of Elastic IPs to create | `number` | `1` | no |
| `vpc` | Boolean flag to determine if the Elastic IP is in a VPC. Sets domain to 'vpc' if true. | `bool` | `true` | no |
| `instance_id` | EC2 instance ID to associate with the Elastic IP | `string` | `null` | no |
| `network_interface_id` | Network interface ID to associate with the Elastic IP | `string` | `null` | no |
| `private_ip_address` | Private IP address to associate with the Elastic IP | `string` | `null` | no |
| `tags` | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `public_ips` | List of public IP addresses assigned to the Elastic IPs |
| `allocation_ids` | List of allocation IDs of the Elastic IPs |
| `association_ids` | List of association IDs of the Elastic IP associations |
