output "alb_dns_name" {
  value = module.alb.dns_name
}

output "s3_env_file_path" {
  value = "s3://${aws_s3_bucket.s3_bucket.bucket}/${aws_s3_bucket_object.environment_file.key}"
}
