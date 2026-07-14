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
  load_balancer_type = "network"
  subnets            = length(var.subnet_mappings) == 0 ? var.subnets : null

  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_deletion_protection       = var.enable_deletion_protection
  ip_address_type                  = var.ip_address_type

  dynamic "subnet_mapping" {
    for_each = var.subnet_mappings
    content {
      subnet_id            = subnet_mapping.value.subnet_id
      allocation_id        = subnet_mapping.value.allocation_id
      private_ipv4_address = subnet_mapping.value.private_ipv4_address
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_lb_listener" "this" {
  for_each          = { for l in var.listeners : "${l.protocol}_${l.port}" => l }
  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = each.value.protocol == "TLS" ? (each.value.ssl_policy != null ? each.value.ssl_policy : "ELBSecurityPolicy-2016-08") : null
  certificate_arn   = each.value.protocol == "TLS" ? each.value.certificate_arn : null
  alpn_policy       = each.value.protocol == "TLS" ? each.value.alpn_policy : null

  default_action {
    type             = "forward"
    target_group_arn = each.value.default_target_group_arn
  }
}
