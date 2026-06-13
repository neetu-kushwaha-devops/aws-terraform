resource "aws_iam_role" "this" {
  count = var.create_role ? 1 : 0
  name  = "${var.name}-lambda-exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  tags = merge({ Name = "${var.name}-role" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "basic" {
  count      = var.create_role ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc" {
  count      = var.create_role && length(var.subnet_ids) > 0 ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "dlq" {
  count       = var.create_role && var.dead_letter_target_arn != null ? 1 : 0
  name        = "${var.name}-lambda-dlq"
  description = "Permissions for Lambda DLQ write"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish",
          "sqs:SendMessage"
        ]
        Resource = var.dead_letter_target_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dlq" {
  count      = var.create_role && var.dead_letter_target_arn != null ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.dlq[0].arn
}

resource "aws_iam_role_policy_attachment" "additional" {
  count      = var.create_role ? length(var.policy_arns) : 0
  role       = aws_iam_role.this[0].name
  policy_arn = var.policy_arns[count.index]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  tags              = merge({ Name = "${var.name}-logs" }, var.tags)
}

resource "aws_lambda_function" "this" {
  function_name = var.name
  description   = var.description
  role          = var.create_role ? aws_iam_role.this[0].arn : var.role_arn

  # For Zip package type
  filename          = var.package_type == "Zip" ? var.filename : null
  s3_bucket         = var.package_type == "Zip" ? var.s3_bucket : null
  s3_key            = var.package_type == "Zip" ? var.s3_key : null
  s3_object_version = var.package_type == "Zip" ? var.s3_object_version : null
  handler           = var.package_type == "Zip" ? var.handler : null
  runtime           = var.package_type == "Zip" ? var.runtime : null
  source_code_hash  = var.package_type == "Zip" ? var.source_code_hash : null

  # For Image package type
  image_uri    = var.package_type == "Image" ? var.image_uri : null
  package_type = var.package_type

  timeout     = var.timeout
  memory_size = var.memory_size
  publish     = var.publish || var.provisioned_concurrent_executions > 0

  reserved_concurrent_executions = var.reserved_concurrent_executions

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [var.environment_variables] : []
    content {
      variables = environment.value
    }
  }

  dynamic "vpc_config" {
    for_each = length(var.subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != null ? [1] : []
    content {
      target_arn = var.dead_letter_target_arn
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_iam_role_policy_attachment.basic,
    aws_iam_role_policy_attachment.vpc,
    aws_iam_role_policy_attachment.dlq,
  ]

  tags = merge({ Name = var.name }, var.tags)
}

resource "aws_lambda_alias" "this" {
  count            = var.alias_name != null ? 1 : 0
  name             = var.alias_name
  description      = "Alias for ${var.name}"
  function_name    = aws_lambda_function.this.function_name
  function_version = aws_lambda_function.this.version
}

resource "aws_lambda_provisioned_concurrency_config" "this" {
  count                             = var.provisioned_concurrent_executions > 0 ? 1 : 0
  function_name                     = aws_lambda_function.this.function_name
  provisioned_concurrent_executions = var.provisioned_concurrent_executions
  qualifier                         = var.alias_name != null ? aws_lambda_alias.this[0].name : aws_lambda_function.this.version
}

resource "aws_lambda_function_url" "this" {
  count              = var.create_function_url ? 1 : 0
  function_name      = aws_lambda_function.this.function_name
  qualifier          = var.alias_name != null ? aws_lambda_alias.this[0].name : null
  authorization_type = var.function_url_auth_type

  dynamic "cors" {
    for_each = length(var.function_url_cors) > 0 ? [var.function_url_cors] : []
    content {
      allow_credentials = lookup(cors.value, "allow_credentials", null)
      allow_headers     = lookup(cors.value, "allow_headers", null)
      allow_methods     = lookup(cors.value, "allow_methods", null)
      allow_origins     = lookup(cors.value, "allow_origins", null)
      expose_headers    = lookup(cors.value, "expose_headers", null)
      max_age           = lookup(cors.value, "max_age", null)
    }
  }
}
