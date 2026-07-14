terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

data "aws_partition" "current" {}

# -----------------------------------------------------------------------------
# IAM Role for Step Functions State Machine Execution
# -----------------------------------------------------------------------------
resource "aws_iam_role" "this" {
  count = var.create_role ? 1 : 0
  name  = "${var.name}-sfn-exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
  tags = merge({ Name = "${var.name}-role" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "xray" {
  count      = var.create_role && var.enable_xray ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

resource "aws_iam_policy" "logging" {
  count       = var.create_role && var.enable_logging ? 1 : 0
  name        = "${var.name}-sfn-logging"
  description = "Permissions for Step Functions logging to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutLogEvents",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "logging" {
  count      = var.create_role && var.enable_logging ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.logging[0].arn
}

resource "aws_iam_role_policy_attachment" "additional" {
  count      = var.create_role ? length(var.policy_arns) : 0
  role       = aws_iam_role.this[0].name
  policy_arn = var.policy_arns[count.index]
}

# -----------------------------------------------------------------------------
# CloudWatch Log Group
# -----------------------------------------------------------------------------
# Log Group names for Step Functions should start with /aws/vendedlogs/ to avoid
# resource policy size limits for cloudwatch log configuration.
resource "aws_cloudwatch_log_group" "sfn" {
  count             = var.enable_logging ? 1 : 0
  name              = "/aws/vendedlogs/states/${var.name}"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  tags              = merge({ Name = "${var.name}-logs" }, var.tags)
}

# -----------------------------------------------------------------------------
# Step Functions State Machine
# -----------------------------------------------------------------------------
resource "aws_sfn_state_machine" "this" {
  name     = var.name
  role_arn = var.create_role ? aws_iam_role.this[0].arn : var.role_arn
  type     = var.type

  definition = var.definition

  dynamic "logging_configuration" {
    for_each = var.enable_logging ? [1] : []
    content {
      log_destination        = "${aws_cloudwatch_log_group.sfn[0].arn}:*"
      level                  = var.log_level
      include_execution_data = var.log_include_execution_data
    }
  }

  dynamic "tracing_configuration" {
    for_each = var.enable_xray ? [1] : []
    content {
      enabled = true
    }
  }

  tags = merge({ Name = var.name }, var.tags)
}
