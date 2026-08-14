resource "aws_iam_role" "glue_role" {
  name = "AWSGlueServiceRole-aws-de-demo"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "glue.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_s3_access" {
  name = "GlueDemoS3ReadAccess"
  role = aws_iam_role.glue_role.id

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
        Resource = "${aws_s3_bucket.data_lake.arn}/bronze/*"
      }
    ]
  })
}

resource "aws_glue_crawler" "customer_a" {
  name          = "customer-a-pharmacy-claims"
  database_name = aws_glue_catalog_database.demo.name
  role          = aws_iam_role.glue_role.arn
  table_prefix  = "customer_a_"

  s3_target {
    path = "s3://${aws_s3_bucket.data_lake.bucket}/bronze/customer_a/pharmacy_claims/"
  }
}

resource "aws_glue_crawler" "customer_b" {
  name          = "customer-b-pharmacy-claims"
  database_name = aws_glue_catalog_database.demo.name
  role          = aws_iam_role.glue_role.arn
  table_prefix  = "customer_b_"

  s3_target {
    path = "s3://${aws_s3_bucket.data_lake.bucket}/bronze/customer_b/pharmacy_claims/"
  }
}