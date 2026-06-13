data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "this" {
  count             = var.create_log_group ? 1 : 0
  name              = var.log_group_name != null ? var.log_group_name : "/aws/application-logs"
  retention_in_days = var.log_group_retention_in_days
  kms_key_id        = var.log_group_kms_key_id

  tags = merge({ Name = "${var.name}-log-group" }, var.tags)
}

# CPU Alarm
resource "aws_cloudwatch_metric_alarm" "cpu" {
  count               = var.cpu_alarm_enabled ? 1 : 0
  alarm_name          = var.cpu_alarm_name != null ? var.cpu_alarm_name : "cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cpu_alarm_evaluation_periods
  metric_name         = var.cpu_alarm_metric_name
  namespace           = var.cpu_alarm_namespace
  period              = var.cpu_alarm_period
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "This metric monitors CPU utilization"
  alarm_actions       = var.sns_topic_arns
  ok_actions          = var.sns_topic_arns

  dimensions = var.cpu_alarm_dimensions

  tags = merge({ Name = "${var.name}-cpu-alarm" }, var.tags)
}

# Memory Alarm
resource "aws_cloudwatch_metric_alarm" "memory" {
  count               = var.memory_alarm_enabled ? 1 : 0
  alarm_name          = var.memory_alarm_name != null ? var.memory_alarm_name : "memory-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.memory_alarm_evaluation_periods
  metric_name         = var.memory_alarm_metric_name
  namespace           = var.memory_alarm_namespace
  period              = var.memory_alarm_period
  statistic           = "Average"
  threshold           = var.memory_alarm_threshold
  alarm_description   = "This metric monitors Memory utilization"
  alarm_actions       = var.sns_topic_arns
  ok_actions          = var.sns_topic_arns

  dimensions = var.memory_alarm_dimensions

  tags = merge({ Name = "${var.name}-memory-alarm" }, var.tags)
}

# Billing Alarm
resource "aws_cloudwatch_metric_alarm" "billing" {
  count               = var.billing_alarm_enabled ? 1 : 0
  alarm_name          = var.billing_alarm_name != null ? var.billing_alarm_name : "billing-charges-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.billing_alarm_evaluation_periods
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = var.billing_alarm_period
  statistic           = "Maximum"
  threshold           = var.billing_alarm_threshold
  alarm_description   = "This metric monitors estimated AWS charges"
  alarm_actions       = var.sns_topic_arns
  ok_actions          = var.sns_topic_arns

  dimensions = {
    Currency = var.billing_alarm_currency
  }

  tags = merge({ Name = "${var.name}-billing-alarm" }, var.tags)
}

# Custom Alarms
resource "aws_cloudwatch_metric_alarm" "custom" {
  for_each            = var.custom_alarms
  alarm_name          = each.key
  comparison_operator = lookup(each.value, "comparison_operator", "GreaterThanOrEqualToThreshold")
  evaluation_periods  = lookup(each.value, "evaluation_periods", 1)
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = lookup(each.value, "period", 300)
  statistic           = lookup(each.value, "statistic", "Average")
  threshold           = each.value.threshold
  alarm_description   = lookup(each.value, "alarm_description", "Managed by Terraform")
  alarm_actions       = lookup(each.value, "alarm_actions", var.sns_topic_arns)
  ok_actions          = lookup(each.value, "ok_actions", var.sns_topic_arns)

  dimensions = lookup(each.value, "dimensions", {})

  tags = merge({ Name = "${var.name}-${each.key}" }, var.tags, lookup(each.value, "tags", {}))
}

# Dashboard
locals {
  dashboard_name = var.dashboard_name != null ? var.dashboard_name : "operations-dashboard"
  dashboard_body = var.dashboard_body != null ? var.dashboard_body : jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization"]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.region
          title  = "EC2 CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Billing", "EstimatedCharges", "Currency", var.billing_alarm_currency]
          ]
          period = 21600
          stat   = "Maximum"
          region = "us-east-1" # Billing metric is stored in us-east-1
          title  = "Estimated Billing Charges"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_dashboard" "this" {
  count          = var.create_dashboard ? 1 : 0
  dashboard_name = local.dashboard_name
  dashboard_body = local.dashboard_body
}
