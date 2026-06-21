# Module: MQ (Message Broker)

This Terraform module provisions a production-ready, highly reusable Amazon MQ broker (supporting both RabbitMQ and ActiveMQ engines). It enforces secure defaults such as encryption at rest and disabled public accessibility.

## Features

- **Multi-Engine Support:** Configurable for either `RabbitMQ` or `ActiveMQ`.
- **Secure by Default:** 
  - Encryption-at-rest via AWS-managed or Customer-managed KMS keys.
  - Publicly accessible endpoint disabled by default.
  - Password fields marked sensitive to protect credentials from console output.
- **Dynamic Configuration:** Supports optionally creating custom configuration resources (`aws_mq_configuration`) or referencing existing ones.
- **Security Group Integration:** Can automatically generate a security group with customizable rules, or accept existing security group IDs.
- **Logging Integration:** Supports enabling general logging and ActiveMQ-specific audit logs.
- **Maintenance Windows:** Allows setting dynamic maintenance start times.
- **Dynamic User Management:** Easily provision multiple users (supporting permissions, groups, and console access options).

---

## Usage Examples

### 1. RabbitMQ Configuration

RabbitMQ uses cluster or single-instance deployment, with EBS storage. Typically, a single broker user is supported by AWS MQ.

```hcl
module "mq_rabbitmq" {
  source = "./modules/mq"

  name               = "production-rabbitmq"
  engine_type        = "RabbitMQ"
  engine_version     = "3.13"
  host_instance_type = "mq.t3.micro"
  deployment_mode    = "SINGLE_INSTANCE"

  vpc_id                = "vpc-0123456789abcdef0"
  subnet_ids            = ["subnet-0123456789abcdef1"]
  create_security_group = true

  security_group_rules = [
    {
      type        = "ingress"
      from_port   = 5671 # AMQPS port
      to_port     = 5671
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "Allow AMQPS from internal network"
    },
    {
      type        = "ingress"
      from_port   = 443 # RabbitMQ Console via HTTPS
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "Allow RabbitMQ Web Console from internal network"
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]

  users = [
    {
      username       = "mq_admin"
      password       = "SuperSecretPassword123!" # Marked sensitive
      console_access = true
    }
  ]

  tags = {
    Environment = "production"
    Owner       = "devops-team"
  }
}
```

### 2. ActiveMQ Configuration (Active-Standby with Custom XML Config)

ActiveMQ supports high-availability Active-Standby across multiple subnets, EFS/EBS storage, and XML configurations.

