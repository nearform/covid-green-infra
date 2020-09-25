# #########################################
# Route53 zone
# #########################################
data "aws_route53_zone" "primary" {
  count        = local.enable_dns_count
  provider     = aws.dns
  name         = var.route53_zone
  private_zone = false
}


# #########################################
# Certificate
# #########################################
resource "aws_acm_certificate" "wildcard_cert" {
  count             = local.enable_certificates_count
  domain_name       = var.wildcard_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "wildcard_cert_validation" {
  provider = aws.dns
  for_each = {
    for dvo in aws_acm_certificate.wildcard_cert.0.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  zone_id         = data.aws_route53_zone.primary[0].id
  ttl             = 60
  allow_overwrite = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "wildcard_cert" {
  count                   = local.enable_certificates_count
  certificate_arn         = aws_acm_certificate.wildcard_cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.wildcard_cert_validation : record.fqdn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "wildcard_cert_us" {
  count             = local.enable_certificates_count
  provider          = aws.us_east_1
  domain_name       = var.wildcard_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "wildcard_cert_validation_us" {
  provider = aws.dns
  for_each = {
    for dvo in aws_acm_certificate.wildcard_cert_us.0.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  zone_id         = data.aws_route53_zone.primary[0].id
  ttl             = 60
  allow_overwrite = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "wildcard_cert_us" {
  count                   = local.enable_certificates_count
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.wildcard_cert_us[0].arn
  validation_record_fqdns = [for record in aws_route53_record.wildcard_cert_validation_us : record.fqdn]

  lifecycle {
    create_before_destroy = true
  }
}

# #########################################
# DNS Records
# #########################################
resource "aws_route53_record" "api" {
  count    = local.enable_dns_count
  provider = aws.dns
  zone_id  = data.aws_route53_zone.primary[0].id
  name     = var.api_dns
  type     = "A"

  alias {
    name                   = aws_api_gateway_domain_name.main[0].cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.main[0].cloudfront_zone_id
    evaluate_target_health = true
  }
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_domain_name.main
  ]
}

resource "aws_route53_record" "push" {
  count    = local.enable_dns_count
  provider = aws.dns
  zone_id  = data.aws_route53_zone.primary.0.id
  name     = var.push_dns
  type     = "A"

  alias {
    name                   = aws_lb.push.dns_name
    zone_id                = aws_lb.push.zone_id
    evaluate_target_health = true
  }
  lifecycle {
    create_before_destroy = true
  }
}
