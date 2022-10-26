resource "aws_wafv2_web_acl" "this" {
  for_each    = toset(var.waf_type)

  name        = "${var.stack_name}-${each.key}-web-acl"
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
       
       dynamic "override_action" {
        for_each = lookup(rule.value, "override_action", null) == null ? [] : [1]
        content {
          dynamic "none" {
            for_each = lower(lookup(rule.value, "override_action", null)) == "none" ? [1] : []
            content {}
          }

          dynamic "count" {
            for_each = lower(lookup(rule.value, "override_action", null)) == "count" ? [1] : []
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
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.stack_name}-default-web-acl-metric-name"
    sampled_requests_enabled   = true
  }
}

# resource "aws_wafv2_web_acl_association" "this" {

#   for_each = var.waf_association_map

#   resource_arn = each.value.resource_arn
#   web_acl_arn  = aws_wafv2_web_acl.this[each.value.type].arn

# }