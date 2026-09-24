USE olist_ecommerce;

-- ============================================================
-- 04_data_validation.sql
-- Olist E-Commerce Data Validation
-- ============================================================


-- ============================================================
-- 1. ROW COUNT VALIDATION
-- ============================================================

SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL
SELECT 'category_translation', COUNT(*) FROM category_translation;


-- ============================================================
-- 2. CHECK DUPLICATE PRIMARY KEYS
-- ============================================================

-- Customers
SELECT customer_id, COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- Orders
SELECT order_id, COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- Products
SELECT product_id, COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- Sellers
SELECT seller_id, COUNT(*) AS duplicate_count
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 3. CHECK NULL VALUES - CUSTOMERS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(customer_unique_id IS NULL) AS missing_unique_customer_id,
    SUM(customer_zip_code_prefix IS NULL) AS missing_zip_code,
    SUM(customer_city IS NULL) AS missing_city,
    SUM(customer_state IS NULL) AS missing_state
FROM customers;


-- ============================================================
-- 4. CHECK NULL VALUES - ORDERS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(order_status IS NULL) AS missing_status,
    SUM(order_purchase_timestamp IS NULL) AS missing_purchase_date,
    SUM(order_approved_at IS NULL) AS missing_approval_date,
    SUM(order_delivered_carrier_date IS NULL) AS missing_carrier_date,
    SUM(order_delivered_customer_date IS NULL) AS missing_delivery_date,
    SUM(order_estimated_delivery_date IS NULL) AS missing_estimated_date
FROM orders;


-- ============================================================
-- 5. CHECK NULL VALUES - ORDER ITEMS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(product_id IS NULL) AS missing_product_id,
    SUM(seller_id IS NULL) AS missing_seller_id,
    SUM(price IS NULL) AS missing_price,
    SUM(freight_value IS NULL) AS missing_freight
FROM order_items;


-- ============================================================
-- 6. CHECK NULL VALUES - PRODUCTS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    SUM(product_id IS NULL) AS missing_product_id,
    SUM(product_category_name IS NULL) AS missing_category,
    SUM(product_name_length IS NULL) AS missing_name_length,
    SUM(product_description_length IS NULL) AS missing_description_length,
    SUM(product_photos_qty IS NULL) AS missing_photos,
    SUM(product_weight_g IS NULL) AS missing_weight,
    SUM(product_length_cm IS NULL) AS missing_length,
    SUM(product_height_cm IS NULL) AS missing_height,
    SUM(product_width_cm IS NULL) AS missing_width
FROM products;


-- ============================================================
-- 7. CHECK NULL VALUES - PAYMENTS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(payment_type IS NULL) AS missing_payment_type,
    SUM(payment_installments IS NULL) AS missing_installments,
    SUM(payment_value IS NULL) AS missing_payment_value
FROM order_payments;


-- ============================================================
-- 8. CHECK NULL VALUES - REVIEWS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    SUM(review_id IS NULL) AS missing_review_id,
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(review_score IS NULL) AS missing_review_score,
    SUM(review_creation_date IS NULL) AS missing_creation_date,
    SUM(review_answer_timestamp IS NULL) AS missing_answer_date
FROM order_reviews;


-- ============================================================
-- 9. CHECK INVALID ORDER STATUS
-- ============================================================

SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- ============================================================
-- 10. FIND INVALID REVIEW SCORES
-- ============================================================

SELECT *
FROM order_reviews
WHERE review_score NOT BETWEEN 1 AND 5;


-- ============================================================
-- 11. CHECK NEGATIVE / ZERO PRICES
-- ============================================================

SELECT *
FROM order_items
WHERE price <= 0;


-- ============================================================
-- 12. CHECK NEGATIVE FREIGHT VALUES
-- ============================================================

SELECT *
FROM order_items
WHERE freight_value < 0;


-- ============================================================
-- 13. CHECK NEGATIVE PAYMENT VALUES
-- ============================================================

SELECT *
FROM order_payments
WHERE payment_value <= 0;


-- ============================================================
-- 14. CHECK PAYMENT INSTALLMENTS
-- ============================================================

SELECT
    MIN(payment_installments) AS minimum_installments,
    MAX(payment_installments) AS maximum_installments
FROM order_payments;


-- ============================================================
-- 15. CHECK INVALID ORDER DATES
-- ============================================================

SELECT *
FROM orders
WHERE order_approved_at < order_purchase_timestamp;


-- ============================================================
-- 16. CHECK ORPHAN ORDER ITEMS
-- ============================================================

SELECT COUNT(*) AS orphan_order_items
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- ============================================================
-- 17. CHECK ORPHAN PRODUCTS
-- ============================================================

SELECT COUNT(*) AS orphan_products
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- ============================================================
-- 18. CHECK ORPHAN SELLERS
-- ============================================================

SELECT COUNT(*) AS orphan_sellers
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


-- ============================================================
-- 19. CHECK ORPHAN CUSTOMERS
-- ============================================================

SELECT COUNT(*) AS orphan_customers
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- ============================================================
-- 20. FINAL DATASET SUMMARY
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM customers) AS customers,
    (SELECT COUNT(*) FROM orders) AS orders,
    (SELECT COUNT(*) FROM order_items) AS order_items,
    (SELECT COUNT(*) FROM order_payments) AS payments,
    (SELECT COUNT(*) FROM order_reviews) AS reviews,
    (SELECT COUNT(*) FROM products) AS products,
    (SELECT COUNT(*) FROM sellers) AS sellers;