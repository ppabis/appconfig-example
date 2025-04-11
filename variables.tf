variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.76.0.0/16"
}

variable "domain_name" {
  description = "The parent domain of subdomain to use for the AppConfig Demo"
  type        = string
  default     = "my-domain.tld"
}

variable "subdomain_name" {
  description = "The subdomain name to use for the AppConfig Demo (just the subdomain, such as app and not app.my-domain.tld)"
  type        = string
  default     = "app"
}

variable "image_tag" {
  description = "The tag to use for the image"
  type        = string
  default     = "01"
}

variable "secrets_manager_secret_name" {
  description = "The name of the Secrets Manager secret (useful if some secret is still pending deletion)"
  type        = string
  default     = "appconfig_demo_secret"
}
