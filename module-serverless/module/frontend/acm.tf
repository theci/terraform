### acm
resource "aws_acm_certificate" "acm_certificate" {
  domain_name               = var.acm_domain_name
  validation_method         = "DNS"
  provider = aws.virginia
  lifecycle {
    create_before_destroy = true
  }
}


data "aws_route53_zone" "route53_zone" {
  zone_id      = var.zone_id
  private_zone = false
}


resource "aws_route53_record" "route53_record" {
  for_each = {
    for dvo in aws_acm_certificate.acm_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.route53_zone.zone_id
}


resource "aws_acm_certificate_validation" "acm_certificate_validation" {
  provider = aws.virginia
  certificate_arn         = aws_acm_certificate.acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.route53_record : record.fqdn]
}

resource "aws_route53_record" "blog" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = var.route53_record
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn_static_site.domain_name
    zone_id                = aws_cloudfront_distribution.cdn_static_site.hosted_zone_id
    evaluate_target_health = false
  }
}