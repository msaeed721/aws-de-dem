import json
from datetime import datetime, timezone

import boto3
from confluent_kafka import Consumer

BUCKET = "aws-de-demo-029633610686"

session = boto3.Session(profile_name="terraform-free-demo")
s3 = session.client("s3")

consumer = Consumer({
    "bootstrap.servers": "localhost:9092",
    "group.id": "pharmacy-claims-s3-consumer-v1",
    "auto.offset.reset": "earliest"
})

consumer.subscribe(["pharmacy-claims-events"])

count = 0

try:
    while count < 3:
        msg = consumer.poll(10)

        if msg is None:
            break

        if msg.error():
            print(f"Consumer error: {msg.error()}")
            continue

        claim = json.loads(msg.value().decode("utf-8"))

        now = datetime.now(timezone.utc)

        key = (
            f"streaming/pharmacy_claims/"
            f"date={now:%Y-%m-%d}/"
            f"{claim['claim_id']}.json"
        )

        s3.put_object(
            Bucket=BUCKET,
            Key=key,
            Body=json.dumps(claim),
            ContentType="application/json"
        )

        print(f"Kafka -> S3: {claim['claim_id']} -> s3://{BUCKET}/{key}")
        count += 1

finally:
    consumer.close()

print(f"Streamed {count} Kafka claims to S3.")
