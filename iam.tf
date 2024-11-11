//   Create the OIDC deployment resource
resource "aws_iam_openid_connect_provider" "GitHubOIDC" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [var.aws_oidc_thumbprint]
  url = var.aws_iam_oidc_provider_url
}

resource "aws_iam_role" "role_to_access" {
  path = "/"
  name = local.iam_deployement_role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.GitHubOIDC.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",
            "token.actions.githubusercontent.com:sub" = "repo:${var.repo_owner}/${var.github_repo_name}:ref:refs/heads/main"
          }
        }
      }
    ]
  })
  max_session_duration = 3600
  tags                 = local.tags.default
}


# Attach Policies to IAM User
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  policy_arn = aws_iam_policy.s3_access_policy.arn
  role       = aws_iam_role.role_to_access.name
}

resource "aws_iam_role_policy_attachment" "cloudfront_policy_attachment" {
  policy_arn = aws_iam_policy.cloudfront_access_policy.arn
  role       = aws_iam_role.role_to_access.name
}