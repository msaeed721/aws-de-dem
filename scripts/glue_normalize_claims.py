import sys

from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql.functions import col, lit, when, current_timestamp


args = getResolvedOptions(
    sys.argv,
    [
        "JOB_NAME",
        "DATABASE_NAME",
        "CUSTOMER_A_TABLE",
        "CUSTOMER_B_TABLE",
        "OUTPUT_PATH",
    ],
)

sc = SparkContext()
glue_context = GlueContext(sc)
spark = glue_context.spark_session

job = Job(glue_context)
job.init(args["JOB_NAME"], args)


# -------------------------
# Customer A
# Already matches normalized schema
# -------------------------

customer_a = (
    glue_context
    .create_dynamic_frame
    .from_catalog(
        database=args["DATABASE_NAME"],
        table_name=args["CUSTOMER_A_TABLE"],
    )
    .toDF()
)

customer_a_normalized = (
    customer_a
    .withColumn("customer_id", lit("customer_a"))
    .withColumn("processed_at", current_timestamp())
)


# -------------------------
# Customer B
# Map customer-specific fields
# into normalized schema
# -------------------------

customer_b = (
    glue_context
    .create_dynamic_frame
    .from_catalog(
        database=args["DATABASE_NAME"],
        table_name=args["CUSTOMER_B_TABLE"],
    )
    .toDF()
)

customer_b_normalized = customer_b.select(
    col("rx_claim_number").alias("claim_id"),
    col("subscriber_key").alias("member_id"),
    col("group_code").alias("plan_id"),
    col("service_date").alias("fill_date"),
    col("product_code").alias("ndc"),
    col("medication_description").alias("drug_name"),
    col("dispensed_qty").alias("quantity"),
    col("supply_days").alias("days_supply"),
    col("gross_cost").alias("total_cost"),
    col("payer_amount").alias("plan_paid"),
    col("patient_amount").alias("member_paid"),
    when(col("status_code") == "P", "PAID")
        .when(col("status_code") == "R", "REJECTED")
        .when(col("status_code") == "V", "REVERSED")
        .otherwise(col("status_code"))
        .alias("claim_status"),
    lit("customer_b").alias("customer_id"),
    current_timestamp().alias("processed_at"),
)


# Combine both customers into one normalized model
normalized = customer_a_normalized.unionByName(customer_b_normalized)


# Write analytics-friendly Parquet to Silver layer
(
    normalized
    .write
    .mode("overwrite")
    .partitionBy("customer_id")
    .parquet(args["OUTPUT_PATH"])
)

print(f"Normalized record count: {normalized.count()}")

job.commit()