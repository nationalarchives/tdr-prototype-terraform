locals {
  web_origin_id = "${var.app_name}-${var.environment}"
} 

resource "aws_cloudfront_distribution" "web_distribution" {
  origin {
    domain_name = "${aws_alb.main.dns_name}"
    origin_id   = "${local.web_origin_id}"
    custom_origin_config {
        http_port                = "80"
        https_port               = "443"
        origin_protocol_policy   = "http-only"
        origin_ssl_protocols     = ["TLSv1"]
        origin_keepalive_timeout = "5"
        origin_read_timeout      = "30"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.web_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
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

  tags = "${merge(
    var.common_tags,
    map(
      "Name", "${var.app_name}-cdn",      
      "CreatedBy", "${var.tag_created_by}"
    )
  )}"
}