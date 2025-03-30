resource "aws_ecr_repository" "application_repository" {
  name = "appconfig-demo"
  tags = {
    Name = "appconfig-demo"
  }
}

########################################################
# Building the image
########################################################
resource "docker_image" "application_image" {
  depends_on   = [aws_ecr_repository.application_repository]
  name         = "${aws_ecr_repository.application_repository.repository_url}:latest"
  keep_locally = true

  build {
    context    = "."
    dockerfile = "Dockerfile"
  }
}

########################################################
# Pushing the image to ECR
########################################################
data "aws_ecr_authorization_token" "token" {
  registry_id = aws_ecr_repository.application_repository.registry_id
}

provider "docker" {
  registry_auth {
    address  = split("/", aws_ecr_repository.application_repository.repository_url)[0]
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

resource "docker_registry_image" "application_image" {
  name          = "${aws_ecr_repository.application_repository.repository_url}:latest"
  keep_remotely = true
}