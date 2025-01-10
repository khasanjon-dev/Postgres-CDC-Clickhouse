-- create table

CREATE TABLE postgres.orders
(
    id          UInt32,
    description String,
    created_at  DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree
      ORDER BY (id)
      SETTINGS index_granularity = 8192;


-- # create kafka engine table

CREATE TABLE kafka_postgres.orders
(
    id          UInt32,
    description String,
    created_at  UInt64
) ENGINE = Kafka
      SETTINGS kafka_broker_list = 'broker:29092',
          kafka_topic_list = 'pg_all.public.orders',
          kafka_group_name = 'clickhouse',
          kafka_format = 'AvroConfluent',
          format_avro_schema_registry_url = 'http://schema-registry:8081';


-- create  view
CREATE MATERIALIZED VIEW kafka_postgres.consumer_orders
            TO postgres.orders
            (
             id UInt32,
             description String,
             created_at UInt64
                )
AS
SELECT id,
       description,
       toDateTime(created_at / 1000000) AS created_at
FROM kafka_postgres.orders;

