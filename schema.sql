-- E-commerce SQL Portfolio Project
-- Dialect: PostgreSQL 13+

BEGIN;

-- Drop tables if they already exist (safe re-run)
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS shipments;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;

-- Core dimensions
CREATE TABLE customers (
  customer_id     SERIAL PRIMARY KEY,
  first_name      VARCHAR(50) NOT NULL,
  last_name       VARCHAR(50) NOT NULL,
  email           VARCHAR(120) UNIQUE NOT NULL,
  created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
  country         VARCHAR(60) NOT NULL,
  city            VARCHAR(80) NOT NULL
);

CREATE TABLE categories (
  category_id         SERIAL PRIMARY KEY,
  name                VARCHAR(80) NOT NULL,
  parent_category_id  INT REFERENCES categories(category_id)
);

CREATE TABLE products (
  product_id   SERIAL PRIMARY KEY,
  category_id  INT NOT NULL REFERENCES categories(category_id),
  name         VARCHAR(120) NOT NULL,
  brand        VARCHAR(80) NOT NULL,
  price        NUMERIC(10,2) NOT NULL CHECK (price >= 0),
  cost         NUMERIC(10,2) NOT NULL CHECK (cost >= 0),
  active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Fact tables
CREATE TABLE orders (
  order_id     SERIAL PRIMARY KEY,
  customer_id  INT NOT NULL REFERENCES customers(customer_id),
  order_date   DATE NOT NULL,
  status       VARCHAR(20) NOT NULL CHECK (status IN ('placed','paid','shipped','delivered','cancelled','refunded')),
  channel      VARCHAR(20) NOT NULL CHECK (channel IN ('web','mobile','marketplace')),
  shipping_fee NUMERIC(10,2) NOT NULL DEFAULT 0,
  tax          NUMERIC(10,2) NOT NULL DEFAULT 0,
  discount     NUMERIC(10,2) NOT NULL DEFAULT 0
);

CREATE TABLE order_items (
  order_item_id  SERIAL PRIMARY KEY,
  order_id       INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
  product_id     INT NOT NULL REFERENCES products(product_id),
  quantity       INT NOT NULL CHECK (quantity > 0),
  unit_price     NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
  item_discount  NUMERIC(10,2) NOT NULL DEFAULT 0
);

CREATE TABLE payments (
  payment_id    SERIAL PRIMARY KEY,
  order_id      INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
  payment_date  DATE NOT NULL,
  method        VARCHAR(20) NOT NULL CHECK (method IN ('card','paypal','bank_transfer','gift_card')),
  amount        NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
  status        VARCHAR(20) NOT NULL CHECK (status IN ('authorized','captured','failed','refunded'))
);

CREATE TABLE shipments (
  shipment_id   SERIAL PRIMARY KEY,
  order_id      INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
  shipped_date  DATE,
  delivered_date DATE,
  carrier       VARCHAR(40) NOT NULL,
  status        VARCHAR(20) NOT NULL CHECK (status IN ('pending','shipped','delivered','lost','returned'))
);

CREATE TABLE reviews (
  review_id    SERIAL PRIMARY KEY,
  product_id   INT NOT NULL REFERENCES products(product_id),
  customer_id  INT NOT NULL REFERENCES customers(customer_id),
  rating       INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  review_date  DATE NOT NULL
);

-- Helpful indexes
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_shipments_order ON shipments(order_id);
CREATE INDEX idx_reviews_product ON reviews(product_id);

-- Sample data (small but rich enough for analytics)
INSERT INTO customers (first_name, last_name, email, created_at, country, city) VALUES
  ('Ava','Nguyen','ava.nguyen@example.com','2024-01-12','USA','Seattle'),
  ('Mateo','Rossi','mateo.rossi@example.com','2024-02-05','USA','Austin'),
  ('Priya','Shah','priya.shah@example.com','2024-02-20','USA','Chicago'),
  ('Lucas','Meyer','lucas.meyer@example.com','2024-03-14','Canada','Toronto'),
  ('Noah','Kim','noah.kim@example.com','2024-03-30','USA','San Diego'),
  ('Maya','Singh','maya.singh@example.com','2024-04-02','USA','New York'),
  ('Ethan','Brown','ethan.brown@example.com','2024-04-10','USA','Denver'),
  ('Sofia','Lopez','sofia.lopez@example.com','2024-05-01','USA','Miami');

INSERT INTO categories (name, parent_category_id) VALUES
  ('Electronics', NULL),
  ('Computers', 1),
  ('Audio', 1),
  ('Home', NULL),
  ('Kitchen', 4),
  ('Fitness', 4),
  ('Accessories', NULL);

INSERT INTO products (category_id, name, brand, price, cost, active, created_at) VALUES
  (2, 'Ultrabook 13"', 'Nimbus', 1299.00, 900.00, TRUE, '2024-01-10'),
  (2, 'Gaming Laptop 15"', 'Vortex', 1799.00, 1200.00, TRUE, '2024-02-02'),
  (3, 'Noise-Canceling Headphones', 'SonicPulse', 249.00, 120.00, TRUE, '2024-02-15'),
  (3, 'Bluetooth Speaker', 'SonicPulse', 119.00, 55.00, TRUE, '2024-03-01'),
  (5, 'Air Fryer', 'HomeChef', 189.00, 90.00, TRUE, '2024-03-18'),
  (6, 'Smart Treadmill', 'PeakFit', 1099.00, 700.00, TRUE, '2024-04-05'),
  (7, 'USB-C Hub', 'Nimbus', 49.00, 18.00, TRUE, '2024-04-20'),
  (7, 'Wireless Mouse', 'Nimbus', 39.00, 12.00, TRUE, '2024-05-10');

INSERT INTO orders (customer_id, order_date, status, channel, shipping_fee, tax, discount) VALUES
  (1, '2024-02-01', 'delivered', 'web', 10.00, 15.60, 0.00),
  (2, '2024-02-12', 'delivered', 'mobile', 12.00, 24.90, 50.00),
  (3, '2024-03-03', 'delivered', 'web', 8.00, 7.40, 0.00),
  (4, '2024-03-20', 'shipped', 'marketplace', 15.00, 32.10, 0.00),
  (5, '2024-04-01', 'paid', 'web', 6.00, 5.50, 10.00),
  (6, '2024-04-15', 'delivered', 'mobile', 9.00, 18.20, 0.00),
  (7, '2024-05-05', 'delivered', 'web', 7.00, 6.30, 0.00),
  (8, '2024-05-18', 'cancelled', 'web', 0.00, 0.00, 0.00),
  (1, '2024-06-02', 'delivered', 'web', 10.00, 12.50, 25.00),
  (2, '2024-06-15', 'delivered', 'mobile', 11.00, 14.40, 0.00);

INSERT INTO order_items (order_id, product_id, quantity, unit_price, item_discount) VALUES
  (1, 1, 1, 1299.00, 0.00),
  (1, 7, 2, 49.00, 0.00),
  (2, 2, 1, 1799.00, 50.00),
  (2, 3, 1, 249.00, 0.00),
  (3, 4, 1, 119.00, 0.00),
  (3, 8, 1, 39.00, 0.00),
  (4, 6, 1, 1099.00, 0.00),
  (5, 5, 1, 189.00, 10.00),
  (6, 3, 2, 239.00, 20.00),
  (7, 7, 1, 49.00, 0.00),
  (7, 8, 2, 39.00, 0.00),
  (8, 1, 1, 1299.00, 0.00),
  (9, 4, 2, 119.00, 0.00),
  (9, 5, 1, 189.00, 0.00),
  (10, 2, 1, 1699.00, 0.00);

INSERT INTO payments (order_id, payment_date, method, amount, status) VALUES
  (1, '2024-02-01', 'card', 1373.60, 'captured'),
  (2, '2024-02-12', 'paypal', 2022.90, 'captured'),
  (3, '2024-03-03', 'card', 173.40, 'captured'),
  (4, '2024-03-21', 'card', 1146.10, 'authorized'),
  (5, '2024-04-01', 'gift_card', 190.50, 'captured'),
  (6, '2024-04-15', 'card', 506.20, 'captured'),
  (7, '2024-05-05', 'bank_transfer', 134.30, 'captured'),
  (8, '2024-05-18', 'card', 0.00, 'failed'),
  (9, '2024-06-02', 'card', 444.50, 'captured'),
  (10, '2024-06-15', 'card', 1724.40, 'captured');

INSERT INTO shipments (order_id, shipped_date, delivered_date, carrier, status) VALUES
  (1, '2024-02-02', '2024-02-05', 'UPS', 'delivered'),
  (2, '2024-02-13', '2024-02-17', 'FedEx', 'delivered'),
  (3, '2024-03-04', '2024-03-07', 'USPS', 'delivered'),
  (4, '2024-03-22', NULL, 'DHL', 'shipped'),
  (6, '2024-04-16', '2024-04-20', 'UPS', 'delivered'),
  (7, '2024-05-06', '2024-05-09', 'USPS', 'delivered'),
  (9, '2024-06-03', '2024-06-06', 'UPS', 'delivered'),
  (10, '2024-06-16', '2024-06-20', 'FedEx', 'delivered');

INSERT INTO reviews (product_id, customer_id, rating, review_date) VALUES
  (1, 1, 5, '2024-02-10'),
  (2, 2, 4, '2024-03-01'),
  (3, 2, 5, '2024-03-05'),
  (4, 3, 4, '2024-03-15'),
  (5, 5, 3, '2024-04-10'),
  (6, 4, 4, '2024-04-25'),
  (7, 7, 5, '2024-05-12'),
  (8, 7, 4, '2024-05-20');

COMMIT;
