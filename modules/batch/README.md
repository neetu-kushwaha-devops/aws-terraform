# AWS Batch Terraform Module

This module provides a production-ready, highly reusable Terraform implementation for AWS Batch. It manages Batch Compute Environments (Fargate & EC2), Job Queues, Job Definitions, and supporting IAM roles/security groups under secure-by-default practices.

## Features

- **EC2 & Fargate Support**: Easily configure Fargate, Fargate Spot, EC2, and EC2 Spot compute environments.
- **Enforced Security Defaults**:
  - **IMDSv2**: Enforced for all EC2 compute resources through a default Launch Template (`http_tokens = "required"`).
  - **Encrypted EBS Volumes**: Default EBS root volumes are encrypted at rest using KMS or AWS managed keys.
  - **Least-Privilege IAM Policies**: Uses dedicated, tailored IAM service roles, instance profiles, execution roles, and task roles with strict assume-role permissions.
- **Dynamic Configuration**: Easily define multiple compute environments, job queues, and job definitions via maps without modifying module code.
- **Automated IAM & Security Groups**: Optionally creates all required IAM roles and security groups, or lets you supply existing ones.
- **Zero Hardcoded IDs**: Fully customizable VPC, subnet, security group, and AMI configurations.

## Usage Examples

### 1. Fargate Batch Compute Environment

This example sets up a simple serverless batch environment using AWS Fargate.

```hcl
module "batch_fargate" {
  source = "./modules/batch"

  name   = "mlops-fargate-batch"
  vpc_id = "vpc-0123456789abcdef0"

  compute_environments = {
    fargate = {
      type = "MANAGED"
      compute_resources = {
        type               = "FARGATE"
        max_vcpus          = 16
        min_vcpus          = 0
        subnets            = ["subnet-0123456789abcdef0", "subnet-9876543210fedcba0"]
        # Security group is automatically created and attached since we passed vpc_id
      }
    }
  }

  job_queues = {
    high_priority = {
      priority             = 10
      compute_environments = ["fargate"] # References the key above
    }
  }

  job_definitions = {
    data_processing = {
      type                  = "container"
      platform_capabilities = ["FARGATE"]
      container_properties = jsonencode({
        image = "public.ecr.aws/amazonlinux/amazonlinux:latest"
        command = ["echo", "Processing ML dataset..."]
        resourceRequirements = [
          { type = "VCPU", value = "0.25" },
          { type = "MEMORY", value = "512" }
        ]
        # Execution role and Job role are automatically created and injected here
      })
    }
  }

  tags = {
    Environment = "production"
    Team        = "mlops"
  }
}
```

### 2. EC2 (Spot) Batch Compute Environment with Custom Security Configuration

This example sets up a managed EC2-Spot batch environment enforcing IMDSv2, EBS encryption, and utilizing custom security groups.

