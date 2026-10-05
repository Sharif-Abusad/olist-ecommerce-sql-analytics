/* =====================================================================
   OLIST E-COMMERCE  |  04b_clean_data_types.sql
   Covers: Section 0 (backups + BEFORE counts), Section 1 (date types),
           Section 2 (standardize text)
   Run order: 1 of 5  (run after 04_data_validation.sql)
   ===================================================================== */

USE olist_ecommerce;
SET SQL_SAFE_UPDATES = 0;

/* ---------------------------------------------------------------------
   SECTION 0. BACKUPS + ROW COUNT SNAPSHOT (before cleaning)
   --------------------------------------------------------------------- */
CREATE TABLE IF NOT EXISTS products_backup             AS SELECT * FROM products;
CREATE TABLE IF NOT EXISTS order_payments_backup       AS SELECT * FROM order_payments;
CREATE TABLE IF NOT EXISTS category_translation_backup AS SELECT * FROM category_translation;

SELECT 'BEFORE' AS stage, 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'BEFORE', 'orders',         COUNT(*) FROM orders
UNION ALL SELECT 'BEFORE', 'order_items',    COUNT(*) FROM order_items
UNION ALL SELECT 'BEFORE', 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'BEFORE', 'order_reviews',  COUNT(*) FROM order_reviews
UNION ALL SELECT 'BEFORE', 'products',       COUNT(*) FROM products
UNION ALL SELECT 'BEFORE', 'sellers',        COUNT(*) FROM sellers
UNION ALL SELECT 'BEFORE', 'geolocation',    COUNT(*) FROM geolocation;


/* ---------------------------------------------------------------------
   SECTION 1. FIX DATE / TIME DATA TYPES
   If a date column was imported as text, empty strings become NULL and the
   column is converted to DATETIME. If it is already DATETIME, nothing changes.
   --------------------------------------------------------------------- */
DROP PROCEDURE IF EXISTS sp_to_datetime;
DELIMITER $$
CREATE PROCEDURE sp_to_datetime(IN p_table VARCHAR(64), IN p_col VARCHAR(64))
BEGIN
    DECLARE v_type VARCHAR(30);

    SELECT DATA_TYPE INTO v_type
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = p_table
      AND COLUMN_NAME  = p_col;

    IF v_type IN ('varchar','char','text','tinytext','mediumtext','longtext') THEN
        SET @s = CONCAT('UPDATE `', p_table, '` SET `', p_col, '` = NULL WHERE TRIM(`', p_col, '`) = ''''');
        PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;

        SET @s = CONCAT('ALTER TABLE `', p_table, '` MODIFY `', p_col, '` DATETIME NULL');
        PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
    END IF;
END$$
DELIMITER ;

CALL sp_to_datetime('orders', 'order_purchase_timestamp');
CALL sp_to_datetime('orders', 'order_approved_at');
CALL sp_to_datetime('orders', 'order_delivered_carrier_date');
CALL sp_to_datetime('orders', 'order_delivered_customer_date');
CALL sp_to_datetime('orders', 'order_estimated_delivery_date');
CALL sp_to_datetime('order_items', 'shipping_limit_date');
CALL sp_to_datetime('order_reviews', 'review_creation_date');
CALL sp_to_datetime('order_reviews', 'review_answer_timestamp');

DROP PROCEDURE IF EXISTS sp_to_datetime;

-- Check: all date columns should now show datetime
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND (COLUMN_NAME LIKE '%date%' OR COLUMN_NAME LIKE '%timestamp%' OR COLUMN_NAME LIKE '%\_at')
ORDER BY TABLE_NAME, COLUMN_NAME;


/* ---------------------------------------------------------------------
   SECTION 2. STANDARDIZE TEXT (trim spaces, consistent case)
   --------------------------------------------------------------------- */
UPDATE customers
SET customer_city  = LOWER(TRIM(customer_city)),
    customer_state = UPPER(TRIM(customer_state));

UPDATE sellers
SET seller_city  = LOWER(TRIM(seller_city)),
    seller_state = UPPER(TRIM(seller_state));

UPDATE orders
SET order_status = LOWER(TRIM(order_status));

UPDATE order_payments
SET payment_type = LOWER(TRIM(payment_type));

SET SQL_SAFE_UPDATES = 1;
