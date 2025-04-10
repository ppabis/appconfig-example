module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name                       = replace("alb-${var.subdomain_name}.${var.domain_name}", ".", "-")
  vpc_id                     = module.vpc.vpc_attributes.id
  subnets                    = values(module.vpc.public_subnet_attributes_by_az)[*].id
  enable_deletion_protection = false
  depends_on                 = [module.vpc]

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = var.vpc_cidr
    }
  }

  listeners = {
    http-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.acm.acm_certificate_arn

      forward = {
        target_group_key = "ecs-service"
      }
    }
  }

  target_groups = {
    ecs-service = {
      name                 = "appconfig-demo"
      protocol             = "HTTP"
      port                 = 8080
      target_type          = "ip"
      create_attachment    = false
      deregistration_delay = 15
    }
  }
}