import csv
from collections import Counter
from pathlib import Path

INPUT = Path("data/customer_b_bad_batch.csv")
VALID_OUTPUT = Path("data/customer_b_valid.csv")
QUARANTINE_OUTPUT = Path("data/customer_b_quarantine.csv")

with open(INPUT, newline="") as f:
    rows = list(csv.DictReader(f))

claim_counts = Counter(row["rx_claim_number"] for row in rows)

valid_rows = []
bad_rows = []

for row in rows:
    errors = []

    if claim_counts[row["rx_claim_number"]] > 1:
        errors.append("DUPLICATE_CLAIM")

    if int(row["dispensed_qty"]) <= 0:
        errors.append("INVALID_QUANTITY")

    total = float(row["gross_cost"])
    paid = float(row["payer_amount"])
    member = float(row["patient_amount"])

    if abs(total - (paid + member)) > 0.01:
        errors.append("COST_RECONCILIATION_ERROR")

    if row["status_code"] not in {"P", "R", "V"}:
        errors.append("INVALID_STATUS")

    if errors:
        row["validation_errors"] = "|".join(errors)
        bad_rows.append(row)
    else:
        valid_rows.append(row)


original_headers = [
    "rx_claim_number",
    "subscriber_key",
    "group_code",
    "service_date",
    "product_code",
    "medication_description",
    "dispensed_qty",
    "supply_days",
    "gross_cost",
    "payer_amount",
    "patient_amount",
    "status_code",
]

quarantine_headers = original_headers + ["validation_errors"]

with open(VALID_OUTPUT, "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=original_headers)
    writer.writeheader()
    writer.writerows(valid_rows)

with open(QUARANTINE_OUTPUT, "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=quarantine_headers)
    writer.writeheader()
    writer.writerows(bad_rows)

print(f"Total records: {len(rows)}")
print(f"Valid records: {len(valid_rows)}")
print(f"Quarantined records: {len(bad_rows)}")