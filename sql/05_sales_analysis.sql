USE olist_ecommerce;

-- ============================================================
-- 05_sales_analysis.sql
-- Olist E-Commerce Sales Analysis
-- ============================================================


-- ============================================================
-- 1. OVERALL SALES PERFORMANCE
-- ============================================================

SELECT
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS total_items_sold,
    COUNT(DISTINCT oi.product_id) AS unique_products,
    COUNT(DISTINCT oi.seller_id) AS unique_sellers,
    ROUND(SUM(oi.price), 2) AS total_product_revenue,
    ROUND(SUM(oi.freight_value), 2) AS total_freight,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_sales_value
FROM order_items oi;


-- ============================================================
-- 2. MONTHLY SALES TREND
-- ============================================================

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS sales_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_sales
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY sales_month
ORDER BY sales_month;


-- ============================================================
-- 3. YEARLY SALES PERFORMANCE
-- ============================================================

SELECT
    YEAR(o.order_purchase_timestamp) AS sales_year,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue,
	ROUND(SUM(oi.freight_value), 2) AS freight,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_sales
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY sales_year
ORDER BY sales_year;


-- ============================================================
-- 4. AVERAGE ORDER VALUE (AOV)
-- ============================================================

WITH order_totals AS (
    SELECT
        order_id,
        SUM(price + freight_value) AS order_value
    FROM order_items
    GROUP BY order_id
)

SELECT
    COUNT(*) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_sales,
    ROUND(AVG(order_value), 2) AS average_order_value
FROM order_totals;


-- ============================================================
-- 5. MONTHLY AVERAGE ORDER VALUE
-- ============================================================

WITH order_totals AS (
    SELECT
        o.order_id,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS sales_month,
        SUM(oi.price + oi.freight_value) AS order_value
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.order_id,
        sales_month
)

SELECT
    sales_month,
    COUNT(*) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_sales,
    ROUND(AVG(order_value), 2) AS average_order_value
FROM order_totals
GROUP BY sales_month
ORDER BY sales_month;


-- ============================================================
-- 6. TOP 10 PRODUCT CATEGORIES BY REVENUE
-- ============================================================

SELECT
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    ) AS category,
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
-- 7. TOP 10 PRODUCTS BY REVENUE
-- ============================================================

SELECT
    oi.product_id,
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    ) AS category,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY
    oi.product_id,
    category
ORDER BY revenue DESC
LIMIT 10;


-- ============================================================
-- 8. TOP 10 SELLERS BY REVENUE
-- ============================================================

SELECT
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN sellers s
    ON oi.seller_id = s.seller_id
GROUP BY
    oi.seller_id,
    s.seller_city,
    s.seller_state
ORDER BY revenue DESC
LIMIT 10;


-- ============================================================
-- 9. SALES BY CUSTOMER'S STATE
-- ============================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS customers,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_sales
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- ============================================================
-- 10. SALES BY DAY OF WEEK
-- ============================================================

SELECT
    DAYNAME(o.order_purchase_timestamp) AS day_of_week,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    DAYOFWEEK(o.order_purchase_timestamp),
    DAYNAME(o.order_purchase_timestamp)
ORDER BY revenue;


-- ============================================================
-- 11. SALES BY HOUR OF DAY
-- ============================================================

SELECT
    HOUR(o.order_purchase_timestamp) AS purchase_hour,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY purchase_hour
ORDER BY revenue;


-- ============================================================
-- 12. PAYMENT METHOD ANALYSIS
-- ============================================================

SELECT
    payment_type,
    COUNT(*) AS payment_transactions,
    COUNT(DISTINCT order_id) AS unique_orders,
    ROUND(SUM(payment_value), 2) AS total_payment,
    ROUND(AVG(payment_value), 2) AS average_payment
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment DESC;


-- ============================================================
-- 13. PAYMENT METHOD SHARE
-- ============================================================

WITH payment_summary AS (
    SELECT
        payment_type,
        SUM(payment_value) AS total_payment
    FROM order_payments
    GROUP BY payment_type
)

SELECT
    payment_type,
    ROUND(total_payment, 2) AS total_payment,
    ROUND(
        100 * total_payment / SUM(total_payment) OVER (),
        2
    ) AS payment_share_percent
FROM payment_summary
ORDER BY total_payment DESC;


-- ============================================================
-- 14. INSTALLMENT ANALYSIS
-- ============================================================

SELECT
    payment_installments,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(payment_value), 2) AS payment_value
FROM order_payments
WHERE payment_type = 'credit_card'
GROUP BY payment_installments
ORDER BY payment_installments;


-- ============================================================
-- 15. REVENUE GROWTH MONTH OVER MONTH
-- ============================================================

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS sales_month,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY sales_month
),

sales_with_previous AS (
    SELECT
        sales_month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY sales_month
        ) AS previous_month_revenue
    FROM monthly_sales
)

SELECT
    sales_month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        100 * (revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS growth_percent
FROM sales_with_previous
ORDER BY sales_month;


-- ============================================================
-- 16. CATEGORY REVENUE CONTRIBUTION
-- ============================================================

WITH category_sales AS (
    SELECT
        COALESCE(
            ct.product_category_name_english,
            p.product_category_name
        ) AS category,
        SUM(oi.price) AS revenue
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN category_translation ct
        ON p.product_category_name = ct.product_category_name
    GROUP BY category
)

SELECT
    category,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        100 * revenue / SUM(revenue) OVER (),
        2
    ) AS revenue_share_percent
FROM category_sales
ORDER BY revenue DESC;


-- ============================================================
-- 17. SALES BY ORDER STATUS
-- ============================================================

SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_status
ORDER BY revenue DESC;


-- ============================================================
-- 18. MONTH WITH HIGHEST REVENUE
-- ============================================================

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS sales_month,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY sales_month
)

SELECT
    sales_month,
    ROUND(revenue, 2) AS revenue
FROM monthly_sales
ORDER BY revenue DESC
LIMIT 1;


-- ============================================================
-- 19. TOP 10 ORDERS BY ORDER VALUE
-- ============================================================

SELECT
    oi.order_id,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS order_value
FROM order_items oi
GROUP BY oi.order_id
ORDER BY order_value DESC
LIMIT 10;


-- ============================================================
-- 20. SALES SUMMARY
-- ============================================================

SELECT
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS customers,
    COUNT(DISTINCT oi.product_id) AS products_sold,
    COUNT(DISTINCT oi.seller_id) AS sellers,
    ROUND(SUM(oi.price), 2) AS product_revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_sales
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id;