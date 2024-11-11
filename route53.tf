#------------------------------------------------------------------------------
# ROUTE 53 ZONE CREATION
#------------------------------------------------------------------------------
resource "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
  tags = local.tags.default
}