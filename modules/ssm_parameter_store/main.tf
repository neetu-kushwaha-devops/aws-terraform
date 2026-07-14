terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_ssm_parameter" "this" {
  for_each = var.parameters

  name            = each.value.name != null ? each.value.name : "${var.parameter_prefix}${each.key}"
  type            = each.value.type
  value           = each.value.value
  description     = each.value.description
  tier            = each.value.tier
  key_id          = each.value.type == "SecureString" ? each.value.key_id : null
  allowed_pattern = each.value.allowed_pattern
  data_type       = each.value.data_type

  tags = merge(
    {
      "Name" = each.value.name != null ? each.value.name : "${var.parameter_prefix}${each.key}"
    },
    var.tags,
    each.value.tags
  )
}
