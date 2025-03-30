terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    docker = {
      source  = "docker/docker"
      version = "~> 0.4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias  = "route53"
  region = "us-east-1"
  # Add here Role to assume if you use some other account
}