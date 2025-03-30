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