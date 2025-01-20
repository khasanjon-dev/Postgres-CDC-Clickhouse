import datetime

import clickhouse_connect
from confluent_kafka import KafkaError, KafkaException
from confluent_kafka.avro import AvroConsumer
from confluent_kafka.avro.serializer import SerializerError

# Kafka Consumer configuration
conf = {
    "bootstrap.servers": "localhost:9092",
    "group.id": "my_consumer_group",
    "auto.offset.reset": "earliest",
    "schema.registry.url": "http://localhost:8081",
}

# ClickHouse connection configuration
clickhouse_client = clickhouse_connect.get_client(
    host="localhost", port=8123, username="default", password="", database="postgres"
)

# Create AvroConsumer instance
consumer = AvroConsumer(conf)

# Subscribe to the topic
# consumer.subscribe(["^pg_schemas\\..*"])


# Function to consume messages and insert into ClickHouse
def consume_and_insert():
    try:
        while True:
            consumer.subscribe(["^pg_schemas\\..*"])
            msg = consumer.poll(timeout=1.0)  # Poll for messages
            if msg is None:
                continue
            if msg.error():
                if msg.error().code() == KafkaError._PARTITION_EOF:
                    # End of partition event
                    print(
                        f"End of partition reached {msg.topic()} [{msg.partition()}] at offset {msg.offset()}"
                    )
                elif msg.error():
                    raise KafkaException(msg.error())
            else:
                # Proper message processing with Avro deserialization
                try:
                    message_value = msg.value()
                    schema_name = msg.topic().split(".")[
                        1
                    ]  # Extract schema name from topic
                    print(
                        f"Received message: {message_value} from topic: {msg.topic()} partition: {msg.partition()} offset: {msg.offset()}"
                    )

                    # Add the schema name as `codename_schema` field
                    message_value["codename_schema"] = schema_name

                    # Insert the message into ClickHouse
                    insert_data_into_clickhouse(message_value)

                except SerializerError as e:
                    print(f"Error deserializing message: {e}. Raw data: {msg.value()}")

    except KeyboardInterrupt:
        pass
    finally:
        # Close down consumer to commit final offsets.
        consumer.close()


# Function to insert data into ClickHouse
def insert_data_into_clickhouse(data):
    try:
        # Convert `created_at` to seconds if it exists and is in microseconds
        if "created_at" in data:
            data["created_at"] = datetime.datetime.fromtimestamp(
                data["created_at"] / 1_000_000
            )

        # Insert into ClickHouse with `codename_schema`
        clickhouse_client.insert(
            "users",
            [
                [
                    data["id"],
                    data["username"],
                    data["email"],
                    data["created_at"],
                    data["codename_schema"],
                ]
            ],
            column_names=["id", "username", "email", "created_at", "codename_schema"],
        )
        print(f"Inserted data into ClickHouse: {data}")
    except Exception as e:
        print(f"Error inserting data into ClickHouse: {e}")


if __name__ == "__main__":
    consume_and_insert()
