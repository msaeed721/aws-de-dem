# ============================================================
# IAM ROLE FOR AWS GLUE
# ============================================================

resource "aws_iam_role" "glue_role" {
  name = "AWSGlueServiceRole-aws-de-demo"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "glue.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project   = "AWS Data Engineering Demo"
    ManagedBy = "Terraform"
  }
}


# ============================================================
# AWS MANAGED GLUE SERVICE POLICY
# ============================================================

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}


# ============================================================
# GLUE ACCESS TO OUR S3 DATA LAKE
# ============================================================

resource "aws_iam_role_policy" "glue_s3_access" {
  name = "GlueDemoS3Access"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      # Allow Glue to list the bucket
      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.data_lake.arn
      },

      # Read raw Bronze data and Glue scripts
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = [
          "${aws_s3_bucket.data_lake.arn}/bronze/*",
          "${aws_s3_bucket.data_lake.arn}/scripts/*"
        ]
      },

      # Write normalized data into Silver
      {
        Effect = "Allow"

        Action = [
          "s3:PutObject",
          "s3:DeleteObject"
        ]

        Resource = "${aws_s3_bucket.data_lake.arn}/silver/*"
      }
    ]
  })
}


# ============================================================
# CUSTOMER A GLUE CRAWLER
# ============================================================

resource "aws_glue_crawler" "customer_a" {
  name          = "customer-a-pharmacy-claims"
  database_name = aws_glue_catalog_database.demo.name
  role          = aws_iam_role.glue_role.arn

  table_prefix = "customer_a_"

  s3_target {
    path = "s3://${aws_s3_bucket.data_lake.bucket}/bronze/customer_a/pharmacy_claims/"
  }

  depends_on = [
    aws_iam_role_policy_attachment.glue_service,
    aws_iam_role_policy.glue_s3_access
  ]
}


# ============================================================
# CUSTOMER B GLUE CRAWLER
# ============================================================

resource "aws_glue_crawler" "customer_b" {
  name          = "customer-b-pharmacy-claims"
  database_name = aws_glue_catalog_database.demo.name
  role          = aws_iam_role.glue_role.arn

  table_prefix = "customer_b_"

  s3_target {
    path = "s3://${aws_s3_bucket.data_lake.bucket}/bronze/customer_b/pharmacy_claims/"
  }

  depends_on = [
    aws_iam_role_policy_attachment.glue_service,
    aws_iam_role_policy.glue_s3_access
  ]
}


# ============================================================
# UPLOAD GLUE PYSPARK SCRIPT TO S3
# ============================================================

resource "aws_s3_object" "glue_normalize_script" {
  bucket = aws_s3_bucket.data_lake.id

  key = "scripts/glue_normalize_claims.py"

  source = "${path.module}/scripts/glue_normalize_claims.py"

  # Terraform detects script changes
  etag = filemd5("${path.module}/scripts/glue_normalize_claims.py")
}


# ============================================================
# GLUE ETL JOB
# ============================================================

resource "aws_glue_job" "normalize_claims" {
  name = "normalize-pharmacy-claims"

  role_arn = aws_iam_role.glue_role.arn

  glue_version = "5.1"

  worker_type       = "G.1X"
  number_of_workers = 2

  timeout = 10

  command {
    name = "glueetl"

    script_location = "s3://${aws_s3_bucket.data_lake.bucket}/${aws_s3_object.glue_normalize_script.key}"

    python_version = "3"
  }

  default_arguments = {
    "--DATABASE_NAME"       = aws_glue_catalog_database.demo.name
    "--CUSTOMER_A_TABLE"    = "customer_a_pharmacy_claims"
    "--CUSTOMER_B_TABLE"    = "customer_b_pharmacy_claims"
    "--OUTPUT_PATH"         = "s3://${aws_s3_bucket.data_lake.bucket}/silver/pharmacy_claims/"
    "--enable-metrics"      = "true"
    "--enable-job-insights" = "true"
  }

  depends_on = [
    aws_iam_role_policy_attachment.glue_service,
    aws_iam_role_policy.glue_s3_access,
    aws_s3_object.glue_normalize_script
  ]

  tags = {
    Project     = "AWS Data Engineering Demo"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}