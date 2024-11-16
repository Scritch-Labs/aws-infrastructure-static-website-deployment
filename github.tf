//  Create the github repository
resource "github_repository" "repo" {
  name                 = var.github_repo_name
  visibility           = "private"
  vulnerability_alerts = false
}

resource "github_actions_variable" "s3_url_variable" {
  repository    = github_repository.repo.name
  variable_name = "S3_BUCKET_NAME"
  value         = aws_s3_bucket.my_bucket.bucket

  depends_on = [aws_s3_bucket.my_bucket, github_repository.repo]
}

resource "github_actions_variable" "iam_role_arn_variable" {
  repository    = github_repository.repo.name
  variable_name = "IAM_DEPLOYMENT_ROLE_ARN"
  value         = aws_iam_role.role_to_access.arn

  depends_on = [aws_iam_role.role_to_access, github_repository.repo]
}

resource "github_actions_variable" "cloud_front_distribution_id" {
  repository    = github_repository.repo.name
  variable_name = "CLOUDFRONT_DISTRIBUTION_ID"
  value         = aws_cloudfront_distribution.my_distribution.id

  depends_on = [aws_cloudfront_distribution.my_distribution, github_repository.repo]
}

resource "github_actions_variable" "aws_region" {
  repository    = github_repository.repo.name
  variable_name = "AWS_REGION"
  value         = var.aws_region

  depends_on = [aws_cloudfront_distribution.my_distribution, github_repository.repo]
}