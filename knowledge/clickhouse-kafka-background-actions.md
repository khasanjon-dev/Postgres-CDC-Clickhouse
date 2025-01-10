**Qanday qilib bu ma'lumotlar ko'rinadi?**

Siz `consumer_users` jadvalini so'rov qilganingizda ko'rayotgan ma'lumotlaringiz ClickHouse Materialized View va Kafka
integratsiyasi orqali qanday ishlashidan kelib chiqadi. Quyidagicha tushuntirib beraman:

---

### **Orqa fonda nima sodir bo'ladi?**

1. **Kafka mavzusi (`pg.public.users`) dagi ma'lumotlar:**
    - Debezium connector orqali PostgreSQL `users` jadvaliga kiritilgan ma'lumotlar Kafka mavzusiga (`pg.public.users`)
      yuboriladi. Siz PostgreSQL'da 20 ta qator qo'shganingizda, Debezium ushbu qo'shimchalarni ushlab olib, Kafka
      mavzusiga Avro formatida jo'natadi.

2. **Kafka jadvali (`kafka_postgres.users`):**
    - Kafka engine jadvali (`kafka_postgres.users`) Kafka mavzusidagi ma'lumotlarni o'qiydi, lekin **saqlamaydi**. Bu
      jadval ma'lumotlarni to'g'ridan-to'g'ri Kafka'dan o'qib beradi yoki materializatsiyalangan qarash bilan ishlaydi.

3. **Materialized View (`kafka_postgres.consumer_users`):**
    - Materialized view `kafka_postgres.users` jadvaliga "tinglovchi" sifatida ulanadi.
    - Kafka mavzusiga yangi ma'lumot kelganda, u Kafka engine jadvali orqali o'qiladi va view bu ma'lumotlarni qayta
      ishlaydi.
    - Qayta ishlangan ma'lumotlar `postgres.users` jadvaliga yoziladi.

4. **Asosiy jadval (`postgres.users`):**
    - Aslida ma'lumotlar ClickHouse'dagi `postgres.users` jadvalida saqlanadi.
    - Siz `consumer_users` ni so'rov qilganingizda, ClickHouse ma'lumotlarni `postgres.users` jadvalidan olib beradi,
      chunki materialized view shu jadvalga yozadi.

---

### **Ma'lumotlar oqimi**

1. **PostgreSQL:** `users` jadvaliga ma'lumot qo'shiladi.
2. **Debezium Kafka Connector:** O'zgarish hodisalarini Kafka mavzusiga (`pg.public.users`) yuboradi.
3. **Kafka jadvali:** `kafka_postgres.users` Kafka'dagi ma'lumotlarni o'qiydi.
4. **Materialized View:** `kafka_postgres.consumer_users` ma'lumotlarni qayta ishlaydi va `postgres.users` jadvaliga
   yozadi.
5. **Asosiy jadval:** `postgres.users` jadvalida ma'lumotlar saqlanadi va sizning so'rovingiz natijasi shu jadvaldan
   olinadi.

---

### **Asosiy xulosalar**

- Siz ko'rayotgan ma'lumotlar ClickHouse'dagi **`postgres.users` jadvalidan** keladi.
- `consumer_users` Materialized View bo'lib, u o'z ichida ma'lumot saqlamaydi. U faqat Kafka jadvalidan ma'lumotlarni
  qayta ishlash va asosiy jadvalga yozish uchun xizmat qiladi.