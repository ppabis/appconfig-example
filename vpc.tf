################################################################################
# VPC
################################################################################
module "vpc" {
  source  = "aws-ia/vpc/aws"
  version = ">= 4.2.0"

  name       = "appconfig-demo"
  cidr_block = var.vpc_cidr
  az_count   = 2

  subnets = {
    public = {
      netmask = 24
    }
    private = {
      netmask = 24
    }
  }
}

module "vpc_endpoints" {
  source                      = "git::https://github.com/aws-ia/terraform-aws-vpc_endpoints.git"
  vpc_id                      = module.vpc.vpc_attributes.id
  enabled_interface_endpoints = ["ecr_api", "ecr_dkr", "logs", "ssm", "secretsmanager"]
  enabled_gateway_endpoints   = ["s3"]
  subnet_ids                  = [values(module.vpc.private_subnet_attributes_by_az)[1].id]
  route_table_ids             = values(module.vpc.rt_attributes_by_type_by_az["private"])[*].id
}

data "aws_region" "current" {}

resource "aws_vpc_endpoint" "appconfig" {
  for_each            = tomap({ "appconfig" : "appconfig", "appconfigdata" : "appconfigdata" })
  vpc_id              = module.vpc.vpc_attributes.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = module.vpc_endpoints.security_group_ids
  subnet_ids          = [values(module.vpc.private_subnet_attributes_by_az)[0].id]
}
