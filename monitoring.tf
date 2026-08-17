resource "aws_cloudwatch_log_metric_filter" "quarantined_batch" {
  name           = "quarantined-batch-detected"
  log_group_name = "/aws/lambda/${aws_lambda_function.batch_validator.function_name}"

  pattern = "\"QUARANTINE_ALERT\""

  metric_transformation {
    name      = "QuarantinedBatchCount"
    namespace = "AWSDataEngineeringDemo"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "quarantined_batch" {
  alarm_name        = "pharmacy-batch-quarantine-alert"
  alarm_description = "A customer pharmacy batch contained quarantined records"
  alarm_actions = [
    aws_sns_topic.pipeline_alerts.arn
  ]
  namespace   = "AWSDataEngineeringDemo"
  metric_name = "QuarantinedBatchCount"

  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"

  tags = {
    Project     = "AWS Data Engineering Demo"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}