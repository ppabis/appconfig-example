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
          secrets = [
            {
              name  = "SSM_PARAMETER"
              valueFrom = aws_ssm_parameter.ssm_parameter.arn
            },
            {
              name  = "SSM_SECRET_PARAMETER"
              valueFrom = aws_secretsmanager_secret.ssm_secret_parameter.arn
            },
            {
              name  = "SECRETS_MANAGER_PARAMETER"
              valueFrom = aws_secretsmanager_secret_version.ssm_secret_parameter_version.arn
            }
          ]
          environment_files = [
            {
              type = "s3"
              value = "${aws_s3_bucket.s3_bucket.arn}/${aws_s3_bucket_object.environment_file.key}"
            }
          ]
        } # end of app =

        agent = {
          image = "${aws_ecr_repository.appconfig_agent_repository.repository_url}:latest"
          essential = true
          port_mappings = [
            {
              name = "agent"
              containerPort = 2772
            }
          ]
        } # end of agent =
      } # end of container_definitions
    } # end of appconfig-demo =
  } # end of services
} # end of module.ecs


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
  name = "AppConfigECSAgentPolicy"
  policy = data.aws_iam_policy_document.appconfig_agent_policy.json
  role = module.ecs.services["appconfig-demo"].tasks_iam_role_name
}