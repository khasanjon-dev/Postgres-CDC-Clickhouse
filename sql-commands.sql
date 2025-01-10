-- CREATE TABLES POSTGRES

-- Foydalanuvchilar jadvali
CREATE TABLE users
(
    id         SERIAL PRIMARY KEY,
    username   VARCHAR(50)  NOT NULL,
    email      VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Mahsulotlar jadvali
CREATE TABLE products
(
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(100)   NOT NULL,
    price      DECIMAL(10, 2) NOT NULL,
    stock      INT       DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Buyurtmalar jadvali
CREATE TABLE orders
(
    id          SERIAL PRIMARY KEY,
    description TEXT NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ADD DATA POSTGRES
-- Foydalanuvchilar uchun yozuvlar
DO
$$
BEGIN
FOR i IN 1..20 LOOP
        INSERT INTO users (username, email, created_at)
        VALUES (
            CONCAT('user', i),
            CONCAT('user', i, '@example.com'),
            NOW() - (INTERVAL '1 day' * (RANDOM() * 365)::INT)
        );
END LOOP;
END $$;
-- Mahsulotlar uchun yozuvlar
DO
$$
BEGIN
FOR i IN 1..1000000 LOOP
        INSERT INTO products (name, price, stock, created_at)
        VALUES (
            CONCAT('product', i),
            (RANDOM() * 100)::NUMERIC(10, 2),
            (RANDOM() * 100)::INT,
            NOW() - (INTERVAL '1 day' * (RANDOM() * 365)::INT)
        );
END LOOP;
END $$;
-- Buyurtmalar uchun yozuvlar
DO
$$
BEGIN
FOR i IN 1..10000000 LOOP
        INSERT INTO orders (description, created_at)
        VALUES (
            CONCAT('Order description for order ', i),
            NOW() - (INTERVAL '1 day' * (RANDOM() * 365)::INT)
        );
END LOOP;
END $$;



-- ```````````````````````````````````````````````````````
-- create table users
CREATE TABLE postgres.users
(
    id         UInt32,
    username   String,
    email      String,
    created_at DateTime DEFAULT now()
) ENGINE = MergeTree()
      ORDER BY (id)
      SETTINGS index_granularity = 8192;


-- create kafka table for read only not saving here
CREATE TABLE kafka_postgres.users
(
    username   String,
    email      String,
    created_at UInt64
)
    ENGINE = Kafka
        SETTINGS kafka_broker_list = 'broker:29092',
            kafka_topic_list = 'pg.public.users',
            kafka_group_name = 'clickhouse',
            kafka_format = 'AvroConfluent',
            format_avro_schema_registry_url = 'http://schema-registry:8081';


-- create view for auto filling
CREATE MATERIALIZED VIEW postgres.consumer_users
            TO postgres.users
            (
             id UInt32,
             username String,
             email String,
             created_at DateTime
                )
AS
SELECT id ,
       username,
       email,
       toDateTime(created_at / 1000000) AS created_at
FROM kafka_postgres.users;


-- to'g'ridan to'g'ri ishlatib bo'midi insertni
SET stream_like_engine_allow_direct_select = 1;
