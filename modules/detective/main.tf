resource "aws_detective_graph" "this" {
  count = var.enable ? 1 : 0
  tags  = var.tags
}

resource "aws_detective_member" "this" {
  for_each      = var.member_accounts
  account_id    = each.key
  email_address = each.value
  graph_arn     = one(aws_detective_graph.this[*].graph_arn)
}
