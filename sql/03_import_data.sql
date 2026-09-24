-- ============================================================
-- 03_import_data.sql
-- Olist E-Commerce Data Import
-- Purpose: Load cleaned CSV files into the MySQL tables.
-- ============================================================

-- NOTE:
-- CSV files were imported using MySQL Workbench
-- Table Data Import Wizard.

-- Source directory:
-- C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/


-- ============================================================
-- CSV → MySQL table mapping
-- ============================================================

-- olist_customers_dataset.csv
--              → customers

-- olist_orders_dataset.csv
--              → orders

-- olist_order_items_dataset.csv
--              → order_items

-- olist_order_payments_dataset.csv
--              → order_payments

-- olist_order_reviews_dataset.csv
--              → order_reviews

-- olist_products_dataset.csv
--              → products

-- olist_sellers_dataset.csv
--              → sellers

-- olist_geolocation_dataset.csv
--              → geolocation

-- product_category_name_translation.csv
--              → category_translation


-- ============================================================
-- 1. IMPORT CUSTOMERS
-- ============================================================

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ============================================================
-- 2. IMPORT ORDER ITEMS
-- ============================================================

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ============================================================
-- 3. IMPORT ORDERS
-- Uses cleaned order data.
-- ============================================================

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders_clean.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ============================================================
-- 4. IMPORT ORDER PAYMENTS
-- ============================================================

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ============================================================
-- 5. IMPORT ORDER REVIEWS
-- Uses cleaned review data.
-- ============================================================

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_reviews_clean.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ============================================================
-- 6. IMPORT GEOLOCATION DATA
-- ============================================================

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_geolocation_dataset.csv'
INTO TABLE geolocation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ============================================================
-- 7. IMPORT PRODUCT CATEGORY TRANSLATIONS
-- ============================================================

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product_category_name_translation.csv'
INTO TABLE category_translation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ============================================================
-- 8. IMPORT SELLERS
-- ============================================================

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ============================================================
-- 9. IMPORT PRODUCTS
-- Handles empty numeric fields by converting them to NULL.
-- ============================================================

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    product_id,
    product_category_name,
    @product_name_length,
    @product_description_length,
    @product_photos_qty,
    @product_weight_g,
    @product_length_cm,
    @product_height_cm,
    @product_width_cm
)
SET
    product_name_length = NULLIF(@product_name_length, ''),
    product_description_length = NULLIF(@product_description_length, ''),
    product_photos_qty = NULLIF(@product_photos_qty, ''),
    product_weight_g = NULLIF(@product_weight_g, ''),
    product_length_cm = NULLIF(@product_length_cm, ''),
    product_height_cm = NULLIF(@product_height_cm, ''),
    product_width_cm = NULLIF(@product_width_cm, '');


-- ============================================================
-- 10. VERIFY IMPORTED TABLES
-- ============================================================

SHOW TABLES;