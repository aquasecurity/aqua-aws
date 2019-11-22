#################################################
# Create Record Set with ALIAS
#################################################

data "aws_route53_zone" "my-zone" {
  name         = var.dns_domain
  private_zone = false
}

resource "aws_route53_record" "aqua-console" {
  zone_id = data.aws_route53_zone.my-zone.id
  name    = var.console_name
  type    = "A"

  alias {
    name                   = aws_alb.alb-console.dns_name
    zone_id                = aws_alb.alb-console.zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.console_name}.${var.dns_domain}"
  validation_method = "DNS"

  tags = {
    Terraform = "true"
    Owner     = var.resource_owner
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.cert.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.cert.domain_validation_options[0].resource_record_type
  zone_id = data.aws_route53_zone.my-zone.id
  records = [aws_acm_certificate.cert.domain_validation_options[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}