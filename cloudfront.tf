resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "api-scot-qa.nf-covid-services.com"
    origin_id   = "APIGateway"
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = "APIGateway"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  origin {
    domain_name = aws_s3_bucket.assets.bucket_regional_domain_name
    origin_path = "/exposures"
    origin_id   = "S3ExposuresBucket"

    s3_origin_config {
      
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity_s3.cloudfront_access_identity_path
    }
  }

    ordered_cache_behavior {
    path_pattern     = "*.zip"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3ExposuresBucket"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  enabled = true

  aliases = ["test-cloudfront.nf-covid-services.com"]



  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = module.labels.tags

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = local.gateway_api_certificate_arn
    ssl_support_method             = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity_s3" {
  comment = "Access identity for CloudFront"
}
