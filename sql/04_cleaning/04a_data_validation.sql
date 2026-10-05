USE olist_ecommerce;

/* =====================================================================
   04a_data_validation.sql
   Olist E-Commerce | Data Validation (READ-ONLY, nothing is changed)

   When to run
   - BEFORE cleaning (04b-04d): finds the problems that need fixing.
   - AFTER  cleaning (04f):     confirms the problems are gone.
   Section 11 (scoreboard) gives a one-table PASS / FAIL / INFO summary.

   Sections
    1. Row counts                    7. Business-rule checks (dates)
    2. Date range and order status   8. Referential integrity (orphans)
    3. Duplicate checks              9. Payments vs items reconciliation
    4. NULL checks                  10. Dataset summary
    5. Blank / whitespace checks    11. VALIDATION SCOREBOARD
    6. Value validity checks
   ===================================================================== */


/* =====================================================================
   1. ROW COUNTS
   ===================================================================== */
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'orders',               COUNT(*) FROM orders
UNION ALL SELECT 'order_items',          COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments',       COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews',        COUNT(*) FROM order_reviews
UNION ALL SELECT 'products',             COUNT(*) FROM products
UNION ALL SELECT 'sellers',              COUNT(*) FROM sellers
UNION ALL SELECT 'geolocation',          COUNT(*) FROM geolocation
UNION ALL SELECT 'category_translation', COUNT(*) FROM category_translation;


/* =====================================================================
   2. DATE RANGE AND ORDER STATUS
   ===================================================================== */

-- 2a. Date coverage (2016 and late 2018 are known to be incomplete)
SELECT
    MIN(order_purchase_timestamp) AS first_order,
    MAX(order_purchase_timestamp) AS last_order,
    COUNT(DISTINCT DATE_FORMAT(order_purchase_timestamp, '%Y-%m')) AS months_covered
FROM orders;

-- 2b. Orders per month (look for months with very few orders)
SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(*) AS orders
FROM orders
GROUP BY order_month
ORDER BY order_month;

-- 2c. Order status distribution with percentage
SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM orders), 2) AS pct_of_orders
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


/* =====================================================================
   3. DUPLICATE CHECKS (every query should return 0 rows)
   ===================================================================== */

-- 3a. Duplicate primary keys
SELECT 'customers' AS table_name, customer_id AS duplicate_key, COUNT(*) AS duplicate_count
FROM customers GROUP BY customer_id HAVING COUNT(*) > 1
UNION ALL
SELECT 'orders', order_id, COUNT(*)
FROM orders GROUP BY order_id HAVING COUNT(*) > 1
UNION ALL
SELECT 'products', product_id, COUNT(*)
FROM products GROUP BY product_id HAVING COUNT(*) > 1
UNION ALL
SELECT 'sellers', seller_id, COUNT(*)
FROM sellers GROUP BY seller_id HAVING COUNT(*) > 1;

-- 3b. Duplicate composite keys
SELECT 'order_items' AS table_name, CONCAT(order_id, ' / ', order_item_id) AS duplicate_key, COUNT(*) AS duplicate_count
FROM order_items GROUP BY order_id, order_item_id HAVING COUNT(*) > 1
UNION ALL
SELECT 'order_payments', CONCAT(order_id, ' / ', payment_sequential), COUNT(*)
FROM order_payments GROUP BY order_id, payment_sequential HAVING COUNT(*) > 1;

-- 3c. Reviews: repeated review_id and orders with more than one review
--     (known issue in Olist; fixed in 04c by keeping the latest review per order)
SELECT 'repeated review_id' AS issue, COUNT(*) AS affected
FROM (SELECT review_id FROM order_reviews GROUP BY review_id HAVING COUNT(*) > 1) t
UNION ALL
SELECT 'orders with multiple reviews', COUNT(*)
FROM (SELECT order_id FROM order_reviews GROUP BY order_id HAVING COUNT(*) > 1) t;

-- 3d. Geolocation: many rows per ZIP prefix (known issue; fixed in 04c)
SELECT
    COUNT(*) AS geolocation_rows,
    COUNT(DISTINCT geolocation_zip_code_prefix) AS distinct_zip_prefixes,
    COUNT(*) - COUNT(DISTINCT geolocation_zip_code_prefix) AS redundant_rows
