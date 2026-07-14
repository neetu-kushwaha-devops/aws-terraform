terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_autoscaling_group" "this" {
  name_prefix = "${var.name}-"

  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.vpc_zone_identifier
  target_group_arns         = var.target_group_arns
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  force_delete              = var.force_delete
  termination_policies      = var.termination_policies
  suspended_processes       = var.suspended_processes
  enabled_metrics           = var.enabled_metrics
  metrics_granularity       = var.metrics_granularity
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  protect_from_scale_in     = var.protect_from_scale_in
  service_linked_role_arn   = var.service_linked_role_arn
  max_instance_lifetime     = var.max_instance_lifetime
  capacity_rebalance        = var.capacity_rebalance

  launch_template {
    id      = var.launch_template_id
    name    = var.launch_template_name
    version = var.launch_template_version
  }

  dynamic "instance_refresh" {
    for_each = var.instance_refresh_strategy != "none" && var.instance_refresh_strategy != "" && var.instance_refresh_strategy != null ? [1] : []
    content {
      strategy = var.instance_refresh_strategy
      preferences {
        min_healthy_percentage = var.instance_refresh_min_healthy_percentage
        instance_warmup        = var.health_check_grace_period
      }
      triggers = var.instance_refresh_triggers
    }
  }

  dynamic "tag" {
    for_each = merge({ Name = var.name }, var.tags)
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  count                     = var.enable_cpu_scaling_policy ? 1 : 0
  name                      = "${var.name}-cpu-scaling"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.this.name
  estimated_instance_warmup = var.health_check_grace_period

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_scaling_target_value
  }
}

resource "aws_autoscaling_policy" "alb_request_tracking" {
  count                     = var.enable_alb_request_scaling_policy && var.alb_resource_label != "" ? 1 : 0
  name                      = "${var.name}-alb-request-scaling"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.this.name
  estimated_instance_warmup = var.health_check_grace_period

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = var.alb_resource_label
    }
    target_value = var.alb_request_scaling_target_value
  }
}
