terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_wafv2_web_acl" "this" {
  name        = var.name
  description = "WAFv2 Web ACL for ${var.name}"
  scope       = var.scope

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "allow" ? [1] : []
      content {}
    }
    dynamic "block" {
      for_each = var.default_action == "block" ? [1] : []
      content {}
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name}-webacl"
    sampled_requests_enabled   = true
  }

  # 1. AWS Managed Common Rule Set
  dynamic "rule" {
    for_each = var.enable_common_rule_set ? [1] : []
    content {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 10

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWSManagedRulesCommonRuleSet"
        sampled_requests_enabled   = true
      }
    }
  }

  # 2. AWS Managed SQL Injection Rule Set
  dynamic "rule" {
    for_each = var.enable_sqli_rule_set ? [1] : []
    content {
      name     = "AWSManagedRulesSQLiRuleSet"
      priority = 20

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesSQLiRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWSManagedRulesSQLiRuleSet"
        sampled_requests_enabled   = true
      }
    }
  }

  # 3. AWS Managed Known Bad Inputs Rule Set
  dynamic "rule" {
    for_each = var.enable_known_bad_inputs ? [1] : []
    content {
      name     = "AWSManagedRulesKnownBadInputsRuleSet"
      priority = 30

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesKnownBadInputsRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
        sampled_requests_enabled   = true
      }
    }
  }

  # 4. Custom IP Rate Limiting Rule
  dynamic "rule" {
    for_each = var.enable_ip_rate_limiting ? [1] : []
    content {
      name     = "IPRateLimitingRule"
      priority = 40

      action {
        dynamic "block" {
          for_each = var.rate_limit_action == "block" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = var.rate_limit_action == "count" ? [1] : []
          content {}
        }
        dynamic "captcha" {
          for_each = var.rate_limit_action == "captcha" ? [1] : []
          content {}
        }
      }

      statement {
        rate_based_statement {
          limit              = var.rate_limit_threshold
          aggregate_key_type = "IP"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "IPRateLimitingRule"
        sampled_requests_enabled   = true
      }
    }
  }

  # 5. Generic Custom Rules
  dynamic "rule" {
    for_each = var.custom_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      dynamic "action" {
        for_each = lookup(rule.value, "action", null) != null ? [rule.value.action] : []
        content {
          dynamic "allow" {
            for_each = action.value == "allow" ? [1] : []
            content {}
          }
          dynamic "block" {
            for_each = action.value == "block" ? [1] : []
            content {}
          }
          dynamic "count" {
            for_each = action.value == "count" ? [1] : []
            content {}
          }
          dynamic "captcha" {
            for_each = action.value == "captcha" ? [1] : []
            content {}
          }
        }
      }

      dynamic "override_action" {
        for_each = lookup(rule.value, "override_action", null) != null ? [rule.value.override_action] : []
        content {
          dynamic "none" {
            for_each = override_action.value == "none" ? [1] : []
            content {}
          }
          dynamic "count" {
            for_each = override_action.value == "count" ? [1] : []
            content {}
          }
        }
      }

      statement {
        dynamic "geo_match_statement" {
          for_each = lookup(rule.value.statement, "geo_match_statement", null) != null ? [rule.value.statement.geo_match_statement] : []
          content {
            country_codes = geo_match_statement.value.country_codes
          }
        }
        dynamic "ip_set_reference_statement" {
          for_each = lookup(rule.value.statement, "ip_set_reference_statement", null) != null ? [rule.value.statement.ip_set_reference_statement] : []
          content {
            arn = ip_set_reference_statement.value.arn
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = lookup(rule.value.visibility_config, "cloudwatch_metrics_enabled", true)
        metric_name                = lookup(rule.value.visibility_config, "metric_name", rule.value.name)
        sampled_requests_enabled   = lookup(rule.value.visibility_config, "sampled_requests_enabled", true)
      }
    }
  }

  tags = merge({ Name = var.name }, var.tags)
}

# Optional CloudWatch Log Group for streaming WAF logs
resource "aws_cloudwatch_log_group" "this" {
  count             = var.create_log_group ? 1 : 0
  name              = "aws-waf-logs-${var.name}"
  retention_in_days = var.log_group_retention_in_days
  tags              = merge({ Name = "${var.name}-logs" }, var.tags)
}

# Logging configuration mapping WAF to log destination
resource "aws_wafv2_web_acl_logging_configuration" "this" {
  count                   = var.create_log_group || var.cloudwatch_log_group_arn != "" ? 1 : 0
  log_destination_configs = [var.create_log_group ? aws_cloudwatch_log_group.this[0].arn : var.cloudwatch_log_group_arn]
  resource_arn            = aws_wafv2_web_acl.this.arn
}
