USE olist_ecommerce;

-- ============================================================
-- 09_advanced_analysis.sql
-- Advanced Olist E-Commerce Analysis
-- ============================================================


-- ============================================================
-- 1. DELIVERY PERFORMANCE
-- ============================================================

SELECT
    COUNT(*) AS delivered_orders,
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),
        2
    ) AS avg_delivery_days,
    MIN(
        DATEDIFF(
            order_delivered_customer_date,
            order_purchase_timestamp
        )
    ) AS fastest_delivery_days,
    MAX(
        DATEDIFF(
            order_delivered_customer_date,
            order_purchase_timestamp
        )
    ) AS slowest_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;


-- ============================================================
-- 2. ON-TIME VS LATE DELIVERIES
-- ============================================================

SELECT
    CASE
        WHEN order_delivered_customer_date
             <= order_estimated_delivery_date
        THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(*) AS orders
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;


-- ============================================================
-- 3. AVERAGE DELIVERY DELAY
-- ============================================================

SELECT
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_estimated_delivery_date
            )
        ),
        2
    ) AS average_delay_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;


-- ============================================================
-- 4. DELIVERY PERFORMANCE BY CUSTOMER STATE
-- ============================================================

SELECT
    c.customer_state,
    COUNT(*) AS delivered_orders,
    ROUND(
        AVG(
            DATEDIFF(
                o.order_delivered_customer_date,
                o.order_purchase_timestamp
            )
        ),
        2
    ) AS avg_delivery_days,
    ROUND(
        100 * AVG(
            CASE
                WHEN o.order_delivered_customer_date
                     <= o.order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ),
        2
    ) AS on_time_percent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY on_time_percent DESC;


-- ============================================================
-- 5. DELIVERY TIME BY ORDER STATUS
-- ============================================================

SELECT
    order_status,
    COUNT(*) AS orders
FROM orders
GROUP BY order_status
ORDER BY orders DESC;


-- ============================================================
-- 6. REVIEW SCORE DISTRIBUTION
-- ============================================================

SELECT
    review_score,
    COUNT(*) AS review_count,
    ROUND(
        100 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS review_percentage
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;


-- ============================================================
-- 7. AVERAGE REVIEW SCORE
-- ============================================================

SELECT
    ROUND(AVG(review_score), 2) AS average_review_score
FROM order_reviews;


-- ============================================================
-- 8. REVIEW SCORE VS DELIVERY PERFORMANCE
-- ============================================================

SELECT
    CASE
        WHEN o.order_delivered_customer_date
             <= o.order_estimated_delivery_date
        THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(*) AS reviews,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM order_reviews r
JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;


-- ============================================================
-- 9. REVIEW SCORE VS DELIVERY DELAY
-- ============================================================

SELECT
    r.review_score,
    COUNT(*) AS reviews,
    ROUND(
        AVG(
            DATEDIFF(
                o.order_delivered_customer_date,
                o.order_estimated_delivery_date
            )
        ),
        2
    ) AS avg_delay_days
FROM order_reviews r
JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score;


-- ============================================================
-- 10. REVENUE VS REVIEW SCORE
-- ============================================================

SELECT
    r.review_score,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM order_reviews r
JOIN orders o
    ON r.order_id = o.order_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY r.review_score
ORDER BY r.review_score DESC;


-- ============================================================
-- 11. CUSTOMER VALUE + REVIEW SCORE
-- ============================================================

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_spending,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
LEFT JOIN order_reviews r
    ON o.order_id = r.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spending DESC
LIMIT 20;


-- ============================================================
-- 12. MONTHLY REVENUE + ORDERS + CUSTOMERS
-- ============================================================

SELECT
    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    ) AS sales_month,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT c.customer_unique_id) AS customers,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY sales_month
ORDER BY sales_month;


-- ============================================================
-- 13. MONTHLY REVENUE GROWTH
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        ) AS sales_month,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY sales_month
),

growth AS (
    SELECT
        sales_month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY sales_month
        ) AS previous_revenue
    FROM monthly_revenue
)

SELECT
    sales_month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_revenue, 2) AS previous_revenue,
    ROUND(
        100 * (revenue - previous_revenue)
        / NULLIF(previous_revenue, 0),
        2
    ) AS growth_percent
FROM growth
ORDER BY sales_month;


-- ============================================================
-- 14. CUSTOMER RFM SEGMENTATION
-- ============================================================

WITH customer_metrics AS (
    SELECT
        c.customer_unique_id,
        DATEDIFF(
            (
                SELECT MAX(order_purchase_timestamp)
                FROM orders
            ),
            MAX(o.order_purchase_timestamp)
        ) AS recency,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(oi.price + oi.freight_value) AS monetary
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
),

rfm AS (
    SELECT
        *,
        NTILE(5) OVER (
            ORDER BY recency DESC
        ) AS r_score,
        NTILE(5) OVER (
            ORDER BY frequency
        ) AS f_score,
        NTILE(5) OVER (
            ORDER BY monetary
        ) AS m_score
    FROM customer_metrics
)

SELECT
    CASE
        WHEN r_score >= 4
             AND f_score >= 4
             AND m_score >= 4
            THEN 'High Value'
        WHEN r_score >= 3
             AND f_score >= 3
            THEN 'Loyal'
        WHEN r_score <= 2
             AND f_score >= 3
            THEN 'At Risk'
        ELSE 'Regular'
    END AS customer_segment,
    COUNT(*) AS customers,
    ROUND(SUM(monetary), 2) AS revenue
FROM rfm
GROUP BY customer_segment
ORDER BY revenue DESC;


-- ============================================================
-- 15. TOP 20 CUSTOMERS BY REVENUE
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

ranked_customers AS (
    SELECT
        customer_unique_id,
        revenue,
        DENSE_RANK() OVER (
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM customer_revenue
)

SELECT
    customer_unique_id,
    ROUND(revenue, 2) AS revenue,
    revenue_rank
FROM ranked_customers
WHERE revenue_rank <= 20
ORDER BY revenue_rank;


-- ============================================================
-- 16. TOP CATEGORY IN EACH STATE
-- ============================================================

WITH state_category_sales AS (
    SELECT
        c.customer_state,
        COALESCE(
            ct.product_category_name_english,
            p.product_category_name
        ) AS category,
        SUM(oi.price) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN category_translation ct
        ON p.product_category_name = ct.product_category_name
    GROUP BY
        c.customer_state,
        category
),

ranked_categories AS (
    SELECT
        customer_state,
        category,
        revenue,
        RANK() OVER (
            PARTITION BY customer_state
            ORDER BY revenue DESC
        ) AS category_rank
    FROM state_category_sales
)

SELECT
    customer_state,
    category,
    ROUND(revenue, 2) AS revenue
FROM ranked_categories
WHERE category_rank = 1
ORDER BY customer_state;


-- ============================================================
-- 17. BUSINESS KPI SUMMARY
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
    ROUND(MAX(order_value), 2) AS highest_order_value
FROM order_values;