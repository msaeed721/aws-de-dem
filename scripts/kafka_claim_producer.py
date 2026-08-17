import json
import time
from confluent_kafka import Producer

producer = Producer({
    "bootstrap.servers": "localhost:9092"
})

topic = "pharmacy-claims-events"

claims = [
    {
        "claim_id": "STRM3001",
        "member_id": "MBR301",
        "plan_id": "PLAN-A",
        "ndc": "SIM-NDC-0201",
        "drug_name": "Atorvastatin",
        "quantity": 30,
        "total_cost": 61.25,
        "claim_status": "PAID"
    },
    {
        "claim_id": "STRM3002",
        "member_id": "MBR302",
        "plan_id": "PLAN-B",
        "ndc": "SIM-NDC-0202",
        "drug_name": "Metformin",
        "quantity": 60,
        "total_cost": 32.50,
        "claim_status": "PAID"
    },
    {
        "claim_id": "STRM3003",
        "member_id": "MBR303",
        "plan_id": "PLAN-A",
        "ndc": "SIM-NDC-0203",
        "drug_name": "Lisinopril",
        "quantity": 30,
        "total_cost": 19.75,
        "claim_status": "PAID"
    }
]

def delivery_report(err, msg):
    if err:
        print(f"Delivery failed: {err}")
    else:
        print(
            f"Delivered claim to {msg.topic()} "
            f"partition={msg.partition()} offset={msg.offset()}"
        )

for claim in claims:
    producer.produce(
        topic,
        key=claim["claim_id"],
        value=json.dumps(claim),
        callback=delivery_report
    )
    producer.poll(0)
    time.sleep(1)

producer.flush()

print("Streaming claims complete.")
