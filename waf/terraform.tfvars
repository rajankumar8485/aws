rules = [
    {
      name            = "AWS-AWSManagedRulesCommonRuleSet"
      priority        = 0
      override_action = "none"
      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "AWSManagedRulesRuleSet-metric"
        sampled_requests_enabled   = false
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
      action          = "allow"
      managed_rule_group_statement = {
        name          = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name   = "AWS"
      }
    }
]