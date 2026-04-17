-- Add optional expiry tracking for products and lots
USE ati_db;

SET @products_col_exists := (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'products'
      AND COLUMN_NAME = 'expiry_date'
);
SET @products_col_sql := IF(
    @products_col_exists = 0,
    'ALTER TABLE products ADD COLUMN expiry_date DATE NULL AFTER description',
    'SELECT 1'
);
PREPARE stmt FROM @products_col_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @products_idx_exists := (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'products'
      AND INDEX_NAME = 'idx_products_expiry_date'
);
SET @products_idx_sql := IF(
    @products_idx_exists = 0,
    'ALTER TABLE products ADD INDEX idx_products_expiry_date (expiry_date)',
    'SELECT 1'
);
PREPARE stmt FROM @products_idx_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @lots_col_exists := (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'lots'
      AND COLUMN_NAME = 'expiry_date'
);
SET @lots_col_sql := IF(
    @lots_col_exists = 0,
    'ALTER TABLE lots ADD COLUMN expiry_date DATE NULL AFTER description',
    'SELECT 1'
);
PREPARE stmt FROM @lots_col_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @lots_idx_exists := (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'lots'
      AND INDEX_NAME = 'idx_lots_expiry_date'
);
SET @lots_idx_sql := IF(
    @lots_idx_exists = 0,
    'ALTER TABLE lots ADD INDEX idx_lots_expiry_date (expiry_date)',
    'SELECT 1'
);
PREPARE stmt FROM @lots_idx_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
