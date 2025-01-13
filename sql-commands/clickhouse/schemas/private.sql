-- create kafka engine for private.users
CREATE TABLE kafka_postgres.private_users
(
    id         UInt32,
    username   String,
    email      String,
    created_at UInt64
) ENGINE = Kafka
      SETTINGS kafka_broker_list = 'broker:29092',
          kafka_topic_list = 'pg_schemas.private.users',
          kafka_group_name = 'clickhouse_users',
          kafka_format = 'AvroConfluent',
          format_avro_schema_registry_url = 'http://schema-registry:8081';

-- view for private.users
CREATE MATERIALIZED VIEW kafka_postgres.consumer_private_users
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
       'private'                         AS codename_schema
FROM kafka_postgres.private_users;
