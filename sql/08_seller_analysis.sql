USE olist_ecommerce;

-- ============================================================
-- 08_seller_analysis.sql
-- Olist E-Commerce Seller Analysis
-- ============================================================


-- ============================================================
-- 1. SELLER SUMMARY
-- ============================================================

SELECT
    COUNT(*) AS total_sellers,
    COUNT(DISTINCT seller_state) AS seller_states,
    COUNT(DISTINCT seller_city) AS seller_cities
FROM sellers;


-- ============================================================
-- 2. SELLERS BY STATE
-- ============================================================

SELECT
    seller_state,
    COUNT(*) AS seller_count
FROM sellers
GROUP BY seller_state
ORDER BY seller_count DESC;


-- ============================================================
-- 3. TOP SELLERS BY REVENUE
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
LIMIT 20;


-- ============================================================
-- 4. TOP SELLERS BY NUMBER OF ORDERS
-- ============================================================

SELECT
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN sellers s
    ON oi.seller_id = s.seller_id
GROUP BY
    oi.seller_id,
    s.seller_city,
    s.seller_state
ORDER BY total_orders DESC
LIMIT 20;


-- ============================================================
-- 5. SELLER AVERAGE ORDER VALUE
-- ============================================================

WITH seller_orders AS (
    SELECT
        oi.seller_id,
        oi.order_id,
        SUM(oi.price + oi.freight_value) AS order_value
    FROM order_items oi
    GROUP BY
        oi.seller_id,
        oi.order_id
)

SELECT
    seller_id,
    COUNT(*) AS total_orders,
    ROUND(AVG(order_value), 2) AS average_order_value,
    ROUND(SUM(order_value), 2) AS total_sales
FROM seller_orders
GROUP BY seller_id
ORDER BY average_order_value DESC
LIMIT 20;


-- ============================================================
-- 6. SELLER REVENUE BY STATE
-- ============================================================

SELECT
    s.seller_state,
    COUNT(DISTINCT s.seller_id) AS sellers,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
GROUP BY s.seller_state
ORDER BY revenue DESC;


-- ============================================================
-- 7. SELLER REVENUE CONTRIBUTION
-- ============================================================

WITH seller_sales AS (
    SELECT
        seller_id,
        SUM(price) AS revenue
    FROM order_items
    GROUP BY seller_id
)

SELECT
    seller_id,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        100 * revenue / SUM(revenue) OVER (),
        2
    ) AS revenue_share_percent
FROM seller_sales
ORDER BY revenue DESC
LIMIT 20;


-- ============================================================
-- 8. SELLER REVENUE RANKING
-- ============================================================

WITH seller_sales AS (
    SELECT
        seller_id,
        SUM(price) AS revenue
    FROM order_items
    GROUP BY seller_id
)

SELECT
    seller_id,
    ROUND(revenue, 2) AS revenue,
    DENSE_RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank
FROM seller_sales
ORDER BY revenue_rank
LIMIT 50;


-- ============================================================
-- 9. SELLER FREIGHT ANALYSIS
-- ============================================================

SELECT
    oi.seller_id,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(SUM(oi.freight_value), 2) AS total_freight,
    ROUND(AVG(oi.freight_value), 2) AS average_freight
FROM order_items oi
GROUP BY oi.seller_id
ORDER BY total_freight DESC
LIMIT 20;


-- ============================================================
-- 10. FREIGHT-TO-REVENUE RATIO BY SELLER
-- ============================================================

SELECT
    seller_id,
    ROUND(SUM(price), 2) AS revenue,
    ROUND(SUM(freight_value), 2) AS freight,
    ROUND(
        100 * SUM(freight_value)
        / NULLIF(SUM(price), 0),
        2
    ) AS freight_to_revenue_percent
FROM order_items
GROUP BY seller_id
HAVING SUM(price) > 0
ORDER BY freight_to_revenue_percent DESC
LIMIT 20;


-- ============================================================
-- 11. SELLER PRODUCT DIVERSITY
-- ============================================================

SELECT
    seller_id,
    COUNT(DISTINCT product_id) AS unique_products,
    COUNT(*) AS items_sold,
    ROUND(SUM(price), 2) AS revenue
FROM order_items
GROUP BY seller_id
ORDER BY unique_products DESC
LIMIT 20;


-- ============================================================
-- 12. SELLERS WITH HIGH PRODUCT DIVERSITY
-- ============================================================

SELECT
    seller_id,
    COUNT(DISTINCT product_id) AS unique_products,
    ROUND(SUM(price), 2) AS revenue
FROM order_items
GROUP BY seller_id
HAVING COUNT(DISTINCT product_id) >= 50
ORDER BY revenue DESC;


-- ============================================================
-- 13. SELLER MONTHLY REVENUE
-- ============================================================

SELECT
    oi.seller_id,
    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    ) AS sales_month,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
GROUP BY
    oi.seller_id,
    sales_month
ORDER BY
    oi.seller_id,
    sales_month;


-- ============================================================
-- 14. TOP SELLER EACH STATE
-- ============================================================

WITH seller_state_sales AS (
    SELECT
        s.seller_state,
        oi.seller_id,
        SUM(oi.price) AS revenue
    FROM sellers s
    JOIN order_items oi
        ON s.seller_id = oi.seller_id
    GROUP BY
        s.seller_state,
        oi.seller_id
),

ranked_sellers AS (
    SELECT
        seller_state,
        seller_id,
        revenue,
        RANK() OVER (
            PARTITION BY seller_state
            ORDER BY revenue DESC
        ) AS seller_rank
    FROM seller_state_sales
)

SELECT
    seller_state,
    seller_id,
    ROUND(revenue, 2) AS revenue
FROM ranked_sellers
WHERE seller_rank = 1
ORDER BY seller_state;


-- ============================================================
-- 15. SELLER PERFORMANCE SEGMENTS
-- ============================================================

WITH seller_sales AS (
    SELECT
        seller_id,
        SUM(price) AS revenue
    FROM order_items
    GROUP BY seller_id
)

SELECT
    CASE
        WHEN revenue < 1000 THEN 'Low revenue'
        WHEN revenue < 10000 THEN 'Medium revenue'
        ELSE 'High revenue'
    END AS seller_segment,
    COUNT(*) AS seller_count,
    ROUND(SUM(revenue), 2) AS segment_revenue
FROM seller_sales
GROUP BY seller_segment
ORDER BY segment_revenue DESC;


-- ============================================================
-- 16. SELLER ORDER FREQUENCY
-- ============================================================

SELECT
    seller_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(price), 2) AS revenue
FROM order_items
GROUP BY seller_id
ORDER BY total_orders DESC
LIMIT 20;


-- ============================================================
-- 17. SELLERS WITH NO SALES
-- ============================================================

SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state
FROM sellers s
LEFT JOIN order_items oi
    ON s.seller_id = oi.seller_id
WHERE oi.seller_id IS NULL;


-- ============================================================
-- 18. TOP 10 SELLERS BY TOTAL SALES VALUE
-- ============================================================

SELECT
    seller_id,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(*) AS items,
    ROUND(SUM(price + freight_value), 2) AS total_sales_value
FROM order_items
GROUP BY seller_id
ORDER BY total_sales_value DESC
LIMIT 10;


-- ============================================================
-- 19. SELLER PERFORMANCE SUMMARY
-- ============================================================

SELECT
    COUNT(DISTINCT seller_id) AS active_sellers,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(price), 2) AS total_revenue,
    ROUND(SUM(freight_value), 2) AS total_freight
FROM order_items;