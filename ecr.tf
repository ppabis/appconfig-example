resource "aws_ecr_repository" "application_repository" {
  name = "appconfig-demo"
  tags = {
    Name = "appconfig-demo"
  }
  force_delete = true
}

########################################################
# Building the image
########################################################
resource "docker_image" "application_image" {
  depends_on   = [aws_ecr_repository.application_repository]
  name         = "${aws_ecr_repository.application_repository.repository_url}:${var.image_tag}"
  keep_locally = true

  build {
    context    = "app"
    dockerfile = "Dockerfile"
  }
}

########################################################
# Pushing the image to ECR
########################################################
data "aws_ecr_authorization_token" "token" {
  registry_id = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
}

provider "docker" {
  registry_auth {
    address  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

resource "docker_registry_image" "application_image" {
  depends_on    = [docker_image.application_image]
  name          = "${aws_ecr_repository.application_repository.repository_url}:${var.image_tag}"
  keep_remotely = true
}

########################################################
# Repository for the AppConfig Agent to be pulled via VPC Endpoint
########################################################
resource "aws_ecr_repository" "appconfig_agent_repository" {
  name         = "appconfig-agent"
  force_delete = true
}

resource "docker_image" "appconfig_agent_image" {
  name = "public.ecr.aws/aws-appconfig/aws-appconfig-agent:2.x"
}

resource "docker_tag" "appconfig_agent_image_tag" {
  source_image = docker_image.appconfig_agent_image.image_id
  target_image = "${aws_ecr_repository.appconfig_agent_repository.repository_url}:latest"
}

resource "docker_registry_image" "appconfig_agent_image" {
  depends_on    = [docker_tag.appconfig_agent_image_tag]
  name          = "${aws_ecr_repository.appconfig_agent_repository.repository_url}:latest"
  keep_remotely = true
}