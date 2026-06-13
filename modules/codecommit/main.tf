resource "aws_codecommit_repository" "this" {
  repository_name = var.repository_name != null ? var.repository_name : var.name
  description     = var.description
  default_branch  = var.default_branch
  kms_key_id      = var.kms_key_id

  tags = merge({ Name = var.name }, var.tags)
}

resource "aws_codecommit_trigger" "this" {
  count           = length(var.triggers) > 0 ? 1 : 0
  repository_name = aws_codecommit_repository.this.repository_name

  dynamic "trigger" {
    for_each = var.triggers
    content {
      name            = trigger.value.name
      destination_arn = trigger.value.destination_arn
      events          = trigger.value.events
      branches        = lookup(trigger.value, "branches", null)
      custom_data     = lookup(trigger.value, "custom_data", null)
    }
  }
}

resource "aws_lambda_permission" "allow_codecommit" {
  for_each      = toset(var.lambda_trigger_permission_arns)
  statement_id  = "AllowExecutionFromCodeCommit-${var.name}"
  action        = "lambda:InvokeFunction"
  function_name = each.value
  principal     = "codecommit.amazonaws.com"
  source_arn    = aws_codecommit_repository.this.arn
}

data "aws_iam_policy_document" "read_only" {
  count = var.create_iam_policies ? 1 : 0
  statement {
    sid    = "CodeCommitReadOnlyAccess"
    effect = "Allow"
    actions = [
      "codecommit:BatchGet*",
      "codecommit:BatchDescribe*",
      "codecommit:Get*",
      "codecommit:Describe*",
      "codecommit:List*",
      "codecommit:GitPull"
    ]
    resources = [
      aws_codecommit_repository.this.arn
    ]
  }
}

resource "aws_iam_policy" "read_only" {
  count       = var.create_iam_policies ? 1 : 0
  name        = "${var.name}-codecommit-read-only"
  path        = var.iam_policy_path
  description = "Read-only access policy for CodeCommit repository ${var.name}"
  policy      = data.aws_iam_policy_document.read_only[0].json
  tags        = merge({ Name = "${var.name}-codecommit-read-only" }, var.tags)
}

data "aws_iam_policy_document" "read_write" {
  count = var.create_iam_policies ? 1 : 0
  statement {
    sid    = "CodeCommitReadWriteAccess"
    effect = "Allow"
    actions = [
      "codecommit:BatchGet*",
      "codecommit:BatchDescribe*",
      "codecommit:Get*",
      "codecommit:Describe*",
      "codecommit:List*",
      "codecommit:GitPull",
      "codecommit:GitPush",
      "codecommit:CreateBranch",
      "codecommit:DeleteBranch",
      "codecommit:PutFile",
      "codecommit:Merge*",
      "codecommit:CreatePullRequest",
      "codecommit:PostComment*",
      "codecommit:UpdatePullRequest*"
    ]
    resources = [
      aws_codecommit_repository.this.arn
    ]
  }
}

resource "aws_iam_policy" "read_write" {
  count       = var.create_iam_policies ? 1 : 0
  name        = "${var.name}-codecommit-read-write"
  path        = var.iam_policy_path
  description = "Read-write access policy for CodeCommit repository ${var.name}"
  policy      = data.aws_iam_policy_document.read_write[0].json
  tags        = merge({ Name = "${var.name}-codecommit-read-write" }, var.tags)
}

data "aws_iam_policy_document" "full_access" {
  count = var.create_iam_policies ? 1 : 0
  statement {
    sid    = "CodeCommitFullAccess"
    effect = "Allow"
    actions = [
      "codecommit:*"
    ]
    resources = [
      aws_codecommit_repository.this.arn
    ]
  }
}

resource "aws_iam_policy" "full_access" {
  count       = var.create_iam_policies ? 1 : 0
  name        = "${var.name}-codecommit-full-access"
  path        = var.iam_policy_path
  description = "Full access policy for CodeCommit repository ${var.name}"
  policy      = data.aws_iam_policy_document.full_access[0].json
  tags        = merge({ Name = "${var.name}-codecommit-full-access" }, var.tags)
}
