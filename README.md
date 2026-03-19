# E-commerce SQL Portfolio Project

## Project Overview
This project demonstrates an end-to-end e-commerce analytics workflow using SQL. It includes a normalized relational schema, realistic sample data, and 18 business-focused queries that cover joins, aggregations, CTEs, and window functions.

## Business Problem
An online retailer needs actionable insights across revenue, customer behavior, product performance, and fulfillment operations. The goal is to model a clean analytics-ready database and answer common business questions with SQL.

## Tools Used
- PostgreSQL (SQL dialect and query execution)
- SQL scripts for schema, data, and analytics queries

## Steps Performed
1. Designed a relational schema for customers, products, orders, payments, shipments, and reviews.
2. Added constraints and indexes for integrity and performance.
3. Generated realistic sample data to support analysis.
4. Wrote 18 SQL queries mapped to real business questions.
5. Documented results and usage instructions.

## Key Insights (Examples)
- Monthly revenue trends and growth drivers.
- Top products and categories by revenue and volume.
- Average order value (AOV) and basket size by channel.
- Customer lifetime value (LTV) and repeat-buyer identification.
- Carrier performance based on average delivery time.
- Cancellation rates by sales channel.

## How To Run the Project
1. Create a PostgreSQL database (local or in a container).
2. Execute the schema and sample data:
   ```sql
   \i schema.sql
   ```
3. Run the analytics queries:
   ```sql
   \i queries.sql
   ```

## Files
- `schema.sql` — schema definitions, constraints, indexes, and sample data
- `queries.sql` — 18 commented SQL queries answering business questions
- `README.md` — project overview and execution guidance

## License
MIT License. See `LICENSE`.
