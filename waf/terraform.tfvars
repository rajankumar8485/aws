rules = [
    {
      name            = "AWS-AWSManagedRulesCommonRuleSet"
      priority        = 0
      override_action = "none"
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
        sampled_requests_enabled   = true
      }
      action          = "allow"
      managed_rule_group_statement = {
        name          = "AWSManagedRulesCommonRuleSet"
        vendor_name   = "AWS"
        excluded_rule = ["SizeRestrictions_BODY","CrossSiteScripting_BODY"]
      }
    },
    {
      name            = "AWS-AWSManagedRulesSQLiRuleSet"
      priority        = 1
      override_action = "none"
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWS-AWSManagedRulesSQLiRuleSet"
        sampled_requests_enabled   = true
      }
      action          = "allow"
      managed_rule_group_statement = {
        name          = "AWSManagedRulesSQLiRuleSet"
        vendor_name   = "AWS"
      }
    },
    {
      name            = "AWS-AWSManagedRulesAmazonIpReputationList"
      priority        = 2
      override_action = "none"
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
        sampled_requests_enabled   = true
      }
      action          = "allow"
      managed_rule_group_statement = {
        name          = "AWSManagedRulesAmazonIpReputationList"
        vendor_name   = "AWS"
      }
    },
    {
      name            = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      priority        = 3
      override_action = "none"
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
        sampled_requests_enabled   = true
      }
      action          = "allow"
      managed_rule_group_statement = {
        name          = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name   = "AWS"
      }
    }
]

waf_association_map = [
  {
    resource_arn = "api_gateway_arn"
    type         = "device"
  },
  {
    resource_arn = "load_balancer_arn"
    type         = "public-api"
  }
]