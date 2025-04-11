resource "random_string" "random_string" {
  length  = 12
  special = false
  upper   = false
}

resource "aws_secretsmanager_secret" "secret_parameter" {
  name = "sm_secret_${random_string.random_string.result}"
  tags = { Purpose = "appconfig-demo" }
}

resource "aws_secretsmanager_secret_version" "secret_parameter_version" {
  secret_id     = aws_secretsmanager_secret.secret_parameter.id
  secret_string = "Secrets Manager 520d58963c1c"
}

resource "aws_ssm_parameter" "ssm_parameter" {
  name  = "/appconfig_demo/ssm_parameter"
  type  = "String"
  value = "String SSM 2f2e12d5c208"
}

resource "aws_ssm_parameter" "secure_string_parameter" {
  name  = "/appconfig_demo/secure_string_parameter"
  type  = "SecureString"
  value = "Secure String SSM 289b36b3fa03"
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "s3-bucket-${random_string.random_string.result}"
  force_destroy = true
}

resource "aws_s3_bucket_object" "environment_file" {
  bucket  = aws_s3_bucket.s3_bucket.bucket
  key     = "parameters.env"
  content = <<-EOF
  S3_ENV_PARAMETER="S3 Env variable 40da0e3acaec"
  EOF
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
    ]
    resources = [
      "${aws_s3_bucket.s3_bucket.arn}/*",
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
        test     = "ArnLike"
        variable = "aws:PrincipalArn"
        values   = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/appconfig*"]
      }
  }
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.s3_bucket.bucket
  policy = data.aws_iam_policy_document.policy.json
}


