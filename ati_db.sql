-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Mar 16, 2026 at 11:10 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.0.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ati_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`, `created_at`) VALUES
(1, 'Pharmaceuticals', '2026-03-02 14:57:03'),
(2, 'Medical Devices', '2026-03-02 14:57:03'),
(3, 'Surgical Supplies', '2026-03-02 14:57:03'),
(4, 'General Merchandise', '2026-03-02 14:57:03');

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `type` varchar(50) NOT NULL DEFAULT 'general' COMMENT 'doctor, pharmacy, wholesaler…',
  `phone` varchar(30) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `created_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`id`, `name`, `type`, `phone`, `email`, `address`, `created_by`, `created_at`, `updated_at`) VALUES
(8, 'Dr. Sameer Khan', 'doctor', '03001234567', 'sameer.khan@example.com', 'Gulshan-e-Iqbal, Karachi', 1, '2026-03-16 06:06:11', '2026-03-16 06:06:11'),
(9, 'City Care Pharmacy', 'pharmacy', '03111234567', 'citycare@example.com', 'Clifton Block 5, Karachi', 1, '2026-03-16 06:06:11', '2026-03-16 06:06:11'),
(10, 'Al Noor Hospital', 'hospital', '03221234567', 'procurement@alnoorhospital.com', 'Shahrah-e-Faisal, Karachi', 1, '2026-03-16 06:06:11', '2026-03-16 06:06:11'),
(11, 'Curl Customer 1773646552', 'pharmacy', '0311773646552', 'curl_customer_1773646552@test.com', 'Test', 1, '2026-03-16 07:35:53', '2026-03-16 07:35:53');

-- --------------------------------------------------------

--
-- Table structure for table `inventory_log`
--

CREATE TABLE `inventory_log` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `variant_unit_id` int(10) UNSIGNED NOT NULL,
  `quantity` decimal(14,4) NOT NULL COMMENT 'positive = in, negative = out',
  `action` enum('handover','sold','returned') NOT NULL,
  `related_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'quotation_id or invoice_id',
  `user_id` int(10) UNSIGNED DEFAULT NULL,
  `note` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inventory_log`
--

