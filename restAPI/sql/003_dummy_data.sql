-- ============================================================
-- ATI – Non-destructive Dummy Data Seed
-- Run AFTER 001_schema.sql and 002_seed.sql
-- Safe to run multiple times (idempotent inserts)
-- ============================================================

USE ati_db;

-- Optional supporting users for testing permissions
INSERT IGNORE INTO users (name, email, password_hash, role) VALUES
    ('Editor User', 'editor@ati.local', '$2y$12$M9AAUzmz5azni3ZiW/MyDOw9v7k8yS3FxGyon0N353m9WUg8cyZO6', 'editor'),
    ('Viewer User', 'viewer@ati.local', '$2y$12$M9AAUzmz5azni3ZiW/MyDOw9v7k8yS3FxGyon0N353m9WUg8cyZO6', 'viewer');
-- Password for editor/viewer above: Demo@1234

-- Products
INSERT IGNORE INTO products (name, category_id, product_code, description, is_active)
VALUES
    (
        'Digital Stethoscope Pro',
        (SELECT id FROM categories WHERE name = 'Medical Devices' LIMIT 1),
        'ATI-PRD-1001',
        'High-fidelity auscultation device for cardiology and general practice',
        1
    ),
    (
        'Latex Surgical Gloves',
        (SELECT id FROM categories WHERE name = 'Surgical Supplies' LIMIT 1),
        'ATI-PRD-1002',
        'Sterile powder-free gloves for operation theaters',
        1
    ),
    (
        'Paracetamol 500mg',
        (SELECT id FROM categories WHERE name = 'Pharmaceuticals' LIMIT 1),
        'ATI-PRD-1003',
        'Analgesic and antipyretic tablet strip',
        1
    ),
    (
        'BP Monitor Auto',
        (SELECT id FROM categories WHERE name = 'Medical Devices' LIMIT 1),
        'ATI-PRD-1004',
        'Automatic blood pressure monitor with digital display',
        1
    );

-- Product variants
INSERT IGNORE INTO product_variants (product_id, attributes, sku, is_active)
VALUES
    (
        (SELECT id FROM products WHERE product_code = 'ATI-PRD-1001' LIMIT 1),
        JSON_OBJECT('model', 'DSP-1', 'color', 'black'),
        'ATI-SKU-2001',
        1
    ),
    (
        (SELECT id FROM products WHERE product_code = 'ATI-PRD-1002' LIMIT 1),
        JSON_OBJECT('size', 'M', 'sterile', 'yes'),
        'ATI-SKU-2002',
        1
    ),
    (
        (SELECT id FROM products WHERE product_code = 'ATI-PRD-1002' LIMIT 1),
        JSON_OBJECT('size', 'L', 'sterile', 'yes'),
        'ATI-SKU-2003',
        1
    ),
    (
        (SELECT id FROM products WHERE product_code = 'ATI-PRD-1003' LIMIT 1),
        JSON_OBJECT('strength', '500mg', 'form', 'tablet'),
        'ATI-SKU-2004',
        1
    ),
    (
        (SELECT id FROM products WHERE product_code = 'ATI-PRD-1004' LIMIT 1),
        JSON_OBJECT('model', 'BPA-2', 'cuff', 'adult'),
        'ATI-SKU-2005',
        1
    );

-- Variant unit pricing and stock
INSERT IGNORE INTO variant_units (variant_id, unit_id, stock_quantity, unit_price)
VALUES
    (
        (SELECT id FROM product_variants WHERE sku = 'ATI-SKU-2001' LIMIT 1),
        (SELECT id FROM units WHERE name = 'piece' LIMIT 1),
        25,
        8500
    ),
    (
        (SELECT id FROM product_variants WHERE sku = 'ATI-SKU-2002' LIMIT 1),
        (SELECT id FROM units WHERE name = 'box of 10' LIMIT 1),
        120,
        450
    ),
    (
        (SELECT id FROM product_variants WHERE sku = 'ATI-SKU-2003' LIMIT 1),
        (SELECT id FROM units WHERE name = 'box of 10' LIMIT 1),
        110,
        480
    ),
    (
        (SELECT id FROM product_variants WHERE sku = 'ATI-SKU-2004' LIMIT 1),
        (SELECT id FROM units WHERE name = 'box of 50' LIMIT 1),
        75,
        320
    ),
    (
        (SELECT id FROM product_variants WHERE sku = 'ATI-SKU-2005' LIMIT 1),
        (SELECT id FROM units WHERE name = 'piece' LIMIT 1),
        40,
        5600
    );

-- Customers (insert only when a matching name+phone pair does not exist)
INSERT INTO customers (name, type, phone, email, address, created_by)
SELECT 'Dr. Sameer Khan', 'doctor', '03001234567', 'sameer.khan@example.com', 'Gulshan-e-Iqbal, Karachi',
       (SELECT id FROM users WHERE email = 'admin@ati.local' LIMIT 1)
WHERE NOT EXISTS (
    SELECT 1 FROM customers WHERE name = 'Dr. Sameer Khan' AND phone = '03001234567'
);

INSERT INTO customers (name, type, phone, email, address, created_by)
SELECT 'City Care Pharmacy', 'pharmacy', '03111234567', 'citycare@example.com', 'Clifton Block 5, Karachi',
       (SELECT id FROM users WHERE email = 'admin@ati.local' LIMIT 1)
WHERE NOT EXISTS (
    SELECT 1 FROM customers WHERE name = 'City Care Pharmacy' AND phone = '03111234567'
);

INSERT INTO customers (name, type, phone, email, address, created_by)
SELECT 'Al Noor Hospital', 'hospital', '03221234567', 'procurement@alnoorhospital.com', 'Shahrah-e-Faisal, Karachi',
       (SELECT id FROM users WHERE email = 'admin@ati.local' LIMIT 1)
WHERE NOT EXISTS (
    SELECT 1 FROM customers WHERE name = 'Al Noor Hospital' AND phone = '03221234567'
);

-- Create sample pending quotation only when no quotations exist yet
INSERT INTO quotation_requests (salesman_id, customer_id, status, note)
SELECT
    (SELECT id FROM users WHERE email = 'salesman@ati.local' LIMIT 1),
    (SELECT id FROM customers WHERE name = 'Dr. Sameer Khan' LIMIT 1),
    'pending',
    'Demo quote for Android app testing'
WHERE (SELECT COUNT(*) FROM quotation_requests) = 0;

-- Add items to the sample quotation if it exists and has no items
INSERT INTO quotation_items (quotation_id, variant_unit_id, quantity, unit_price)
SELECT
    qr.id,
    (SELECT vu.id FROM variant_units vu JOIN product_variants pv ON pv.id = vu.variant_id WHERE pv.sku = 'ATI-SKU-2001' LIMIT 1),
    1,
    (SELECT vu.unit_price FROM variant_units vu JOIN product_variants pv ON pv.id = vu.variant_id WHERE pv.sku = 'ATI-SKU-2001' LIMIT 1)
FROM quotation_requests qr
WHERE qr.note = 'Demo quote for Android app testing'
  AND NOT EXISTS (SELECT 1 FROM quotation_items qi WHERE qi.quotation_id = qr.id);
