# ============================================================
# GOLD DIMENSION - CUSTOMER
# ============================================================

resource "aws_glue_catalog_table" "gold_dim_customer" {
  name          = "gold_dim_customer"
  database_name = aws_glue_catalog_database.demo.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    classification = "parquet"
    EXTERNAL       = "TRUE"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.data_lake.bucket}/gold/dim_customer/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    columns {
      name = "customer_id"
      type = "string"
    }

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }
  }
}


# ============================================================
# GOLD DIMENSION - DRUG
# ============================================================

resource "aws_glue_catalog_table" "gold_dim_drug" {
  name          = "gold_dim_drug"
  database_name = aws_glue_catalog_database.demo.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    classification = "parquet"
    EXTERNAL       = "TRUE"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.data_lake.bucket}/gold/dim_drug/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    columns {
      name = "ndc"
      type = "string"
    }

    columns {
      name = "drug_name"
      type = "string"
    }

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }
  }
}


# ============================================================
# GOLD DIMENSION - PLAN
# ============================================================

resource "aws_glue_catalog_table" "gold_dim_plan" {
  name          = "gold_dim_plan"
  database_name = aws_glue_catalog_database.demo.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    classification = "parquet"
    EXTERNAL       = "TRUE"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.data_lake.bucket}/gold/dim_plan/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    columns {
      name = "plan_id"
      type = "string"
    }

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }
  }
}


# ============================================================
# GOLD FACT - PHARMACY CLAIM
# ============================================================

resource "aws_glue_catalog_table" "gold_fact_pharmacy_claim" {
  name          = "gold_fact_pharmacy_claim"
  database_name = aws_glue_catalog_database.demo.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    classification = "parquet"
    EXTERNAL       = "TRUE"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.data_lake.bucket}/gold/fact_pharmacy_claim/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    columns {
      name = "claim_id"
      type = "string"
    }

    columns {
      name = "customer_id"
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
      name = "ndc"
      type = "string"
    }

    columns {
      name = "fill_date"
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
}