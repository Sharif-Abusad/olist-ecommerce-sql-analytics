/* =====================================================================
   OLIST E-COMMERCE  |  04d_clean_nulls_and_fixes.sql
   Covers: Section 4 (nulls and invalid values), Section 5 (category translation)
   Run order: 3 of 5
   ===================================================================== */

USE olist_ecommerce;
SET SQL_SAFE_UPDATES = 0;

/* ---------------------------------------------------------------------
   SECTION 4. HANDLE NULLS AND INVALID VALUES
   --------------------------------------------------------------------- */

-- 4a. products: missing category -> 'unknown'; weight of 0 is invalid -> NULL
UPDATE products
SET product_category_name = 'unknown'
WHERE product_category_name IS NULL OR TRIM(product_category_name) = '';

UPDATE products
SET product_weight_g = NULL
WHERE product_weight_g = 0;

-- 4b. order_payments: remove 'not_defined' rows; installments of 0 -> 1
DELETE FROM order_payments WHERE payment_type = 'not_defined';

UPDATE order_payments
SET payment_installments = 1
WHERE payment_installments = 0;

-- 4c. Expected NULLs (kept on purpose): delivery dates on undelivered orders.
--     Check: delivered orders that have no delivery date (should be tiny)
SELECT COUNT(*) AS delivered_without_delivery_date
FROM orders
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NULL;


/* ---------------------------------------------------------------------
   SECTION 5. FIX CATEGORY TRANSLATION (add missing categories)
   --------------------------------------------------------------------- */
INSERT INTO category_translation (product_category_name, product_category_name_english)
SELECT x.pt, x.en
FROM (
    SELECT 'pc_gamer' AS pt, 'pc_gamer' AS en
    UNION ALL SELECT 'portateis_cozinha_e_preparadores_de_alimentos', 'portable_kitchen_and_food_preparers'
    UNION ALL SELECT 'unknown', 'unknown'
) x
WHERE x.pt NOT IN (SELECT product_category_name FROM category_translation);

-- Check: categories still without an English name (should return 0 rows)
SELECT DISTINCT p.product_category_name
FROM products p
LEFT JOIN category_translation t ON t.product_category_name = p.product_category_name
WHERE t.product_category_name IS NULL;

SET SQL_SAFE_UPDATES = 1;
