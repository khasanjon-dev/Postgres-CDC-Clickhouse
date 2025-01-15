CREATE TABLE users
(
    id         SERIAL PRIMARY KEY,
    username   VARCHAR(50)  NOT NULL,
    email      VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products
(
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(100)   NOT NULL,
    price      DECIMAL(10, 2) NOT NULL,
    stock      INT       DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders
(
    id          SERIAL PRIMARY KEY,
    description TEXT NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DO
$$
    BEGIN
        FOR i IN 1..5000
            LOOP
                INSERT INTO users (username, email, created_at)
                VALUES (CONCAT('user', i),
                        CONCAT('user', i, '@example.com'),
                        NOW() - (INTERVAL '1 day' * (RANDOM() * 365)::INT));
            END LOOP;
    END $$;

DO
$$
    BEGIN
        FOR i IN 1..1000
            LOOP
                INSERT INTO products (name, price, stock, created_at)
                VALUES (CONCAT('product', i),
                        (RANDOM() * 100)::NUMERIC(10, 2),
                        (RANDOM() * 100)::INT,
                        NOW() - (INTERVAL '1 day' * (RANDOM() * 365)::INT));
            END LOOP;
    END $$;

DO
$$
    BEGIN
        FOR i IN 1..10000000
            LOOP
                INSERT INTO orders (description, created_at)
                VALUES (CONCAT('Order description for order ', i),
                        NOW() - (INTERVAL '1 day' * (RANDOM() * 365)::INT));
            END LOOP;
    END $$;