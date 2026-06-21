resource "aws_networkfirewall_firewall_policy" "this" {
  name = "${var.name}-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:pass"]
    stateless_fragment_default_actions = ["aws:pass"]

    dynamic "stateless_rule_group_reference" {
      for_each = var.stateless_rule_groups
      content {
        priority     = stateless_rule_group_reference.value.priority
        resource_arn = stateless_rule_group_reference.value.resource_arn
      }
    }

    dynamic "stateful_rule_group_reference" {
      for_each = var.stateful_rule_groups
      content {
        resource_arn = stateful_rule_group_reference.value.resource_arn
      }
    }
  }

  tags = merge(
    {
      Name = "${var.name}-policy"
    },
    var.tags
  )
}

resource "aws_networkfirewall_firewall" "this" {
  name                = var.name
  firewall_policy_arn = aws_networkfirewall_firewall_policy.this.arn
  vpc_id              = var.vpc_id

  dynamic "subnet_mapping" {
    for_each = var.subnet_mappings
    content {
      subnet_id = subnet_mapping.value.subnet_id
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_networkfirewall_logging_configuration" "this" {
  count        = length(var.logging_destinations) > 0 ? 1 : 0
  firewall_arn = aws_networkfirewall_firewall.this.arn

  logging_configuration {
    dynamic "log_destination_config" {
      for_each = var.logging_destinations
      content {
        log_destination      = log_destination_config.value.log_destination
        log_destination_type = log_destination_config.value.log_destination_type
        log_type             = log_destination_config.value.log_type
      }
    }
  }
}
