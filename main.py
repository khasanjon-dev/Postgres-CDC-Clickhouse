from confluent_kafka import KafkaError, KafkaException
from confluent_kafka.avro import AvroConsumer
from confluent_kafka.avro.serializer import SerializerError

# Kafka Consumer configuration
conf = {
    'bootstrap.servers': 'localhost:9092',
    'group.id': 'my_consumer_group',
    'auto.offset.reset': 'earliest',
    'schema.registry.url': 'http://localhost:8081'
}

# Create AvroConsumer instance
consumer = AvroConsumer(conf)

# Subscribe to the topic
topic = 'pg.public.users'
consumer.subscribe([topic])


# Function to consume messages
def consume_messages():
    try:
        while True:
            msg = consumer.poll(timeout=1.0)  # Poll for messages
            if msg is None:
                continue
            if msg.error():
                if msg.error().code() == KafkaError._PARTITION_EOF:
                    # End of partition event
                    print(f'End of partition reached {msg.topic()} [{msg.partition()}] at offset {msg.offset()}')
                elif msg.error():
                    raise KafkaException(msg.error())
            else:
                # Proper message processing with Avro deserialization
                try:
                    message_value = msg.value()
                    print(
                        f'Received message: {message_value} from topic: {msg.topic()} partition: {msg.partition()} offset: {msg.offset()}')
                except SerializerError as e:
                    print(f'Error deserializing message: {e}. Raw data: {msg.value()}')

    except KeyboardInterrupt:
        pass
    finally:
        # Close down consumer to commit final offsets.
        consumer.close()


if __name__ == '__main__':
    consume_messages()
