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

################################################################################
# ECS Cluster
################################################################################
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.12.0"

  cluster_name = "appconfig-demo"
  cluster_settings = [
    {
      name  = "containerInsights"
      value = "disabled"
    }
  ]

  cloudwatch_log_group_retention_in_days = 14

}