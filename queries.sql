-- E-commerce SQL Portfolio Project
-- Each query answers a business question.

-- 1. Which products are currently active and priced under $100?
SELECT product_id, name, brand, price
FROM products
WHERE active = TRUE AND price < 100
ORDER BY price ASC;

-- 2. Which customers joined most recently?
SELECT customer_id, first_name, last_name, created_at
FROM customers
ORDER BY created_at DESC
LIMIT 5;

-- 3. What is total revenue by month (captured payments only)?
SELECT DATE_TRUNC('month', payment_date) AS month,
       SUM(amount) AS revenue
FROM payments
WHERE status = 'captured'
GROUP BY DATE_TRUNC('month', payment_date)
ORDER BY month;

-- 4. What is average order value (AOV) for delivered orders?
SELECT ROUND(AVG(order_total), 2) AS avg_order_value
FROM (
  SELECT o.order_id,
         SUM(oi.quantity * oi.unit_price - oi.item_discount) + o.shipping_fee + o.tax - o.discount AS order_total
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.status = 'delivered'
  GROUP BY o.order_id, o.shipping_fee, o.tax, o.discount
) t;

-- 5. Which products generate the most revenue (top 5)?
SELECT p.product_id, p.name,
       SUM(oi.quantity * oi.unit_price - oi.item_discount) AS product_revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.status IN ('paid','shipped','delivered')
GROUP BY p.product_id, p.name
ORDER BY product_revenue DESC
LIMIT 5;

-- 6. Which categories drive the most sales volume (units sold)?
SELECT c.name AS category,
       SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN categories c ON c.category_id = p.category_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.status IN ('paid','shipped','delivered')
GROUP BY c.name
ORDER BY units_sold DESC;

-- 7. What is the gross margin by product (revenue - cost)?
SELECT p.product_id, p.name,
       SUM(oi.quantity * oi.unit_price - oi.item_discount) AS revenue,
       SUM(oi.quantity * p.cost) AS cost,
       SUM(oi.quantity * oi.unit_price - oi.item_discount) - SUM(oi.quantity * p.cost) AS gross_margin
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.status IN ('paid','shipped','delivered')
GROUP BY p.product_id, p.name
ORDER BY gross_margin DESC;

-- 8. Which customers are repeat buyers (2+ delivered orders)?
SELECT c.customer_id, c.first_name, c.last_name,
       COUNT(*) AS delivered_orders
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.status = 'delivered'
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(*) >= 2
ORDER BY delivered_orders DESC;

-- 9. What is the average shipping time by carrier (in days)?
SELECT carrier,
       ROUND(AVG(delivered_date - shipped_date), 2) AS avg_days_to_deliver
FROM shipments
WHERE status = 'delivered' AND delivered_date IS NOT NULL AND shipped_date IS NOT NULL
GROUP BY carrier
ORDER BY avg_days_to_deliver;

-- 10. What share of orders are cancelled by channel?
SELECT channel,
       COUNT(*) FILTER (WHERE status = 'cancelled')::DECIMAL / COUNT(*) AS cancel_rate
FROM orders
GROUP BY channel
ORDER BY cancel_rate DESC;

-- 11. Which products have the highest average review rating (min 2 reviews)?
SELECT p.product_id, p.name,
       ROUND(AVG(r.rating), 2) AS avg_rating,
       COUNT(*) AS review_count
FROM reviews r
JOIN products p ON p.product_id = r.product_id
GROUP BY p.product_id, p.name
HAVING COUNT(*) >= 2
ORDER BY avg_rating DESC;

-- 12. Which customers have the highest lifetime value (LTV)?
SELECT c.customer_id, c.first_name, c.last_name,
       SUM(oi.quantity * oi.unit_price - oi.item_discount) + SUM(o.shipping_fee + o.tax - o.discount) AS ltv
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status IN ('paid','shipped','delivered')
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY ltv DESC;

-- 13. What is the average basket size (items per order) by channel?
SELECT o.channel,
       ROUND(AVG(items_per_order), 2) AS avg_items
FROM (
  SELECT o.order_id, o.channel, SUM(oi.quantity) AS items_per_order
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.status IN ('paid','shipped','delivered')
  GROUP BY o.order_id, o.channel
) t
GROUP BY o.channel
ORDER BY avg_items DESC;

-- 14. CTE: Which month had the biggest revenue growth vs previous month?
WITH monthly_revenue AS (
  SELECT DATE_TRUNC('month', payment_date) AS month,
         SUM(amount) AS revenue
  FROM payments
  WHERE status = 'captured'
  GROUP BY DATE_TRUNC('month', payment_date)
),
revenue_with_lag AS (
  SELECT month, revenue,
         LAG(revenue) OVER (ORDER BY month) AS prev_revenue
  FROM monthly_revenue
)
SELECT month, revenue,
       revenue - prev_revenue AS revenue_change
FROM revenue_with_lag
WHERE prev_revenue IS NOT NULL
ORDER BY revenue_change DESC
LIMIT 1;

-- 15. CTE: What percentage of customers are new vs returning each month?
WITH customer_first_order AS (
  SELECT customer_id, MIN(order_date) AS first_order_date
  FROM orders
  WHERE status IN ('paid','shipped','delivered')
  GROUP BY customer_id
),
orders_with_type AS (
  SELECT o.order_id, o.order_date,
         CASE WHEN o.order_date = c.first_order_date THEN 'new' ELSE 'returning' END AS customer_type
  FROM orders o
  JOIN customer_first_order c ON c.customer_id = o.customer_id
  WHERE o.status IN ('paid','shipped','delivered')
)
SELECT DATE_TRUNC('month', order_date) AS month,
       customer_type,
       COUNT(*) AS orders,
       ROUND(COUNT(*)::DECIMAL / SUM(COUNT(*)) OVER (PARTITION BY DATE_TRUNC('month', order_date)), 2) AS share
FROM orders_with_type
GROUP BY DATE_TRUNC('month', order_date), customer_type
ORDER BY month, customer_type;

-- 16. Window: Rank products by revenue within each category.
SELECT c.name AS category, p.name AS product,
       SUM(oi.quantity * oi.unit_price - oi.item_discount) AS revenue,
       RANK() OVER (PARTITION BY c.category_id ORDER BY SUM(oi.quantity * oi.unit_price - oi.item_discount) DESC) AS revenue_rank
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN categories c ON c.category_id = p.category_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.status IN ('paid','shipped','delivered')
GROUP BY c.category_id, c.name, p.name
ORDER BY c.name, revenue_rank;

-- 17. Window: Identify orders that are above the monthly average order value.
WITH order_totals AS (
  SELECT o.order_id, o.order_date,
         SUM(oi.quantity * oi.unit_price - oi.item_discount) + o.shipping_fee + o.tax - o.discount AS order_total
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.status IN ('paid','shipped','delivered')
  GROUP BY o.order_id, o.order_date, o.shipping_fee, o.tax, o.discount
)
SELECT order_id, order_date, order_total,
       AVG(order_total) OVER (PARTITION BY DATE_TRUNC('month', order_date)) AS avg_monthly_order
FROM order_totals
WHERE order_total > AVG(order_total) OVER (PARTITION BY DATE_TRUNC('month', order_date))
ORDER BY order_date;

-- 18. Window: What is the running cumulative revenue by date (captured payments)?
SELECT payment_date,
       SUM(amount) AS daily_revenue,
       SUM(SUM(amount)) OVER (ORDER BY payment_date) AS running_revenue
FROM payments
WHERE status = 'captured'
GROUP BY payment_date
ORDER BY payment_date;
