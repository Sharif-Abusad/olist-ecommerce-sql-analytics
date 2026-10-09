/* =====================================================================
   OLIST E-COMMERCE  |  04c_clean_duplicates.sql
   Covers: Section 3 (remove duplicates)
   Run order: 2 of 5
   WARNING: Run this file ONCE. It renames order_reviews and geolocation to
   *_raw. Running it twice will fail. To undo, rename the *_raw tables back.
   If you already ran 10_query_optimization.sql and 12_add_foreign_keys.sql,
   re-run them after this file.
   ===================================================================== */

USE olist_ecommerce;
SET SQL_SAFE_UPDATES = 0;

/* ---------------------------------------------------------------------
   3a. order_reviews: keep ONE review per order (the latest one).
       Also converts empty comment text to NULL and drops scores outside 1-5.
   --------------------------------------------------------------------- */
DROP TABLE IF EXISTS order_reviews_clean;

CREATE TABLE order_reviews_clean AS
SELECT review_id,
       order_id,
       review_score,
       NULLIF(TRIM(review_comment_title), '')   AS review_comment_title,
       NULLIF(TRIM(review_comment_message), '') AS review_comment_message,
       review_creation_date,
       review_answer_timestamp
FROM (
    SELECT r.*,
           ROW_NUMBER() OVER (
               PARTITION BY order_id
               ORDER BY review_answer_timestamp DESC, review_creation_date DESC, review_id
           ) AS rn
    FROM order_reviews r
) t
WHERE rn = 1
  AND review_score BETWEEN 1 AND 5;

ALTER TABLE order_reviews_clean ADD PRIMARY KEY (order_id);
ALTER TABLE order_reviews_clean ADD INDEX idx_reviews_review_id (review_id);

RENAME TABLE order_reviews       TO order_reviews_raw,
             order_reviews_clean TO order_reviews;


/* ---------------------------------------------------------------------
   3b. geolocation: keep ONE row per ZIP prefix (average lat/lng).
   --------------------------------------------------------------------- */
DROP TABLE IF EXISTS geolocation_clean;

CREATE TABLE geolocation_clean AS
SELECT geolocation_zip_code_prefix,
       AVG(geolocation_lat)                AS geolocation_lat,
       AVG(geolocation_lng)                AS geolocation_lng,
       MIN(LOWER(TRIM(geolocation_city)))  AS geolocation_city,
       MIN(UPPER(TRIM(geolocation_state))) AS geolocation_state
FROM geolocation
GROUP BY geolocation_zip_code_prefix;

ALTER TABLE geolocation_clean ADD PRIMARY KEY (geolocation_zip_code_prefix);

RENAME TABLE geolocation       TO geolocation_raw,
             geolocation_clean TO geolocation;


/* ---------------------------------------------------------------------
   3c. Check other tables for duplicate keys (all should return 0 rows)
   --------------------------------------------------------------------- */
SELECT 'dup customers' AS chk, customer_id AS id, COUNT(*) AS c
FROM customers GROUP BY customer_id HAVING COUNT(*) > 1
UNION ALL
SELECT 'dup orders', order_id, COUNT(*)
FROM orders GROUP BY order_id HAVING COUNT(*) > 1
UNION ALL
SELECT 'dup products', product_id, COUNT(*)
FROM products GROUP BY product_id HAVING COUNT(*) > 1
UNION ALL
SELECT 'dup sellers', seller_id, COUNT(*)
FROM sellers GROUP BY seller_id HAVING COUNT(*) > 1;

SELECT 'dup order_items' AS chk, order_id, order_item_id, COUNT(*) AS c
FROM order_items GROUP BY order_id, order_item_id HAVING COUNT(*) > 1;

SET SQL_SAFE_UPDATES = 1;
