USE olist_ecommerce;

-- ============================================================
-- 10_query_optimization.sql
-- Olist E-Commerce Query Optimization
-- ============================================================


-- ============================================================
-- 1. CHECK EXISTING INDEXES
-- ============================================================

SHOW INDEX FROM customers;
SHOW INDEX FROM orders;
SHOW INDEX FROM order_items;
SHOW INDEX FROM order_payments;
SHOW INDEX FROM products;
SHOW INDEX FROM sellers;


-- ============================================================
-- 2. INDEX FOR CUSTOMER LOOKUPS
-- ============================================================

CREATE INDEX idx_customers_unique_id
ON customers(customer_unique_id);


-- ============================================================
-- 3. INDEX FOR ORDER-CUSTOMER JOINS
-- ============================================================

CREATE INDEX idx_orders_customer_id
ON orders(customer_id);


-- ============================================================
-- 4. INDEX FOR ORDER PURCHASE DATE
-- Useful for monthly/yearly sales analysis.
-- ============================================================

CREATE INDEX idx_orders_purchase_date
ON orders(order_purchase_timestamp);


-- ============================================================
-- 5. INDEX FOR ORDER STATUS
-- Useful for filtering orders by status.
-- ============================================================

CREATE INDEX idx_orders_status
ON orders(order_status);


-- ============================================================
-- 6. INDEX FOR PRODUCT LOOKUPS
-- ============================================================

CREATE INDEX idx_order_items_product_id
ON order_items(product_id);


-- ============================================================
-- 7. INDEX FOR SELLER ANALYSIS
-- ============================================================

CREATE INDEX idx_order_items_seller_id
ON order_items(seller_id);


-- ============================================================
-- 8. INDEX FOR ORDER REVIEWS
-- ============================================================

CREATE INDEX idx_reviews_order_id
ON order_reviews(order_id);


-- ============================================================
-- 9. INDEX FOR PAYMENT ANALYSIS
-- ============================================================

CREATE INDEX idx_payments_order_id
ON order_payments(order_id);


-- ============================================================
-- 10. INDEX FOR PRODUCT CATEGORY ANALYSIS
-- ============================================================

CREATE INDEX idx_products_category
ON products(product_category_name);


-- ============================================================
-- 11. VERIFY CREATED INDEXES
-- ============================================================

SHOW INDEX FROM orders;
SHOW INDEX FROM order_items;
SHOW INDEX FROM order_reviews;
SHOW INDEX FROM products;


-- ============================================================
-- 12. QUERY EXECUTION PLAN - BEFORE/AFTER INDEXING
-- ============================================================

EXPLAIN
SELECT
    customer_id,
    order_id,
    order_status,
    order_purchase_timestamp
FROM orders
WHERE customer_id = 'example_customer_id';


-- ============================================================
-- 13. QUERY USING PURCHASE DATE
-- ============================================================

EXPLAIN
SELECT
    DATE(order_purchase_timestamp) AS order_date,
    COUNT(*) AS total_orders
FROM orders
WHERE order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp < '2018-01-01'
GROUP BY DATE(order_purchase_timestamp);


-- ============================================================
-- 14. QUERY USING ORDER STATUS
-- ============================================================

EXPLAIN
SELECT
    order_id,
    customer_id,
    order_purchase_timestamp
FROM orders
WHERE order_status = 'delivered';


-- ============================================================
-- 15. QUERY USING PRODUCT CATEGORY
-- ============================================================

EXPLAIN
SELECT
    product_id,
    product_category_name
FROM products
WHERE product_category_name = 'beleza_saude';


-- ============================================================
-- 16. COMPOSITE INDEX FOR ORDER ANALYSIS
-- Useful when filtering by customer and ordering by date.
-- ============================================================

CREATE INDEX idx_orders_customer_date
ON orders(customer_id, order_purchase_timestamp);


-- ============================================================
-- 17. VERIFY COMPOSITE INDEX
-- ============================================================

SHOW INDEX FROM orders;


-- ============================================================
-- 18. TEST COMPOSITE INDEX
-- ============================================================

EXPLAIN
SELECT
    order_id,
    order_status,
    order_purchase_timestamp
FROM orders
WHERE customer_id = 'example_customer_id'
ORDER BY order_purchase_timestamp DESC;


-- ============================================================
-- 19. CHECK TABLE SIZE
-- ============================================================

SELECT
    table_name,
    table_rows,
    ROUND(data_length / 1024 / 1024, 2) AS data_size_mb,
    ROUND(index_length / 1024 / 1024, 2) AS index_size_mb
FROM information_schema.tables
WHERE table_schema = 'olist_ecommerce'
ORDER BY data_length DESC;


-- ============================================================
-- 20. FINAL INDEX SUMMARY
-- ============================================================

SELECT
    table_name,
    index_name,
    column_name,
    seq_in_index
FROM information_schema.statistics
WHERE table_schema = 'olist_ecommerce'
ORDER BY table_name, index_name, seq_in_index;