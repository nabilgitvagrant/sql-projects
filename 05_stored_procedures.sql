-- ============================================================================
-- SQL Projects: Optimized Stored Procedures
-- Purpose: Reusable database logic for improved performance and maintainability
-- ============================================================================

USE ecommerce;

-- ============================================================================
-- PROCEDURE 1: Get Customer Order History with Summary
-- ============================================================================
DELIMITER //

CREATE PROCEDURE GetCustomerOrderHistory(
    IN p_customer_id INT,
    IN p_limit INT DEFAULT 10
)
READS SQL DATA
BEGIN
    -- Get customer info
    SELECT 
        customer_id,
        CONCAT(first_name, ' ', last_name) AS full_name,
        email,
        country,
        created_at
    FROM customers
    WHERE customer_id = p_customer_id;
    
    -- Get recent orders
    SELECT 
        order_id,
        order_date,
        total_amount,
        order_status,
        payment_method,
        (SELECT COUNT(*) FROM order_items WHERE order_id = o.order_id) AS item_count
    FROM orders o
    WHERE customer_id = p_customer_id
    ORDER BY order_date DESC
    LIMIT p_limit;
END //

DELIMITER ;

-- ============================================================================
-- PROCEDURE 2: Create New Order with Items
-- ============================================================================
DELIMITER //

CREATE PROCEDURE CreateNewOrder(
    IN p_customer_id INT,
    IN p_payment_method VARCHAR(30),
    OUT p_order_id INT,
    OUT p_error_message VARCHAR(255)
)
MODIFIES SQL DATA
BEGIN
    DECLARE v_customer_exists INT;
    
    START TRANSACTION;
    
    -- Check if customer exists
    SELECT COUNT(*) INTO v_customer_exists 
    FROM customers 
    WHERE customer_id = p_customer_id;
    
    IF v_customer_exists = 0 THEN
        SET p_error_message = 'Customer not found';
        ROLLBACK;
        SET p_order_id = 0;
    ELSE
        -- Create order
        INSERT INTO orders (customer_id, total_amount, order_status, payment_method)
        VALUES (p_customer_id, 0, 'pending', p_payment_method);
        
        SET p_order_id = LAST_INSERT_ID();
        SET p_error_message = 'Order created successfully';
        
        COMMIT;
    END IF;
END //

DELIMITER ;

-- ============================================================================
-- PROCEDURE 3: Add Item to Order
-- ============================================================================
DELIMITER //

CREATE PROCEDURE AddItemToOrder(
    IN p_order_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    OUT p_success BOOLEAN,
    OUT p_error_message VARCHAR(255)
)
MODIFIES SQL DATA
BEGIN
    DECLARE v_product_price DECIMAL(10, 2);
    DECLARE v_stock_available INT;
    DECLARE v_order_exists INT;
    
    START TRANSACTION;
    
    -- Validate order exists
    SELECT COUNT(*) INTO v_order_exists 
    FROM orders 
    WHERE order_id = p_order_id;
    
    IF v_order_exists = 0 THEN
        SET p_success = FALSE;
        SET p_error_message = 'Order not found';
        ROLLBACK;
    ELSE
        -- Get product price and stock
        SELECT price, stock_quantity 
        INTO v_product_price, v_stock_available
        FROM products
        WHERE product_id = p_product_id;
        
        IF v_product_price IS NULL THEN
            SET p_success = FALSE;
            SET p_error_message = 'Product not found';
            ROLLBACK;
        ELSEIF v_stock_available < p_quantity THEN
            SET p_success = FALSE;
            SET p_error_message = CONCAT('Insufficient stock. Available: ', v_stock_available);
            ROLLBACK;
        ELSE
            -- Add order item
            INSERT INTO order_items (order_id, product_id, quantity, unit_price)
            VALUES (p_order_id, p_product_id, p_quantity, v_product_price);
            
            -- Update order total
            UPDATE orders
            SET total_amount = (
                SELECT SUM(subtotal) FROM order_items WHERE order_id = p_order_id
            )
            WHERE order_id = p_order_id;
            
            -- Reduce stock
            UPDATE products
            SET stock_quantity = stock_quantity - p_quantity
            WHERE product_id = p_product_id;
            
            SET p_success = TRUE;
            SET p_error_message = 'Item added successfully';
            COMMIT;
        END IF;
    END IF;
