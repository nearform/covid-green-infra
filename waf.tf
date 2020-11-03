resource "aws_wafregional_web_acl" "acl" {
  name        = format("%s-waf", module.labels.id)
  metric_name = format("ftWaf%s", var.environment)

  tags = module.labels.tags

  default_action {
    type = "ALLOW"
  }

  # Only add this rule if we have a list, if empty ignore - unrestricted
  # Action is block as we have negated the rule (Anything not in the list will be blocked)
  dynamic rule {
    for_each = local.waf_geo_blocking_count == 1 ? { 1 : 1 } : {}

    content {
      action {
        type = "BLOCK"
      }

      priority = 5
      rule_id  = aws_wafregional_rule.geo_allowed[0].id
      type     = "REGULAR"
    }
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 10
    rule_id  = aws_wafregional_rule.sqli.id
    type     = "REGULAR"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 20
    rule_id  = aws_wafregional_rule.xss.id
    type     = "REGULAR"
  }
}

## Geo blocking
resource "aws_wafregional_geo_match_set" "geo_allowed" {
  count = local.waf_geo_blocking_count

  name = format("%s-geo-allowed", module.labels.id)

  dynamic geo_match_constraint {
    for_each = toset(var.waf_geo_allowed_countries)

    content {
      type  = "Country"
      value = geo_match_constraint.key
    }
  }
}

resource "aws_wafregional_rule" "geo_allowed" {
  count       = local.waf_geo_blocking_count
  name        = format("%s-geo-allowed", module.labels.id)
  metric_name = format("ftGEO%s", var.environment)

  predicate {
    data_id = aws_wafregional_geo_match_set.geo_allowed[0].id
    negated = true # This does a flip so we can do a block at the Web ACL rule
    type    = "GeoMatch"
  }
}

## slq injection
resource "aws_wafregional_sql_injection_match_set" "sqli" {
  name = format("%s-generic-sqli", module.labels.id)

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "HEADER"
      data = "Authorization"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "HEADER"
      data = "Authorization"
    }
  }
}

resource "aws_wafregional_rule" "sqli" {
  name        = format("%s-generic-sqli", module.labels.id)
  metric_name = format("ftSQLI%s", var.environment)

  predicate {
    data_id = aws_wafregional_sql_injection_match_set.sqli.id
    negated = false
    type    = "SqlInjectionMatch"
  }
}

## xss
resource "aws_wafregional_xss_match_set" "xss" {
  name = format("%s-generic-xss", module.labels.id)

  xss_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  xss_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  xss_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  xss_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  xss_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  xss_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  xss_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }

  xss_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }
}

resource "aws_wafregional_rule" "xss" {
  name        = format("%s-generic-xss", module.labels.id)
  metric_name = format("ftXSS%s", var.environment)

  predicate {
    data_id = aws_wafregional_xss_match_set.xss.id
    negated = false
    type    = "XssMatch"
  }
}

resource "aws_wafregional_web_acl_association" "gateway" {
  count        = var.attach_waf ? 1 : 0
  resource_arn = aws_api_gateway_stage.live.arn
  web_acl_id   = aws_wafregional_web_acl.acl.id
}

resource "aws_wafregional_web_acl_association" "api" {
  count        = var.attach_waf ? 1 : 0
  resource_arn = aws_lb.api.arn
  web_acl_id   = aws_wafregional_web_acl.acl.id
}

resource "aws_wafregional_web_acl_association" "push" {
  count        = var.attach_waf ? 1 : 0
  resource_arn = aws_lb.push.arn
  web_acl_id   = aws_wafregional_web_acl.acl.id
}
