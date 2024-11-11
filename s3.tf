data "aws_cloudfront_cache_policy" "s3-cache-optimized" {
  name = "Managed-CachingOptimized"
}


# S3 Bucket Policy
resource "aws_iam_policy" "s3_access_policy" {
  depends_on = [aws_s3_bucket.my_bucket]
  name        = "${var.aws_region}_${local.client_name_no_spaces}_S3_Policy"
  description = "Policy to allow S3 access"
  tags = local.tags.default
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["s3:ListBucket", "s3:GetObject", "s3:PutObject"],
        Effect = "Allow",
        Resource = [
          aws_s3_bucket.my_bucket.arn,
          "${aws_s3_bucket.my_bucket.arn}/*"
        ]
      }
    ]
  })
}


# Create S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = local.s3_bucket_name
  tags   = local.tags.default
}


resource "aws_s3_bucket_policy" "allow_cloudfront_access" {
  bucket = aws_s3_bucket.my_bucket.id
  policy = data.aws_iam_policy_document.allow_cloudfront_access.json
}