END //

DELIMITER ;

-- ============================================================================
-- PROCEDURE 4: Complete Order
-- ============================================================================
DELIMITER //

CREATE PROCEDURE CompleteOrder(
    IN p_order_id INT,
    OUT p_success BOOLEAN,
    OUT p_error_message VARCHAR(255)
)
MODIFIES SQL DATA
BEGIN
    DECLARE v_order_status VARCHAR(20);
    
    START TRANSACTION;
    
    -- Get order status
    SELECT order_status INTO v_order_status
    FROM orders
    WHERE order_id = p_order_id;
    
    IF v_order_status IS NULL THEN
        SET p_success = FALSE;
        SET p_error_message = 'Order not found';
        ROLLBACK;
    ELSEIF v_order_status = 'completed' THEN
        SET p_success = FALSE;
        SET p_error_message = 'Order is already completed';
        ROLLBACK;
    ELSE
        UPDATE orders
        SET order_status = 'completed',
            updated_at = NOW()
        WHERE order_id = p_order_id;
        
        SET p_success = TRUE;
        SET p_error_message = 'Order completed successfully';
        COMMIT;
    END IF;
END //

DELIMITER ;

-- ============================================================================
-- PROCEDURE 5: Update Stock for Product
-- ============================================================================
DELIMITER //

CREATE PROCEDURE UpdateProductStock(
    IN p_product_id INT,
    IN p_quantity_change INT,
    OUT p_success BOOLEAN,
    OUT p_error_message VARCHAR(255)
)
MODIFIES SQL DATA
BEGIN
    DECLARE v_current_stock INT;
    
    START TRANSACTION;
    
    -- Get current stock
    SELECT stock_quantity INTO v_current_stock
    FROM products
    WHERE product_id = p_product_id;
    
    IF v_current_stock IS NULL THEN
        SET p_success = FALSE;
        SET p_error_message = 'Product not found';
        ROLLBACK;
    ELSEIF (v_current_stock + p_quantity_change) < 0 THEN
        SET p_success = FALSE;
        SET p_error_message = 'Insufficient stock for reduction';
        ROLLBACK;
    ELSE
        UPDATE products
        SET stock_quantity = stock_quantity + p_quantity_change,
            updated_at = NOW()
        WHERE product_id = p_product_id;
        
        SET p_success = TRUE;
        SET p_error_message = 'Stock updated successfully';
        COMMIT;
    END IF;
END //

DELIMITER ;

-- ============================================================================
-- PROCEDURE 6: Generate Sales Report by Period
-- ============================================================================
DELIMITER //

CREATE PROCEDURE GenerateSalesReport(
    IN p_start_date DATE,
    IN p_end_date DATE
)
READS SQL DATA
BEGIN
    -- Daily sales summary
    SELECT 
        DATE(order_date) AS sale_date,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT customer_id) AS unique_customers,
        SUM(total_amount) AS daily_revenue,
        AVG(total_amount) AS avg_order_value,
        MIN(total_amount) AS min_order,
        MAX(total_amount) AS max_order
    FROM orders
    WHERE order_date >= p_start_date
        AND order_date < DATE_ADD(p_end_date, INTERVAL 1 DAY)
        AND order_status IN ('completed', 'shipped')
    GROUP BY DATE(order_date)
    ORDER BY sale_date DESC;
    
    -- Product sales breakdown
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        COUNT(DISTINCT oi.order_id) AS sales_count,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.subtotal) AS total_revenue
    FROM products p
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    LEFT JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= p_start_date
        AND o.order_date < DATE_ADD(p_end_date, INTERVAL 1 DAY)
        AND o.order_status IN ('completed', 'shipped')
    GROUP BY p.product_id, p.product_name, p.category
    ORDER BY total_revenue DESC;
