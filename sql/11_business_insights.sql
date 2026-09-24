USE olist_ecommerce;

-- ============================================================
-- 11_business_insights.sql
-- Olist E-Commerce Business Insights
-- ============================================================


-- ============================================================
-- 1. TOP 10 REVENUE-GENERATING CATEGORIES
-- ============================================================

SELECT
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    ) AS category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;


-- ============================================================
-- 2. TOP 10 CUSTOMERS BY TOTAL SPENDING
-- ============================================================

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_spending
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spending DESC
LIMIT 10;


-- ============================================================
-- 3. REPEAT CUSTOMER RATE
-- ============================================================

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    COUNT(*) AS total_customers,
    SUM(order_count > 1) AS repeat_customers,
    ROUND(
        100 * SUM(order_count > 1) / COUNT(*),
        2
    ) AS repeat_customer_rate
FROM customer_orders;


-- ============================================================
-- 4. STATES WITH THE HIGHEST SALES
-- ============================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- ============================================================
-- 5. STATES WITH THE HIGHEST AVERAGE ORDER VALUE
-- ============================================================

WITH order_values AS (
    SELECT
        o.order_id,
        c.customer_state,
        SUM(oi.price + oi.freight_value) AS order_value
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.order_id,
        c.customer_state
)

SELECT
    customer_state,
    COUNT(*) AS orders,
    ROUND(AVG(order_value), 2) AS average_order_value
FROM order_values
GROUP BY customer_state
ORDER BY average_order_value DESC;


-- ============================================================
-- 6. SELLERS WITH HIGH REVENUE AND HIGH CUSTOMER RATINGS
-- ============================================================

WITH seller_revenue AS (
    SELECT
        seller_id,
        COUNT(DISTINCT order_id) AS orders,
        SUM(price) AS revenue
    FROM order_items
    GROUP BY seller_id
),

seller_reviews AS (
    SELECT
        oi.seller_id,
        AVG(r.review_score) AS avg_review_score
    FROM order_items oi
    JOIN order_reviews r
        ON oi.order_id = r.order_id
    GROUP BY oi.seller_id
)

SELECT
    sr.seller_id,
    sr.orders,
    ROUND(sr.revenue, 2) AS revenue,
    ROUND(srv.avg_review_score, 2) AS avg_review_score
FROM seller_revenue sr
JOIN seller_reviews srv
    ON sr.seller_id = srv.seller_id
WHERE sr.orders >= 100
  AND srv.avg_review_score >= 4
ORDER BY sr.revenue DESC;


-- ============================================================
-- 7. CATEGORIES WITH LOW CUSTOMER SATISFACTION
-- ============================================================

SELECT
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    ) AS category,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN order_reviews r
    ON oi.order_id = r.order_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY category
HAVING COUNT(DISTINCT oi.order_id) >= 100
ORDER BY avg_review_score ASC;


-- ============================================================
-- 8. LATE DELIVERY RATE BY STATE
-- ============================================================

SELECT
    c.customer_state,
    COUNT(*) AS delivered_orders,
    SUM(
        o.order_delivered_customer_date >
        o.order_estimated_delivery_date
    ) AS late_orders,
    ROUND(
        100 * SUM(
            o.order_delivered_customer_date >
            o.order_estimated_delivery_date
        ) / COUNT(*),
        2
    ) AS late_delivery_rate
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY late_delivery_rate DESC;


-- ============================================================
-- 9. PRODUCTS WITH HIGH SALES VOLUME
-- ============================================================

SELECT
    oi.product_id,
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    ) AS category,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY
    oi.product_id,
    category
ORDER BY units_sold DESC
LIMIT 20;


-- ============================================================
-- 10. HIGH-VALUE ORDERS
-- ============================================================

WITH order_values AS (
    SELECT
        order_id,
        SUM(price + freight_value) AS order_value
    FROM order_items
    GROUP BY order_id
)

SELECT
    order_id,
    ROUND(order_value, 2) AS order_value
FROM order_values
ORDER BY order_value DESC
LIMIT 20;


-- ============================================================
-- 11. PAYMENT METHOD BUSINESS ANALYSIS
-- ============================================================

SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(payment_value), 2) AS total_payment,
    ROUND(AVG(payment_value), 2) AS average_payment
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment DESC;


-- ============================================================
-- 12. MONTHLY SALES TREND
-- ============================================================

SELECT
    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    ) AS sales_month,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY sales_month
ORDER BY sales_month;


-- ============================================================
-- 13. REVENUE CONCENTRATION
-- Identify how much revenue comes from the top 20%
-- of customers.
-- ============================================================

WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price + oi.freight_value) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
),

ranked AS (
    SELECT
        customer_unique_id,
        revenue,
        ROW_NUMBER() OVER (
            ORDER BY revenue DESC
        ) AS customer_rank,
        COUNT(*) OVER () AS total_customers
    FROM customer_revenue
)

SELECT
    ROUND(
        SUM(
            CASE
                WHEN customer_rank <= total_customers * 0.20
                THEN revenue
                ELSE 0
            END
        ),
        2
    ) AS top_20_percent_revenue,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(
        100 * SUM(
            CASE
                WHEN customer_rank <= total_customers * 0.20
                THEN revenue
                ELSE 0
            END
        ) / SUM(revenue),
        2
    ) AS top_20_revenue_percentage
FROM ranked;


-- ============================================================
-- 14. PRODUCTS NEVER SOLD
-- ============================================================

SELECT
    p.product_id,
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    ) AS category
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
WHERE oi.product_id IS NULL
ORDER BY category;


-- ============================================================
-- 15. OVERALL BUSINESS KPI SUMMARY
-- ============================================================

WITH order_values AS (
    SELECT
        order_id,
        SUM(price + freight_value) AS order_value
    FROM order_items
    GROUP BY order_id
)

SELECT
    COUNT(*) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_sales,
    ROUND(AVG(order_value), 2) AS average_order_value,
    ROUND(MIN(order_value), 2) AS minimum_order_value,
    ROUND(MAX(order_value), 2) AS maximum_order_value
FROM order_values;