FROM geolocation;

-- 3e. Customer identity: customer_id is per order, customer_unique_id is per person
SELECT
    COUNT(DISTINCT customer_id)        AS distinct_customer_ids,
    COUNT(DISTINCT customer_unique_id) AS distinct_real_customers
FROM customers;


/* =====================================================================
   4. NULL CHECKS
   ===================================================================== */

-- 4a. Customers
SELECT
    COUNT(*) AS total_rows,
    SUM(customer_id IS NULL)              AS missing_customer_id,
    SUM(customer_unique_id IS NULL)       AS missing_unique_customer_id,
    SUM(customer_zip_code_prefix IS NULL) AS missing_zip_code,
    SUM(customer_city IS NULL)            AS missing_city,
    SUM(customer_state IS NULL)           AS missing_state
FROM customers;

-- 4b. Orders (missing delivery dates are normal for undelivered orders)
SELECT
    COUNT(*) AS total_rows,
    SUM(order_id IS NULL)                       AS missing_order_id,
    SUM(customer_id IS NULL)                    AS missing_customer_id,
    SUM(order_status IS NULL)                   AS missing_status,
    SUM(order_purchase_timestamp IS NULL)       AS missing_purchase_date,
    SUM(order_approved_at IS NULL)              AS missing_approval_date,
    SUM(order_delivered_carrier_date IS NULL)   AS missing_carrier_date,
    SUM(order_delivered_customer_date IS NULL)  AS missing_delivery_date,
    SUM(order_estimated_delivery_date IS NULL)  AS missing_estimated_date
FROM orders;

-- 4c. Order items
SELECT
    COUNT(*) AS total_rows,
    SUM(order_id IS NULL)      AS missing_order_id,
    SUM(product_id IS NULL)    AS missing_product_id,
    SUM(seller_id IS NULL)     AS missing_seller_id,
    SUM(price IS NULL)         AS missing_price,
    SUM(freight_value IS NULL) AS missing_freight
FROM order_items;

-- 4d. Products
SELECT
    COUNT(*) AS total_rows,
    SUM(product_id IS NULL)                  AS missing_product_id,
    SUM(product_category_name IS NULL)       AS missing_category,
    SUM(product_name_length IS NULL)         AS missing_name_length,
    SUM(product_description_length IS NULL)  AS missing_description_length,
    SUM(product_photos_qty IS NULL)          AS missing_photos,
    SUM(product_weight_g IS NULL)            AS missing_weight,
    SUM(product_length_cm IS NULL)           AS missing_length,
    SUM(product_height_cm IS NULL)           AS missing_height,
    SUM(product_width_cm IS NULL)            AS missing_width
FROM products;

-- 4e. Payments
SELECT
    COUNT(*) AS total_rows,
    SUM(order_id IS NULL)              AS missing_order_id,
    SUM(payment_type IS NULL)          AS missing_payment_type,
    SUM(payment_installments IS NULL)  AS missing_installments,
    SUM(payment_value IS NULL)         AS missing_payment_value
FROM order_payments;

-- 4f. Reviews (missing comments are normal)
SELECT
    COUNT(*) AS total_rows,
    SUM(review_id IS NULL)                AS missing_review_id,
    SUM(order_id IS NULL)                 AS missing_order_id,
    SUM(review_score IS NULL)             AS missing_review_score,
    SUM(review_creation_date IS NULL)     AS missing_creation_date,
    SUM(review_answer_timestamp IS NULL)  AS missing_answer_date
FROM order_reviews;

-- 4g. Sellers and geolocation
SELECT
    (SELECT SUM(seller_id IS NULL OR seller_state IS NULL OR seller_city IS NULL) FROM sellers)
        AS sellers_with_missing_values,
    (SELECT SUM(geolocation_lat IS NULL OR geolocation_lng IS NULL) FROM geolocation)
        AS geolocation_missing_coordinates;


