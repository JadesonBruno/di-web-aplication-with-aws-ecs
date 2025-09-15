output "env_vars_bucket_arn" {
    description = "The ARN of the S3 bucket for environment variables"
    value = aws_s3_bucket.env_vars.arn
}
