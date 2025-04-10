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
      subnet_ids = data.aws_subnets.private_subnets.ids

      security_group_rules = {
        alb_ingress_8080 = {
          type                     = "ingress"
          from_port                = 8080
          to_port                  = 8080
          protocol                 = "tcp"
          description              = "Service port"
          source_security_group_id = data.aws_security_group.security_group.id
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
          target_group_arn = data.aws_alb_target_group.target_group.arn
          container_name   = "app"
          container_port   = 8080
        }
      }

      runtime_platform = {
        cpu_architecture        = "ARM64"
        operating_system_family = "LINUX"
      }

      container_definitions = {
        app = {
          image     = "${data.aws_ecr_repository.application_repository.repository_url}:${var.image_tag}"
          essential = true
          port_mappings = [
            {
              name          = "app"
              containerPort = 8080
              protocol      = "tcp"
            }
          ]
          secrets = [
            {
              name      = "SSM_PARAMETER"
              valueFrom = data.aws_ssm_parameter.ssm_parameter.arn
            },
            {
              name      = "SSM_SECRET_PARAMETER"
              valueFrom = data.aws_ssm_parameter.secure_string_parameter.arn
            },
            {
              name      = "SECRETS_MANAGER_PARAMETER"
              valueFrom = data.aws_secretsmanager_secret.secret.arn
            }
          ]
          environment_files = [
            {
              type  = "s3"
              value = var.env_file_s3_path
            }
          ]
        } # end of app =

        agent = {
          image     = "${data.aws_ecr_repository.appconfig_agent_repository.repository_url}:latest"
          essential = true
          port_mappings = [
            {
              name          = "agent"
              containerPort = 2772
            }
          ]
        } # end of agent =
      }   # end of container_definitions
    }     # end of appconfig-demo =
  }       # end of services
}         # end of module.ecs


########################################################
# AppConfig Agent IAM Permissions
########################################################
data "aws_iam_policy_document" "appconfig_agent_policy" {
  statement {
    actions = [
      "appconfig:StartConfigurationSession",
      "appconfig:GetLatestConfiguration",
      "appconfig:GetConfiguration",
      "appconfig:GetConfigurationProfile",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "appconfig_agent_policy" {
  name   = "AppConfigECSAgentPolicy"
  policy = data.aws_iam_policy_document.appconfig_agent_policy.json
  role   = module.ecs.services["appconfig-demo"].tasks_iam_role_name
}