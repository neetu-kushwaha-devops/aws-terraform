resource "aws_codedeploy_app" "this" {
  name             = var.name
  compute_platform = var.compute_platform

  tags = merge({ Name = var.name }, var.tags)
}

locals {
  default_policies = {
    "Server" = ["arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"]
    "ECS"    = ["arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"]
    "Lambda" = ["arn:aws:iam::aws:policy/service-role/AWSCodeDeployRoleForLambda"]
  }

  policy_arns_to_attach = length(var.iam_role_policy_arns) > 0 ? var.iam_role_policy_arns : lookup(local.default_policies, var.compute_platform, [])
  dg_name               = var.deployment_group_name != null ? var.deployment_group_name : "${var.name}-dg"
  role_name             = var.iam_role_name != null ? var.iam_role_name : "${var.name}-codedeploy-role"
}

resource "aws_iam_role" "codedeploy" {
  count = var.create_service_role ? 1 : 0
  name  = local.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })

  tags = merge({ Name = local.role_name }, var.tags)
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  for_each   = var.create_service_role ? toset(local.policy_arns_to_attach) : []
  role       = aws_iam_role.codedeploy[0].name
  policy_arn = each.value
}

resource "aws_codedeploy_deployment_group" "this" {
  app_name               = aws_codedeploy_app.this.name
  deployment_group_name  = local.dg_name
  service_role_arn       = var.create_service_role ? aws_iam_role.codedeploy[0].arn : var.service_role_arn
  deployment_config_name = var.deployment_config_name

  dynamic "deployment_style" {
    for_each = var.deployment_style != null ? [var.deployment_style] : []
    content {
      deployment_option = lookup(deployment_style.value, "deployment_option", null)
      deployment_type   = lookup(deployment_style.value, "deployment_type", null)
    }
  }

  dynamic "blue_green_deployment_config" {
    for_each = var.blue_green_deployment_config != null ? [var.blue_green_deployment_config] : []
    content {
      dynamic "deployment_ready_option" {
        for_each = lookup(blue_green_deployment_config.value, "deployment_ready_option", null) != null ? [blue_green_deployment_config.value.deployment_ready_option] : []
        content {
          action_on_timeout    = lookup(deployment_ready_option.value, "action_on_timeout", null)
          wait_time_in_minutes = lookup(deployment_ready_option.value, "wait_time_in_minutes", null)
        }
      }

      dynamic "terminate_blue_instances_on_deployment_success" {
        for_each = lookup(blue_green_deployment_config.value, "terminate_blue_instances_on_deployment_success", null) != null ? [blue_green_deployment_config.value.terminate_blue_instances_on_deployment_success] : []
        content {
          action                           = lookup(terminate_blue_instances_on_deployment_success.value, "action", null)
          termination_wait_time_in_minutes = lookup(terminate_blue_instances_on_deployment_success.value, "termination_wait_time_in_minutes", null)
        }
      }

      dynamic "green_fleet_provisioning_option" {
        for_each = lookup(blue_green_deployment_config.value, "green_fleet_provisioning_option", null) != null ? [blue_green_deployment_config.value.green_fleet_provisioning_option] : []
        content {
          action = lookup(green_fleet_provisioning_option.value, "action", null)
        }
      }
    }
  }

  dynamic "load_balancer_info" {
    for_each = var.load_balancer_info != null ? [var.load_balancer_info] : []
    content {
      dynamic "elb_info" {
        for_each = lookup(load_balancer_info.value, "elb_info", null) != null ? load_balancer_info.value.elb_info : []
        content {
          name = elb_info.value.name
        }
      }

      dynamic "target_group_info" {
        for_each = lookup(load_balancer_info.value, "target_group_info", null) != null ? load_balancer_info.value.target_group_info : []
        content {
          name = target_group_info.value.name
        }
      }

      dynamic "target_group_pair_info" {
        for_each = lookup(load_balancer_info.value, "target_group_pair_info", null) != null ? [load_balancer_info.value.target_group_pair_info] : []
        content {
          prod_traffic_route {
            listener_arns = target_group_pair_info.value.prod_traffic_route.listener_arns
          }

          dynamic "test_traffic_route" {
            for_each = lookup(target_group_pair_info.value, "test_traffic_route", null) != null ? [target_group_pair_info.value.test_traffic_route] : []
            content {
              listener_arns = test_traffic_route.value.listener_arns
            }
          }

          dynamic "target_group" {
            for_each = target_group_pair_info.value.target_group
            content {
              name = target_group.value.name
            }
          }
        }
      }
    }
  }

  dynamic "auto_rollback_configuration" {
    for_each = var.auto_rollback_enabled ? [1] : []
    content {
      enabled = true
      events  = var.auto_rollback_events
    }
  }

  dynamic "alarm_configuration" {
    for_each = var.alarm_enabled ? [1] : []
    content {
      alarms                    = var.alarm_names
      enabled                   = true
      ignore_poll_alarm_failure = var.ignore_poll_alarm_failure
    }
  }

  dynamic "trigger_configuration" {
    for_each = var.trigger_configurations
    content {
      trigger_events     = trigger_configuration.value.trigger_events
      trigger_name       = trigger_configuration.value.trigger_name
      trigger_target_arn = trigger_configuration.value.trigger_target_arn
    }
  }

  dynamic "ec2_tag_filter" {
    for_each = var.ec2_tag_filters
    content {
      key   = lookup(ec2_tag_filter.value, "key", null)
      type  = lookup(ec2_tag_filter.value, "type", null)
      value = lookup(ec2_tag_filter.value, "value", null)
    }
  }

  dynamic "ec2_tag_set" {
    for_each = var.ec2_tag_sets
    content {
      dynamic "ec2_tag_filter" {
        for_each = ec2_tag_set.value.ec2_tag_filters
        content {
          key   = lookup(ec2_tag_filter.value, "key", null)
          type  = lookup(ec2_tag_filter.value, "type", null)
          value = lookup(ec2_tag_filter.value, "value", null)
        }
      }
    }
  }

  dynamic "on_premises_instance_tag_filter" {
    for_each = var.on_premises_instance_tag_filters
    content {
      key   = lookup(on_premises_instance_tag_filter.value, "key", null)
      type  = lookup(on_premises_instance_tag_filter.value, "type", null)
      value = lookup(on_premises_instance_tag_filter.value, "value", null)
    }
  }

  autoscaling_groups = length(var.auto_scaling_groups) > 0 ? var.auto_scaling_groups : null

  dynamic "ecs_service" {
    for_each = var.ecs_service != null ? [var.ecs_service] : []
    content {
      cluster_name = ecs_service.value.cluster_name
      service_name = ecs_service.value.service_name
    }
  }

  tags = merge({ Name = local.dg_name }, var.tags)
}
