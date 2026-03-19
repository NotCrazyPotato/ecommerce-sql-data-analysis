# E-commerce SQL Portfolio Project

This project showcases a complete e-commerce analytics workflow using SQL. It includes a relational schema, realistic sample data, and 18 business-focused queries covering joins, aggregations, CTEs, and window functions.

## Dataset
The dataset is generated directly in `schema.sql` with sample `INSERT` statements. It represents a mid-sized online retailer with:
- Customers
- Categories and products
- Orders and order items
- Payments
- Shipments
- Product reviews

## Database Schema
**Core tables**
- `customers` — customer profile and geography
- `categories` — product category hierarchy
- `products` — catalog with price and cost

**Fact tables**
- `orders` — customer orders with fees, taxes, discounts
- `order_items` — line items per order
- `payments` — payment records and status
- `shipments` — fulfillment timelines and carrier
- `reviews` — product ratings

Relationships:
- `customers` 1—* `orders`
- `orders` 1—* `order_items`
- `products` 1—* `order_items`
- `categories` 1—* `products`
- `orders` 1—* `payments`
- `orders` 1—* `shipments`
- `products` 1—* `reviews`

## How To Run
1. Create a PostgreSQL database (local or in a container).
2. Execute the schema and sample data:
   ```sql
   \i schema.sql
   ```
3. Run the analytics queries:
   ```sql
   \i queries.sql
   ```

## Business Insights Covered
The queries in `queries.sql` answer real-world e-commerce questions, such as:
- Which products are active and competitively priced?
- Who are the newest customers?
- How does monthly revenue trend over time?
- What is average order value (AOV) for delivered orders?
- Which products and categories drive the most revenue and volume?
- What products have the best gross margin?
- Which customers are repeat buyers and have the highest LTV?
- How do carriers compare on delivery speed?
- Which channels have the highest cancellation rate?
- Which products earn the highest ratings?
- What is the average basket size by channel?
- Which month shows the largest revenue growth?
- What share of orders come from new vs returning customers?
- Which products rank highest by revenue within each category?
- Which orders outperform the monthly average order value?
- What is the running revenue trend by date?

## Files
- `schema.sql` — schema definitions, constraints, indexes, and sample data
- `queries.sql` — 18 commented SQL queries answering business questions
- `README.md` — project overview and insight summaries
