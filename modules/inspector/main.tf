data "aws_caller_identity" "current" {}

locals {
  resource_types = concat(
    var.enable_ec2 ? ["EC2"] : [],
    var.enable_ecr ? ["ECR"] : [],
    var.enable_lambda ? ["LAMBDA"] : [],
    var.enable_lambda_code ? ["LAMBDA_CODE"] : []
  )
  account_ids = length(var.account_ids) > 0 ? var.account_ids : [data.aws_caller_identity.current.account_id]
}

resource "aws_inspector2_enabler" "this" {
  count          = var.enabled && length(local.resource_types) > 0 ? 1 : 0
  resource_types = local.resource_types
  account_ids    = local.account_ids
}