/* =====================================================================
   5. BLANK / WHITESPACE CHECKS
   Empty strings look like data but behave like NULLs.
   ===================================================================== */
SELECT
    (SELECT COUNT(*) FROM products
      WHERE product_category_name IS NOT NULL AND TRIM(product_category_name) = '')
        AS blank_product_category,
    (SELECT COUNT(*) FROM customers
      WHERE customer_city <> TRIM(customer_city) OR customer_state <> TRIM(customer_state))
        AS customers_with_extra_spaces,
    (SELECT COUNT(*) FROM sellers
      WHERE seller_city <> TRIM(seller_city) OR seller_state <> TRIM(seller_state))
        AS sellers_with_extra_spaces,
    (SELECT COUNT(*) FROM orders
      WHERE order_status <> LOWER(TRIM(order_status)))
        AS status_not_standardized;


/* =====================================================================
   6. VALUE VALIDITY CHECKS
   ===================================================================== */

-- 6a. Invalid review scores (expected: 0 rows)
SELECT * FROM order_reviews WHERE review_score NOT BETWEEN 1 AND 5;

-- 6b. Zero or negative prices (expected: 0 rows)
SELECT * FROM order_items WHERE price <= 0;

-- 6c. Negative freight (expected: 0 rows)
SELECT * FROM order_items WHERE freight_value < 0;

-- 6d. Zero or negative payments (a few 'not_defined' rows are known; removed in 04d)
SELECT * FROM order_payments WHERE payment_value <= 0;

-- 6e. Installment range (minimum should be 1)
SELECT
    MIN(payment_installments) AS minimum_installments,
    MAX(payment_installments) AS maximum_installments
FROM order_payments;

-- 6f. Payment types in use (look for 'not_defined')
SELECT payment_type, COUNT(*) AS payments, ROUND(SUM(payment_value), 2) AS total_value
FROM order_payments
GROUP BY payment_type
ORDER BY payments DESC;

-- 6g. State codes that are not exactly 2 letters (expected: 0 rows)
SELECT 'customers' AS table_name, customer_state AS state_value, COUNT(*) AS rows_affected
FROM customers WHERE customer_state IS NULL OR CHAR_LENGTH(TRIM(customer_state)) <> 2
GROUP BY customer_state
UNION ALL
SELECT 'sellers', seller_state, COUNT(*)
FROM sellers WHERE seller_state IS NULL OR CHAR_LENGTH(TRIM(seller_state)) <> 2
GROUP BY seller_state;

-- 6h. Product dimension sanity (zero or negative values)
SELECT
    SUM(product_weight_g <= 0) AS non_positive_weight,
    SUM(product_length_cm <= 0 OR product_height_cm <= 0 OR product_width_cm <= 0) AS non_positive_dimensions
FROM products;


/* =====================================================================
   7. BUSINESS-RULE CHECKS (date logic)
   ===================================================================== */
SELECT 'approved before purchase' AS check_name, COUNT(*) AS issue_count
FROM orders WHERE order_approved_at < order_purchase_timestamp
UNION ALL
SELECT 'carrier pickup before approval', COUNT(*)
FROM orders WHERE order_delivered_carrier_date < order_approved_at
UNION ALL
SELECT 'delivered before carrier pickup', COUNT(*)
FROM orders WHERE order_delivered_customer_date < order_delivered_carrier_date
UNION ALL
SELECT 'delivered before purchase', COUNT(*)
FROM orders WHERE order_delivered_customer_date < order_purchase_timestamp
UNION ALL
SELECT 'estimated delivery before purchase', COUNT(*)
FROM orders WHERE order_estimated_delivery_date < order_purchase_timestamp
UNION ALL
SELECT 'delivered status but no delivery date', COUNT(*)
FROM orders WHERE order_status = 'delivered' AND order_delivered_customer_date IS NULL
UNION ALL
SELECT 'has delivery date but status not delivered', COUNT(*)
FROM orders WHERE order_status <> 'delivered' AND order_delivered_customer_date IS NOT NULL;


/* =====================================================================
   8. REFERENTIAL INTEGRITY (ORPHAN CHECKS)
   ===================================================================== */
