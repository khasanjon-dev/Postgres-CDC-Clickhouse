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
topic = "pg.public.users"
consumer.subscribe([topic])


# Function to consume messages and insert into ClickHouse
def consume_and_insert():
    try:
        while True:
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
                    print(
                        f"Received message: {message_value} from topic: {msg.topic()} partition: {msg.partition()} offset: {msg.offset()}"
                    )

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
            # Assuming `created_at` is in microseconds, divide by 1,000,000 to get seconds
            data["created_at"] = datetime.datetime.fromtimestamp(
                data["created_at"] / 1_000_000
            )

        # Assuming data is a dictionary with keys matching the ClickHouse table columns
        clickhouse_client.insert(
            "users",
            [[data["id"], data["username"], data["email"], data["created_at"]]],
            column_names=["id", "username", "email", "created_at"],
        )
        print(f"Inserted data into ClickHouse: {data}")
    except Exception as e:
        print(f"Error inserting data into ClickHouse: {e}")


if __name__ == "__main__":
    consume_and_insert()