```hcl
module "batch_ec2_spot" {
  source = "./modules/batch"

  name   = "mlops-ec2-batch"
  vpc_id = "vpc-0123456789abcdef0"

  # Optional configurations for default launch template
  launch_template_volume_size = 50
  launch_template_volume_type = "gp3"

  compute_environments = {
    ec2_spot = {
      type = "MANAGED"
      compute_resources = {
        type                = "SPOT"
        max_vcpus           = 64
        min_vcpus           = 0
        instance_type       = ["c5.large", "m5.large"]
        allocation_strategy = "SPOT_CAPACITY_OPTIMIZED"
        subnets             = ["subnet-0123456789abcdef0"]
        # Override with custom security groups if desired:
        # security_group_ids = ["sg-0123456789abcdef0"]
      }
    }
  }

  job_queues = {
    default = {
      priority             = 1
      compute_environments = ["ec2_spot"]
    }
  }

  job_definitions = {
    train_model = {
      type                  = "container"
      platform_capabilities = ["EC2"]
      container_properties = jsonencode({
        image = "public.ecr.aws/amazonlinux/amazonlinux:latest"
        command = ["echo", "Training neural network..."]
        resourceRequirements = [
          { type = "VCPU", value = "2.0" },
          { type = "MEMORY", value = "4096" }
        ]
      })
    }
  }

  tags = {
    Environment = "production"
    CostCenter  = "ml-research"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Base name for AWS Batch resources (used as prefixes and Name tags) | `string` | n/a | yes |
| `vpc_id` | The VPC ID where the security group will be created. Required if `create_security_group` is true | `string` | `null` | no |
| `tags` | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |
| `create_service_role` | Whether to create a custom IAM service role for AWS Batch | `bool` | `true` | no |
| `service_role_arn` | ARN of an existing IAM role for AWS Batch service. Used if `create_service_role` is false | `string` | `null` | no |
| `service_role_additional_policies` | List of additional IAM policy ARNs to attach to the AWS Batch service role | `list(string)` | `[]` | no |
| `create_instance_role` | Whether to create a custom IAM instance profile/role for EC2 compute environments | `bool` | `true` | no |
| `instance_role_arn` | ARN of an existing IAM role for EC2 instances. Used if `create_instance_role` is false | `string` | `null` | no |
| `instance_role_additional_policies` | List of additional IAM policy ARNs to attach to the ECS instance role | `list(string)` | `[]` | no |
| `create_job_execution_role` | Whether to create a default ECS task execution role for Fargate/EC2 Batch jobs | `bool` | `true` | no |
| `job_execution_role_additional_policies` | List of additional IAM policy ARNs to attach to the job execution role | `list(string)` | `[]` | no |
| `create_job_role` | Whether to create a default IAM role for the Batch job container execution | `bool` | `true` | no |
| `job_role_additional_policies` | List of additional IAM policy ARNs to attach to the job role | `list(string)` | `[]` | no |
| `create_security_group` | Whether to create a dedicated security group for AWS Batch EC2 instances | `bool` | `true` | no |
| `security_group_ingress` | Ingress rules for the created security group | `list(object({...}))` | `[]` | no |
| `security_group_egress` | Egress rules for the created security group | `list(object({...}))` | *See below* | no |
| `create_launch_template` | Whether to create a default launch template that enforces IMDSv2 and encrypted EBS volumes for EC2 compute resources | `bool` | `true` | no |
| `launch_template_volume_size` | Size of the encrypted EBS volume in GB | `number` | `30` | no |
| `launch_template_volume_type` | Type of the encrypted EBS volume | `string` | `"gp3"` | no |
| `launch_template_device_name` | Block device name for EBS volume | `string` | `"/dev/xvda"` | no |
| `launch_template_http_put_response_hop_limit` | The HTTP put response hop limit for IMDSv2 | `number` | `2` | no |
| `kms_key_arn` | The ARN of the KMS key to encrypt EBS volumes. If null, standard AWS managed EBS key is used | `string` | `null` | no |
| `compute_environments` | Configuration map for AWS Batch compute environments | `map(object({...}))` | `{}` | no |
| `job_queues` | Configuration map for AWS Batch job queues | `map(object({...}))` | `{}` | no |
| `job_definitions` | Configuration map for AWS Batch job definitions | `map(object({...}))` | `{}` | no |

### Default Security Group Egress Rule
```hcl
[
  {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]
```

## Outputs

| Name | Description |
|------|-------------|
| `compute_environments_details` | Map of details (ARN, ID, Name, Type, State, Status) for all created compute environments |
| `job_queues_details` | Map of details (ARN, ID, Name, State, Priority) for all created job queues |
| `job_definitions_details` | Map of details (ARN, ID, Name, Revision, Type) for all created job definitions |
| `batch_service_role_arn` | ARN of the IAM role used by AWS Batch service |
| `ecs_instance_role_arn` | ARN of the IAM role used by EC2 instances in Batch compute environments |
| `ecs_instance_profile_arn` | ARN of the IAM instance profile used by EC2 instances in Batch compute environments |
| `security_group_id` | ID of the security group created for Batch EC2 instances |
| `batch_job_execution_role_arn` | ARN of the default job execution role |
| `batch_job_role_arn` | ARN of the default job role |
