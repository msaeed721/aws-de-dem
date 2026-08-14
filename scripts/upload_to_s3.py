from pathlib import Path
import boto3

BUCKET = "aws-de-demo-657173565830"
PROFILE = "aws-demo"

uploads = {
    Path("data/customer_a_pharmacy_claims.csv"):
        "bronze/customer_a/pharmacy_claims/customer_a_pharmacy_claims.csv",

    Path("data/customer_b_pharmacy_claims.csv"):
        "bronze/customer_b/pharmacy_claims/customer_b_pharmacy_claims.csv",
}

session = boto3.Session(profile_name=PROFILE, region_name="us-east-2")
s3 = session.client("s3")

for local_file, s3_key in uploads.items():
    print(f"Uploading {local_file} -> s3://{BUCKET}/{s3_key}")
    s3.upload_file(str(local_file), BUCKET, s3_key)

print("Upload complete.")