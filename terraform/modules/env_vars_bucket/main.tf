data "aws_caller_identity" "current" {}


resource "aws_s3_bucket" "env_vars" {
  bucket = "${var.project_name}-${var.environment}-env-vars-bucket-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-${var.environment}-env-vars-bucket"
    Project = var.project_name
    Environment = var.environment
    Service = "Nginx"
    Terraform = "true"
  }
}


resource "aws_s3_bucket_public_access_block" "env_vars" {
  bucket = aws_s3_bucket.env_vars.id

  block_public_acls = true
  ignore_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_versioning" "env_vars" {
  bucket = aws_s3_bucket.env_vars.id

  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_object" "env_vars" {
  bucket = aws_s3_bucket.env_vars.id
  key = "env_vars.env"
  source = "${path.module}/env_vars.env"
  etag = filemd5("${path.module}/env_vars.env")
  content_type = "text/plain"

  tags = {
    Name = "${var.project_name}-${var.environment}-env-vars-object"
    Project = var.project_name
    Environment = var.environment
    Service = "Nginx"
    Terraform = "true"
  }
}
