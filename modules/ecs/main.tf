resource "aws_ecs_cluster" "this" {
  name = var.name

  dynamic "setting" {
    for_each = var.cluster_settings
    content {
      name  = setting.value.name
      value = setting.value.value
    }
  }

  tags = merge({ Name = var.name }, var.tags)
}

resource "aws_ecs_capacity_provider" "ec2" {
  for_each = var.ec2_capacity_providers

  name = each.key

  auto_scaling_group_provider {
    auto_scaling_group_arn         = each.value.auto_scaling_group_arn
    managed_termination_protection = lookup(each.value, "managed_termination_protection", "DISABLED")

    managed_scaling {
      maximum_scaling_step_size = lookup(each.value, "maximum_scaling_step_size", null)
      minimum_scaling_step_size = lookup(each.value, "minimum_scaling_step_size", null)
      status                    = lookup(each.value, "status", "ENABLED")
      target_capacity           = lookup(each.value, "target_capacity", null)
    }
  }

  tags = merge({ Name = "${var.name}-${each.key}-capacity-provider" }, var.tags)
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = concat(var.fargate_capacity_providers, [for cp in aws_ecs_capacity_provider.ec2 : cp.name])

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy
    content {
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
      weight            = lookup(default_capacity_provider_strategy.value, "weight", null)
      base              = lookup(default_capacity_provider_strategy.value, "base", null)
    }
  }
}

# Task Execution Role
resource "aws_iam_role" "ecs_execution" {
  count = var.create_execution_role ? 1 : 0
  name  = "${var.name}-ecs-execution-role"

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

  tags = merge({ Name = "${var.name}-execution-role" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  count      = var.create_execution_role ? 1 : 0
  role       = aws_iam_role.ecs_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_execution_secrets" {
  count = var.create_execution_role ? 1 : 0
  name  = "${var.name}-ecs-execution-secrets"
  role  = aws_iam_role.ecs_execution[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ]
        Resource = "*"
      }
    ]
  })
}

# Task Role
resource "aws_iam_role" "ecs_task" {
  count = var.create_task_role ? 1 : 0
  name  = "${var.name}-ecs-task-role"

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

  tags = merge({ Name = "${var.name}-task-role" }, var.tags)
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "this" {
  count             = var.create_log_group ? 1 : 0
  name              = "/ecs/${var.name}"
  retention_in_days = var.log_group_retention

  tags = merge({ Name = "${var.name}-logs" }, var.tags)
}

# Task Definition
resource "aws_ecs_task_definition" "this" {
  count = var.create_task_definition ? 1 : 0

  family                   = var.task_family != null ? var.task_family : var.name
  container_definitions    = var.container_definitions
  execution_role_arn       = var.create_execution_role ? aws_iam_role.ecs_execution[0].arn : var.execution_role_arn
  task_role_arn            = var.create_task_role ? aws_iam_role.ecs_task[0].arn : var.task_role_arn
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.task_cpu
  memory                   = var.task_memory

  dynamic "volume" {
    for_each = var.volumes
    content {
      name      = volume.value.name
      host_path = lookup(volume.value, "host_path", null)

      dynamic "efs_volume_configuration" {
        for_each = lookup(volume.value, "efs_volume_configuration", [])
        content {
          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = lookup(efs_volume_configuration.value, "root_directory", null)
          transit_encryption      = lookup(efs_volume_configuration.value, "transit_encryption", null)
          transit_encryption_port = lookup(efs_volume_configuration.value, "transit_encryption_port", null)

          dynamic "authorization_config" {
            for_each = lookup(efs_volume_configuration.value, "authorization_config", [])
            content {
              access_point_id = lookup(authorization_config.value, "access_point_id", null)
              iam             = lookup(authorization_config.value, "iam", null)
            }
          }
        }
      }
    }
  }

  tags = merge({ Name = coalesce(var.task_family, var.name) }, var.tags)
}

# ECS Service
resource "aws_ecs_service" "this" {
  count = var.create_service ? 1 : 0

  name                               = var.service_name != null ? var.service_name : var.name
  cluster                            = aws_ecs_cluster.this.id
  task_definition                    = var.create_task_definition ? aws_ecs_task_definition.this[0].arn : var.task_definition_arn
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  propagate_tags                     = var.propagate_tags

  # network_configuration is optional/only for awsvpc
  dynamic "network_configuration" {
    for_each = length(var.subnets) > 0 ? [1] : []
    content {
      subnets          = var.subnets
      security_groups  = var.security_groups
      assign_public_ip = var.assign_public_ip
    }
  }

  dynamic "load_balancer" {
    for_each = var.load_balancers
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  dynamic "service_registries" {
    for_each = var.service_registries
    content {
      registry_arn   = service_registries.value.registry_arn
      port           = lookup(service_registries.value, "port", null)
      container_name = lookup(service_registries.value, "container_name", null)
      container_port = lookup(service_registries.value, "container_port", null)
    }
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.service_capacity_provider_strategy
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
      base              = lookup(capacity_provider_strategy.value, "base", null)
    }
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = merge({ Name = coalesce(var.service_name, var.name) }, var.tags)
}

# Autoscaling for ECS Service
resource "aws_appautoscaling_target" "this" {
  count              = var.create_service && var.enable_autoscaling ? 1 : 0
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this[0].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  count              = var.create_service && var.enable_autoscaling ? 1 : 0
  name               = "${var.name}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.cpu_threshold
    disable_scale_in   = false
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "memory" {
  count              = var.create_service && var.enable_autoscaling ? 1 : 0
  name               = "${var.name}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.memory_threshold
    disable_scale_in   = false
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}
