import csv
from pathlib import Path

output = Path("data")
output.mkdir(exist_ok=True)

rows = [
    ["CLM1001", "MBR001", "PLAN-A", "2026-08-01",
     "SIM-NDC-0001", "Atorvastatin", 30, 30, 58.40, 48.40, 10.00, "PAID"],

    ["CLM1002", "MBR002", "PLAN-A", "2026-08-01",
     "SIM-NDC-0002", "Metformin", 60, 30, 24.75, 19.75, 5.00, "PAID"],

    ["CLM1003", "MBR003", "PLAN-A", "2026-08-02",
     "SIM-NDC-0003", "Lisinopril", 30, 30, 18.25, 13.25, 5.00, "PAID"],

    ["CLM1004", "MBR004", "PLAN-B", "2026-08-02",
     "SIM-NDC-0004", "Omeprazole", 30, 30, 42.10, 32.10, 10.00, "PAID"],

    ["CLM1005", "MBR005", "PLAN-B", "2026-08-03",
     "SIM-NDC-0005", "Amlodipine", 30, 30, 16.90, 11.90, 5.00, "PAID"],
]

headers = [
    "claim_id",
    "member_id",
    "plan_id",
    "fill_date",
    "ndc",
    "drug_name",
    "quantity",
    "days_supply",
    "total_cost",
    "plan_paid",
    "member_paid",
    "claim_status",
]

with open(output / "customer_a_pharmacy_claims.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(headers)
    writer.writerows(rows)

print("Created data/customer_a_pharmacy_claims.csv")