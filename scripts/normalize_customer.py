import csv
import json
from pathlib import Path

CONFIG_FILE = Path("config/customer_b_mapping.json")
INPUT_FILE = Path("data/customer_b_pharmacy_claims.csv")
OUTPUT_FILE = Path("data/customer_b_normalized.csv")

with open(CONFIG_FILE) as f:
    config = json.load(f)

column_mapping = config["column_mapping"]
value_mapping = config.get("value_mapping", {})

with open(INPUT_FILE, newline="") as infile:
    reader = csv.DictReader(infile)

    normalized_rows = []

    for row in reader:
        normalized = {}

        for source_column, target_column in column_mapping.items():
            value = row[source_column]

            if target_column in value_mapping:
                value = value_mapping[target_column].get(value, value)

            normalized[target_column] = value

        normalized_rows.append(normalized)

headers = list(column_mapping.values())

with open(OUTPUT_FILE, "w", newline="") as outfile:
    writer = csv.DictWriter(outfile, fieldnames=headers)
    writer.writeheader()
    writer.writerows(normalized_rows)

print(f"Normalized {len(normalized_rows)} records")
print(f"Output: {OUTPUT_FILE}")