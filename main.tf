//  Create a github repository in terraform as code
provider "github" {
  token = var.github_token
  owner = var.repo_owner
}

provider "aws" {
  region = var.aws_region
}