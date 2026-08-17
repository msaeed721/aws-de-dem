resource "aws_secretsmanager_secret" "customer_api" {
  name        = "aws-de-demo/customer-b/api-config"
  description = "Demo customer API configuration used by the pharmacy ingestion pipeline"

  # Allows clean teardown of this demo environment
  recovery_window_in_days = 0

  tags = {
    Project     = "AWS Data Engineering Demo"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}