# SQL Projects - Deployment Guide

## Overview
This guide provides step-by-step instructions for deploying SQL optimization and views into customer environments.

---

## Table of Contents
1. [Pre-Deployment Checklist](#pre-deployment-checklist)
2. [Environment Setup](#environment-setup)
3. [Deployment Steps](#deployment-steps)
4. [Validation & Testing](#validation--testing)
5. [Performance Monitoring](#performance-monitoring)
6. [Rollback Procedures](#rollback-procedures)
7. [Troubleshooting](#troubleshooting)

---

## Pre-Deployment Checklist

Before deploying to a customer environment, ensure:

- [ ] MySQL version 5.7 or higher installed
- [ ] Database backup completed
- [ ] Customer environment access verified
- [ ] Deployment window scheduled
- [ ] Team members notified
- [ ] Rollback plan documented
- [ ] Performance baseline established

### Version Requirements
```
MySQL 5.7+
InnoDB Storage Engine
UTF-8 or UTF-8MB4 Character Set
```

---

## Environment Setup

### Step 1: Verify MySQL Version
```bash
mysql --version
# Expected: mysql  Ver 5.7.x or higher
```

### Step 2: Connect to Database
```bash
mysql -h <hostname> -u <username> -p -A
# -A flag skips initialization of database list
```

### Step 3: Create Target Database (if needed)
```sql
CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;
SHOW DATABASES;
```

### Step 4: Check Existing Tables
```sql
SHOW TABLES;
SHOW TABLE STATUS;
```

---

## Deployment Steps

### Phase 1: Initial Schema Setup

#### Step 1.1: Run Base Database Setup
```bash
mysql -h <hostname> -u <username> -p ecommerce < 01_sample_database_setup.sql
```

**Expected Output:**
```
Database setup completed successfully!
Customers: 5
Products: 8
Orders: 5
```

**Validation Query:**
```sql
SELECT TABLE_NAME, TABLE_ROWS 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'ecommerce';
```

#### Step 1.2: Verify Data Integrity
```sql
-- Check table row counts
SELECT 'customers' AS table_name, COUNT(*) AS count FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;
```

---

### Phase 2: Deploy Views

#### Step 2.1: Create Views
```bash
mysql -h <hostname> -u <username> -p ecommerce < 02_basic_views.sql
```

**Expected Output:**
```
All views created successfully!
```

#### Step 2.2: Verify Views
```sql
SHOW FULL TABLES FROM ecommerce WHERE TABLE_TYPE LIKE 'VIEW';
```

**Expected Count:** 8 views

#### Step 2.3: Test Each View
```sql
-- Test each view for functionality
SELECT * FROM customer_order_summary LIMIT 1;
SELECT * FROM product_sales_performance LIMIT 1;
SELECT * FROM monthly_revenue_report LIMIT 1;
SELECT * FROM customer_geographic_distribution LIMIT 1;
SELECT * FROM top_customers LIMIT 1;
SELECT * FROM order_details_with_customer LIMIT 1;
SELECT * FROM low_stock_alert;
SELECT * FROM customer_purchase_frequency LIMIT 1;
```

---

### Phase 3: Deploy Indexes

#### Step 3.1: Run Index Optimization
```bash
mysql -h <hostname> -u <username> -p ecommerce < 04_index_strategies.sql
```

#### Step 3.2: Analyze Tables
```sql
ANALYZE TABLE customers;
ANALYZE TABLE orders;
ANALYZE TABLE products;
ANALYZE TABLE order_items;
```

#### Step 3.3: Verify Indexes
```sql
SHOW INDEX FROM customers;
SHOW INDEX FROM orders;
SHOW INDEX FROM products;
SHOW INDEX FROM order_items;
```

---

### Phase 4: Deploy Stored Procedures

#### Step 4.1: Create Procedures
```bash
mysql -h <hostname> -u <username> -p ecommerce < 05_stored_procedures.sql
```

#### Step 4.2: Verify Procedures
```sql
SHOW PROCEDURE STATUS WHERE Db = 'ecommerce';
```

**Expected Count:** 9 procedures

---

### Phase 5: Load Optimization Queries (Reference Only)

The `03_optimized_queries.sql` file contains EXPLAIN statements for reference. These are not meant to be executed as part of deployment, but serve as documentation for query patterns.

```sql
-- Review the documentation in 03_optimized_queries.sql
-- No execution required for this file
```

---

## Validation & Testing

### Test 1: View Performance
```sql
-- Test all views execute without errors
SELECT COUNT(*) FROM customer_order_summary;
SELECT COUNT(*) FROM product_sales_performance;
SELECT COUNT(*) FROM monthly_revenue_report;
SELECT COUNT(*) FROM customer_geographic_distribution;
SELECT COUNT(*) FROM top_customers;
SELECT COUNT(*) FROM order_details_with_customer;
SELECT COUNT(*) FROM low_stock_alert;
SELECT COUNT(*) FROM customer_purchase_frequency;
```

### Test 2: Stored Procedure Execution
```sql
-- Test GetCustomerOrderHistory
CALL GetCustomerOrderHistory(1, 5);

-- Test GenerateSalesReport
CALL GenerateSalesReport('2026-01-01', '2026-12-31');

-- Test GetTopProductsByRevenue
CALL GetTopProductsByRevenue(10, 30);
```

### Test 3: Query Performance
```sql
-- Run EXPLAIN on key queries to verify index usage
EXPLAIN SELECT * FROM customers WHERE email = 'john.doe@example.com';

EXPLAIN SELECT customer_id, COUNT(*) FROM orders 
WHERE customer_id = 1 AND order_date >= '2026-01-01'
GROUP BY customer_id;

EXPLAIN SELECT * FROM products WHERE category = 'Electronics';
```

### Test 4: Index Usage Verification
```sql
-- Check if indexes are being used (key column should not be NULL)
EXPLAIN FORMAT=JSON SELECT * FROM orders 
WHERE customer_id = 1 AND order_date >= '2026-01-01'\G
```

---

## Performance Monitoring

### Check Query Execution Time
```sql
-- Enable profiling
SET profiling = 1;

-- Run test query
SELECT * FROM orders WHERE customer_id = 1;

-- View profiling results
SHOW PROFILE FOR QUERY 1;

-- Disable profiling
SET profiling = 0;
```

### Monitor Slow Queries
```sql
-- Check slow query log (if enabled)
SHOW VARIABLES LIKE 'slow_query_log%';

-- View slow queries (if available)
SELECT * FROM mysql.slow_log LIMIT 10;
```

### Check Table and Index Statistics
```sql
-- View index statistics
SELECT 
    OBJECT_NAME,
    INDEX_NAME,
    COUNT_READ,
    COUNT_WRITE,
    COUNT_DELETE,
    COUNT_UPDATE
FROM PERFORMANCE_SCHEMA.TABLE_IO_WAITS_SUMMARY_BY_INDEX_USAGE
WHERE OBJECT_SCHEMA = 'ecommerce'
ORDER BY COUNT_READ DESC;
```

### Disk Space Usage
```sql
-- Check database size
SELECT 
    table_schema,
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS size_mb
FROM information_schema.tables
WHERE table_schema = 'ecommerce'
GROUP BY table_schema;

-- Check table sizes
SELECT 
    TABLE_NAME,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'ecommerce'
ORDER BY size_mb DESC;
```

---

## Rollback Procedures

### Quick Rollback Steps

If deployment fails or issues arise:

#### Step 1: Stop Application Traffic
- Redirect traffic away from the database
- Notify customer of maintenance window

#### Step 2: Restore from Backup
```bash
# Restore from backup (example with mysqldump)
mysql -h <hostname> -u <username> -p < backup_ecommerce.sql
```

#### Step 3: Verify Rollback
```sql
USE ecommerce;
SHOW TABLES;
SHOW PROCEDURE STATUS WHERE Db = 'ecommerce';
```

#### Step 4: Resume Operations
- Redirect traffic back to database
- Monitor for any issues
- Document what failed

### Selective Rollback (Drop Components)

```sql
-- Drop all views
DROP VIEW IF EXISTS customer_order_summary;
DROP VIEW IF EXISTS product_sales_performance;
DROP VIEW IF EXISTS monthly_revenue_report;
DROP VIEW IF EXISTS customer_geographic_distribution;
DROP VIEW IF EXISTS top_customers;
DROP VIEW IF EXISTS order_details_with_customer;
DROP VIEW IF EXISTS low_stock_alert;
DROP VIEW IF EXISTS customer_purchase_frequency;

-- Drop all procedures
DROP PROCEDURE IF EXISTS GetCustomerOrderHistory;
DROP PROCEDURE IF EXISTS CreateNewOrder;
DROP PROCEDURE IF EXISTS AddItemToOrder;
DROP PROCEDURE IF EXISTS CompleteOrder;
DROP PROCEDURE IF EXISTS UpdateProductStock;
DROP PROCEDURE IF EXISTS GenerateSalesReport;
DROP PROCEDURE IF EXISTS ArchiveOldOrders;
DROP PROCEDURE IF EXISTS GetTopProductsByRevenue;
DROP PROCEDURE IF EXISTS LogCustomerActivity;

-- Drop specific indexes (if needed)
ALTER TABLE orders DROP INDEX idx_customer_order_covering;
```

---

## Troubleshooting

### Issue: Insufficient Privileges
```
Error: Access denied for user 'username'@'hostname'
```

**Solution:**
```bash
# Use account with appropriate privileges
mysql -u root -p

# Grant privileges
GRANT ALL PRIVILEGES ON ecommerce.* TO 'username'@'hostname';
FLUSH PRIVILEGES;
```

### Issue: Character Set Mismatch
```
Error: Illegal mix of collations
```

**Solution:**
```sql
-- Convert all tables to UTF-8MB4
ALTER TABLE customers CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE orders CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE products CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE order_items CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### Issue: Foreign Key Constraint Error
```
Error: Cannot add or update a child row: a foreign key constraint fails
```

**Solution:**
```sql
-- Check existing foreign keys
SELECT CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME 
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME IS NOT NULL AND TABLE_SCHEMA = 'ecommerce';

-- Temporarily disable foreign key checks during deployment
SET FOREIGN_KEY_CHECKS = 0;
-- Run deployment scripts
SET FOREIGN_KEY_CHECKS = 1;
```

### Issue: Slow Query Performance
```
Queries take longer than expected
```

**Solution:**
```sql
-- Force index usage
ANALYZE TABLE table_name;

-- Check execution plan
EXPLAIN SELECT ... \G

-- Verify indexes exist
SHOW INDEX FROM table_name;

-- Rebuild indexes if necessary
OPTIMIZE TABLE table_name;
```

### Issue: Duplicate Key Error
```
Error: Duplicate entry for key 'unique_key'
```

**Solution:**
```sql
-- Check for duplicates before deployment
SELECT email, COUNT(*) FROM customers GROUP BY email HAVING COUNT(*) > 1;

-- Remove duplicates (adjust as needed)
DELETE FROM customers WHERE email IN (SELECT email FROM customers GROUP BY email HAVING COUNT(*) > 1);
```

---

## Post-Deployment Checklist

After successful deployment:

- [ ] All tables created and populated
- [ ] All views functioning correctly
- [ ] All stored procedures callable
- [ ] All indexes created and in use
- [ ] Performance baseline exceeded
- [ ] Backup completed post-deployment
- [ ] Documentation updated
- [ ] Customer notification sent
- [ ] Monitoring configured
- [ ] Support team trained

---

## Support and Maintenance

### Daily Maintenance
```sql
-- Daily backup
mysqldump -h hostname -u username -p ecommerce > backup_ecommerce_$(date +%Y%m%d).sql

-- Weekly analysis
ANALYZE TABLE customers;
ANALYZE TABLE orders;
ANALYZE TABLE products;
ANALYZE TABLE order_items;
```

### Regular Health Checks
```sql
-- Check for table fragmentation
SELECT TABLE_NAME, DATA_FREE 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'ecommerce' 
AND DATA_FREE > 0;

-- Check for unused indexes
SELECT OBJECT_NAME, INDEX_NAME, COUNT_READ, COUNT_WRITE 
FROM PERFORMANCE_SCHEMA.TABLE_IO_WAITS_SUMMARY_BY_INDEX_USAGE
WHERE OBJECT_SCHEMA = 'ecommerce' AND COUNT_READ = 0;
```

---

## Contact & Documentation
For questions or issues, refer to:
- GitHub Repository: https://github.com/nabilgitvagrant/sql-projects
- MySQL Documentation: https://dev.mysql.com/doc/
- Performance Schema Guide: https://dev.mysql.com/doc/refman/8.0/en/performance-schema.html

---

*Last Updated: 2026-06-03*