INSERT INTO `inventory_log` (`id`, `variant_unit_id`, `quantity`, `action`, `related_id`, `user_id`, `note`, `created_at`) VALUES
(1, 2, -2.0000, 'handover', 1, 1, 'Quotation #1 accepted', '2026-03-02 15:42:56'),
(2, 2, 2.0000, 'returned', 1, 1, 'Quotation #1 returned', '2026-03-02 15:42:56'),
(3, 3, -2.0000, 'handover', 3, 1, 'Quotation #3 accepted', '2026-03-02 15:43:47'),
(4, 3, 2.0000, 'returned', 3, 1, 'Quotation #3 returned', '2026-03-02 15:43:47'),
(5, 4, -2.0000, 'handover', 5, 1, 'Quotation #5 accepted', '2026-03-02 15:44:52'),
(6, 4, 2.0000, 'returned', 5, 1, 'Quotation #5 returned', '2026-03-02 15:44:52'),
(15, 14, -2.0000, 'handover', 15, 1, 'Quotation #15 accepted', '2026-03-16 07:35:54');

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id` int(10) UNSIGNED NOT NULL,
  `invoice_id` int(10) UNSIGNED NOT NULL,
  `amount_paid` decimal(14,2) NOT NULL,
  `payment_date` date NOT NULL,
  `method` varchar(50) DEFAULT NULL COMMENT 'cash, bank_transfer…',
  `reference` varchar(100) DEFAULT NULL,
  `received_by` int(10) UNSIGNED DEFAULT NULL,
  `note` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`id`, `invoice_id`, `amount_paid`, `payment_date`, `method`, `reference`, `received_by`, `note`, `created_at`) VALUES
(1, 1, 100.00, '2026-03-02', 'cash', 'PAY-T01', 1, NULL, '2026-03-02 15:42:56'),
(2, 2, 100.00, '2026-03-02', 'cash', 'PAY-T01', 1, NULL, '2026-03-02 15:43:47');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(200) NOT NULL,
  `category_id` int(10) UNSIGNED DEFAULT NULL,
  `product_code` varchar(50) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `name`, `category_id`, `product_code`, `description`, `is_active`, `created_at`, `updated_at`) VALUES
(12, 'Digital Stethoscope Pro', 2, 'ATI-PRD-1001', 'High-fidelity auscultation device for cardiology and general practice', 1, '2026-03-16 06:06:11', '2026-03-16 06:06:11'),
(13, 'Latex Surgical Gloves', 3, 'ATI-PRD-1002', 'Sterile powder-free gloves for operation theaters', 1, '2026-03-16 06:06:11', '2026-03-16 06:06:11'),
(14, 'Paracetamol 500mg', 1, 'ATI-PRD-1003', 'Analgesic and antipyretic tablet strip', 1, '2026-03-16 06:06:11', '2026-03-16 06:06:11'),
(15, 'BP Monitor Auto', 2, 'ATI-PRD-1004', 'Automatic blood pressure monitor with digital display', 1, '2026-03-16 06:06:11', '2026-03-16 06:06:11'),
(16, 'CurlProd_1773646552', NULL, 'ATI-20260316-84249', NULL, 1, '2026-03-16 07:35:52', '2026-03-16 07:35:52');

-- --------------------------------------------------------

--
-- Table structure for table `product_variants`
--

CREATE TABLE `product_variants` (
  `id` int(10) UNSIGNED NOT NULL,
  `product_id` int(10) UNSIGNED NOT NULL,
  `attributes` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`attributes`)),
  `sku` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `product_variants`
--

INSERT INTO `product_variants` (`id`, `product_id`, `attributes`, `sku`, `is_active`, `created_at`, `updated_at`) VALUES
(9, 12, '{\"model\": \"DSP-1\", \"color\": \"black\"}', 'ATI-SKU-2001', 1, '2026-03-16 06:06:11', '2026-03-16 06:06:11'),
(10, 13, '{\"size\": \"M\", \"sterile\": \"yes\"}', 'ATI-SKU-2002', 1, '2026-03-16 06:06:11', '2026-03-16 06:06:11'),
(11, 13, '{\"size\": \"L\", \"sterile\": \"yes\"}', 'ATI-SKU-2003', 1, '2026-03-16 06:06:11', '2026-03-16 06:06:11'),
(12, 14, '{\"strength\": \"500mg\", \"form\": \"tablet\"}', 'ATI-SKU-2004', 1, '2026-03-16 06:06:11', '2026-03-16 06:06:11'),
(13, 15, '{\"model\": \"BPA-2\", \"cuff\": \"adult\"}', 'ATI-SKU-2005', 1, '2026-03-16 06:06:11', '2026-03-16 06:06:11'),
(14, 16, '{\"color\":\"blue\"}', 'CURLSKU_1773646552', 1, '2026-03-16 07:35:52', '2026-03-16 07:35:52');

-- --------------------------------------------------------

--
-- Table structure for table `quotation_items`
--

CREATE TABLE `quotation_items` (
  `id` int(10) UNSIGNED NOT NULL,
  `quotation_id` int(10) UNSIGNED NOT NULL,
  `variant_unit_id` int(10) UNSIGNED NOT NULL,
  `quantity` decimal(14,4) NOT NULL,
  `unit_price` decimal(14,2) NOT NULL COMMENT 'price snapshotted at quote time'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `quotation_items`
--

INSERT INTO `quotation_items` (`id`, `quotation_id`, `variant_unit_id`, `quantity`, `unit_price`) VALUES
(1, 1, 2, 2.0000, 150.00),
(2, 2, 2, 1.0000, 150.00),
(3, 3, 3, 2.0000, 150.00),
(4, 4, 3, 1.0000, 150.00),
(15, 15, 14, 2.0000, 150.00);

-- --------------------------------------------------------

--
-- Table structure for table `quotation_requests`
--

CREATE TABLE `quotation_requests` (
  `id` int(10) UNSIGNED NOT NULL,
  `salesman_id` int(10) UNSIGNED NOT NULL,
  `customer_id` int(10) UNSIGNED DEFAULT NULL,
  `status` enum('pending','accepted','returned','rejected') NOT NULL DEFAULT 'pending',
  `note` text DEFAULT NULL,
  `editor_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'editor who acted on this quote',
  `requested_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `processed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `quotation_requests`
--

INSERT INTO `quotation_requests` (`id`, `salesman_id`, `customer_id`, `status`, `note`, `editor_id`, `requested_at`, `processed_at`) VALUES
(1, 1, 1, 'returned', 'Test quotation', 1, '2026-03-02 15:42:56', '2026-03-02 15:42:56'),
(2, 1, 1, 'rejected', 'Reject me', 1, '2026-03-02 15:42:56', '2026-03-02 15:42:56'),
(3, 1, 2, 'returned', 'Test quotation', 1, '2026-03-02 15:43:47', '2026-03-02 15:43:47'),
(4, 1, 2, 'rejected', 'Reject me', 1, '2026-03-02 15:43:47', '2026-03-02 15:43:47'),
(15, 1, 11, 'accepted', 'curl quote', 1, '2026-03-16 07:35:54', '2026-03-16 07:35:54');

