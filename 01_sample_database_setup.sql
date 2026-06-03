-- ============================================================================
-- SQL Projects: Sample Database Setup
-- MySQL Database Schema for E-Commerce Platform
-- Purpose: Demonstrate optimization and performance tuning
-- ============================================================================

-- Create Database
CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

-- ============================================================================
-- 1. CUSTOMERS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    country VARCHAR(50),
    city VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
    INDEX idx_created_at (created_at),
    INDEX idx_country_city (country, city)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 2. PRODUCTS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL,
    supplier_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_category (category),
    INDEX idx_price (price),
    INDEX idx_stock_quantity (stock_quantity),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 3. ORDERS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(12, 2) NOT NULL,
    order_status VARCHAR(20) DEFAULT 'pending',
    payment_method VARCHAR(30),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_customer_id (customer_id),
    INDEX idx_order_date (order_date),
    INDEX idx_order_status (order_status),
    INDEX idx_customer_date (customer_id, order_date),
    
    CONSTRAINT fk_customer_id FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 4. ORDER_ITEMS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(12, 2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id),
    
    CONSTRAINT fk_order_id FOREIGN KEY (order_id) 
        REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_product_id FOREIGN KEY (product_id) 
        REFERENCES products(product_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 5. CUSTOMER_ACTIVITY TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS customer_activity (
    activity_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    activity_type VARCHAR(30) NOT NULL,
    activity_description VARCHAR(255),
    ip_address VARCHAR(15),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_customer_id (customer_id),
    INDEX idx_activity_type (activity_type),
    INDEX idx_created_at (created_at),
    INDEX idx_customer_date (customer_id, created_at),
    
    CONSTRAINT fk_activity_customer FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- Sample Data Insertion
-- ============================================================================

-- Insert sample customers
INSERT INTO customers (first_name, last_name, email, phone, country, city) VALUES
('John', 'Doe', 'john.doe@example.com', '1234567890', 'USA', 'New York'),
('Jane', 'Smith', 'jane.smith@example.com', '0987654321', 'USA', 'Los Angeles'),
('Ahmed', 'Hassan', 'ahmed.hassan@example.com', '5555555555', 'Egypt', 'Cairo'),
('Maria', 'Garcia', 'maria.garcia@example.com', '6666666666', 'Spain', 'Madrid'),
('John', 'Johnson', 'john.johnson@example.com', '7777777777', 'UK', 'London');

-- Insert sample products
INSERT INTO products (product_name, category, price, stock_quantity, supplier_id) VALUES
('Laptop', 'Electronics', 999.99, 50, 1),
('Mouse', 'Electronics', 29.99, 200, 1),
('Keyboard', 'Electronics', 79.99, 150, 1),
('Monitor', 'Electronics', 299.99, 75, 2),
('Desk Chair', 'Furniture', 199.99, 100, 3),
('Standing Desk', 'Furniture', 499.99, 50, 3),
('USB Cable', 'Accessories', 9.99, 500, 4),
('Monitor Stand', 'Accessories', 49.99, 100, 4);

-- Insert sample orders
INSERT INTO orders (customer_id, total_amount, order_status, payment_method) VALUES
(1, 1059.98, 'completed', 'credit_card'),
(2, 299.99, 'completed', 'paypal'),
(3, 1279.97, 'pending', 'credit_card'),
(4, 199.99, 'completed', 'debit_card'),
(1, 79.99, 'shipped', 'credit_card');

-- Insert sample order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 999.99),
(1, 2, 2, 29.99),
(2, 4, 1, 299.99),
(3, 1, 1, 999.99),
(3, 5, 1, 199.99),
(3, 7, 8, 9.99),
(4, 5, 1, 199.99),
(5, 3, 1, 79.99);

-- Insert sample activity logs
INSERT INTO customer_activity (customer_id, activity_type, activity_description, ip_address) VALUES
(1, 'login', 'User logged in', '192.168.1.1'),
(1, 'purchase', 'Completed order #1', '192.168.1.1'),
(2, 'login', 'User logged in', '192.168.1.2'),
(2, 'purchase', 'Completed order #2', '192.168.1.2'),
(3, 'browse', 'Viewed laptop', '192.168.1.3'),
(3, 'purchase', 'Initiated order #3', '192.168.1.3');

-- ============================================================================
-- Verification Queries
-- ============================================================================
SELECT 'Database setup completed successfully!' AS status;
SELECT CONCAT('Customers: ', COUNT(*)) FROM customers;
SELECT CONCAT('Products: ', COUNT(*)) FROM products;
SELECT CONCAT('Orders: ', COUNT(*)) FROM orders;
