/* =====================================================================
   OLIST E-COMMERCE  |  04f_create_analysis_views.sql
   Covers: Section 7 (analysis-ready view), Section 8 (final validation)
   Run order: 5 of 5 (run last)
   ===================================================================== */

USE olist_ecommerce;

/* ---------------------------------------------------------------------
   SECTION 7. ANALYSIS-READY VIEW (load this in Power BI)
   - Limits to Jan 2017 - Aug 2018 (2016 and late 2018 are incomplete)
   - Adds customer_unique_id and customer_state
   - Adds delivery_days, delay_days, is_late (only for valid delivered orders)
   Change the dates below if you want a different range.
   --------------------------------------------------------------------- */
CREATE OR REPLACE VIEW v_orders_clean AS
SELECT
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    c.customer_state,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    CASE WHEN o.order_status = 'delivered'
          AND o.order_delivered_customer_date >= o.order_purchase_timestamp
         THEN DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)
    END AS delivery_days,
    CASE WHEN o.order_status = 'delivered'
          AND o.order_delivered_customer_date IS NOT NULL
         THEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)
    END AS delay_days,
    CASE WHEN o.order_status = 'delivered'
          AND o.order_delivered_customer_date IS NOT NULL
         THEN CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                   THEN 1 ELSE 0 END
    END AS is_late
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp <  '2018-09-01';


/* ---------------------------------------------------------------------
   SECTION 8. FINAL VALIDATION (row counts after cleaning)
   --------------------------------------------------------------------- */
SELECT 'AFTER' AS stage, 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'AFTER', 'orders',                COUNT(*) FROM orders
UNION ALL SELECT 'AFTER', 'order_items',           COUNT(*) FROM order_items
UNION ALL SELECT 'AFTER', 'order_payments',        COUNT(*) FROM order_payments
UNION ALL SELECT 'AFTER', 'order_reviews',         COUNT(*) FROM order_reviews
UNION ALL SELECT 'AFTER', 'products',              COUNT(*) FROM products
UNION ALL SELECT 'AFTER', 'sellers',               COUNT(*) FROM sellers
UNION ALL SELECT 'AFTER', 'geolocation',           COUNT(*) FROM geolocation
UNION ALL SELECT 'AFTER', 'v_orders_clean (view)', COUNT(*) FROM v_orders_clean;

-- Sanity checks
SELECT COUNT(DISTINCT customer_unique_id) AS unique_customers FROM customers;                 -- about 96K
SELECT COUNT(*) AS reviews, COUNT(DISTINCT order_id) AS distinct_orders FROM order_reviews;   -- equal numbers
