data "aws_route53_zone" "parent_domain" {
  name     = var.domain_name
  provider = aws.route53
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "${var.subdomain_name}.${var.domain_name}"

  validation_method = "DNS"

  create_route53_records  = false
  validation_record_fqdns = module.route53_records.validation_route53_record_fqdns
}

module "route53_records" {
  source    = "terraform-aws-modules/acm/aws"
  version   = "~> 4.0"
  providers = { aws = aws.route53 }

  create_certificate          = false
  create_route53_records_only = true

  validation_method = "DNS"

  distinct_domain_names = module.acm.distinct_domain_names
  zone_id               = data.aws_route53_zone.parent_domain.zone_id

  acm_certificate_domain_validation_options = module.acm.acm_certificate_domain_validation_options
}