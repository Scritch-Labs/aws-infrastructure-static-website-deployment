#------------------------------------------------------------------------------
# CREATE CLOUDFRONT CERTIFICATE
#------------------------------------------------------------------------------
resource "aws_acm_certificate" "certificate" {
  domain_name = var.domain_name
  subject_alternative_names = [
    var.domain_name
  ]
  certificate_chain = ""
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
    ignore_changes = [aws_acm_certificate.certificate.certificate_body]
  }

  tags = local.tags.default
}

#------------------------------------------------------------------------------
# ROUTE 53 VERIFICATION
#------------------------------------------------------------------------------
resource "aws_route53_record" "route53_record" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.hosted_zone.zone_id

  depends_on = [aws_acm_certificate.certificate]
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  count = var.domain_name_verified ? 1 : 0
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.route53_record : record.fqdn]

  depends_on = [aws_route53_record.route53_record]
}