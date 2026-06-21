resource "aws_auditmanager_assessment" "this" {
  name         = var.name
  description  = var.description
  framework_id = var.framework_id

  assessment_reports_destination {
    destination      = var.s3_destination
    destination_type = "S3"
  }

  dynamic "roles" {
    for_each = var.roles
    content {
      role_arn  = roles.value.role_arn
      role_type = roles.value.role_type
    }
  }

  scope {
    dynamic "aws_accounts" {
      for_each = var.scope.aws_accounts
      content {
        id = aws_accounts.value.id
      }
    }

    dynamic "aws_services" {
      for_each = var.scope.aws_services
      content {
        name = aws_services.value.name
      }
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}
