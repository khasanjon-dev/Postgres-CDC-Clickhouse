PostgreSQL jadvaliga faqatgina ma'lumot yozilganini tasdiqlash uchun quyidagi amallarni bajarishingiz mumkin:

### 1. **Qo'shimcha ma'lumot olish uchun `system.parts` jadvalidan foydalanish:**

`postgres.users` jadvali uchun ma'lumotlarni `system.parts` dan kuzatishingiz mumkin:

```sql
SELECT table, sum (rows) AS total_rows
FROM system.parts
WHERE database = 'postgres'
GROUP BY table;
```

- Bu jadval qaysi jadvallarda real ma'lumot saqlanayotganini ko'rsatadi. Faqat `postgres.users` jadvali uchun yozuvlar
  aks etadi.

---

### Xulosa:

- `kafka_postgres.users` ma'lumotlarni Kafka mavzusidan vaqtincha o'qiydi, lekin saqlamaydi.
- `consumer_users` Materialized View o'zi ma'lumotni saqlamaydi, faqat `postgres.users` jadvaliga yozadi.
- Faqat `postgres.users` jadvali real ma'lumotlarni saqlaydi, bu `system.parts` orqali ham tasdiqlanadi.