```hcl
module "mq_activemq" {
  source = "./modules/mq"

  name               = "production-activemq"
  engine_type        = "ActiveMQ"
  engine_version     = "5.18"
  host_instance_type = "mq.m5.large"
  deployment_mode    = "ACTIVE_STANDBY_MULTI_AZ"
  storage_type       = "efs"

  vpc_id                = "vpc-0123456789abcdef0"
  subnet_ids            = ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2"]
  create_security_group = true

  security_group_rules = [
    {
      type        = "ingress"
      from_port   = 61617 # OpenWire over SSL
      to_port     = 61617
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "Allow OpenWire connection"
    },
    {
      type        = "ingress"
      from_port   = 8162 # Web Console
      to_port     = 8162
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "Allow Console access"
    }
  ]

  create_configuration = true
  configuration_data   = <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<broker xmlns="http://activemq.apache.org/schema/core">
  <plugins>
    <forcePersistencyModeBrokerPlugin persistenceFlag="true"/>
  </plugins>
</broker>
EOF

  general_log_enabled = true
  audit_log_enabled   = true

  users = [
    {
      username       = "activemq_admin"
      password       = "StrongAdminPassword987!"
      console_access = true
      groups         = ["admin"]
    },
    {
      username       = "app_client"
      password       = "AppClientPassword456!"
      console_access = false
      groups         = ["users"]
    }
  ]

  tags = {
    Environment = "production"
    Owner       = "devops-team"
  }
}
```

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the Amazon MQ broker. Also used to name associated resources like security groups. | `string` | n/a | **yes** |
| `engine_type` | The type of broker engine. Valid values: `ActiveMQ`, `RabbitMQ`. | `string` | `"RabbitMQ"` | no |
| `engine_version` | The version of the broker engine. E.g. `3.13` or `5.18`. | `string` | `"3.13"` | no |
| `host_instance_type` | The broker's instance type. E.g. `mq.t3.micro`, `mq.m5.large`. | `string` | `"mq.t3.micro"` | no |
| `deployment_mode` | The deployment mode of the broker. Valid values: `SINGLE_INSTANCE`, `ACTIVE_STANDBY_MULTI_AZ`, `CLUSTER_MULTI_AZ`. | `string` | `"SINGLE_INSTANCE"` | no |
| `storage_type` | The storage type of the broker. Valid values: `ebs` or `efs`. RabbitMQ only supports `ebs`. | `string` | `"ebs"` | no |
| `authentication_strategy` | The authentication strategy used to secure the broker. Valid values: `simple`, `ldap`. RabbitMQ only supports `simple`. | `string` | `"simple"` | no |
| `publicly_accessible` | Whether the broker is publicly accessible. Enforced to `false` by default for security. | `bool` | `false` | no |
| `subnet_ids` | List of VPC subnet IDs. `SINGLE_INSTANCE` requires exactly one. `ACTIVE_STANDBY_MULTI_AZ` requires exactly two in different AZs. `CLUSTER_MULTI_AZ` requires two or three depending on deployment. | `list(string)` | `[]` | no |
| `security_groups` | List of security group IDs to associate with the broker. Combined with the created security group if `create_security_group` is true. | `list(string)` | `[]` | no |
| `create_security_group` | Whether to create a security group for the MQ broker. | `bool` | `false` | no |
| `vpc_id` | The VPC ID where the security group and broker will be deployed (required if `create_security_group` is true). | `string` | `null` | no |
| `security_group_rules` | Custom security group rules to apply to the created security group. | `list(object)` | `[]` | no |
| `kms_key_arn` | The ARN of the KMS customer master key (CMK) to use for encryption at rest. If not specified, Amazon MQ will use the AWS-managed KMS key. | `string` | `null` | no |
| `auto_minor_version_upgrade` | Whether to automatically upgrade minor versions during the maintenance window. | `bool` | `true` | no |
| `create_configuration` | Whether to create a custom MQ configuration. | `bool` | `false` | no |
| `configuration_name` | The name of the custom configuration. Defaults to `var.name-config`. | `string` | `null` | no |
| `configuration_data` | The configuration data in XML (ActiveMQ) or Cuttlefish (RabbitMQ) format. | `string` | `""` | no |
| `configuration_id` | The ID of an existing configuration to associate with the broker. | `string` | `null` | no |
| `configuration_revision` | The revision of an existing configuration to associate with the broker. | `number` | `null` | no |
| `general_log_enabled` | Enable general logging to Amazon CloudWatch Logs. | `bool` | `true` | no |
| `audit_log_enabled` | Enable audit logging to Amazon CloudWatch Logs (ActiveMQ only). | `bool` | `false` | no |
| `maintenance_window_start_time` | The maintenance window start time. | `object` | `null` | no |
| `users` | List of users who can access the MQ broker console or API. Passwords should be marked sensitive. | `list(object)` | `[]` | no |
| `tags` | A mapping of tags to assign to all resources. | `map(string)` | `{}` | no |

---

## Outputs

| Name | Description | Value |
|------|-------------|-------|
| `broker_id` | The ID of the Amazon MQ broker | `aws_mq_broker.this.id` |
| `broker_arn` | The ARN of the Amazon MQ broker | `aws_mq_broker.this.arn` |
| `broker_instances_endpoints` | A list of connection endpoints for each broker instance | `aws_mq_broker.this.instances[*].endpoints` |
| `broker_console_url` | The console URL of the Amazon MQ broker | `aws_mq_broker.this.instances[0].console_url` |
| `configuration_id` | The ID of the custom Amazon MQ configuration (if created) | `aws_mq_configuration.this[0].id` |
| `configuration_arn` | The ARN of the custom Amazon MQ configuration (if created) | `aws_mq_configuration.this[0].arn` |
| `security_group_id` | The ID of the created security group (if `create_security_group` is true) | `aws_security_group.this[0].id` |
