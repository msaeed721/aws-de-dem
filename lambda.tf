# ============================================================
# PACKAGE LAMBDA PYTHON CODE
# ============================================================

data "archive_file" "batch_validator" {
  type        = "zip"
  source_file = "${path.module}/scripts/lambda_validate_batch.py"
  output_path = "${path.module}/lambda_validate_batch.zip"
}


# ============================================================
# LAMBDA EXECUTION ROLE
# ============================================================

resource "aws_iam_role" "lambda_validator" {
  name = "lambda-pharmacy-batch-validator"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "lambda.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Project   = "AWS Data Engineering Demo"
    ManagedBy = "Terraform"
  }
}


# ============================================================
# CLOUDWATCH LOGGING
# ============================================================

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_validator.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


# ============================================================
# LAMBDA S3 ACCESS
# ============================================================

resource "aws_iam_role_policy" "lambda_s3_access" {
  name = "LambdaPharmacyS3Access"
  role = aws_iam_role.lambda_validator.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.data_lake.arn
      },

      {
        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = "${aws_s3_bucket.data_lake.arn}/incoming/customer_b/*"
      },

      {
        Effect = "Allow"

        Action = [
          "s3:PutObject"
        ]

        Resource = [
          "${aws_s3_bucket.data_lake.arn}/bronze/customer_b/*",
          "${aws_s3_bucket.data_lake.arn}/quarantine/customer_b/*"
        ]
      }
    ]
  })
}


# ============================================================
# LAMBDA FUNCTION
# ============================================================

resource "aws_lambda_function" "batch_validator" {
  environment {
    variables = {
      CUSTOMER_SECRET_NAME = aws_secretsmanager_secret.customer_api.name
    }
  }

  function_name = "validate-customer-b-batch"

  filename         = data.archive_file.batch_validator.output_path
  source_code_hash = data.archive_file.batch_validator.output_base64sha256

  role    = aws_iam_role.lambda_validator.arn
  handler = "lambda_validate_batch.lambda_handler"
  runtime = "python3.14"

  timeout     = 30
  memory_size = 128

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy.lambda_s3_access,
    aws_iam_role_policy.lambda_secret_access
  ]

  tags = {
    Project     = "AWS Data Engineering Demo"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}


# ============================================================
# ALLOW S3 TO INVOKE LAMBDA
# ============================================================

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.batch_validator.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.data_lake.arn
}


# ============================================================
# S3 EVENT TRIGGER
# ============================================================

resource "aws_s3_bucket_notification" "incoming_batch" {
  bucket = aws_s3_bucket.data_lake.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.batch_validator.arn

    events = [
      "s3:ObjectCreated:*"
    ]

    filter_prefix = "incoming/customer_b/"
    filter_suffix = ".csv"
  }

  depends_on = [
    aws_lambda_permission.allow_s3
  ]
}


resource "aws_iam_role_policy" "lambda_secret_access" {
  name = "LambdaCustomerSecretAccess"
  role = aws_iam_role.lambda_validator.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "secretsmanager:GetSecretValue"
      ]

      Resource = aws_secretsmanager_secret.customer_api.arn
    }]
  })
}