SELECT 'order_items without order' AS check_name, COUNT(*) AS orphan_count
FROM order_items oi LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'order_items without product', COUNT(*)
FROM order_items oi LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL
UNION ALL
SELECT 'order_items without seller', COUNT(*)
FROM order_items oi LEFT JOIN sellers s ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL
UNION ALL
SELECT 'orders without customer', COUNT(*)
FROM orders o LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT 'payments without order', COUNT(*)
FROM order_payments op LEFT JOIN orders o ON op.order_id = o.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'reviews without order', COUNT(*)
FROM order_reviews r LEFT JOIN orders o ON r.order_id = o.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'product categories without English name', COUNT(DISTINCT p.product_category_name)
FROM products p LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL AND t.product_category_name IS NULL
UNION ALL
SELECT 'orders without items (canceled/unavailable are normal)', COUNT(*)
FROM orders o LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;


/* =====================================================================
   9. PAYMENTS VS ITEMS RECONCILIATION
   Order total (price + freight) should be close to the amount paid.
   Small differences (vouchers, rounding) are normal; large ones are not.
   ===================================================================== */
SELECT
    COUNT(*) AS orders_compared,
    SUM(ABS(i.items_total - p.paid_total) > 1) AS orders_off_by_more_than_1,
    ROUND(100 * SUM(ABS(i.items_total - p.paid_total) > 1) / COUNT(*), 2) AS pct_off
FROM (
    SELECT order_id, SUM(price + freight_value) AS items_total
    FROM order_items GROUP BY order_id
) i
JOIN (
    SELECT order_id, SUM(payment_value) AS paid_total
    FROM order_payments GROUP BY order_id
) p ON p.order_id = i.order_id;


/* =====================================================================
   10. DATASET SUMMARY
   ===================================================================== */
SELECT
    (SELECT COUNT(*) FROM customers)                        AS customer_rows,
    (SELECT COUNT(DISTINCT customer_unique_id) FROM customers) AS unique_customers,
    (SELECT COUNT(*) FROM orders)                           AS orders,
    (SELECT COUNT(*) FROM order_items)                      AS order_items,
    (SELECT COUNT(*) FROM order_payments)                   AS payments,
    (SELECT COUNT(*) FROM order_reviews)                    AS reviews,
    (SELECT COUNT(*) FROM products)                         AS products,
    (SELECT COUNT(*) FROM sellers)                          AS sellers;


/* =====================================================================
   11. VALIDATION SCOREBOARD
   One table with every key check.
   PASS = 0 issues | FAIL = needs fixing | INFO = expected, for awareness.
   Before cleaning, these usually FAIL: multiple reviews per order,
   geolocation duplicates, non-positive payments, installments below 1,
   untranslated categories. After 04b-04d they should all show PASS.
   ===================================================================== */
SELECT check_name, issue_count,
       CASE
           WHEN severity = 'INFO' THEN 'INFO'
           WHEN issue_count = 0   THEN 'PASS'
           ELSE 'FAIL'
       END AS status
