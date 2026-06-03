-- ============================================================================
-- SQL Projects: Basic Views for E-Commerce Database
-- Purpose: Demonstrate view creation and usage for reporting
-- ============================================================================

USE ecommerce;

-- ============================================================================
-- VIEW 1: Customer Order Summary
-- ============================================================================
CREATE OR REPLACE VIEW customer_order_summary AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS avg_order_value,
    MAX(o.order_date) AS last_order_date,
    c.created_at AS customer_since
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.created_at;

-- ============================================================================
-- VIEW 2: Product Sales Performance
-- ============================================================================
CREATE OR REPLACE VIEW product_sales_performance AS
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    p.stock_quantity,
    COUNT(DISTINCT oi.order_id) AS total_sales,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.subtotal) AS revenue_generated,
    AVG(oi.unit_price) AS avg_selling_price
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category, p.price, p.stock_quantity;

-- ============================================================================
-- VIEW 3: Monthly Revenue Report
-- ============================================================================
CREATE OR REPLACE VIEW monthly_revenue_report AS
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    SUM(o.total_amount) AS total_revenue,
    AVG(o.total_amount) AS avg_order_value,
    MIN(o.total_amount) AS min_order_value,
    MAX(o.total_amount) AS max_order_value
FROM orders o
WHERE o.order_status IN ('completed', 'shipped')
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m');

-- ============================================================================
-- VIEW 4: Customer Geographic Distribution
-- ============================================================================
CREATE OR REPLACE VIEW customer_geographic_distribution AS
SELECT 
    c.country,
    c.city,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_revenue,
    AVG(o.total_amount) AS avg_order_value
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.country, c.city
ORDER BY total_revenue DESC;

-- ============================================================================
-- VIEW 5: Top Customers
-- ============================================================================
CREATE OR REPLACE VIEW top_customers AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    c.country,
    COUNT(o.order_id) AS order_count,
    SUM(o.total_amount) AS total_spent,
    MAX(o.order_date) AS last_purchase_date,
    DATEDIFF(NOW(), MAX(o.order_date)) AS days_since_last_purchase
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.country
ORDER BY total_spent DESC;

-- ============================================================================
-- VIEW 6: Order Details with Customer Info
-- ============================================================================
CREATE OR REPLACE VIEW order_details_with_customer AS
SELECT 
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    c.country,
    o.order_date,
    o.total_amount,
    o.order_status,
    o.payment_method,
    COUNT(oi.order_item_id) AS item_count,
    SUM(oi.quantity) AS total_quantity
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, c.first_name, c.last_name, c.email, c.country, 
         o.order_date, o.total_amount, o.order_status, o.payment_method;

-- ============================================================================
-- VIEW 7: Low Stock Alert
-- ============================================================================
CREATE OR REPLACE VIEW low_stock_alert AS
SELECT 
    product_id,
    product_name,
    category,
    stock_quantity,
    price,
    (price * stock_quantity) AS inventory_value,
    CASE 
        WHEN stock_quantity <= 10 THEN 'CRITICAL'
        WHEN stock_quantity <= 25 THEN 'LOW'
        WHEN stock_quantity <= 50 THEN 'MEDIUM'
        ELSE 'OK'
    END AS stock_status
FROM products
WHERE stock_quantity <= 50
ORDER BY stock_quantity ASC;

-- ============================================================================
-- VIEW 8: Customer Purchase Frequency
-- ============================================================================
CREATE OR REPLACE VIEW customer_purchase_frequency AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(o.order_id) AS purchase_count,
    CASE 
        WHEN COUNT(o.order_id) = 0 THEN 'No Purchases'
        WHEN COUNT(o.order_id) = 1 THEN 'One-Time Buyer'
        WHEN COUNT(o.order_id) BETWEEN 2 AND 5 THEN 'Regular'
        WHEN COUNT(o.order_id) > 5 THEN 'VIP'
    END AS customer_tier,
    MIN(o.order_date) AS first_purchase_date,
    MAX(o.order_date) AS last_purchase_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

-- ============================================================================
-- Verification
-- ============================================================================
SELECT 'All views created successfully!' AS status;
SHOW FULL TABLES FROM ecommerce WHERE TABLE_TYPE LIKE 'VIEW';
