-- ============================================================
-- DIMENSION: CUSTOMER
-- ============================================================

CREATE TABLE aws_de_demo.gold_dim_customer
WITH (
    format = 'PARQUET',
    external_location = 's3://aws-de-demo-029633610686/gold/dim_customer/'
) AS
SELECT DISTINCT
    customer_id
FROM aws_de_demo.silver_pharmacy_claims;


-- ============================================================
-- DIMENSION: DRUG
-- ============================================================

CREATE TABLE aws_de_demo.gold_dim_drug
WITH (
    format = 'PARQUET',
    external_location = 's3://aws-de-demo-029633610686/gold/dim_drug/'
) AS
SELECT DISTINCT
    ndc,
    drug_name
FROM aws_de_demo.silver_pharmacy_claims;


-- ============================================================
-- DIMENSION: PLAN
-- ============================================================

CREATE TABLE aws_de_demo.gold_dim_plan
WITH (
    format = 'PARQUET',
    external_location = 's3://aws-de-demo-029633610686/gold/dim_plan/'
) AS
SELECT DISTINCT
    plan_id
FROM aws_de_demo.silver_pharmacy_claims;


-- ============================================================
-- FACT: PHARMACY CLAIM
-- ============================================================

CREATE TABLE aws_de_demo.gold_fact_pharmacy_claim
WITH (
    format = 'PARQUET',
    external_location = 's3://aws-de-demo-029633610686/gold/fact_pharmacy_claim/'
) AS
SELECT
    claim_id,
    customer_id,
    member_id,
    plan_id,
    ndc,
    fill_date,
    quantity,
    days_supply,
    total_cost,
    plan_paid,
    member_paid,
    claim_status,
    processed_at
FROM aws_de_demo.silver_pharmacy_claims;