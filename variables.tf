# Input Variables
variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "domain_name" {
  description = "The domain name associated with the account."
  type        = string
}

variable "client_name" {
  description = "The name of the client"
  type        = string
}

variable "multi_page" {
  description = "Whether the site is a single page or multi page site."
  type        = bool
  default     = false
}

variable "aliases" {
  description = "A list of aliases for the site."
  type = list(string)
  default = []
}

variable "domain_name_verified" {
  description = "Whether the domain name has been verified."
  type        = bool
  default     = false
}

variable "aws_iam_oidc_provider_url" {
  description = "The URL of the OIDC provider."
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "aws_oidc_thumbprint" {
  description = "The thumbprint of the OIDC provider."
  type        = string
  default     = "a031c467c254c5f6c7b66d7b0a3d9a5168b6cb5e"
  sensitive   = true
}


locals {
  s3_bucket_name    = "${var.domain_name}-website"
  redirect_from_url = "www.${var.domain_name}"
  cert_domain       = "*.${var.domain_name}"
  client_name_no_spaces = replace(var.client_name, " ", "")
  cloud-front = {
    origin_id = "S3-${local.s3_bucket_name}"
  }
  iam_deployement_role = "github-oidc-${local.client_name_no_spaces}"

  tags = {
    description = "Tags to set on the bucket."
    default = {
      Client      = var.client_name
      Terraform   = "true"
      Environment = terraform.workspace == "default" ? "production" : terraform.workspace
    }
  }
}