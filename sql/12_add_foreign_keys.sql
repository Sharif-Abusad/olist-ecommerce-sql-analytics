USE olist_ecommerce;

-- ============================================================
-- 12_add_foreign_keys.sql
-- Olist E-Commerce Database
-- Add foreign-key relationships between related tables
-- ============================================================


-- ============================================================
-- 1. ORDERS → CUSTOMERS
-- Each order belongs to a customer
-- ============================================================

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);


-- ============================================================
-- 2. ORDER_ITEMS → ORDERS
-- Each order item belongs to an order
-- ============================================================

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);


-- ============================================================
-- 3. ORDER_ITEMS → PRODUCTS
-- Each order item references a product
-- ============================================================

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_product
FOREIGN KEY (product_id)
REFERENCES products(product_id);


-- ============================================================
-- 4. ORDER_ITEMS → SELLERS
-- Each order item is associated with a seller
-- ============================================================

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_seller
FOREIGN KEY (seller_id)
REFERENCES sellers(seller_id);


-- ============================================================
-- 5. ORDER_PAYMENTS → ORDERS
-- Each payment record belongs to an order
-- ============================================================

ALTER TABLE order_payments
ADD CONSTRAINT fk_order_payments_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);


-- ============================================================
-- 6. ORDER_REVIEWS → ORDERS
-- Each review is associated with an order
-- ============================================================

ALTER TABLE order_reviews
ADD CONSTRAINT fk_order_reviews_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);


-- ============================================================
-- 7. PRODUCTS → CATEGORY TRANSLATION
-- Product categories can be mapped to English translations
-- ============================================================
ALTER TABLE products
ADD CONSTRAINT fk_products_category
FOREIGN KEY (product_category_name)
REFERENCES category_translation(product_category_name);


-- ============================================================
-- FOREIGN KEY VALIDATION
-- Display all foreign keys created for this database
-- ============================================================

SELECT
    TABLE_NAME,
    CONSTRAINT_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'olist_ecommerce'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME;