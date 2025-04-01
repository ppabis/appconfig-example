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

  services = {
    appconfig-demo = {
      cpu        = 512
      memory     = 1024
      name       = "appconfig-demo"
      subnet_ids = values(module.vpc.private_subnet_attributes_by_az)[*].id

      security_group_rules = {
        alb_ingress_8080 = {
          type                     = "ingress"
          from_port                = 8080
          to_port                  = 8080
          protocol                 = "tcp"
          description              = "Service port"
          source_security_group_id = module.alb.security_group_id
        }

        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["ecs-service"].arn
          container_name   = "app"
          container_port   = 8080
        }
      }

      runtime_platform = {
        cpu_architecture = "ARM64"
        operating_system_family = "LINUX"
      }

      container_definitions = {
        app = {
          image     = "${aws_ecr_repository.application_repository.repository_url}:${var.image_tag}"
          essential = true
          port_mappings = [
            {
              name          = "app"
              containerPort = 8080
              protocol      = "tcp"
            }
          ]
        }
      }

    }
  }
}