-- ============================================================
-- Olist E-Commerce Database Schema
-- Purpose: Create database tables for the Olist E-Commerce
--          SQL analysis project.
-- ============================================================

USE olist_ecommerce;


-- ============================================================
-- 1. CUSTOMERS TABLE
-- Stores customer information and location details.
-- ============================================================

CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);


-- ============================================================
-- 2. ORDERS TABLE
-- Stores order-level information, status, and delivery dates.
-- ============================================================

CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);


-- ============================================================
-- 3. ORDER ITEMS TABLE
-- Stores products purchased within each order,
-- including seller, price, and freight information.
-- ============================================================

CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),

    PRIMARY KEY (order_id, order_item_id)
);


-- ============================================================
-- 4. ORDER PAYMENTS TABLE
-- Stores payment methods, installments, and payment values.
-- ============================================================

CREATE TABLE order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10,2),

    PRIMARY KEY (order_id, payment_sequential)
);


-- ============================================================
-- 5. ORDER REVIEWS TABLE
-- Stores customer review scores and review comments.
-- ============================================================

CREATE TABLE order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);


-- ============================================================
-- 6. PRODUCTS TABLE
-- Stores product categories, dimensions, weight,
-- description length, and number of photos.
-- ============================================================

CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);


-- ============================================================
-- 7. SELLERS TABLE
-- Stores seller identification and location details.
-- ============================================================

CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);


-- ============================================================
-- 8. GEOLOCATION TABLE
-- Stores geographical coordinates and location information
-- associated with Brazilian ZIP code prefixes.
-- ============================================================

CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat DECIMAL(10,7),
    geolocation_lng DECIMAL(10,7),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(10)
);


-- ============================================================
-- 9. CATEGORY TRANSLATION TABLE
-- Maps Portuguese product category names to English names.
-- ============================================================

CREATE TABLE category_translation (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);


-- ============================================================
-- DATABASE VERIFICATION
-- ============================================================

-- Display all tables created in the database.
SHOW TABLES;


-- Check MySQL's permitted directory for LOAD DATA INFILE.
SHOW VARIABLES LIKE 'secure_file_priv';


-- Check whether LOCAL INFILE is enabled.
SHOW VARIABLES LIKE 'local_infile';

-- Enable LOCAL INFILE for the current MySQL server session.
-- Required when using LOAD DATA LOCAL INFILE.
SET GLOBAL local_infile = 1;
INSERT INTO category_translation
    (product_category_name, product_category_name_english)
VALUES
    ('pc_gamer', 'gaming computer'),
    ('portateis_cozinha_e_preparadores_de_alimentos', 'portable kitchen and food preparers');
    
SELECT
    COUNT(*) AS total,
    SUM(product_category_name IS NULL) AS null_categories,
    SUM(product_category_name = '') AS empty_categories
FROM products;

UPDATE products
SET product_category_name = NULL
WHERE product_category_name = '';