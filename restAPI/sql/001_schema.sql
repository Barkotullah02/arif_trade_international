-- ============================================================
-- ATI (Arif Trade International) – Core Schema
-- Engine: MySQL InnoDB | Charset: utf8mb4
-- ============================================================

CREATE DATABASE IF NOT EXISTS ati_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE ati_db;

SET FOREIGN_KEY_CHECKS = 0;
SET sql_mode = '';

-- ------------------------------------------------------------
-- 1. USERS (roles: superadmin | editor | viewer | salesman)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id            INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    name          VARCHAR(150)     NOT NULL,
    email         VARCHAR(150)     NOT NULL,
    password_hash VARCHAR(255)     NOT NULL,
    role          ENUM('superadmin','editor','viewer','salesman') NOT NULL DEFAULT 'viewer',
    is_active     TINYINT(1)       NOT NULL DEFAULT 1,
    created_at    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 2. CATEGORIES
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS categories (
    id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name       VARCHAR(100) NOT NULL,
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_categories_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 3. PRODUCTS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS products (
    id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name         VARCHAR(200) NOT NULL,
    category_id  INT UNSIGNED          DEFAULT NULL,
    product_code VARCHAR(50)  NOT NULL,
    description  TEXT                  DEFAULT NULL,
    expiry_date  DATE                  DEFAULT NULL,
    is_active    TINYINT(1)   NOT NULL DEFAULT 1,
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_products_code (product_code),
    KEY          idx_products_category (category_id),
    KEY          idx_products_expiry_date (expiry_date),
    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id) REFERENCES categories (id)
            ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 4. PRODUCT VARIANTS
--    attributes stored as JSON: {"size":"L","color":"red"}
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS product_variants (
    id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    product_id INT UNSIGNED NOT NULL,
    attributes JSON         NOT NULL,
    sku        VARCHAR(100)          DEFAULT NULL,
    is_active  TINYINT(1)   NOT NULL DEFAULT 1,
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_variants_sku (sku),
    KEY        idx_variants_product (product_id),
    CONSTRAINT fk_variants_product
        FOREIGN KEY (product_id) REFERENCES products (id)
            ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 5. UNITS  (e.g. "piece" multiplier=1, "box of 10" multiplier=10)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS units (
    id         INT UNSIGNED   NOT NULL AUTO_INCREMENT,
    name       VARCHAR(100)   NOT NULL,
    multiplier DECIMAL(10,4)  NOT NULL DEFAULT 1.0000 COMMENT 'conversion factor to base unit',
    created_at TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_units_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 6. VARIANT UNITS  – links each variant to its sellable units,
--    tracks stock and unit price per combination
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS variant_units (
    id             INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    variant_id     INT UNSIGNED  NOT NULL,
    unit_id        INT UNSIGNED  NOT NULL,
    stock_quantity DECIMAL(14,4) NOT NULL DEFAULT 0.0000,
    unit_price     DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    created_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_variant_unit (variant_id, unit_id),
    KEY            idx_vu_variant (variant_id),
    KEY            idx_vu_unit (unit_id),
    CONSTRAINT fk_vu_variant
        FOREIGN KEY (variant_id) REFERENCES product_variants (id)
            ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_vu_unit
        FOREIGN KEY (unit_id) REFERENCES units (id)
            ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 7. INVENTORY LOG
--    action: handover (stock given to salesman/customer)
--            sold     (invoice raised)
--            returned (stock back from customer)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS inventory_log (
    id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    variant_unit_id INT UNSIGNED    NOT NULL,
    quantity        DECIMAL(14,4)   NOT NULL COMMENT 'positive = in, negative = out',
    action          ENUM('handover','sold','returned') NOT NULL,
    related_id      INT UNSIGNED             DEFAULT NULL COMMENT 'quotation_id or invoice_id',
    user_id         INT UNSIGNED             DEFAULT NULL,
    note            TEXT                     DEFAULT NULL,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_invlog_variant_unit  (variant_unit_id),
    KEY idx_invlog_action        (action),
    KEY idx_invlog_created       (created_at),
    KEY idx_invlog_user          (user_id),
    CONSTRAINT fk_invlog_variant_unit
        FOREIGN KEY (variant_unit_id) REFERENCES variant_units (id)
            ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_invlog_user
        FOREIGN KEY (user_id) REFERENCES users (id)
            ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 8. CUSTOMERS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS customers (
    id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name       VARCHAR(150) NOT NULL,
    type       VARCHAR(50)  NOT NULL DEFAULT 'general' COMMENT 'doctor, pharmacy, wholesaler…',
    phone      VARCHAR(30)           DEFAULT NULL,
    email      VARCHAR(150)          DEFAULT NULL,
    address    TEXT                  DEFAULT NULL,
    created_by INT UNSIGNED          DEFAULT NULL,
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_customers_type       (type),
    KEY idx_customers_created_by (created_by),
    CONSTRAINT fk_customers_created_by
        FOREIGN KEY (created_by) REFERENCES users (id)
            ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 9. QUOTATION REQUESTS
--    status lifecycle: pending → accepted | rejected | returned
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS quotation_requests (
    id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
    salesman_id  INT UNSIGNED NOT NULL,
    customer_id  INT UNSIGNED          DEFAULT NULL,
    status       ENUM('pending','accepted','returned','rejected') NOT NULL DEFAULT 'pending',
    note         TEXT                  DEFAULT NULL,
    editor_id    INT UNSIGNED          DEFAULT NULL COMMENT 'editor who acted on this quote',
    requested_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP    NULL     DEFAULT NULL,
    PRIMARY KEY (id),
    KEY idx_qr_salesman   (salesman_id),
    KEY idx_qr_customer   (customer_id),
    KEY idx_qr_status     (status),
    KEY idx_qr_editor     (editor_id),
    KEY idx_qr_requested  (requested_at),
    CONSTRAINT fk_qr_salesman
        FOREIGN KEY (salesman_id) REFERENCES users (id)
            ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_qr_customer
        FOREIGN KEY (customer_id) REFERENCES customers (id)
            ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_qr_editor
        FOREIGN KEY (editor_id) REFERENCES users (id)
            ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 10. QUOTATION ITEMS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS quotation_items (
    id              INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    quotation_id    INT UNSIGNED  NOT NULL,
    variant_unit_id INT UNSIGNED  NOT NULL,
    quantity        DECIMAL(14,4) NOT NULL,
    unit_price      DECIMAL(14,2) NOT NULL COMMENT 'price snapshotted at quote time',
    PRIMARY KEY (id),
    KEY idx_qi_quotation    (quotation_id),
    KEY idx_qi_variant_unit (variant_unit_id),
    CONSTRAINT fk_qi_quotation
        FOREIGN KEY (quotation_id) REFERENCES quotation_requests (id)
            ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_qi_variant_unit
        FOREIGN KEY (variant_unit_id) REFERENCES variant_units (id)
            ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 11. SALES INVOICES
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sales_invoices (
    id           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    quotation_id INT UNSIGNED  NOT NULL,
    customer_id  INT UNSIGNED  NOT NULL,
    date         DATE          NOT NULL,
    total_amount DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    status       ENUM('active','returned','void') NOT NULL DEFAULT 'active',
    created_by   INT UNSIGNED           DEFAULT NULL,
    created_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_invoice_quotation (quotation_id),
    KEY         idx_invoice_customer  (customer_id),
    KEY         idx_invoice_date      (date),
    KEY         idx_invoice_status    (status),
    KEY         idx_invoice_created_by(created_by),
    CONSTRAINT fk_invoice_quotation
        FOREIGN KEY (quotation_id) REFERENCES quotation_requests (id)
            ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_invoice_customer
        FOREIGN KEY (customer_id) REFERENCES customers (id)
            ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_invoice_created_by
        FOREIGN KEY (created_by) REFERENCES users (id)
            ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 12. PAYMENTS  (multiple partial payments per invoice)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS payments (
    id           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    invoice_id   INT UNSIGNED  NOT NULL,
    amount_paid  DECIMAL(14,2) NOT NULL,
    payment_date DATE          NOT NULL,
    method       VARCHAR(50)            DEFAULT NULL COMMENT 'cash, bank_transfer…',
    reference    VARCHAR(100)           DEFAULT NULL,
    received_by  INT UNSIGNED           DEFAULT NULL,
    note         TEXT                   DEFAULT NULL,
    created_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_payments_invoice     (invoice_id),
    KEY idx_payments_date        (payment_date),
    KEY idx_payments_received_by (received_by),
    CONSTRAINT fk_payments_invoice
        FOREIGN KEY (invoice_id) REFERENCES sales_invoices (id)
            ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_payments_received_by
        FOREIGN KEY (received_by) REFERENCES users (id)
            ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 13. LOTS (product-level lots/batches)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lots (
    id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    product_id  INT UNSIGNED NOT NULL,
    name        VARCHAR(120) NOT NULL,
    description VARCHAR(255)          DEFAULT NULL,
    expiry_date DATE                  DEFAULT NULL,
    is_active   TINYINT(1)   NOT NULL DEFAULT 1,
    created_by  INT UNSIGNED          DEFAULT NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_lots_product_name (product_id, name),
    KEY idx_lots_product (product_id),
    KEY idx_lots_active (is_active),
    KEY idx_lots_expiry_date (expiry_date),
    CONSTRAINT fk_lots_product
        FOREIGN KEY (product_id) REFERENCES products (id)
            ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_lots_created_by
        FOREIGN KEY (created_by) REFERENCES users (id)
            ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 14. LOT STOCKS (variant-unit quantity per lot)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lot_stocks (
    id             INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    lot_id         INT UNSIGNED  NOT NULL,
    variant_unit_id INT UNSIGNED NOT NULL,
    quantity_total DECIMAL(14,4) NOT NULL DEFAULT 0.0000,
    quantity_sold  DECIMAL(14,4) NOT NULL DEFAULT 0.0000,
    created_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_lot_stocks_lot_variant_unit (lot_id, variant_unit_id),
    KEY idx_lot_stocks_lot (lot_id),
    KEY idx_lot_stocks_variant_unit (variant_unit_id),
    CONSTRAINT fk_lot_stocks_lot
        FOREIGN KEY (lot_id) REFERENCES lots (id)
            ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_lot_stocks_variant_unit
        FOREIGN KEY (variant_unit_id) REFERENCES variant_units (id)
            ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 15. LOT ASSIGNMENTS (explicit lot split per quotation item)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lot_assignments (
    id                INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    quotation_item_id INT UNSIGNED  NOT NULL,
    lot_id            INT UNSIGNED  NOT NULL,
    quantity          DECIMAL(14,4) NOT NULL,
    created_at        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_lot_assignments_qi (quotation_item_id),
    KEY idx_lot_assignments_lot (lot_id),
    CONSTRAINT fk_lot_assignments_qi
        FOREIGN KEY (quotation_item_id) REFERENCES quotation_items (id)
            ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_lot_assignments_lot
        FOREIGN KEY (lot_id) REFERENCES lots (id)
            ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
