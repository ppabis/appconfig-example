data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["appconfig-demo"]
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["private*"]
  }
}

data "aws_security_group" "security_group" {
  name = replace("alb-${var.subdomain_name}.${var.domain_name}", ".", "-")
}

data "aws_alb_target_group" "target_group" {
  name = "appconfig-demo"
}

data "aws_ssm_parameter" "ssm_parameter" {
  name = "/appconfig_demo/ssm_parameter"
}

data "aws_ssm_parameter" "secure_string_parameter" {
  name = "/appconfig_demo/secure_string_parameter"
}

data "aws_ecr_repository" "appconfig_agent_repository" {
  name = "appconfig-agent"
}

data "aws_ecr_repository" "application_repository" {
  name = "appconfig-demo"
}

data "aws_secretsmanager_secrets" "secrets" {
  filter {
    name = "tag:Purpose"
    values = ["appconfig-demo"]
  }
}