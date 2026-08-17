resource "aws_sns_topic" "pipeline_alerts" {
  name = "aws-de-demo-pipeline-alerts"

  tags = {
    Project     = "AWS Data Engineering Demo"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_sns_topic_subscription" "pipeline_alert_email" {
  topic_arn = aws_sns_topic.pipeline_alerts.arn
  protocol  = "email"
  endpoint  = "aws_alarm@yahoo.com"
}