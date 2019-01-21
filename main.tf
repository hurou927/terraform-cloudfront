provider "aws" {
  region  = "ap-northeast-1"
  version = "1.0.0"
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "s3-bucket"
}

resource "aws_cloudfront_distribution" "dist" {
  depends_on = ["aws_cloudfront_origin_access_identity.oai"]
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"
  price_class = "PriceClass_200"
  # PriceClass_All All Edge Location
  # PriceClass_200 U.S., Canada, Europe, Asia and Africa
  # PriceClass_100 U.S., Canada and Europe
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  origin {
    # S3 static web site hosting
    domain_name = "react-hosting-hurou927.s3-website-us-east-1.amazonaws.com"
    origin_id = "static-hosting"

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_keepalive_timeout = 30
      origin_read_timeout = 5
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = [
          "TLSv1", "TLSv1.1", "TLSv1.2"
      ]
    }

  }
  origin {
    # S3 BUCKET
    domain_name = "react-hosting-hurou927.s3.amazonaws.com"
    origin_id = "s3-bucket"
    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path }"
    }
  }
  origin {
     # API Gateway
    domain_name = "api.hurouap.com"
    origin_id = "rest-api"
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_keepalive_timeout = 30
      origin_read_timeout = 5
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = [
          "TLSv1", "TLSv1.1", "TLSv1.2"
      ]
    }
    # }
  }
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "static-hosting"
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 0 #3600
    max_ttl                = 0 #86400
  }
  # Cache behavior with precedence 1
  cache_behavior {
    path_pattern     = "img/*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-bucket"
    forwarded_values {
      query_string = true
      headers      = [
        "Origin", "User-Agent", "CloudFront-Is-Mobile-Viewer","CloudFront-Is-Tablet-Viewer","CloudFront-Is-SmartTV-Viewer","CloudFront-Is-Desktop-Viewer"
      ]
      cookies {
        forward = "none"
      }
    }
    min_ttl                = 0
    default_ttl            = 0# 86400
    max_ttl                = 0# 31536000
    compress               = true
    viewer_protocol_policy = "https-only"
  }
  # Cache behavior with precedence 2
  cache_behavior {
    path_pattern     = "api/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "rest-api"
    forwarded_values {
      query_string = true
      headers      = [
        "Origin", "User-Agent", "CloudFront-Is-Mobile-Viewer","CloudFront-Is-Tablet-Viewer","CloudFront-Is-SmartTV-Viewer","CloudFront-Is-Desktop-Viewer"
      ]
      cookies {
        forward = "none"
      }
    }
    min_ttl                = 0
    default_ttl            = 0# 86400
    max_ttl                = 0# 31536000
    compress               = true
    viewer_protocol_policy = "https-only"
  }
  
  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:008190894346:certificate/4b9944cf-5a5e-46a1-8c13-bc453c212bd6"
    cloudfront_default_certificate = true
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
  aliases = ["cf.hurouap.com"]
}