END //

DELIMITER ;

-- ============================================================================
-- PROCEDURE 7: Archive Old Orders
-- ============================================================================
DELIMITER //

CREATE PROCEDURE ArchiveOldOrders(
    IN p_days_old INT,
    OUT p_archived_count INT
)
MODIFIES SQL DATA
BEGIN
    DECLARE v_cutoff_date DATETIME;
    
    SET v_cutoff_date = DATE_SUB(NOW(), INTERVAL p_days_old DAY);
    
    START TRANSACTION;
    
    -- Count orders to be archived
    SELECT COUNT(*) INTO p_archived_count
    FROM orders
    WHERE order_date < v_cutoff_date
        AND order_status IN ('completed', 'shipped', 'cancelled');
    
    -- Mark orders as archived (add archived flag or move to archive table)
    UPDATE orders
    SET order_status = 'archived'
    WHERE order_date < v_cutoff_date
        AND order_status IN ('completed', 'shipped', 'cancelled');
    
    COMMIT;
END //

DELIMITER ;

-- ============================================================================
-- PROCEDURE 8: Get Top Products by Revenue
-- ============================================================================
DELIMITER //

CREATE PROCEDURE GetTopProductsByRevenue(
    IN p_limit INT DEFAULT 10,
    IN p_period_days INT DEFAULT 30
)
READS SQL DATA
BEGIN
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        COUNT(DISTINCT oi.order_id) AS sales_count,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.subtotal) AS total_revenue,
        AVG(oi.unit_price) AS avg_price
    FROM products p
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    LEFT JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= DATE_SUB(NOW(), INTERVAL p_period_days DAY)
        OR o.order_id IS NULL
    GROUP BY p.product_id, p.product_name, p.category
    ORDER BY total_revenue DESC
    LIMIT p_limit;
END //

DELIMITER ;

-- ============================================================================
-- PROCEDURE 9: Customer Activity Log
-- ============================================================================
DELIMITER //

CREATE PROCEDURE LogCustomerActivity(
    IN p_customer_id INT,
    IN p_activity_type VARCHAR(30),
    IN p_description VARCHAR(255),
    IN p_ip_address VARCHAR(15),
    OUT p_success BOOLEAN
)
MODIFIES SQL DATA
BEGIN
    START TRANSACTION;
    
    INSERT INTO customer_activity (
        customer_id,
        activity_type,
        activity_description,
        ip_address,
        created_at
    ) VALUES (
        p_customer_id,
        p_activity_type,
        p_description,
        p_ip_address,
        NOW()
    );
    
    SET p_success = TRUE;
    COMMIT;
END //

DELIMITER ;

-- ============================================================================
-- Procedure Verification
-- ============================================================================
SHOW PROCEDURE STATUS WHERE Db = 'ecommerce';

-- ============================================================================
-- Usage Examples (Commented)
-- ============================================================================
/*
-- Get customer order history
CALL GetCustomerOrderHistory(1, 5);

-- Create new order
CALL CreateNewOrder(1, 'credit_card', @order_id, @message);
SELECT @order_id, @message;

-- Add item to order
CALL AddItemToOrder(@order_id, 1, 2, @success, @msg);
SELECT @success, @msg;

-- Complete order
CALL CompleteOrder(@order_id, @success, @msg);
SELECT @success, @msg;

-- Update stock
CALL UpdateProductStock(1, -5, @success, @msg);
SELECT @success, @msg;

-- Generate sales report
CALL GenerateSalesReport('2026-01-01', '2026-12-31');

-- Get top products
CALL GetTopProductsByRevenue(10, 30);

-- Log activity
CALL LogCustomerActivity(1, 'login', 'User logged in', '192.168.1.1', @success);
SELECT @success;
*/

SELECT 'All stored procedures created successfully!' AS status;
