data "aws_iam_policy_document" "allow_cloudfront_access" {
  statement {
    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type = "Service"
    }

    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.my_bucket.arn}/*",
    ]

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "AWS:SourceArn"
      values = [
        aws_cloudfront_distribution.my_distribution.arn,
      ]
    }
  }
}

data "aws_cloudfront_function" "www-redirect-to-nonwww" {
  name = "www-redirect-with-index-redirection"
  stage = "LIVE"
}

data "aws_cloudfront_function" "www-redirect-with-index-redirection" {
  name = "www-redirect-with-index-redirection"
  stage = "LIVE"
}

# CloudFront Policy
resource "aws_iam_policy" "cloudfront_access_policy" {
  name        = "global_${local.client_name_no_spaces}_CloudFront_Policy"
  description = "Policy to allow CloudFront access"
  tags        = local.tags.default
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["cloudfront:CreateInvalidation"],
        Effect   = "Allow",
        Resource = "*",
        Condition = {
          StringEquals = {
            "cloudfront:ResourceTag/Client" = "$${aws:PrincipalTag/Client}"
          }
        }
      }
    ]
  })
}

# Origin Access Control
resource "aws_cloudfront_origin_access_control" "origin_access_control" {
  depends_on = [aws_s3_bucket.my_bucket, aws_iam_policy.cloudfront_access_policy]

  name                              = aws_s3_bucket.my_bucket.bucket_regional_domain_name
  description                       = ""
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Create cloudfront
resource "aws_cloudfront_distribution" "my_distribution" {
  depends_on = [aws_s3_bucket.my_bucket]

  tags = local.tags.default

  origin {
    domain_name              = aws_s3_bucket.my_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.origin_access_control.id
    origin_id                = local.cloud-front.origin_id
  }

  enabled             = true
  comment             = "${var.client_name} Website"
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100" # US, Canada, Europe
  custom_error_response {
    error_code         = 403
    response_code      = 404
    response_page_path = "/404.html"
  }
  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/404.html"
  }

  aliases = var.domain_name_verified ? [
    var.domain_name,
    local.redirect_from_url
  ] : []

  default_cache_behavior {
    cache_policy_id  = data.aws_cloudfront_cache_policy.s3-cache-optimized.id
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = local.cloud-front.origin_id
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
    function_association {
      event_type   = "viewer-request"
      function_arn =  var.multi_page ? data.aws_cloudfront_function.www-redirect-with-index-redirection.arn : data.aws_cloudfront_function.www-redirect-to-nonwww.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.domain_name_verified ? aws_acm_certificate.certificate.arn : null
    cloudfront_default_certificate = !var.domain_name_verified
    minimum_protocol_version       = var.domain_name_verified ? "TLSv1.2_2021" : null
    ssl_support_method             = var.domain_name_verified ?"sni-only" : null
  }
}

# Create CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Access Identity for S3 bucket"
}