resource "aws_acm_certificate" "ssl_cert" {
  domain_name       = "devops42.online"
  validation_method = "DNS"

  subject_alternative_names = ["*.devops42.online"]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "SSL Certificate"
  }
}

# Prevent duplicate Route53 record error
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.ssl_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      value  = dvo.resource_record_value
    }
  }

  allow_overwrite = true  # <-- Fixes the duplicate record error

  zone_id = "Z0119957311W2KYKJ50SY"
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.value]
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.ssl_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

