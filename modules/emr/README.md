# AWS EMR (Elastic MapReduce) Terraform Module

This module provisions a production-ready, highly reusable, and secure Amazon EMR (Elastic MapReduce) cluster. It enforces secure-by-default configurations (encryption at rest/in transit enabled by default, VPC binding, and security group isolation) while offering maximum flexibility to use custom KMS keys, security groups, bootstrap actions, configurations, and IAM roles.

## Features

- **Secure by Default**: Out-of-the-box support for at-rest encryption (EBS local disk and EMRFS on S3 via Customer Managed KMS Keys) and in-transit encryption.
- **VPC Bindings & Isolation**: Forces subnet bindings and provisions dedicated EMR-managed master, slave, and service access security groups with minimum privilege egress rules and clean lifecycle hooks.
- **IAM Management**: Creates standard EMR Service roles (`AmazonEMRServicePolicy_v2`) and EC2 Instance Profiles (`AmazonElasticMapReduceforEC2Role`) with optional permissions boundaries and custom policy attachments.
- **Dynamic Task Node Sizing**: Seamlessly manages Uniform Instance Groups for master and core nodes, along with dynamic maps of `aws_emr_instance_group` resources for spot or on-demand task groups.
- **Bootstrap & Configurations**: Full support for inline cluster bootstrap actions and custom software properties (Spark, Hive, Hadoop, etc.) via JSON.

## Usage

### Simple / Default Secure Deployment

This example uses the module's built-in KMS key creation, IAM role creation, and default security configuration (enabling EBS volume encryption and EMRFS S3 KMS encryption).

```hcl
module "emr_cluster" {
  source = "./modules/emr"

  name      = "my-emr-analytics"
  vpc_id    = "vpc-0123456789abcdef0"
  subnet_id = "subnet-0123456789abcdef0" # Private subnet recommended

  # Default: create_kms_key = true
  # Default: enable_at_rest_encryption = true
  # Default: enable_in_transit_encryption = true (requires TLS certificate zip on S3)
  in_transit_certificate_s3_object = "s3://my-secure-bucket/certs/emr-certs.zip"

  master_instance_group = {
    instance_type  = "m5.xlarge"
    instance_count = 1
    ebs_config = [
      {
        size                 = 50
        type                 = "gp3"
        volumes_per_instance = 1
      }
    ]
  }

  core_instance_group = {
    instance_type  = "m5.xlarge"
    instance_count = 2
    ebs_config = [
      {
        size                 = 100
        type                 = "gp3"
        volumes_per_instance = 2
      }
    ]
  }

  tags = {
    Environment = "production"
    Department  = "data-science"
  }
}
```

### Advanced Deployment with Existing KMS Key, IAM Roles & Spot Task Nodes

