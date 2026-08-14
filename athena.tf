resource "aws_athena_workgroup" "demo" {
  name          = "aws-de-demo"
  force_destroy = true
  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    # 100 MB maximum scan per query
    bytes_scanned_cutoff_per_query = 104857600

    result_configuration {
      output_location = "s3://${aws_s3_bucket.data_lake.bucket}/athena-results/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }

  tags = {
    Project     = "AWS Data Engineering Demo"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}