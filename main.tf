data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "data_lake" {
  bucket = "aws-de-demo-${data.aws_caller_identity.current.account_id}"

  tags = {
    Project     = "AWS Data Engineering Demo"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}