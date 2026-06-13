data "aws_iam_policy_document" "default_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  count = var.create_role ? 1 : 0

  name                  = var.name
  path                  = var.role_path
  description           = var.role_description
  assume_role_policy    = var.assume_role_policy != null ? var.assume_role_policy : data.aws_iam_policy_document.default_assume_role.json
  permissions_boundary  = var.role_permissions_boundary_arn
  max_session_duration  = var.max_session_duration
  force_detach_policies = var.force_detach_policies

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_iam_policy" "custom" {
  count = var.create_policy ? 1 : 0

  name        = var.policy_name != null ? var.policy_name : "${var.name}-policy"
  path        = var.policy_path
  description = var.policy_description
  policy      = var.policy_json

  tags = merge(
    {
      Name = var.policy_name != null ? var.policy_name : "${var.name}-policy"
    },
    var.tags
  )
}

# Attach custom policy to the created role if both are created
resource "aws_iam_role_policy_attachment" "custom" {
  count = var.create_role && var.create_policy ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.custom[0].arn
}

# Attach additional managed/existing policy ARNs to the created role
resource "aws_iam_role_policy_attachment" "managed" {
  for_each = var.create_role ? toset(var.attached_policy_arns) : toset([])

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0

  name = var.instance_profile_name != null ? var.instance_profile_name : var.name
  role = var.create_role ? aws_iam_role.this[0].name : var.name

  tags = merge(
    {
      Name = var.instance_profile_name != null ? var.instance_profile_name : var.name
    },
    var.tags
  )
}
