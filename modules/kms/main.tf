data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "default" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

resource "aws_kms_key" "this" {
  description              = var.description
  deletion_window_in_days  = var.deletion_window_in_days
  key_usage                = var.key_usage
  customer_master_key_spec = var.customer_master_key_spec
  is_enabled               = var.is_enabled
  enable_key_rotation      = var.enable_key_rotation
  multi_region             = var.multi_region
  policy                   = var.policy != null ? var.policy : data.aws_iam_policy_document.default.json

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

locals {
  aliases = length(var.aliases) > 0 ? var.aliases : [var.name]
}

resource "aws_kms_alias" "this" {
  for_each = toset(local.aliases)

  name          = startswith(each.value, "alias/") ? each.value : "alias/${each.value}"
  target_key_id = aws_kms_key.this.key_id
}
