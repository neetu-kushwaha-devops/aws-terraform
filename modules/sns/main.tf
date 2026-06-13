resource "aws_sns_topic" "this" {
  name                        = var.name
  display_name                = var.display_name
  kms_master_key_id           = var.kms_master_key_id
  delivery_policy             = var.delivery_policy
  fifo_topic                  = var.fifo_topic
  content_based_deduplication = var.content_based_deduplication

  tags = merge({ Name = var.name }, var.tags)
}

resource "aws_sns_topic_policy" "this" {
  count = var.policy != null ? 1 : 0

  arn    = aws_sns_topic.this.arn
  policy = var.policy
}

resource "aws_sns_topic_subscription" "this" {
  for_each = var.subscriptions

  topic_arn              = aws_sns_topic.this.arn
  protocol               = each.value.protocol
  endpoint               = each.value.endpoint
  endpoint_auto_confirms = lookup(each.value, "endpoint_auto_confirms", null)
  filter_policy          = lookup(each.value, "filter_policy", null)
  filter_policy_scope    = lookup(each.value, "filter_policy_scope", null)
  raw_message_delivery   = lookup(each.value, "raw_message_delivery", null)
  redrive_policy         = lookup(each.value, "redrive_policy", null)
  subscription_role_arn  = lookup(each.value, "subscription_role_arn", null)
  delivery_policy        = lookup(each.value, "delivery_policy", null)
}
