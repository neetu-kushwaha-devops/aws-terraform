terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_lb_target_group" "this" {
  name        = var.name
  port        = var.target_type == "lambda" ? null : var.port
  protocol    = var.target_type == "lambda" ? null : var.protocol
  vpc_id      = var.target_type == "lambda" ? null : var.vpc_id
  target_type = var.target_type

  deregistration_delay          = var.deregistration_delay
  slow_start                    = var.slow_start
  load_balancing_algorithm_type = var.target_type == "lambda" || var.target_type == "alb" || contains(["TCP", "TLS", "UDP", "TCP_UDP"], var.protocol) ? null : var.load_balancing_algorithm_type

  health_check {
    enabled             = var.health_check_enabled
    path                = (var.target_type == "lambda" || contains(["HTTP", "HTTPS"], coalesce(var.health_check_protocol, var.protocol, "HTTP"))) ? var.health_check_path : null
    port                = var.health_check_port
    protocol            = var.health_check_protocol != null ? var.health_check_protocol : (var.target_type == "lambda" ? "HTTP" : var.protocol)
    interval            = var.health_check_interval
    timeout             = var.target_type == "lambda" ? null : var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    matcher             = (var.target_type == "lambda" || contains(["HTTP", "HTTPS"], coalesce(var.health_check_protocol, var.protocol, "HTTP"))) ? var.health_check_matcher : null
  }

  dynamic "stickiness" {
    for_each = var.stickiness_enabled ? [1] : []
    content {
      type            = var.stickiness_type
      cookie_duration = var.stickiness_type == "lb_cookie" || var.stickiness_type == "app_cookie" ? var.stickiness_cookie_duration : null
      cookie_name     = var.stickiness_type == "app_cookie" ? var.stickiness_cookie_name : null
      enabled         = true
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each          = { for t in var.targets : t.id => t }
  target_group_arn  = aws_lb_target_group.this.arn
  target_id         = each.value.id
  port              = var.target_type == "lambda" ? null : (each.value.port != null ? each.value.port : var.port)
  availability_zone = each.value.availability_zone
}
