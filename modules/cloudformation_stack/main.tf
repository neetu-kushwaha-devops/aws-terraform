terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

locals {
  # Flatten deployments to individual stack set instances.
  stack_set_instances_list = flatten([
    for idx, dep in var.stack_set_deployments : [
      dep.organizational_unit_ids != null && length(coalesce(dep.organizational_unit_ids, [])) > 0 ? [
        for region in coalesce(dep.regions, []) : {
          key                     = "service_managed_${idx}_${region}"
          account_id              = null
          region                  = region
          organizational_unit_ids = dep.organizational_unit_ids
          account_filter_type     = dep.account_filter_type
          accounts                = dep.accounts
          parameter_overrides     = dep.parameter_overrides
          retain_stack            = dep.retain_stack
          call_as                 = dep.call_as
          operation_preferences   = dep.operation_preferences
        }
        ] : [
        for account in coalesce(dep.accounts, []) : [
          for region in coalesce(dep.regions, []) : {
            key                     = "self_managed_${idx}_${account}_${region}"
            account_id              = account
            region                  = region
            organizational_unit_ids = null
            account_filter_type     = null
            accounts                = null
            parameter_overrides     = dep.parameter_overrides
            retain_stack            = dep.retain_stack
            call_as                 = dep.call_as
            operation_preferences   = dep.operation_preferences
          }
        ]
      ]
    ]
  ])

  stack_set_instances = {
    for inst in local.stack_set_instances_list : inst.key => inst
  }
}

# Standalone CloudFormation Stack
resource "aws_cloudformation_stack" "this" {
  count = var.create_stack ? 1 : 0

  name               = var.name
  template_body      = var.template_body
  template_url       = var.template_url
  parameters         = var.parameters
  capabilities       = var.capabilities
  disable_rollback   = var.disable_rollback
  timeout_in_minutes = var.timeout_in_minutes
  iam_role_arn       = var.iam_role_arn
  notification_arns  = var.notification_arns
  on_failure         = var.on_failure
  policy_body        = var.policy_body
  policy_url         = var.policy_url

  tags = merge({ Name = var.name }, var.tags)
}

# CloudFormation StackSet
resource "aws_cloudformation_stack_set" "this" {
  count = var.create_stack_set ? 1 : 0

  name                    = var.name
  description             = var.description
  template_body           = var.template_body
  template_url            = var.template_url
  parameters              = var.parameters
  capabilities            = var.capabilities
  administration_role_arn = var.administration_role_arn
  execution_role_name     = var.execution_role_name
  permission_model        = var.permission_model
  call_as                 = var.call_as

  dynamic "auto_deployment" {
    for_each = var.auto_deployment != null ? [var.auto_deployment] : []
    content {
      enabled                          = lookup(auto_deployment.value, "enabled", null)
      retain_stacks_on_account_removal = lookup(auto_deployment.value, "retain_stacks_on_account_removal", null)
    }
  }

  dynamic "managed_execution" {
    for_each = var.managed_execution != null ? [var.managed_execution] : []
    content {
      active = lookup(managed_execution.value, "active", null)
    }
  }

  tags = merge({ Name = var.name }, var.tags)
}

# CloudFormation StackSet Instance(s)
resource "aws_cloudformation_stack_set_instance" "this" {
  for_each = var.create_stack_set ? local.stack_set_instances : {}

  stack_set_name      = one(aws_cloudformation_stack_set.this[*].name)
  account_id          = each.value.account_id
  region              = each.value.region
  parameter_overrides = each.value.parameter_overrides
  retain_stack        = each.value.retain_stack
  call_as             = each.value.call_as

  dynamic "deployment_targets" {
    for_each = each.value.organizational_unit_ids != null ? [1] : []
    content {
      organizational_unit_ids = each.value.organizational_unit_ids
      account_filter_type     = each.value.account_filter_type
      accounts                = each.value.accounts
    }
  }

  dynamic "operation_preferences" {
    for_each = each.value.operation_preferences != null ? [each.value.operation_preferences] : []
    content {
      failure_tolerance_count      = lookup(operation_preferences.value, "failure_tolerance_count", null)
      failure_tolerance_percentage = lookup(operation_preferences.value, "failure_tolerance_percentage", null)
      max_concurrent_count         = lookup(operation_preferences.value, "max_concurrent_count", null)
      max_concurrent_percentage    = lookup(operation_preferences.value, "max_concurrent_percentage", null)
      region_concurrency_type      = lookup(operation_preferences.value, "region_concurrency_type", null)
      region_order                 = lookup(operation_preferences.value, "region_order", null)
    }
  }
}
