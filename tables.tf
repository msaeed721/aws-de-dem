# ============================================================
# CUSTOMER A - RAW CSV TABLE
# ============================================================

resource "aws_glue_catalog_table" "customer_a_pharmacy_claims" {
  name          = "customer_a_pharmacy_claims"
  database_name = aws_glue_catalog_database.demo.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification"         = "csv"
    "skip.header.line.count" = "1"
    "typeOfData"             = "file"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.data_lake.bucket}/bronze/customer_a/pharmacy_claims/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    columns {
      name = "claim_id"
      type = "string"
    }

    columns {
      name = "member_id"
      type = "string"
    }

    columns {
      name = "plan_id"
      type = "string"
    }

    columns {
      name = "fill_date"
      type = "string"
    }

    columns {
      name = "ndc"
      type = "string"
    }

    columns {
      name = "drug_name"
      type = "string"
    }

    columns {
      name = "quantity"
      type = "bigint"
    }

    columns {
      name = "days_supply"
      type = "bigint"
    }

    columns {
      name = "total_cost"
      type = "double"
    }

    columns {
      name = "plan_paid"
      type = "double"
    }

    columns {
      name = "member_paid"
      type = "double"
    }

    columns {
      name = "claim_status"
      type = "string"
    }

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"

      parameters = {
        separatorChar = ","
        quoteChar     = "\""
        escapeChar    = "\\"
      }
    }
  }
}


# ============================================================
# CUSTOMER B - RAW CSV TABLE
# ============================================================

resource "aws_glue_catalog_table" "customer_b_pharmacy_claims" {
  name          = "customer_b_pharmacy_claims"
  database_name = aws_glue_catalog_database.demo.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification"         = "csv"
    "skip.header.line.count" = "1"
    "typeOfData"             = "file"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.data_lake.bucket}/bronze/customer_b/pharmacy_claims/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    columns {
      name = "rx_claim_number"
      type = "string"
    }

    columns {
      name = "subscriber_key"
      type = "string"
    }

    columns {
      name = "group_code"
      type = "string"
    }

    columns {
      name = "service_date"
      type = "string"
    }

    columns {
      name = "product_code"
      type = "string"
    }

    columns {
      name = "medication_description"
      type = "string"
    }

    columns {
      name = "dispensed_qty"
      type = "bigint"
    }

    columns {
      name = "supply_days"
      type = "bigint"
    }

    columns {
      name = "gross_cost"
      type = "double"
    }

    columns {
      name = "payer_amount"
      type = "double"
    }

    columns {
      name = "patient_amount"
      type = "double"
    }

    columns {
      name = "status_code"
      type = "string"
    }

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"

      parameters = {
        separatorChar = ","
        quoteChar     = "\""
        escapeChar    = "\\"
      }
    }
  }
}


# ============================================================
# SILVER - NORMALIZED PARQUET TABLE
# ============================================================

resource "aws_glue_catalog_table" "silver_pharmacy_claims" {
  name          = "silver_pharmacy_claims"
  database_name = aws_glue_catalog_database.demo.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification" = "parquet"
    "typeOfData"     = "file"

    # Avoid crawler/MSCK runs by using Athena partition projection
    "projection.enabled"            = "true"
    "projection.customer_id.type"   = "enum"
    "projection.customer_id.values" = "customer_a,customer_b"

    "storage.location.template" = "s3://${aws_s3_bucket.data_lake.bucket}/silver/pharmacy_claims/customer_id=$${customer_id}/"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.data_lake.bucket}/silver/pharmacy_claims/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    columns {
      name = "claim_id"
      type = "string"
    }

    columns {
      name = "member_id"
      type = "string"
    }

    columns {
      name = "plan_id"
      type = "string"
    }

    columns {
      name = "fill_date"
      type = "string"
    }

    columns {
      name = "ndc"
      type = "string"
    }

    columns {
      name = "drug_name"
      type = "string"
    }

    columns {
      name = "quantity"
      type = "bigint"
    }

    columns {
      name = "days_supply"
      type = "bigint"
    }

    columns {
      name = "total_cost"
      type = "double"
    }

    columns {
      name = "plan_paid"
      type = "double"
    }

    columns {
      name = "member_paid"
      type = "double"
    }

    columns {
      name = "claim_status"
      type = "string"
    }

    columns {
      name = "processed_at"
      type = "timestamp"
    }

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }
  }

  partition_keys {
    name = "customer_id"
    type = "string"
  }
}