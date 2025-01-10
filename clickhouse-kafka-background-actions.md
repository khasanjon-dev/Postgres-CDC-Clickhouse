The data you see when querying `consumer_users` is the result of how **ClickHouse Materialized Views** and Kafka
integration work. Let’s break it down:

### **What Happens Behind the Scenes?**

1. **Data in Kafka Topic (`pg.public.users`):**
    - The Kafka topic `pg.public.users` receives data from PostgreSQL through the Debezium connector. When you inserted
      20 rows into the PostgreSQL `users` table, the Debezium connector captured these inserts and sent them to the
      Kafka topic in Avro format.

2. **Kafka Table (`kafka_postgres.users`):**
    - The Kafka engine table (`kafka_postgres.users`) reads the messages from the Kafka topic (`pg.public.users`) when
      queried or used in a materialized view.
    - This table allows ClickHouse to access the streamed data in Kafka but does **not** store it.

3. **Materialized View (`kafka_postgres.consumer_users`):**
    - The materialized view listens to the `kafka_postgres.users` table.
    - As soon as data appears in the Kafka topic, it is read by the Kafka engine table and processed by the materialized
      view.
    - The view transforms and inserts the processed data into the **destination table** (`postgres.users`).

4. **Main Table (`postgres.users`):**
    - The actual data is permanently stored in the `postgres.users` table in ClickHouse.
    - When you query `consumer_users`, ClickHouse retrieves the data from the `postgres.users` table because the
      materialized view's target table is `postgres.users`.

---

### **Data Flow Overview**

1. **PostgreSQL:** Data is inserted into the `users` table.
2. **Debezium Kafka Connector:** Sends change events (inserts) to the Kafka topic `pg.public.users`.
3. **Kafka Table in ClickHouse:** `kafka_postgres.users` reads these events when queried or consumed by the materialized
   view.
4. **Materialized View:** `kafka_postgres.consumer_users` processes the Kafka events and inserts the data into
   `postgres.users`.
5. **Main Table:** `postgres.users` stores the data permanently, and your query fetches it from this table.

---

### **Key Insights**

- The data you see comes from the **`postgres.users` table**, which is populated by the materialized view
  `consumer_users`.
- The `consumer_users` materialized view does not store data itself; it just acts as a transformation layer to insert
  data into `postgres.users`.