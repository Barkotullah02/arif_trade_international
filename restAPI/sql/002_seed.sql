-- ============================================================
-- ATI – Seed Data
-- Run AFTER 001_schema.sql
-- ============================================================

USE ati_db;

-- Default units
INSERT IGNORE INTO units (name, multiplier) VALUES
    ('piece',     1.0000),
    ('box of 10', 10.0000),
    ('box of 50', 50.0000),
    ('carton',    100.0000),
    ('dozen',     12.0000);

-- Default categories
INSERT IGNORE INTO categories (name) VALUES
    ('Pharmaceuticals'),
    ('Medical Devices'),
    ('Surgical Supplies'),
    ('General Merchandise');

-- Superadmin user  (default password: Admin@1234  – CHANGE IN PRODUCTION)
-- Regenerate hash: php -r "echo password_hash('YOUR_PASSWORD', PASSWORD_BCRYPT, ['cost'=>12]);"
INSERT IGNORE INTO users (name, email, password_hash, role) VALUES
    ('System Admin', 'admin@ati.local',
    '$2y$12$dWocNLz2xXy2LpwGjzde4u2tYS4EJ3EqbBl9Y.rOcs7Kfuw7zkneS',
     'superadmin');

-- Salesman user for mobile app login (default password: Sales@1234)
INSERT IGNORE INTO users (name, email, password_hash, role) VALUES
    ('Ali Sales', 'salesman@ati.local',
    '$2y$12$E0p6euXNC58mzgO4chlpu.MrqPz66R9L7th9MxvECI4LeyQ/DsG5.',
    'salesman');
