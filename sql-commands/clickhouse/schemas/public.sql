CREATE TABLE postgres.users
(
    id              UInt32,
    username        String,
    email           String,
    created_at      DateTime,
    codename_schema String
)
    ENGINE = ReplacingMergeTree
        ORDER BY (id)
        SETTINGS index_granularity = 8192;

-- create kafka engine for public.users
CREATE TABLE kafka_postgres.public_users
(
    id         UInt32,
    username   String,
    email      String,
    created_at UInt64
) ENGINE = Kafka
      SETTINGS kafka_broker_list = 'broker:29092',
          kafka_topic_list = 'pg_schemas.public.users',
          kafka_group_name = 'clickhouse_users',
          kafka_format = 'AvroConfluent',
          format_avro_schema_registry_url = 'http://schema-registry:8081';

-- create  view for fill auto public.users
CREATE MATERIALIZED VIEW kafka_postgres.consumer_public_users
            TO postgres.users
            (
             id UInt32,
             username String,
             email String,
             created_at DateTime,
             codename_schema String
                )
AS
SELECT id,
       username,
       email,
       toDateTime(created_at / 1000000) AS created_at,
       'public'                         AS codename_schema
FROM kafka_postgres.public_users;
