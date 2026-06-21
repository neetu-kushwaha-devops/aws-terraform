# ------------------------------------------------------------------------------
# IAM Service Roles for AWS Batch
# ------------------------------------------------------------------------------

# AWS Batch Service Role
resource "aws_iam_role" "batch_service_role" {
  count = var.create_service_role ? 1 : 0
  name  = "${var.name}-batch-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "batch.amazonaws.com"
        }
      }
    ]
  })

  tags = merge({ Name = "${var.name}-batch-service-role" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "batch_service_role" {
  count      = var.create_service_role ? 1 : 0
  role       = aws_iam_role.batch_service_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_iam_role_policy_attachment" "batch_service_role_additional" {
  for_each   = var.create_service_role ? toset(var.service_role_additional_policies) : []
  role       = aws_iam_role.batch_service_role[0].name
  policy_arn = each.value
}

# ECS Instance Role & Profile (for EC2 Compute Environments)
resource "aws_iam_role" "ecs_instance_role" {
  count = var.create_instance_role ? 1 : 0
  name  = "${var.name}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge({ Name = "${var.name}-ecs-instance-role" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role" {
  count      = var.create_instance_role ? 1 : 0
  role       = aws_iam_role.ecs_instance_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_additional" {
  for_each   = var.create_instance_role ? toset(var.instance_role_additional_policies) : []
  role       = aws_iam_role.ecs_instance_role[0].name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  count = var.create_instance_role ? 1 : 0
  name  = "${var.name}-ecs-instance-profile"
  role  = aws_iam_role.ecs_instance_role[0].name

  tags = merge({ Name = "${var.name}-ecs-instance-profile" }, var.tags)
}

# ------------------------------------------------------------------------------
# IAM Roles for Job Execution and Containers (Task Roles)
# ------------------------------------------------------------------------------

# Default Job Execution Role (allows Fargate/ECS agent to pull image and write logs)
resource "aws_iam_role" "batch_job_execution_role" {
  count = var.create_job_execution_role ? 1 : 0
  name  = "${var.name}-batch-job-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge({ Name = "${var.name}-batch-job-execution-role" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "batch_job_execution_role" {
  count      = var.create_job_execution_role ? 1 : 0
  role       = aws_iam_role.batch_job_execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "batch_job_execution_role_additional" {
  for_each   = var.create_job_execution_role ? toset(var.job_execution_role_additional_policies) : []
  role       = aws_iam_role.batch_job_execution_role[0].name
  policy_arn = each.value
}

# Default Job Role (gives container specific AWS API permissions, e.g. S3 access)
resource "aws_iam_role" "batch_job_role" {
  count = var.create_job_role ? 1 : 0
  name  = "${var.name}-batch-job-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge({ Name = "${var.name}-batch-job-role" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "batch_job_role_additional" {
  for_each   = var.create_job_role ? toset(var.job_role_additional_policies) : []
  role       = aws_iam_role.batch_job_role[0].name
  policy_arn = each.value
}

# ------------------------------------------------------------------------------
# Network and Security Groups Configuration
# ------------------------------------------------------------------------------

resource "aws_security_group" "this" {
  count       = var.create_security_group ? 1 : 0
  name        = "${var.name}-batch-sg"
  description = "Security group for AWS Batch EC2 instances"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.security_group_ingress
    content {
      description      = lookup(ingress.value, "description", null)
      from_port        = lookup(ingress.value, "from_port", 0)
      to_port          = lookup(ingress.value, "to_port", 0)
      protocol         = lookup(ingress.value, "protocol", "-1")
      cidr_blocks      = lookup(ingress.value, "cidr_blocks", null) != null ? split(",", ingress.value["cidr_blocks"]) : (lookup(ingress.value, "cidr_block", null) != null ? [ingress.value["cidr_block"]] : null)
      ipv6_cidr_blocks = lookup(ingress.value, "ipv6_cidr_blocks", null) != null ? split(",", ingress.value["ipv6_cidr_blocks"]) : (lookup(ingress.value, "ipv6_cidr_block", null) != null ? [ingress.value["ipv6_cidr_block"]] : null)
      prefix_list_ids  = lookup(ingress.value, "prefix_list_ids", null) != null ? split(",", ingress.value["prefix_list_ids"]) : null
      security_groups  = lookup(ingress.value, "security_groups", null) != null ? split(",", ingress.value["security_groups"]) : (lookup(ingress.value, "security_group_id", null) != null ? [ingress.value["security_group_id"]] : null)
      self             = lookup(ingress.value, "self", null) != null ? tobool(ingress.value["self"]) : null
    }
  }

  dynamic "egress" {
    for_each = var.security_group_egress
    content {
      description      = lookup(egress.value, "description", null)
      from_port        = lookup(egress.value, "from_port", 0)
      to_port          = lookup(egress.value, "to_port", 0)
      protocol         = lookup(egress.value, "protocol", "-1")
      cidr_blocks      = lookup(egress.value, "cidr_blocks", null) != null ? split(",", egress.value["cidr_blocks"]) : (lookup(egress.value, "cidr_block", null) != null ? [egress.value["cidr_block"]] : null)
      ipv6_cidr_blocks = lookup(egress.value, "ipv6_cidr_blocks", null) != null ? split(",", egress.value["ipv6_cidr_blocks"]) : (lookup(egress.value, "ipv6_cidr_block", null) != null ? [egress.value["ipv6_cidr_block"]] : null)
      prefix_list_ids  = lookup(egress.value, "prefix_list_ids", null) != null ? split(",", egress.value["prefix_list_ids"]) : null
      security_groups  = lookup(egress.value, "security_groups", null) != null ? split(",", egress.value["security_groups"]) : (lookup(egress.value, "security_group_id", null) != null ? [egress.value["security_group_id"]] : null)
      self             = lookup(egress.value, "self", null) != null ? tobool(egress.value["self"]) : null
    }
  }

  tags = merge({ Name = "${var.name}-batch-sg" }, var.tags)
}

# ------------------------------------------------------------------------------
# Launch Template (to enforce IMDSv2 and encrypted EBS volumes)
# ------------------------------------------------------------------------------

resource "aws_launch_template" "this" {
  count = var.create_launch_template ? 1 : 0

  name_prefix = "${var.name}-batch-lt-"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Enforce IMDSv2
    http_put_response_hop_limit = var.launch_template_http_put_response_hop_limit
  }

  block_device_mappings {
    device_name = var.launch_template_device_name
    ebs {
      volume_size           = var.launch_template_volume_size
      volume_type           = var.launch_template_volume_type
      encrypted             = true # Enforce EBS volume encryption
      kms_key_id            = var.kms_key_arn
      delete_on_termination = true
    }
  }

  tags = merge({ Name = "${var.name}-launch-template" }, var.tags)
}

# ------------------------------------------------------------------------------
# AWS Batch Compute Environments
# ------------------------------------------------------------------------------

resource "aws_batch_compute_environment" "this" {
  for_each = var.compute_environments

  name         = lookup(each.value, "name", "${var.name}-${each.key}")
  type         = lookup(each.value, "type", "MANAGED")
  state        = lookup(each.value, "state", "ENABLED")
  service_role = lookup(each.value, "service_role", null) != null ? each.value.service_role : one(aws_iam_role.batch_service_role[*].arn)

  dynamic "compute_resources" {
    for_each = lookup(each.value, "compute_resources", null) != null ? [each.value.compute_resources] : []
    content {
      type                = compute_resources.value.type
      max_vcpus           = compute_resources.value.max_vcpus
      min_vcpus           = lookup(compute_resources.value, "min_vcpus", 0)
      desired_vcpus       = lookup(compute_resources.value, "desired_vcpus", null)
      allocation_strategy = lookup(compute_resources.value, "allocation_strategy", null)

      # EC2/SPOT specific settings
      instance_type       = (compute_resources.value.type == "EC2" || compute_resources.value.type == "SPOT") ? lookup(compute_resources.value, "instance_type", ["optimal"]) : null
      instance_role       = (compute_resources.value.type == "EC2" || compute_resources.value.type == "SPOT") ? (lookup(compute_resources.value, "instance_role", null) != null ? compute_resources.value.instance_role : one(aws_iam_instance_profile.ecs_instance_profile[*].arn)) : null
      bid_percentage      = compute_resources.value.type == "SPOT" ? lookup(compute_resources.value, "bid_percentage", null) : null
      ec2_key_pair        = (compute_resources.value.type == "EC2" || compute_resources.value.type == "SPOT") ? lookup(compute_resources.value, "ec2_key_pair", null) : null
      image_id            = (compute_resources.value.type == "EC2" || compute_resources.value.type == "SPOT") ? lookup(compute_resources.value, "image_id", null) : null
      spot_iam_fleet_role = compute_resources.value.type == "SPOT" ? lookup(compute_resources.value, "spot_iam_fleet_role", null) : null

      subnets            = compute_resources.value.subnets
      security_group_ids = lookup(compute_resources.value, "security_group_ids", null) != null ? compute_resources.value.security_group_ids : [for sg in aws_security_group.this : sg.id]

      dynamic "launch_template" {
        for_each = (compute_resources.value.type == "EC2" || compute_resources.value.type == "SPOT") && (lookup(compute_resources.value, "launch_template_id", null) != null || lookup(compute_resources.value, "launch_template_name", null) != null || var.create_launch_template) ? [1] : []
        content {
          launch_template_id   = lookup(compute_resources.value, "launch_template_id", one(aws_launch_template.this[*].id))
          launch_template_name = lookup(compute_resources.value, "launch_template_id", null) == null ? lookup(compute_resources.value, "launch_template_name", null) : null
          version              = lookup(compute_resources.value, "launch_template_version", "$Latest")
        }
      }

      dynamic "ec2_configuration" {
        for_each = lookup(compute_resources.value, "ec2_configuration", [])
        content {
          image_id_override = lookup(ec2_configuration.value, "image_id_override", null)
          image_type        = lookup(ec2_configuration.value, "image_type", null)
        }
      }

      tags = merge(
        { Name = "${var.name}-${each.key}-compute-resources" },
        var.tags,
        lookup(compute_resources.value, "tags", {})
      )
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({ Name = lookup(each.value, "name", "${var.name}-${each.key}") }, var.tags)
}

# ------------------------------------------------------------------------------
# AWS Batch Job Queues
# ------------------------------------------------------------------------------

resource "aws_batch_job_queue" "this" {
  for_each = var.job_queues

  name     = lookup(each.value, "name", "${var.name}-${each.key}")
  state    = lookup(each.value, "state", "ENABLED")
  priority = lookup(each.value, "priority", 1)

  dynamic "compute_environment_order" {
    for_each = lookup(each.value, "compute_environment_order", null) != null ? each.value.compute_environment_order : [
      for idx, ce in lookup(each.value, "compute_environments", []) : {
        order               = idx + 1
        compute_environment = ce
      }
    ]
    content {
      order               = compute_environment_order.value.order
      compute_environment = lookup(aws_batch_compute_environment.this, compute_environment_order.value.compute_environment, null) != null ? aws_batch_compute_environment.this[compute_environment_order.value.compute_environment].arn : compute_environment_order.value.compute_environment
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({ Name = lookup(each.value, "name", "${var.name}-${each.key}") }, var.tags)
}

# ------------------------------------------------------------------------------
# AWS Batch Job Definitions
# ------------------------------------------------------------------------------

resource "aws_batch_job_definition" "this" {
  for_each = var.job_definitions

  name = lookup(each.value, "name", "${var.name}-${each.key}")
  type = lookup(each.value, "type", "container")

  container_properties = lookup(each.value, "container_properties", null) != null ? jsonencode(
    merge(
      jsondecode(each.value.container_properties),
      lookup(jsondecode(each.value.container_properties), "executionRoleArn", null) == null && var.create_job_execution_role ? {
        executionRoleArn = one(aws_iam_role.batch_job_execution_role[*].arn)
      } : {},
      lookup(jsondecode(each.value.container_properties), "jobRoleArn", null) == null && var.create_job_role ? {
        jobRoleArn = one(aws_iam_role.batch_job_role[*].arn)
      } : {}
    )
  ) : null

  parameters            = lookup(each.value, "parameters", null)
  platform_capabilities = lookup(each.value, "platform_capabilities", null)
  propagate_tags        = lookup(each.value, "propagate_tags", null)

  dynamic "retry_strategy" {
    for_each = lookup(each.value, "retry_strategy", null) != null ? [each.value.retry_strategy] : []
    content {
      attempts = lookup(retry_strategy.value, "attempts", null)
      dynamic "evaluate_on_exit" {
        for_each = lookup(retry_strategy.value, "evaluate_on_exit", [])
        content {
          action           = evaluate_on_exit.value.action
          on_exit_code     = lookup(evaluate_on_exit.value, "on_exit_code", null)
          on_reason        = lookup(evaluate_on_exit.value, "on_reason", null)
          on_status_reason = lookup(evaluate_on_exit.value, "on_status_reason", null)
        }
      }
    }
  }

  dynamic "timeout" {
    for_each = lookup(each.value, "timeout", null) != null ? [each.value.timeout] : []
    content {
      attempt_duration_seconds = lookup(timeout.value, "attempt_duration_seconds", null)
    }
  }

  tags = merge({ Name = lookup(each.value, "name", "${var.name}-${each.key}") }, var.tags)
}
