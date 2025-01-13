create database postgres;
-- create table

CREATE TABLE postgres.users
(
    id         UInt32,
    username   String,
    email      String,
    created_at DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree
      ORDER BY (id)
      SETTINGS index_granularity = 8192;

create database kafka_postgres;
-- # create kafka engine table

CREATE TABLE kafka_postgres.users
(
    id         UInt32,
    username   String,
    email      String,
    created_at UInt64
) ENGINE = Kafka
      SETTINGS kafka_broker_list = 'broker:29092',
          kafka_topic_list = 'pg_all.public.users',
          kafka_group_name = 'clickhouse_users',
          kafka_format = 'AvroConfluent',
          format_avro_schema_registry_url = 'http://schema-registry:8081';


-- create  view
CREATE MATERIALIZED VIEW kafka_postgres.consumer_users
            TO postgres.users
            (
             id UInt32,
             username String,
             email String,
             created_at DateTime
                )
AS
SELECT id,
       username,
       email,
       toDateTime(created_at / 1000000) AS created_at
FROM kafka_postgres.users;

