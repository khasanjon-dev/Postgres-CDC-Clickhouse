-- create table

CREATE TABLE postgres.products
(
    id         UInt32,
    name       String,
    price      Decimal(10, 2),
    stock      Int32    DEFAULT 0,
    created_at DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree
      ORDER BY (id)
      SETTINGS index_granularity = 8192;


-- # create kafka engine table

CREATE TABLE kafka_postgres.users
(
    id         UInt32,
    name       String,
    price      Decimal(10, 2),
    stock      Int32,
    created_at UInt64
) ENGINE = Kafka
      SETTINGS kafka_broker_list = 'broker:29092',
          kafka_topic_list = 'pg.public.users',
          kafka_group_name = 'clickhouse_products',
          kafka_format = 'AvroConfluent',
          format_avro_schema_registry_url = 'http://schema-registry:8081';


-- create  view
CREATE MATERIALIZED VIEW kafka_postgres.consumer__products
            TO postgres.products
            (
             id UInt32,
             name String,
             price Decimal(10, 2),
             stock Int32,
             created_at DateTime
                )
AS
SELECT id,
       name,
       price,
       stock,
       toDateTime(created_at / 1000000) AS created_at
FROM kafka_postgres.products;