```hcl
module "emr_cluster" {
  source = "./modules/emr"

  name              = "mlops-spark-cluster"
  vpc_id            = "vpc-0123456789abcdef0"
  subnet_id         = "subnet-0123456789abcdef0"
  is_private_subnet = true

  # Use existing KMS key for encryption-at-rest
  create_kms_key = false
  kms_key_arn    = "arn:aws:kms:us-west-2:123456789012:key/abc-123-xyz"

  # Use existing IAM roles
  create_service_role          = false
  service_role_arn             = "arn:aws:iam::123456789012:role/MyEMRServiceRole"
  create_instance_profile      = false
  instance_profile_name_or_arn = "arn:aws:iam::123456789012:instance-profile/MyEMREC2Profile"
  instance_profile_role_arn    = "arn:aws:iam::123456789012:role/MyEMREC2Role" # Required for KMS key policy

  # Disable in-transit encryption (e.g., in air-gapped sandboxes without local CA certs)
  enable_in_transit_encryption = false

  # EMR Applications
  applications = ["Hadoop", "Spark", "Hive", "Presto"]

  # Instance Groups
  master_instance_group = {
    instance_type  = "m5.2xlarge"
    instance_count = 1
  }

  core_instance_group = {
    instance_type  = "m5.2xlarge"
    instance_count = 3
  }

  # Dynamic Spot Task Groups
  task_instance_groups = {
    spot-task-group = {
      instance_type  = "r5.2xlarge"
      instance_count = 5
      bid_price      = "0.25" # Max bid price for spot instances
      ebs_config = [
        {
          size                 = 50
          type                 = "gp3"
          volumes_per_instance = 1
        }
      ]
    }
  }

  # Bootstrap Action Example
  bootstrap_actions = [
    {
      name = "install-python-packages"
      path = "s3://my-bucket/scripts/bootstrap.sh"
      args = ["--upgrade", "numpy pandas scikit-learn"]
    }
  ]

  # Configurations JSON Example
  configurations_json = jsonencode([
    {
      Classification = "spark-env"
      Configurations = [
        {
          Classification = "export"
          Properties = {
            PYSPARK_PYTHON = "/usr/bin/python3"
          }
        }
      ]
    }
  ])

  # SSH Access (securely restricted)
  key_name                = "my-emr-ssh-key"
  ssh_allowed_cidr_blocks = ["10.0.0.0/16"]

  tags = {
    Project = "mlops-platform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the EMR cluster | `string` | n/a | yes |
| `release_label` | The EMR release label | `string` | `"emr-6.15.0"` | no |
| `applications` | A list of applications to install on the EMR cluster | `list(string)` | `["Hadoop", "Spark"]` | no |
| `vpc_id` | The ID of the VPC where the EMR cluster and security groups will be created | `string` | n/a | yes |
| `subnet_id` | The VPC subnet ID in which to launch the cluster | `string` | n/a | yes |
| `is_private_subnet` | Whether the subnet is a private subnet (attaches service access security group) | `bool` | `true` | no |
| `key_name` | The EC2 key pair name for SSH access to the cluster nodes | `string` | `null` | no |
| `ssh_allowed_cidr_blocks` | List of CIDR blocks allowed to SSH to the master node | `list(string)` | `[]` | no |
| `create_kms_key` | Specifies whether to create a customer managed KMS key for EMR encryption | `bool` | `true` | no |
| `kms_key_arn` | The ARN of an existing KMS key to use if `create_kms_key` is set to false | `string` | `null` | no |
| `kms_key_deletion_window` | The deletion window in days for the created KMS key | `number` | `30` | no |
| `kms_key_policy` | A custom KMS key policy JSON. If not specified, a default secure policy will be generated | `string` | `null` | no |
| `create_security_configuration` | Specifies whether to create an EMR security configuration | `bool` | `true` | no |
| `security_configuration` | A custom EMR security configuration JSON string. If provided, it overrides all other encryption variables | `string` | `null` | no |
| `security_configuration_name` | The name of an existing EMR security configuration to use if `create_security_configuration` is false | `string` | `null` | no |
| `enable_in_transit_encryption` | Enables in-transit encryption | `bool` | `true` | no |
| `in_transit_certificate_provider_type` | The certificate provider type for in-transit encryption. Valid values: `PEM`, `Custom` | `string` | `"PEM"` | no |
| `in_transit_certificate_s3_object` | S3 URI pointing to the certificate ZIP file (required for PEM) or JAR file (required for Custom) | `string` | `null` | no |
| `in_transit_certificate_provider_class` | The Java class containing custom certificate provider logic (only used when provider type is Custom) | `string` | `null` | no |
| `enable_at_rest_encryption` | Enables encryption at rest for local disks and EMRFS on S3 | `bool` | `true` | no |
| `enable_ebs_encryption` | Enables EBS volume encryption for EMR instances | `bool` | `true` | no |
| `s3_encryption_mode` | EMRFS S3 encryption mode. Valid values: `SSE-S3`, `SSE-KMS`, `CSE-KMS` | `string` | `"SSE-KMS"` | no |
| `create_service_role` | Specifies whether to create the EMR Service IAM role | `bool` | `true` | no |
| `service_role_arn` | The ARN of an existing EMR Service IAM role if `create_service_role` is false | `string` | `null` | no |
| `service_role_permissions_boundary` | Permissions boundary ARN for the EMR Service IAM role | `string` | `null` | no |
| `service_role_additional_policies` | List of additional policy ARNs to attach to the EMR Service IAM role | `list(string)` | `[]` | no |
| `create_instance_profile` | Specifies whether to create the EMR EC2 instance profile | `bool` | `true` | no |
| `instance_profile_name_or_arn` | The name or ARN of an existing EMR EC2 instance profile if `create_instance_profile` is false | `string` | `null` | no |
| `instance_profile_role_arn` | The IAM role ARN associated with the existing instance profile if `create_instance_profile` is false (needed for KMS key policy) | `string` | `null` | no |
| `instance_profile_role_permissions_boundary` | Permissions boundary ARN for the EMR EC2 role | `string` | `null` | no |
| `instance_profile_additional_policies` | List of additional policy ARNs to attach to the EMR EC2 IAM role | `list(string)` | `[]` | no |
| `master_instance_group` | Configuration for the master instance group (maps to `master_instance_group` block) | `object` | *see variables.tf* | no |
| `core_instance_group` | Configuration for the core instance group (maps to `core_instance_group` block) | `object` | *see variables.tf* | no |
| `task_instance_groups` | Map of task instance groups to associate with the cluster (creates `aws_emr_instance_group` resources) | `map(object)` | `{}` | no |
| `create_security_groups` | Specifies whether to create the EMR master, slave, and service access security groups | `bool` | `true` | no |
| `emr_managed_master_security_group` | The ID of an existing security group for the EMR master node if `create_security_groups` is false | `string` | `null` | no |
| `emr_managed_slave_security_group` | The ID of an existing security group for the EMR slave nodes if `create_security_groups` is false | `string` | `null` | no |
| `service_access_security_group` | The ID of an existing security group for the EMR service access if `create_security_groups` is false | `string` | `null` | no |
| `bootstrap_actions` | List of bootstrap actions to run on cluster start | `list(object)` | `[]` | no |
| `configurations_json` | List of software configurations presented as a JSON string | `string` | `null` | no |
| `keep_job_flow_alive_when_no_steps` | Whether the cluster should stay active after steps complete | `bool` | `true` | no |
| `termination_protection` | Whether to enable termination protection for the cluster | `bool` | `false` | no |
| `log_uri` | S3 bucket path for EMR cluster logs | `string` | `null` | no |
| `tags` | A map of tags to assign to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_id` | The ID of the EMR cluster |
| `cluster_arn` | The ARN of the EMR cluster |
| `master_public_dns` | The public DNS name of the master node |
| `kms_key_arn` | The ARN of the KMS key used for encryption |
| `security_configuration_name` | The name of the security configuration associated with the cluster |
| `service_role_arn` | The ARN of the IAM service role used by EMR |
| `instance_profile_arn` | The ARN of the IAM instance profile used by the EC2 instances |
