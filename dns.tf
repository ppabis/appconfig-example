data "aws_route53_zone" "parent_domain" {
  name     = var.domain_name
  provider = aws.route53
}

resource "aws_route53_record" "subdomain" {
  zone_id = data.aws_route53_zone.parent_domain.zone_id
  name    = "${var.subdomain_name}.${var.domain_name}"
  type    = "A"
  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = false
  }
  provider = aws.route53
}