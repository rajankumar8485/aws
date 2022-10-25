resource "aws_wafv2_web_acl" "this" {
  name        = "${var.stack_name}_web_acl"
  description = "Web acl"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = var.rules
    content {
       name     = lookup(rule.value, "name")
       priority = lookup(rule.value, "priority")
       
       override_action {
        count {}
       }
       
       dynamic "action" {
        for_each = lookup(rule.value, "action", null) == null ? [] : [lookup(rule.value, "action")]
        content {
          dynamic "allow" {
            for_each = lower(action.value) == "allow" ? [1] : []
            content {}
          }

          dynamic "block" {
            for_each = lower(action.value) == "block" ? [1] : []
            content {}
          }

          dynamic "count" {
            for_each = lower(action.value) == "count" ? [1] : []
            content {}
          }
        }
      }

      statement {
        dynamic "managed_rule_group_statement" {
          for_each = lookup(rule.value, "managed_rule_group_statement", null) == null ? [] : [lookup(rule.value, "managed_rule_group_statement")]
          content {
            name        = lookup(managed_rule_group_statement.value, "name")
            vendor_name = lookup(managed_rule_group_statement.value, "vendor_name", "AWS")

            dynamic "excluded_rule" {
              for_each = lookup(managed_rule_group_statement.value, "excluded_rule", null) == null ? [] : lookup(managed_rule_group_statement.value, "excluded_rule")
              content {
                name = excluded_rule.value
              }
            }
          }
        }
      }

      dynamic "visibility_config" {
        for_each = [lookup(rule.value, "visibility_config", {})]
        content {
            cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
            metric_name                = lookup(visibility_config.value, "metric_name", "${var.stack_name}-default-rule-metric-name")
            sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
        }
      }
    
    }

  }

  tags = var.tags

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "${var.stack_name}-default-web-acl-metric"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_association" "this" {

  count = var.waf_association_create ? 1 : 0

  resource_arn = var.aws_resource_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn

}