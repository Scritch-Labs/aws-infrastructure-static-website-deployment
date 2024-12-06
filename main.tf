terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.80.0"
    }
  }
}

//  Create a github repository in terraform as code
provider "github" {
  token = var.github_token
  owner = var.repo_owner
}

provider "aws" {
  region = var.aws_region
}