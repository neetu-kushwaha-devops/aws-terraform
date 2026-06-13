# -----------------------------------------------------------------------------
# Custom Event Bus (Optional)
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_event_bus" "this" {
  count = var.create_bus ? 1 : 0
  name  = var.bus_name
  tags  = merge({ Name = "${var.name}-bus" }, var.tags)
}

# -----------------------------------------------------------------------------
# EventBridge Rule
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "this" {
  name                = var.name
  description         = var.description
  event_bus_name      = var.create_bus ? aws_cloudwatch_event_bus.this[0].name : var.bus_name
  schedule_expression = var.schedule_expression
  event_pattern       = var.event_pattern
  is_enabled          = var.is_enabled
  tags                = merge({ Name = var.name }, var.tags)
}

# -----------------------------------------------------------------------------
# Automated IAM Role for EventBridge Targets (SFN, ECS)
# -----------------------------------------------------------------------------
resource "aws_iam_role" "target" {
  count = var.create_target_role ? 1 : 0
  name  = "${var.name}-eb-tg-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
  tags = merge({ Name = "${var.name}-target-role" }, var.tags)
}

resource "aws_iam_policy" "target_execution" {
  count       = var.create_target_role ? 1 : 0
  name        = "${var.name}-eb-tg-policy"
  description = "Permissions for EventBridge targets execution"

  # We dynamically generate statements based on targets configured
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect = "Allow"
          Action = [
            "states:StartExecution"
          ]
          Resource = [for k, v in var.targets : v.arn if length(regexall("^arn:aws:states:", v.arn)) > 0]
        }
      ],
      length([for k, v in var.targets : v.arn if length(regexall("^arn:aws:ecs:", v.arn)) > 0]) > 0 ? [
        {
          Effect = "Allow"
          Action = [
            "ecs:RunTask"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "iam:PassRole"
          ]
          Resource = "*"
        }
      ] : []
    )
  })
}

resource "aws_iam_role_policy_attachment" "target" {
  count      = var.create_target_role ? 1 : 0
  role       = aws_iam_role.target[0].name
  policy_arn = aws_iam_policy.target_execution[0].arn
}

# -----------------------------------------------------------------------------
# EventBridge Targets Mapping
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_event_target" "this" {
  for_each       = var.targets
  event_bus_name = var.create_bus ? aws_cloudwatch_event_bus.this[0].name : var.bus_name
  rule           = aws_cloudwatch_event_rule.this.name
  target_id      = each.key
  arn            = each.value.arn

  # Automatically resolve target execution role for SFN/ECS if create_target_role is enabled
  role_arn = lookup(each.value, "role_arn", null) != null ? each.value.role_arn : (
    var.create_target_role && (
      length(regexall("^arn:aws:states:", each.value.arn)) > 0 ||
      length(regexall("^arn:aws:ecs:", each.value.arn)) > 0
    ) ? aws_iam_role.target[0].arn : null
  )

  input      = lookup(each.value, "input", null)
  input_path = lookup(each.value, "input_path", null)

  dynamic "ecs_target" {
    for_each = lookup(each.value, "ecs_target", null) != null ? [each.value.ecs_target] : []
    content {
      task_definition_arn = ecs_target.value.task_definition_arn
      task_count          = lookup(ecs_target.value, "task_count", 1)
      launch_type         = lookup(ecs_target.value, "launch_type", "FARGATE")
      platform_version    = lookup(ecs_target.value, "platform_version", "LATEST")
      group               = lookup(ecs_target.value, "group", null)

      dynamic "network_configuration" {
        for_each = (
          lookup(ecs_target.value, "subnet_ids", null) != null &&
          length(lookup(ecs_target.value, "subnet_ids", [])) > 0
        ) ? [1] : []
        content {
          subnets          = ecs_target.value.subnet_ids
          security_groups  = lookup(ecs_target.value, "security_groups", null)
          assign_public_ip = lookup(ecs_target.value, "assign_public_ip", false)
        }
      }
    }
  }

  dynamic "dead_letter_config" {
    for_each = lookup(each.value, "dead_letter_arn", null) != null ? [1] : []
    content {
      arn = each.value.dead_letter_arn
    }
  }
}

# -----------------------------------------------------------------------------
# Lambda Permission for Rule Execution
# -----------------------------------------------------------------------------
resource "aws_lambda_permission" "eventbridge" {
  for_each      = { for k, v in var.targets : k => v if length(regexall("^arn:aws:lambda:", v.arn)) > 0 }
  statement_id  = "AllowEventBridgeInvoke-${var.name}-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}
