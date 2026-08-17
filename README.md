<img width="1672" height="941" alt="ChatGPT Image Aug 17, 2026, 04_07_55 PM" src="https://github.com/user-attachments/assets/fc0ca328-8ad7-4319-8a93-4d12d2e44884" />
# AWS Data Engineering Demo

This is a small end-to-end AWS data engineering project using pharmacy claims data.

The goal is to show how customer data can be ingested, validated, transformed, monitored, and analyzed.

Two sample customers send pharmacy claims in different CSV formats.

Customer A already uses a format close to the target schema.

Customer B uses different column names and status codes.

A mapping file is used to standardize Customer B data.

Incoming files are stored in Amazon S3.

AWS Lambda validates incoming Customer B files.

Good records continue into the Bronze layer.

Bad records are moved to a Quarantine area.

CloudWatch monitors validation events and errors.

SNS can send an email alert when bad data is detected.

AWS Glue runs PySpark transformations.

Glue converts different customer schemas into one common Silver schema.

Silver data is stored as Parquet in S3.

The Glue Data Catalog stores table and schema information.

Amazon Athena is used to query Silver and Gold data with SQL.

Data quality checks validate duplicates, quantities, costs, and claim statuses.

Gold contains simple fact and dimension tables for analytics.

A small Apache Kafka demo is also included for streaming claim events.

The Kafka producer sends claim events to a topic.

The Kafka consumer reads the events and writes them to S3.

Secrets Manager is used for sensitive application configuration.

IAM roles control access between AWS services.

Terraform manages the AWS infrastructure as code.

GitHub stores the project code and Terraform files.

GitHub Actions validates Terraform and runs Terraform plans using AWS OIDC.

The project demonstrates batch processing, streaming, ETL, data quality, monitoring, security, analytics, and CI/CD.
