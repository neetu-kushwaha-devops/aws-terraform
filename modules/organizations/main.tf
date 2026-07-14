terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_organizations_organization" "this" {
  count                         = var.create_organization ? 1 : 0
  feature_set                   = var.feature_set
  aws_service_access_principals = var.aws_service_access_principals
  enabled_policy_types          = var.enabled_policy_types
}

data "aws_partition" "current" {}

data "aws_organizations_organization" "this" {
  count = var.create_organization ? 0 : 1
}

locals {
  root_id = var.create_organization ? aws_organizations_organization.this[0].roots[0].id : data.aws_organizations_organization.this[0].roots[0].id
  org_arn = var.create_organization ? aws_organizations_organization.this[0].arn : data.aws_organizations_organization.this[0].arn
  org_id  = var.create_organization ? aws_organizations_organization.this[0].id : data.aws_organizations_organization.this[0].id

  # Built-in SCP content definitions
  deny_root_policy_content = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyRootUserAccess",
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:PrincipalArn": "arn:${data.aws_partition.current.partition}:iam::*:root"
        }
      }
    }
  ]
}
EOF

  prevent_leave_org_policy_content = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PreventLeavingOrg",
      "Effect": "Deny",
      "Action": [
        "organizations:LeaveOrganization"
      ],
      "Resource": "*"
    }
  ]
}
EOF

  restrict_regions_policy_content = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "RestrictRegions",
      "Effect": "Deny",
      "NotAction": [
        "a4b:*",
        "acm:*",
        "aws-portal:*",
        "budgets:*",
        "chime:*",
        "cloudfront:*",
        "config:*",
        "cur:*",
        "directconnect:*",
        "ec2:DescribeRegions",
        "ec2:DescribeTransitGateways",
        "events:*",
        "fms:*",
        "globalaccelerator:*",
        "health:*",
        "iam:*",
        "importexport:*",
        "kms:*",
        "lightsail:*",
        "mobileanalytics:*",
        "organizations:*",
        "route53:*",
        "route53domains:*",
        "route53resolver:*",
        "shield:*",
        "support:*",
        "tag:*",
        "trustedadvisor:*",
        "waf:*",
        "waf-regional:*",
        "wafv2:*",
        "wellarchitected:*"
      ],
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": ${jsonencode(var.allowed_regions)}
        },
        "ArnNotEquals": {
          "aws:PrincipalARN": [
            "arn:${data.aws_partition.current.partition}:iam::*:role/OrganizationAccountAccessRole"
          ]
        }
      }
    }
  ]
}
EOF
}

# Organizational Units
resource "aws_organizations_organizational_unit" "this" {
  for_each  = var.organizational_units
  name      = each.value.name
  parent_id = coalesce(each.value.parent_id, local.root_id)
}

# Provisioning Sandbox, Dev, Prod Accounts
resource "aws_organizations_account" "this" {
  for_each  = var.accounts
  name      = each.value.name
  email     = each.value.email
  parent_id = contains(keys(aws_organizations_organizational_unit.this), each.value.ou_key) ? aws_organizations_organizational_unit.this[each.value.ou_key].id : local.root_id

  iam_user_access_to_billing = each.value.iam_user_access_to_billing
  role_name                  = each.value.role_name

  lifecycle {
    ignore_changes = [
      role_name,
      email
    ]
  }

  tags = merge({ Name = each.value.name }, var.tags)
}

# SCPs: Built-in Policies
resource "aws_organizations_policy" "deny_root" {
  count       = var.enable_deny_root_scp ? 1 : 0
  name        = "DenyRootUserAccess"
  description = "SCP to deny root user access in member accounts"
  type        = "SERVICE_CONTROL_POLICY"
  content     = local.deny_root_policy_content
  tags        = merge({ Name = "${var.organization_name}-deny-root-scp" }, var.tags)
}

resource "aws_organizations_policy" "prevent_leave_org" {
  count       = var.enable_prevent_leave_org_scp ? 1 : 0
  name        = "PreventLeaveOrganization"
  description = "SCP to prevent member accounts from leaving the organization"
  type        = "SERVICE_CONTROL_POLICY"
  content     = local.prevent_leave_org_policy_content
  tags        = merge({ Name = "${var.organization_name}-prevent-leave-scp" }, var.tags)
}

resource "aws_organizations_policy" "restrict_regions" {
  count       = var.enable_region_restriction_scp ? 1 : 0
  name        = "RestrictRegions"
  description = "SCP to restrict operations to approved AWS regions"
  type        = "SERVICE_CONTROL_POLICY"
  content     = local.restrict_regions_policy_content
  tags        = merge({ Name = "${var.organization_name}-restrict-regions-scp" }, var.tags)
}

# SCPs: Custom Policies
resource "aws_organizations_policy" "custom" {
  for_each    = var.service_control_policies
  name        = each.value.name
  description = each.value.description
  type        = "SERVICE_CONTROL_POLICY"
  content     = each.value.content
  tags        = merge({ Name = "${var.organization_name}-${each.key}-policy" }, var.tags)
}

# Resolving Policy Targets and Attachments
locals {
  deny_root_targets = {
    for target in var.deny_root_scp_targets : target => (
      target == "root" ? local.root_id : (
        contains(keys(aws_organizations_organizational_unit.this), target) ? aws_organizations_organizational_unit.this[target].id : target
      )
    )
  }

  prevent_leave_org_targets = {
    for target in var.prevent_leave_org_scp_targets : target => (
      target == "root" ? local.root_id : (
        contains(keys(aws_organizations_organizational_unit.this), target) ? aws_organizations_organizational_unit.this[target].id : target
      )
    )
  }

  restrict_regions_targets = {
    for target in var.restrict_regions_scp_targets : target => (
      target == "root" ? local.root_id : (
        contains(keys(aws_organizations_organizational_unit.this), target) ? aws_organizations_organizational_unit.this[target].id : target
      )
    )
  }

  custom_attachments = {
    for k, v in var.custom_policy_attachments : k => {
      policy_id = aws_organizations_policy.custom[v.policy_key].id
      target_id = (
        v.target_key == "root" ? local.root_id : (
          contains(keys(aws_organizations_organizational_unit.this), v.target_key) ? aws_organizations_organizational_unit.this[v.target_key].id : (
            contains(keys(aws_organizations_account.this), v.target_key) ? aws_organizations_account.this[v.target_key].id : v.target_key
          )
        )
      )
    }
  }
}

resource "aws_organizations_policy_attachment" "deny_root" {
  for_each  = var.enable_deny_root_scp ? local.deny_root_targets : {}
  policy_id = join("", aws_organizations_policy.deny_root[*].id)
  target_id = each.value
}

resource "aws_organizations_policy_attachment" "prevent_leave_org" {
  for_each  = var.enable_prevent_leave_org_scp ? local.prevent_leave_org_targets : {}
  policy_id = join("", aws_organizations_policy.prevent_leave_org[*].id)
  target_id = each.value
}

resource "aws_organizations_policy_attachment" "restrict_regions" {
  for_each  = var.enable_region_restriction_scp ? local.restrict_regions_targets : {}
  policy_id = join("", aws_organizations_policy.restrict_regions[*].id)
  target_id = each.value
}

resource "aws_organizations_policy_attachment" "custom" {
  for_each  = local.custom_attachments
  policy_id = each.value.policy_id
  target_id = each.value.target_id
}
