resource "aws_cloudfront_origin_access_control" "default" {
  name                              = var.bucket_regional_domain_name
  description                       = "Hillel-DZ18 AWS CloudFront Origin Access Control"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_response_headers_policy" "this" {
  name = "security-headers-policy"

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 31536000
      override                   = false
    }

    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "SAMEORIGIN"
      override     = false
    }

    xss_protection {
      protection = true
      mode_block = true
      override   = false
    }

    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = false
    }
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = [
    aws_cloudfront_origin_access_control.default,
    aws_cloudfront_response_headers_policy.this
  ]

  origin {
    domain_name              = var.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = var.bucket_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Hillel DZ18"
  default_root_object = "index.html"

  default_cache_behavior {
    # Using the CachingDisabled managed policy ID:
    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    allowed_methods            = ["DELETE", "GET"]
    cached_methods             = ["GET", "HEAD"]
    response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    target_origin_id           = var.bucket_id
    viewer_protocol_policy     = "allow-all"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
