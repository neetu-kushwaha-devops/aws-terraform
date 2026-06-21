locals {
  managed_policies = merge([
    for ps_key, ps_val in var.permission_sets : {
      for policy in ps_val.managed_policy_arns : "${ps_key}.${policy}" => {
        permission_set_key = ps_key
        policy_arn         = policy
      }
    }
  ]...)
}

resource "aws_ssoadmin_permission_set" "this" {
  for_each         = var.permission_sets
  name             = each.key
  description      = each.value.description
  instance_arn     = var.instance_arn
  session_duration = each.value.session_duration

  tags = var.tags
}

resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each = {
    for k, v in var.permission_sets : k => v if v.inline_policy != null && v.inline_policy != ""
  }
  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
  inline_policy      = each.value.inline_policy
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each           = local.managed_policies
  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set_key].arn
  managed_policy_arn = each.value.policy_arn
}

resource "aws_ssoadmin_account_assignment" "this" {
  count              = length(var.account_assignments)
  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[var.account_assignments[count.index].permission_set_key].arn
  principal_id       = var.account_assignments[count.index].principal_id
  principal_type     = var.account_assignments[count.index].principal_type
  target_id          = var.account_assignments[count.index].target_id
  target_type        = "AWS_ACCOUNT"
}
