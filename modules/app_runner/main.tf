terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

data "aws_partition" "current" {}

locals {
  is_private_ecr     = var.source_type == "IMAGE" && try(var.image_repository.image_repository_type, "") == "ECR"
  create_access_role = var.create_access_role && local.is_private_ecr
}

# AWS App Runner Connection (GitHub connection - only created if source_type is CODE)
resource "aws_apprunner_connection" "this" {
  count           = var.source_type == "CODE" && var.create_connection ? 1 : 0
  connection_name = var.connection_name != null ? var.connection_name : "${var.name}-connection"
  provider_type   = var.connection_provider_type
  tags            = merge({ Name = var.connection_name != null ? var.connection_name : "${var.name}-connection" }, var.tags)
}

# AWS App Runner Auto Scaling Configuration
resource "aws_apprunner_auto_scaling_configuration_version" "this" {
  count                           = var.create_auto_scaling_config ? 1 : 0
  auto_scaling_configuration_name = var.auto_scaling_config_name != null ? var.auto_scaling_config_name : "${var.name}-as-config"
  max_concurrency                 = var.auto_scaling_max_concurrency
  max_size                        = var.auto_scaling_max_size
  min_size                        = var.auto_scaling_min_size
  tags                            = merge({ Name = var.auto_scaling_config_name != null ? var.auto_scaling_config_name : "${var.name}-as-config" }, var.tags)
}

# AWS App Runner VPC Connector
resource "aws_apprunner_vpc_connector" "this" {
  count              = var.create_vpc_connector ? 1 : 0
  vpc_connector_name = var.vpc_connector_name != null ? var.vpc_connector_name : "${var.name}-vpc-connector"
  subnets            = var.vpc_subnets
  security_groups    = var.vpc_security_groups
  tags               = merge({ Name = var.vpc_connector_name != null ? var.vpc_connector_name : "${var.name}-vpc-connector" }, var.tags)
}

# IAM Access Role (to read private ECR repositories)
resource "aws_iam_role" "access_role" {
  count = local.create_access_role ? 1 : 0
  name  = var.access_role_name != null ? var.access_role_name : "${var.name}-apprunner-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
      }
    ]
  })

  tags = merge({ Name = var.access_role_name != null ? var.access_role_name : "${var.name}-apprunner-access-role" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "access_role_policy" {
  count      = local.create_access_role ? 1 : 0
  role       = aws_iam_role.access_role[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECR"
}

# IAM Instance Role (for container runtime execution permissions)
resource "aws_iam_role" "instance_role" {
  count = var.create_instance_role ? 1 : 0
  name  = var.instance_role_name != null ? var.instance_role_name : "${var.name}-apprunner-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "tasks.apprunner.amazonaws.com"
        }
      }
    ]
  })

  tags = merge({ Name = var.instance_role_name != null ? var.instance_role_name : "${var.name}-apprunner-instance-role" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "instance_role_policies" {
  for_each   = var.create_instance_role ? toset(var.instance_role_policies) : []
  role       = aws_iam_role.instance_role[0].name
  policy_arn = each.value
}

# AWS App Runner Service
resource "aws_apprunner_service" "this" {
  service_name = var.name

  auto_scaling_configuration_arn = var.create_auto_scaling_config ? aws_apprunner_auto_scaling_configuration_version.this[0].arn : var.auto_scaling_configuration_arn

  dynamic "encryption_configuration" {
    for_each = var.kms_key_arn != null ? [1] : []
    content {
      kms_key = var.kms_key_arn
    }
  }

  instance_configuration {
    cpu               = var.cpu
    memory            = var.memory
    instance_role_arn = var.create_instance_role ? aws_iam_role.instance_role[0].arn : var.instance_role_arn
  }

  network_configuration {
    egress_configuration {
      egress_type       = var.create_vpc_connector || var.vpc_connector_arn != null ? "VPC" : "DEFAULT"
      vpc_connector_arn = var.create_vpc_connector ? aws_apprunner_vpc_connector.this[0].arn : var.vpc_connector_arn
    }
    ingress_configuration {
      is_publicly_accessible = var.is_publicly_accessible
    }
  }

  source_configuration {
    auto_deployments_enabled = var.auto_deployments_enabled

    authentication_configuration {
      access_role_arn = local.is_private_ecr ? (var.create_access_role ? aws_iam_role.access_role[0].arn : var.access_role_arn) : null
      connection_arn  = var.source_type == "CODE" ? (var.create_connection ? aws_apprunner_connection.this[0].arn : var.connection_arn) : null
    }

    # Image Repository Configuration (source_type = IMAGE)
    dynamic "image_repository" {
      for_each = var.source_type == "IMAGE" && var.image_repository != null ? [var.image_repository] : []
      content {
        image_identifier      = image_repository.value.image_identifier
        image_repository_type = image_repository.value.image_repository_type

        dynamic "image_configuration" {
          for_each = image_repository.value.image_configuration != null ? [image_repository.value.image_configuration] : []
          content {
            port                          = image_configuration.value.port
            start_command                 = image_configuration.value.start_command
            runtime_environment_variables = image_configuration.value.runtime_environment_variables
            runtime_environment_secrets   = image_configuration.value.runtime_environment_secrets
          }
        }
      }
    }

    # Code Repository Configuration (source_type = CODE)
    dynamic "code_repository" {
      for_each = var.source_type == "CODE" && var.code_repository != null ? [var.code_repository] : []
      content {
        repository_url = code_repository.value.repository_url

        source_code_version {
          type  = code_repository.value.source_code_version.type
          value = code_repository.value.source_code_version.value
        }

        dynamic "code_configuration" {
          for_each = code_repository.value.code_configuration != null ? [code_repository.value.code_configuration] : []
          content {
            configuration_source = code_configuration.value.configuration_source

            dynamic "code_configuration_values" {
              for_each = code_configuration.value.code_configuration_values != null ? [code_configuration.value.code_configuration_values] : []
              content {
                runtime                       = code_configuration_values.value.runtime
                build_command                 = code_configuration_values.value.build_command
                start_command                 = code_configuration_values.value.start_command
                port                          = code_configuration_values.value.port
                runtime_environment_variables = code_configuration_values.value.runtime_environment_variables
                runtime_environment_secrets   = code_configuration_values.value.runtime_environment_secrets
              }
            }
          }
        }
      }
    }
  }

  dynamic "health_check_configuration" {
    for_each = var.health_check_configuration != null ? [var.health_check_configuration] : []
    content {
      protocol            = health_check_configuration.value.protocol
      path                = health_check_configuration.value.path
      interval            = health_check_configuration.value.interval
      timeout             = health_check_configuration.value.timeout
      healthy_threshold   = health_check_configuration.value.healthy_threshold
      unhealthy_threshold = health_check_configuration.value.unhealthy_threshold
    }
  }

  tags = merge({ Name = var.name }, var.tags)
}
