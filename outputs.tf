output "alb_dns_name" {
  value = module.alb.dns_name
}

output "env_file_s3_arn" {
  value = "arn:aws:s3:::${aws_s3_bucket.s3_bucket.bucket}/${aws_s3_bucket_object.environment_file.key}"
}
