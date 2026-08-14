SELECT
    COUNT(*) AS total_records,

    SUM(
        CASE
            WHEN claim_id IS NULL
              OR member_id IS NULL
              OR ndc IS NULL
              OR fill_date IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_required_fields,

    COUNT(*) - COUNT(DISTINCT claim_id) AS duplicate_claims,

    SUM(
        CASE
            WHEN quantity <= 0 OR days_supply <= 0
            THEN 1 ELSE 0
        END
    ) AS invalid_quantity_or_supply,

    SUM(
        CASE
            WHEN ABS(total_cost - (plan_paid + member_paid)) > 0.01
            THEN 1 ELSE 0
        END
    ) AS cost_reconciliation_errors,

    SUM(
        CASE
            WHEN claim_status NOT IN ('PAID', 'REJECTED', 'REVERSED')
            THEN 1 ELSE 0
        END
    ) AS invalid_status

FROM aws_de_demo.silver_pharmacy_claims;