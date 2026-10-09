/* =====================================================================
   OLIST E-COMMERCE  |  04e_data_quality_checks.sql
   Covers: Section 6 (check for bad records)
   Run order: 4 of 5
   This file only READS data. Nothing is changed or deleted.
   ===================================================================== */

USE olist_ecommerce;

/* ---------------------------------------------------------------------
   SECTION 6. CHECK FOR BAD RECORDS (review the results)
   --------------------------------------------------------------------- */

-- 6a. Invalid prices / freight (expected: 0)
SELECT COUNT(*) AS bad_price_or_freight
FROM order_items
WHERE price <= 0 OR freight_value < 0;

-- 6b. Illogical dates: delivered before purchase (expected: 0 or very few)
SELECT COUNT(*) AS delivered_before_purchase
FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp;

-- 6c. Orphan records (all should be 0, except "orders without items")
SELECT 'items without order' AS chk, COUNT(*) AS cnt
FROM order_items oi LEFT JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'items without product', COUNT(*)
FROM order_items oi LEFT JOIN products p ON p.product_id = oi.product_id
WHERE p.product_id IS NULL
UNION ALL
SELECT 'items without seller', COUNT(*)
FROM order_items oi LEFT JOIN sellers s ON s.seller_id = oi.seller_id
WHERE s.seller_id IS NULL
UNION ALL
SELECT 'orders without customer', COUNT(*)
FROM orders o LEFT JOIN customers c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT 'payments without order', COUNT(*)
FROM order_payments op LEFT JOIN orders o ON o.order_id = op.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'reviews without order', COUNT(*)
FROM order_reviews r LEFT JOIN orders o ON o.order_id = r.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'orders without items (canceled/unavailable, OK)', COUNT(*)
FROM orders o LEFT JOIN order_items oi ON oi.order_id = o.order_id
WHERE oi.order_id IS NULL;
