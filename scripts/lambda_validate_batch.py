import boto3
import csv
import io
import logging
from collections import Counter
from urllib.parse import unquote_plus

s3 = boto3.client("s3")
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):

    for record in event["Records"]:

        bucket = record["s3"]["bucket"]["name"]
        key = unquote_plus(record["s3"]["object"]["key"])

        logger.info("Processing file: s3://%s/%s", bucket, key)

        response = s3.get_object(Bucket=bucket, Key=key)
        content = response["Body"].read().decode("utf-8")

        rows = list(csv.DictReader(io.StringIO(content)))

        claim_counts = Counter(
            row["rx_claim_number"]
            for row in rows
        )

        valid_rows = []
        bad_rows = []

        for row in rows:

            errors = []

            if claim_counts[row["rx_claim_number"]] > 1:
                errors.append("DUPLICATE_CLAIM")

            if int(row["dispensed_qty"]) <= 0:
                errors.append("INVALID_QUANTITY")

            total = float(row["gross_cost"])
            payer = float(row["payer_amount"])
            patient = float(row["patient_amount"])

            if abs(total - (payer + patient)) > 0.01:
                errors.append("COST_RECONCILIATION_ERROR")

            if row["status_code"] not in {"P", "R", "V"}:
                errors.append("INVALID_STATUS")

            if errors:
                row["validation_errors"] = "|".join(errors)
                bad_rows.append(row)
            else:
                valid_rows.append(row)

        source_headers = list(rows[0].keys())

        if "validation_errors" in source_headers:
            source_headers.remove("validation_errors")

        # Write valid records to Bronze
        if valid_rows:

            output = io.StringIO()

            writer = csv.DictWriter(
                output,
                fieldnames=source_headers
            )

            writer.writeheader()
            writer.writerows(valid_rows)

            valid_key = key.replace(
                "incoming/customer_b/",
                "bronze/customer_b/pharmacy_claims/"
            )

            s3.put_object(
                Bucket=bucket,
                Key=valid_key,
                Body=output.getvalue()
            )

        # Write invalid records to Quarantine
        if bad_rows:

            quarantine_headers = source_headers + [
                "validation_errors"
            ]

            output = io.StringIO()

            writer = csv.DictWriter(
                output,
                fieldnames=quarantine_headers
            )

            writer.writeheader()
            writer.writerows(bad_rows)

            quarantine_key = key.replace(
                "incoming/customer_b/",
                "quarantine/customer_b/"
            )

            s3.put_object(
                Bucket=bucket,
                Key=quarantine_key,
                Body=output.getvalue()
            )

        logger.info(
            "Validation complete. Total=%d Valid=%d Quarantined=%d",
            len(rows),
            len(valid_rows),
            len(bad_rows)
        )

        if bad_rows:
            logger.warning(
                "QUARANTINE_ALERT customer=customer_b count=%d",
                len(bad_rows)
            )

    return {
        "statusCode": 200,
        "message": "Validation completed"
    }