FROM (
    SELECT 'Duplicate customer_id' AS check_name, 'MUST' AS severity,
           (SELECT COUNT(*) FROM (SELECT customer_id FROM customers GROUP BY customer_id HAVING COUNT(*) > 1) t) AS issue_count
    UNION ALL SELECT 'Duplicate order_id', 'MUST',
           (SELECT COUNT(*) FROM (SELECT order_id FROM orders GROUP BY order_id HAVING COUNT(*) > 1) t)
    UNION ALL SELECT 'Duplicate product_id', 'MUST',
           (SELECT COUNT(*) FROM (SELECT product_id FROM products GROUP BY product_id HAVING COUNT(*) > 1) t)
    UNION ALL SELECT 'Duplicate seller_id', 'MUST',
           (SELECT COUNT(*) FROM (SELECT seller_id FROM sellers GROUP BY seller_id HAVING COUNT(*) > 1) t)
    UNION ALL SELECT 'Duplicate order_items key', 'MUST',
           (SELECT COUNT(*) FROM (SELECT order_id, order_item_id FROM order_items GROUP BY order_id, order_item_id HAVING COUNT(*) > 1) t)
    UNION ALL SELECT 'Orders with multiple reviews', 'MUST',
           (SELECT COUNT(*) FROM (SELECT order_id FROM order_reviews GROUP BY order_id HAVING COUNT(*) > 1) t)
    UNION ALL SELECT 'Redundant geolocation rows', 'MUST',
           (SELECT COUNT(*) - COUNT(DISTINCT geolocation_zip_code_prefix) FROM geolocation)
    UNION ALL SELECT 'Invalid review scores', 'MUST',
           (SELECT COUNT(*) FROM order_reviews WHERE review_score NOT BETWEEN 1 AND 5)
    UNION ALL SELECT 'Price <= 0', 'MUST',
           (SELECT COUNT(*) FROM order_items WHERE price <= 0)
    UNION ALL SELECT 'Freight < 0', 'MUST',
           (SELECT COUNT(*) FROM order_items WHERE freight_value < 0)
    UNION ALL SELECT 'Payment value <= 0', 'MUST',
           (SELECT COUNT(*) FROM order_payments WHERE payment_value <= 0)
    UNION ALL SELECT 'Installments < 1', 'MUST',
           (SELECT COUNT(*) FROM order_payments WHERE payment_installments < 1)
    UNION ALL SELECT 'Approved before purchase', 'MUST',
           (SELECT COUNT(*) FROM orders WHERE order_approved_at < order_purchase_timestamp)
    UNION ALL SELECT 'Delivered before purchase', 'MUST',
           (SELECT COUNT(*) FROM orders WHERE order_delivered_customer_date < order_purchase_timestamp)
    UNION ALL SELECT 'Delivered status without delivery date', 'MUST',
           (SELECT COUNT(*) FROM orders WHERE order_status = 'delivered' AND order_delivered_customer_date IS NULL)
    UNION ALL SELECT 'Order items without order', 'MUST',
           (SELECT COUNT(*) FROM order_items oi LEFT JOIN orders o ON oi.order_id = o.order_id WHERE o.order_id IS NULL)
    UNION ALL SELECT 'Order items without product', 'MUST',
           (SELECT COUNT(*) FROM order_items oi LEFT JOIN products p ON oi.product_id = p.product_id WHERE p.product_id IS NULL)
    UNION ALL SELECT 'Order items without seller', 'MUST',
           (SELECT COUNT(*) FROM order_items oi LEFT JOIN sellers s ON oi.seller_id = s.seller_id WHERE s.seller_id IS NULL)
    UNION ALL SELECT 'Orders without customer', 'MUST',
           (SELECT COUNT(*) FROM orders o LEFT JOIN customers c ON o.customer_id = c.customer_id WHERE c.customer_id IS NULL)
    UNION ALL SELECT 'Payments without order', 'MUST',
           (SELECT COUNT(*) FROM order_payments op LEFT JOIN orders o ON op.order_id = o.order_id WHERE o.order_id IS NULL)
    UNION ALL SELECT 'Reviews without order', 'MUST',
           (SELECT COUNT(*) FROM order_reviews r LEFT JOIN orders o ON r.order_id = o.order_id WHERE o.order_id IS NULL)
    UNION ALL SELECT 'Categories without English name', 'MUST',
           (SELECT COUNT(DISTINCT p.product_category_name) FROM products p
              LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
             WHERE p.product_category_name IS NOT NULL AND t.product_category_name IS NULL)
    UNION ALL SELECT 'Products with missing category', 'INFO',
           (SELECT COUNT(*) FROM products WHERE product_category_name IS NULL OR TRIM(product_category_name) = '')
    UNION ALL SELECT 'Orders without items (canceled/unavailable)', 'INFO',
           (SELECT COUNT(*) FROM orders o LEFT JOIN order_items oi ON o.order_id = oi.order_id WHERE oi.order_id IS NULL)
) checks
ORDER BY FIELD(CASE WHEN severity = 'INFO' THEN 'INFO' WHEN issue_count = 0 THEN 'PASS' ELSE 'FAIL' END,
               'FAIL', 'INFO', 'PASS'),
         check_name;