-- --------------------------------------------------------

--
-- Table structure for table `sales_invoices`
--

CREATE TABLE `sales_invoices` (
  `id` int(10) UNSIGNED NOT NULL,
  `quotation_id` int(10) UNSIGNED NOT NULL,
  `customer_id` int(10) UNSIGNED NOT NULL,
  `date` date NOT NULL,
  `total_amount` decimal(14,2) NOT NULL DEFAULT 0.00,
  `status` enum('active','returned','void') NOT NULL DEFAULT 'active',
  `created_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sales_invoices`
--

INSERT INTO `sales_invoices` (`id`, `quotation_id`, `customer_id`, `date`, `total_amount`, `status`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2026-03-02', 300.00, 'returned', 1, '2026-03-02 15:42:56', '2026-03-02 15:42:56'),
(2, 3, 2, '2026-03-02', 300.00, 'returned', 1, '2026-03-02 15:43:47', '2026-03-02 15:43:47'),
(8, 15, 11, '2026-03-16', 300.00, 'active', 1, '2026-03-16 07:35:54', '2026-03-16 07:35:54');

-- --------------------------------------------------------

--
-- Table structure for table `units`
--

CREATE TABLE `units` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `multiplier` decimal(10,4) NOT NULL DEFAULT 1.0000 COMMENT 'conversion factor to base unit',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `units`
--

INSERT INTO `units` (`id`, `name`, `multiplier`, `created_at`) VALUES
(1, 'piece', 1.0000, '2026-03-02 14:57:03'),
(2, 'box of 10', 10.0000, '2026-03-02 14:57:03'),
(3, 'box of 50', 50.0000, '2026-03-02 14:57:03'),
(4, 'carton', 100.0000, '2026-03-02 14:57:03'),
(5, 'dozen', 12.0000, '2026-03-02 14:57:03'),
(16, 'CurlUnit_1773646552', 5.0000, '2026-03-16 07:35:53');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('superadmin','editor','viewer','salesman') NOT NULL DEFAULT 'viewer',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `role`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'System Admin', 'admin@ati.local', '$2y$12$ALTH6Nu6WEvYD/id.Ft5n.YRUC4/wMAlZMNwcrOwm99SHwDvtae5i', 'superadmin', 1, '2026-03-02 14:57:03', '2026-03-02 14:57:03'),
(13, 'Ali Sales', 'salesman@ati.local', '$2y$12$ld/Yceu0W7XNJKodknKp0OvbB1AD1QyMey4FTYvoXl6YlywHyQQUi', 'salesman', 1, '2026-03-16 05:55:35', '2026-03-16 05:55:35'),
(15, 'Editor User', 'editor@ati.local', '$2y$12$M9AAUzmz5azni3ZiW/MyDOw9v7k8yS3FxGyon0N353m9WUg8cyZO6', 'editor', 1, '2026-03-16 06:06:11', '2026-03-16 06:06:11'),
(16, 'Viewer User', 'viewer@ati.local', '$2y$12$M9AAUzmz5azni3ZiW/MyDOw9v7k8yS3FxGyon0N353m9WUg8cyZO6', 'viewer', 1, '2026-03-16 06:06:11', '2026-03-16 06:06:11'),
(17, 'Curl User 1773646453', 'curl_user_1773646453@ati.local', '$2y$12$BY806xdIBhLAIrGovjsHLegU0ctuFhXWMVLBW3Vwn10ej6/L5UTnq', 'viewer', 1, '2026-03-16 07:34:13', '2026-03-16 07:34:13');

-- --------------------------------------------------------

--
-- Table structure for table `variant_units`
--

CREATE TABLE `variant_units` (
  `id` int(10) UNSIGNED NOT NULL,
  `variant_id` int(10) UNSIGNED NOT NULL,
  `unit_id` int(10) UNSIGNED NOT NULL,
  `stock_quantity` decimal(14,4) NOT NULL DEFAULT 0.0000,
  `unit_price` decimal(14,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `variant_units`
--

INSERT INTO `variant_units` (`id`, `variant_id`, `unit_id`, `stock_quantity`, `unit_price`, `created_at`, `updated_at`) VALUES
(9, 9, 1, 25.0000, 8500.00, '2026-03-16 06:06:11', '2026-03-16 06:06:11'),
(10, 10, 2, 120.0000, 450.00, '2026-03-16 06:06:11', '2026-03-16 06:06:11'),
(11, 11, 2, 110.0000, 480.00, '2026-03-16 06:06:11', '2026-03-16 06:06:11'),
(12, 12, 3, 75.0000, 320.00, '2026-03-16 06:06:11', '2026-03-16 06:06:11'),
(13, 13, 1, 40.0000, 5600.00, '2026-03-16 06:06:11', '2026-03-16 06:06:11'),
(14, 14, 16, 48.0000, 150.00, '2026-03-16 07:35:53', '2026-03-16 07:35:54');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_categories_name` (`name`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_customers_type` (`type`),
  ADD KEY `idx_customers_created_by` (`created_by`);

--
-- Indexes for table `inventory_log`
--
ALTER TABLE `inventory_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_invlog_variant_unit` (`variant_unit_id`),
  ADD KEY `idx_invlog_action` (`action`),
  ADD KEY `idx_invlog_created` (`created_at`),
  ADD KEY `idx_invlog_user` (`user_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_payments_invoice` (`invoice_id`),
  ADD KEY `idx_payments_date` (`payment_date`),
  ADD KEY `idx_payments_received_by` (`received_by`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_products_code` (`product_code`),
  ADD KEY `idx_products_category` (`category_id`);

--
-- Indexes for table `product_variants`
--
ALTER TABLE `product_variants`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_variants_sku` (`sku`),
  ADD KEY `idx_variants_product` (`product_id`);

--
-- Indexes for table `quotation_items`
--
ALTER TABLE `quotation_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_qi_quotation` (`quotation_id`),
  ADD KEY `idx_qi_variant_unit` (`variant_unit_id`);

--
-- Indexes for table `quotation_requests`
--
ALTER TABLE `quotation_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_qr_salesman` (`salesman_id`),
  ADD KEY `idx_qr_customer` (`customer_id`),
  ADD KEY `idx_qr_status` (`status`),
  ADD KEY `idx_qr_editor` (`editor_id`),
  ADD KEY `idx_qr_requested` (`requested_at`);

--
-- Indexes for table `sales_invoices`
--
ALTER TABLE `sales_invoices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_invoice_quotation` (`quotation_id`),
  ADD KEY `idx_invoice_customer` (`customer_id`),
  ADD KEY `idx_invoice_date` (`date`),
  ADD KEY `idx_invoice_status` (`status`),
  ADD KEY `idx_invoice_created_by` (`created_by`);

--
-- Indexes for table `units`
--
ALTER TABLE `units`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_units_name` (`name`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_users_email` (`email`);

--
-- Indexes for table `variant_units`
--
ALTER TABLE `variant_units`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_variant_unit` (`variant_id`,`unit_id`),
  ADD KEY `idx_vu_variant` (`variant_id`),
  ADD KEY `idx_vu_unit` (`unit_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `inventory_log`
--
ALTER TABLE `inventory_log`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `product_variants`
--
ALTER TABLE `product_variants`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `quotation_items`
--
ALTER TABLE `quotation_items`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `quotation_requests`
--
ALTER TABLE `quotation_requests`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `sales_invoices`
--
ALTER TABLE `sales_invoices`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `units`
--
ALTER TABLE `units`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `variant_units`
--
ALTER TABLE `variant_units`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `customers`
--
ALTER TABLE `customers`
  ADD CONSTRAINT `fk_customers_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `inventory_log`
--
ALTER TABLE `inventory_log`
  ADD CONSTRAINT `fk_invlog_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_invlog_variant_unit` FOREIGN KEY (`variant_unit_id`) REFERENCES `variant_units` (`id`) ON UPDATE CASCADE;

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `fk_payments_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `sales_invoices` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_payments_received_by` FOREIGN KEY (`received_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `product_variants`
--
ALTER TABLE `product_variants`
  ADD CONSTRAINT `fk_variants_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `quotation_items`
--
ALTER TABLE `quotation_items`
  ADD CONSTRAINT `fk_qi_quotation` FOREIGN KEY (`quotation_id`) REFERENCES `quotation_requests` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_qi_variant_unit` FOREIGN KEY (`variant_unit_id`) REFERENCES `variant_units` (`id`) ON UPDATE CASCADE;

--
-- Constraints for table `quotation_requests`
--
ALTER TABLE `quotation_requests`
  ADD CONSTRAINT `fk_qr_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_qr_editor` FOREIGN KEY (`editor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_qr_salesman` FOREIGN KEY (`salesman_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE;

--
-- Constraints for table `sales_invoices`
--
ALTER TABLE `sales_invoices`
  ADD CONSTRAINT `fk_invoice_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_invoice_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_invoice_quotation` FOREIGN KEY (`quotation_id`) REFERENCES `quotation_requests` (`id`) ON UPDATE CASCADE;

--
-- Constraints for table `variant_units`
--
ALTER TABLE `variant_units`
  ADD CONSTRAINT `fk_vu_unit` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_vu_variant` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
