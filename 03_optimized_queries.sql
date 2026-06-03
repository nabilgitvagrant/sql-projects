-- ============================================================================
-- SQL Projects: Optimized Query Examples
-- Purpose: Demonstrate query optimization techniques and performance tuning
-- ============================================================================

USE ecommerce;

-- ============================================================================
-- OPTIMIZATION 1: Using JOINs efficiently
-- ============================================================================
-- ❌ POOR APPROACH (Cartesian Product Risk)
-- SELECT * FROM orders, customers WHERE orders.customer_id = customers.customer_id;

-- ✅ OPTIMIZED APPROACH
SELECT 
    o.order_id,
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    o.order_date,
    o.total_amount,
    o.order_status
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY o.order_date DESC;

-- ============================================================================
-- OPTIMIZATION 2: Using Indexes effectively
-- ============================================================================
-- This query benefits from the composite index (customer_id, order_date)
EXPLAIN SELECT 
    customer_id,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_spent
FROM orders
WHERE customer_id = 1 
    AND order_date >= DATE_SUB(NOW(), INTERVAL 1 YEAR)
GROUP BY customer_id;

-- ============================================================================
-- OPTIMIZATION 3: Aggregation with proper indexing
-- ============================================================================
-- Uses index on (category, price) for efficient grouping
EXPLAIN SELECT 
    category,
    COUNT(*) AS product_count,
    AVG(price) AS avg_price,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    SUM(stock_quantity) AS total_stock
FROM products
WHERE price > 50
GROUP BY category
HAVING product_count > 1
ORDER BY avg_price DESC;

-- ============================================================================
-- OPTIMIZATION 4: Avoiding N+1 Query Problem
-- ============================================================================
-- ❌ POOR: Would require separate queries for each order
-- SELECT * FROM orders WHERE customer_id = 1;
-- For each order: SELECT * FROM order_items WHERE order_id = ?;

-- ✅ OPTIMIZED: Single query with JOIN
SELECT 
    o.order_id,
    o.order_date,
    o.total_amount,
    oi.product_id,
    oi.quantity,
    oi.unit_price,
    oi.subtotal
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.customer_id = 1
ORDER BY o.order_date DESC, o.order_id;

-- ============================================================================
-- OPTIMIZATION 5: Using LIMIT to reduce data transfer
-- ============================================================================
-- Get top 10 customers by spending
EXPLAIN SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(o.total_amount) AS total_spent
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 10;

-- ============================================================================
-- OPTIMIZATION 6: Subquery vs JOIN comparison
-- ============================================================================
-- ❌ POOR: Using subquery (may create temporary table)
-- SELECT * FROM customers WHERE customer_id IN 
-- (SELECT customer_id FROM orders WHERE total_amount > 100);

-- ✅ OPTIMIZED: Using JOIN
SELECT DISTINCT c.customer_id,
    c.first_name,
    c.last_name,
    c.email
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.total_amount > 100;

-- ============================================================================
-- OPTIMIZATION 7: Using CASE for conditional logic
-- ============================================================================
EXPLAIN SELECT 
    customer_id,
    COUNT(*) AS order_count,
    SUM(CASE WHEN order_status = 'completed' THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN order_status = 'pending' THEN 1 ELSE 0 END) AS pending_orders,
    SUM(CASE WHEN order_status = 'shipped' THEN 1 ELSE 0 END) AS shipped_orders,
    SUM(total_amount) AS total_revenue
FROM orders
GROUP BY customer_id
HAVING order_count > 0;

-- ============================================================================
-- OPTIMIZATION 8: Using UNION instead of OR for multiple conditions
-- ============================================================================
-- ❌ POOR: OR condition (may not use indexes efficiently)
-- SELECT * FROM orders WHERE status = 'completed' OR status = 'shipped';

-- ✅ OPTIMIZED: UNION (can use indexes better)
SELECT order_id, customer_id, total_amount, order_status, order_date
FROM orders
WHERE order_status = 'completed'
UNION
SELECT order_id, customer_id, total_amount, order_status, order_date
FROM orders
WHERE order_status = 'shipped'
ORDER BY order_date DESC;

-- ============================================================================
-- OPTIMIZATION 9: Batch processing for large updates
-- ============================================================================
-- Update with LIMIT for safer batch processing
-- UPDATE order_items SET quantity = quantity * 1.1 
-- WHERE product_id = 1 LIMIT 100;

-- ============================================================================
-- OPTIMIZATION 10: Using WINDOW FUNCTIONS (MySQL 8.0+)
-- ============================================================================
-- Get customer rank by total spending
SELECT 
    customer_id,
    total_spent,
    ROW_NUMBER() OVER (ORDER BY total_spent DESC) AS rank,
    PERCENT_RANK() OVER (ORDER BY total_spent DESC) AS percent_rank,
    SUM(total_spent) OVER (ORDER BY total_spent DESC 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM (
    SELECT 
        c.customer_id,
        SUM(o.total_amount) AS total_spent
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
) customer_totals
ORDER BY rank;

-- ============================================================================
-- OPTIMIZATION 11: Date-based partitioning queries
-- ============================================================================
-- Efficiently query recent orders
EXPLAIN SELECT 
    DATE(order_date) AS order_day,
    COUNT(*) AS daily_orders,
    SUM(total_amount) AS daily_revenue
FROM orders
WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY DATE(order_date)
ORDER BY order_day DESC;

-- ============================================================================
-- OPTIMIZATION 12: Selective column retrieval
-- ============================================================================
-- ❌ POOR: Selecting all columns
-- SELECT * FROM order_items WHERE order_id = 1;

-- ✅ OPTIMIZED: Only needed columns
SELECT 
    order_item_id,
    product_id,
    quantity,
    unit_price,
    subtotal
FROM order_items
WHERE order_id = 1;

-- ============================================================================
-- Performance Analysis Queries
-- ============================================================================

-- Check table statistics
SELECT 
    TABLE_NAME,
    TABLE_ROWS,
    DATA_LENGTH,
    INDEX_LENGTH
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'ecommerce'
ORDER BY DATA_LENGTH DESC;

-- Check query performance
-- EXPLAIN FORMAT=JSON SELECT ... (detailed explanation)

-- Verify indexes are being used
SHOW INDEX FROM orders;
SHOW INDEX FROM customers;
SHOW INDEX FROM products;
SHOW INDEX FROM order_items;
