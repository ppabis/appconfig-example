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

variable "env_file_s3_arn" {
  description = "The ARN of the environment file in the S3 bucket"
  type        = string
}

variable "image_tag" {
  description = "The tag to use for the image"
  type        = string
  default     = "01"
}