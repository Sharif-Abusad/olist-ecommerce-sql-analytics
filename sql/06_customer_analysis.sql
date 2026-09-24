USE olist_ecommerce;

-- ============================================================
-- 06_customer_analysis.sql
-- Olist E-Commerce Customer Analysis
-- ============================================================


-- ============================================================
-- 1. TOTAL CUSTOMERS AND UNIQUE CUSTOMERS
-- ============================================================

SELECT
    COUNT(*) AS customer_records,
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers;


-- ============================================================
-- 2. CUSTOMERS BY STATE
-- ============================================================

SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC;


-- ============================================================
-- 3. TOP CUSTOMERS BY TOTAL SPENDING
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
LIMIT 20;


-- ============================================================
-- 4. AVERAGE CUSTOMER SPENDING
-- ============================================================

WITH customer_spending AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price + oi.freight_value) AS total_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    ROUND(AVG(total_spending), 2) AS average_customer_spending,
    ROUND(MIN(total_spending), 2) AS minimum_spending,
    ROUND(MAX(total_spending), 2) AS maximum_spending
FROM customer_spending;


-- ============================================================
-- 5. ONE-TIME VS REPEAT CUSTOMERS
-- ============================================================

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-time customer'
        ELSE 'Repeat customer'
    END AS customer_type,
    COUNT(*) AS customer_count
FROM customer_orders
GROUP BY customer_type;


-- ============================================================
-- 6. REPEAT CUSTOMER RATE
-- ============================================================

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    COUNT(*) AS total_customers,
    SUM(total_orders > 1) AS repeat_customers,
    ROUND(
        100 * SUM(total_orders > 1) / COUNT(*),
        2
    ) AS repeat_customer_rate
FROM customer_orders;


-- ============================================================
-- 7. CUSTOMER PURCHASE FREQUENCY
-- ============================================================

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    total_orders,
    COUNT(*) AS customer_count
FROM customer_orders
GROUP BY total_orders
ORDER BY total_orders;


-- ============================================================
-- 8. CUSTOMER SPENDING BY STATE
-- ============================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS customers,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_spending,
    ROUND(
        SUM(oi.price + oi.freight_value)
        / COUNT(DISTINCT c.customer_unique_id),
        2
    ) AS spending_per_customer
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_spending DESC;


-- ============================================================
-- 9. CUSTOMER ORDER VALUE
-- ============================================================

WITH order_values AS (
    SELECT
        o.order_id,
        c.customer_unique_id,
        SUM(oi.price + oi.freight_value) AS order_value
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.order_id,
        c.customer_unique_id
)

SELECT
    customer_unique_id,
    ROUND(AVG(order_value), 2) AS average_order_value,
    COUNT(*) AS total_orders
FROM order_values
GROUP BY customer_unique_id
ORDER BY average_order_value DESC
LIMIT 20;


-- ============================================================
-- 10. FIRST AND LAST PURCHASE DATE
-- ============================================================

SELECT
    c.customer_unique_id,
    MIN(o.order_purchase_timestamp) AS first_purchase,
    MAX(o.order_purchase_timestamp) AS last_purchase,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY first_purchase
LIMIT 20;


-- ============================================================
-- 11. CUSTOMER LIFETIME PERIOD
-- ============================================================

SELECT
    c.customer_unique_id,
    DATEDIFF(
        MAX(o.order_purchase_timestamp),
        MIN(o.order_purchase_timestamp)
    ) AS customer_lifetime_days,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
HAVING total_orders > 1
ORDER BY customer_lifetime_days DESC
LIMIT 20;


-- ============================================================
-- 12. MONTHLY NEW CUSTOMERS
-- ============================================================

WITH first_purchases AS (
    SELECT
        c.customer_unique_id,
        DATE_FORMAT(
            MIN(o.order_purchase_timestamp),
            '%Y-%m'
        ) AS first_purchase_month
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    first_purchase_month,
    COUNT(*) AS new_customers
FROM first_purchases
GROUP BY first_purchase_month
ORDER BY first_purchase_month;


-- ============================================================
-- 13. MONTHLY ACTIVE CUSTOMERS
-- ============================================================

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS sales_month,
    COUNT(DISTINCT c.customer_unique_id) AS active_customers
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY sales_month
ORDER BY sales_month;


-- ============================================================
-- 14. TOP 20 CUSTOMERS BY ORDER COUNT
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
ORDER BY total_orders DESC, total_spending DESC
LIMIT 20;


-- ============================================================
-- 15. CUSTOMER RANKING BY SPENDING
-- ============================================================

WITH customer_spending AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price + oi.freight_value) AS total_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    customer_unique_id,
    ROUND(total_spending, 2) AS total_spending,
FROM customer_spending
ORDER BY spending_rank
LIMIT 20;


-- ============================================================
-- 16. CUSTOMER SPENDING SEGMENTS
-- ============================================================

WITH customer_spending AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price + oi.freight_value) AS total_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    CASE
        WHEN total_spending < 100 THEN 'Low spender'
        WHEN total_spending < 500 THEN 'Medium spender'
        ELSE 'High spender'
    END AS spending_segment,
    COUNT(*) AS customer_count,
    ROUND(SUM(total_spending), 2) AS segment_revenue
FROM customer_spending
GROUP BY spending_segment
ORDER BY segment_revenue DESC;


-- ============================================================
-- 17. RFM CUSTOMER ANALYSIS
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
        ) AS recency_days,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(oi.price + oi.freight_value) AS monetary
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
),

rfm_scores AS (
    SELECT
        customer_unique_id,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS recency_score,
        NTILE(5) OVER (
            ORDER BY frequency
        ) AS frequency_score,
        NTILE(5) OVER (
            ORDER BY monetary
        ) AS monetary_score
    FROM customer_metrics
)

SELECT
    customer_unique_id,
    recency_days,
    frequency,
    ROUND(monetary, 2) AS monetary,
    recency_score,
    frequency_score,
    monetary_score,
    CONCAT(
        recency_score,
        frequency_score,
        monetary_score
    ) AS rfm_score
FROM rfm_scores
ORDER BY monetary DESC
LIMIT 50;


-- ============================================================
-- 18. CUSTOMER REVENUE CONTRIBUTION
-- ============================================================

WITH customer_spending AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price + oi.freight_value) AS total_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    customer_unique_id,
    ROUND(total_spending, 2) AS total_spending,
    ROUND(
        100 * total_spending / SUM(total_spending) OVER (),
        2
    ) AS revenue_contribution_percent
FROM customer_spending
ORDER BY total_spending DESC
LIMIT 20;


-- ============================================================
-- 19. CUSTOMER COHORT BY FIRST PURCHASE MONTH
-- ============================================================

WITH customer_first_purchase AS (
    SELECT
        c.customer_unique_id,
        DATE_FORMAT(
            MIN(o.order_purchase_timestamp),
            '%Y-%m'
        ) AS cohort_month
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    cohort_month,
    COUNT(*) AS customers_in_cohort
FROM customer_first_purchase
GROUP BY cohort_month
ORDER BY cohort_month;


-- ============================================================
-- 20. CUSTOMER ANALYSIS SUMMARY
-- ============================================================

WITH customer_summary AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.price + oi.freight_value) AS total_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    COUNT(*) AS total_customers,
    SUM(total_orders > 1) AS repeat_customers,
    ROUND(AVG(total_orders), 2) AS average_orders_per_customer,
    ROUND(AVG(total_spending), 2) AS average_customer_spending,
    ROUND(SUM(total_spending), 2) AS total_customer_revenue
FROM customer_summary;