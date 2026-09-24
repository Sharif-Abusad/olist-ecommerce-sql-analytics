USE olist_ecommerce;

-- ============================================================
-- 07_product_analysis.sql
-- Olist E-Commerce Product Analysis
-- ============================================================


-- ============================================================
-- 1. PRODUCT CATALOG SUMMARY
-- ============================================================

SELECT
    COUNT(*) AS total_products,
    COUNT(DISTINCT product_category_name) AS total_categories,
    ROUND(AVG(product_photos_qty), 2) AS avg_photos,
    ROUND(AVG(product_weight_g), 2) AS avg_weight_g
FROM products;


-- ============================================================
-- 2. PRODUCTS BY CATEGORY
-- ============================================================

SELECT
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    ) AS category,
    COUNT(*) AS product_count
FROM products p
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY category
ORDER BY product_count DESC;


-- ============================================================
-- 3. CATEGORY SALES PERFORMANCE
-- ============================================================

SELECT
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    ) AS category,
    COUNT(DISTINCT oi.product_id) AS products_sold,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(AVG(oi.price), 2) AS average_price
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY category
ORDER BY revenue DESC;


-- ============================================================
-- 4. TOP 20 PRODUCTS BY REVENUE
-- ============================================================

SELECT
    oi.product_id,
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    ) AS category,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(AVG(oi.price), 2) AS average_price
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY oi.product_id, category
ORDER BY revenue DESC
LIMIT 20;


-- ============================================================
-- 5. TOP 20 PRODUCTS BY UNITS SOLD
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
GROUP BY oi.product_id, category
ORDER BY units_sold DESC
LIMIT 20;


-- ============================================================
-- 6. MOST EXPENSIVE PRODUCTS SOLD
-- ============================================================

SELECT
    oi.product_id,
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    ) AS category,
    ROUND(MAX(oi.price), 2) AS highest_price,
    COUNT(*) AS units_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY oi.product_id, category
ORDER BY highest_price DESC
LIMIT 20;


-- ============================================================
-- 7. CATEGORY AVERAGE PRICE
-- ============================================================

SELECT
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    ) AS category,
    COUNT(*) AS units_sold,
    ROUND(AVG(oi.price), 2) AS average_price,
    ROUND(MIN(oi.price), 2) AS minimum_price,
    ROUND(MAX(oi.price), 2) AS maximum_price
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY category
ORDER BY average_price DESC;


-- ============================================================
-- 8. CATEGORY FREIGHT ANALYSIS
-- ============================================================

SELECT
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    ) AS category,
    ROUND(SUM(oi.freight_value), 2) AS total_freight,
    ROUND(AVG(oi.freight_value), 2) AS avg_freight,
    ROUND(AVG(oi.price), 2) AS avg_product_price
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY category
ORDER BY total_freight DESC;


-- ============================================================
-- 9. FREIGHT-TO-PRICE RATIO
-- ============================================================

SELECT
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    ) AS category,
    ROUND(AVG(
        oi.freight_value / NULLIF(oi.price, 0) * 100
    ), 2) AS avg_freight_percent
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY category
ORDER BY avg_freight_percent DESC;


-- ============================================================
-- 10. PRODUCT PHOTOS VS SALES
-- ============================================================

SELECT
    p.product_photos_qty,
    COUNT(DISTINCT p.product_id) AS products,
    COUNT(oi.product_id) AS units_sold,
    ROUND(SUM(oi.price), 2) AS revenue
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_photos_qty
ORDER BY p.product_photos_qty;


-- ============================================================
-- 11. PRODUCT WEIGHT VS AVERAGE PRICE
-- ============================================================

SELECT
    CASE
        WHEN product_weight_g < 1000 THEN '< 1 kg'
        WHEN product_weight_g < 3000 THEN '1-3 kg'
        WHEN product_weight_g < 5000 THEN '3-5 kg'
        ELSE '5+ kg'
    END AS weight_category,
    COUNT(*) AS products
FROM products
WHERE product_weight_g IS NOT NULL
GROUP BY weight_category
ORDER BY products DESC;


-- ============================================================
-- 12. PRODUCT DESCRIPTION LENGTH ANALYSIS
-- ============================================================

SELECT
    CASE
        WHEN product_description_length < 300 THEN 'Short'
        WHEN product_description_length < 1000 THEN 'Medium'
        ELSE 'Long'
    END AS description_category,
    COUNT(*) AS products
FROM products
WHERE product_description_length IS NOT NULL
GROUP BY description_category
ORDER BY products DESC;


-- ============================================================
-- 13. CATEGORY REVENUE RANKING
-- ============================================================

WITH category_sales AS (
    SELECT
        COALESCE(
            ct.product_category_name_english,
            p.product_category_name
        ) AS category,
        SUM(oi.price) AS revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    LEFT JOIN category_translation ct
        ON p.product_category_name = ct.product_category_name
    GROUP BY category
)

SELECT
    category,
    ROUND(revenue, 2) AS revenue,
    DENSE_RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank
FROM category_sales
ORDER BY revenue_rank;


-- ============================================================
-- 14. TOP 10 CATEGORIES BY UNITS SOLD
-- ============================================================

SELECT
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    ) AS category,
    COUNT(*) AS units_sold
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY category
ORDER BY units_sold DESC
LIMIT 10;


-- ============================================================
-- 15. PRODUCTS WITH HIGH SALES BUT LOW PRICE
-- ============================================================

SELECT
    oi.product_id,
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    ) AS category,
    COUNT(*) AS units_sold,
    ROUND(AVG(oi.price), 2) AS average_price,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY oi.product_id, category
HAVING units_sold >= 50
ORDER BY units_sold DESC, average_price
LIMIT 20;


-- ============================================================
-- 16. CATEGORY CONTRIBUTION TO TOTAL REVENUE
-- ============================================================

WITH category_sales AS (
    SELECT
        COALESCE(
            ct.product_category_name_english,
            p.product_category_name
        ) AS category,
        SUM(oi.price) AS revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
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
-- 17. PRODUCTS NEVER SOLD
-- ============================================================

SELECT
    p.product_id,
    p.product_category_name
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;


-- ============================================================
-- 18. PRODUCT SALES SUMMARY
-- ============================================================

SELECT
    COUNT(DISTINCT p.product_id) AS total_products,
    COUNT(DISTINCT oi.product_id) AS products_with_sales,
    COUNT(DISTINCT CASE
        WHEN oi.product_id IS NULL THEN p.product_id
    END) AS products_without_sales,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id;