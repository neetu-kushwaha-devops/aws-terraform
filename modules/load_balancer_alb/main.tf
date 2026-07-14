terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets

  idle_timeout               = var.idle_timeout
  enable_deletion_protection = var.enable_deletion_protection
  enable_http2               = var.enable_http2
  ip_address_type            = var.ip_address_type

  dynamic "access_logs" {
    for_each = var.access_logs_enabled && var.access_logs_bucket != null && var.access_logs_bucket != "" ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_lb_listener" "http" {
  count             = var.http_enabled ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = var.http_port
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = var.http_redirect_to_https ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = var.default_target_group_arn
    }
  }

  dynamic "default_action" {
    for_each = var.http_redirect_to_https ? [1] : []
    content {
      type = "redirect"

      redirect {
        port        = tostring(var.https_port)
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }
}

resource "aws_lb_listener" "https" {
  count             = var.https_enabled ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = var.https_port
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = var.default_target_group_arn
  }
}

resource "aws_lb_listener_certificate" "additional" {
  count           = var.https_enabled ? length(var.additional_certificate_arns) : 0
  listener_arn    = aws_lb_listener.https[0].arn
  certificate_arn = var.additional_certificate_arns[count.index]
}

resource "aws_wafv2_web_acl_association" "this" {
  count        = var.waf_web_acl_arn != null && var.waf_web_acl_arn != "" ? 1 : 0
  resource_arn = aws_lb.this.arn
  web_acl_arn  = var.waf_web_acl_arn
}
