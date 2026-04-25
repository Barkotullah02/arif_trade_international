-- MySQL dump 10.13  Distrib 8.0.45, for Linux (x86_64)
--
-- Host: localhost    Database: ati_db
-- ------------------------------------------------------
-- Server version	8.0.45-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_categories_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=96 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'Pharmaceuticals','2026-03-02 14:57:03'),(2,'Medical Devices','2026-03-02 14:57:03'),(3,'Surgical Supplies','2026-03-02 14:57:03'),(4,'General Merchandise','2026-03-02 14:57:03');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'general' COMMENT 'doctor, pharmacy, wholesaler…',
  `phone` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_customers_type` (`type`),
  KEY `idx_customers_created_by` (`created_by`),
  CONSTRAINT `fk_customers_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=87 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (8,'Dr. Sameer Khan','doctor','03001234567','sameer.khan@example.com','Gulshan-e-Iqbal, Karachi',1,'2026-03-16 06:06:11','2026-03-16 06:06:11'),(9,'City Care Pharmacy','pharmacy','03111234567','citycare@example.com','Clifton Block 5, Karachi',1,'2026-03-16 06:06:11','2026-03-16 06:06:11'),(10,'Al Noor Hospital','hospital','03221234567','procurement@alnoorhospital.com','Shahrah-e-Faisal, Karachi',1,'2026-03-16 06:06:11','2026-03-16 06:06:11'),(11,'Curl Customer 1773646552','pharmacy','0311773646552','curl_customer_1773646552@test.com','Test',1,'2026-03-16 07:35:53','2026-03-16 07:35:53'),(13,'API Test Customer','general',NULL,'api-test-customer.1774698586@ati.local',NULL,1,'2026-03-28 11:49:48','2026-03-28 11:49:48'),(14,'API Test Customer','general',NULL,'api-test-customer.1774698612@ati.local',NULL,1,'2026-03-28 11:50:13','2026-03-28 11:50:13'),(15,'API Test Customer','general',NULL,'api-test-customer.1774698822@ati.local',NULL,1,'2026-03-28 11:53:44','2026-03-28 11:53:44'),(16,'API Test Customer','general',NULL,'api-test-customer.1774699214@ati.local',NULL,1,'2026-03-28 12:00:15','2026-03-28 12:00:15'),(17,'API Test Customer','general',NULL,'api-test-customer.1775211856@ati.local',NULL,1,'2026-04-03 10:24:17','2026-04-03 10:24:17'),(18,'API Test Customer','general',NULL,'api-test-customer.1775233339@ati.local',NULL,1,'2026-04-03 16:22:21','2026-04-03 16:22:21'),(19,'API Test Customer','general',NULL,'api-test-customer.1775234030@ati.local',NULL,1,'2026-04-03 16:33:52','2026-04-03 16:33:52'),(20,'API Test Customer','general',NULL,'api-test-customer.1775236587@ati.local',NULL,1,'2026-04-03 17:16:29','2026-04-03 17:16:29'),(21,'API Test Customer','general',NULL,'api-test-customer.1775236854@ati.local',NULL,1,'2026-04-03 17:20:56','2026-04-03 17:20:56'),(22,'API Test Customer','general',NULL,'api-test-customer.1775237014@ati.local',NULL,1,'2026-04-03 17:23:37','2026-04-03 17:23:37'),(23,'API Test Customer','general',NULL,'api-test-customer.1775237238@ati.local',NULL,1,'2026-04-03 17:27:21','2026-04-03 17:27:21'),(24,'API Test Customer','general',NULL,'api-test-customer.1775237388@ati.local',NULL,1,'2026-04-03 17:29:50','2026-04-03 17:29:50'),(25,'API Test Customer','general',NULL,'api-test-customer.1775237642@ati.local',NULL,1,'2026-04-03 17:34:04','2026-04-03 17:34:04'),(27,'API Test Customer','general',NULL,'api-test-customer.1775238231@ati.local',NULL,1,'2026-04-03 17:43:54','2026-04-03 17:43:54'),(29,'API Test Customer','general',NULL,'api-test-customer.1775238438@ati.local',NULL,1,'2026-04-03 17:47:20','2026-04-03 17:47:20'),(31,'API Test Customer','general',NULL,'api-test-customer.1775238714@ati.local',NULL,1,'2026-04-03 17:51:57','2026-04-03 17:51:57'),(33,'API Test Customer','general',NULL,'api-test-customer.1775239074@ati.local',NULL,1,'2026-04-03 17:57:57','2026-04-03 17:57:57'),(35,'API Test Customer','general',NULL,'api-test-customer.1775239221@ati.local',NULL,1,'2026-04-03 18:00:24','2026-04-03 18:00:24'),(37,'API Test Customer','general',NULL,'api-test-customer.1775239466@ati.local',NULL,1,'2026-04-03 18:04:29','2026-04-03 18:04:29'),(39,'API Test Customer','general',NULL,'api-test-customer.1775239610@ati.local',NULL,1,'2026-04-03 18:06:53','2026-04-03 18:06:53'),(41,'API Test Customer','general',NULL,'api-test-customer.1775239708@ati.local',NULL,1,'2026-04-03 18:08:31','2026-04-03 18:08:31'),(43,'API Test Customer','general',NULL,'api-test-customer.1775239788@ati.local',NULL,1,'2026-04-03 18:09:51','2026-04-03 18:09:51'),(45,'API Test Customer','general',NULL,'api-test-customer.1775239947@ati.local',NULL,1,'2026-04-03 18:12:30','2026-04-03 18:12:30'),(47,'API Test Customer','general',NULL,'api-test-customer.1775240091@ati.local',NULL,1,'2026-04-03 18:14:54','2026-04-03 18:14:54'),(49,'API Test Customer','general',NULL,'api-test-customer.1775240268@ati.local',NULL,1,'2026-04-03 18:17:51','2026-04-03 18:17:51'),(51,'API Test Customer','general',NULL,'api-test-customer.1775240617@ati.local',NULL,1,'2026-04-03 18:23:41','2026-04-03 18:23:41'),(53,'API Test Customer','general',NULL,'api-test-customer.1775240839@ati.local',NULL,1,'2026-04-03 18:27:22','2026-04-03 18:27:22'),(55,'API Test Customer','general',NULL,'api-test-customer.1775241137@ati.local',NULL,1,'2026-04-03 18:32:20','2026-04-03 18:32:20'),(57,'API Test Customer','general',NULL,'api-test-customer.1775242133@ati.local',NULL,1,'2026-04-03 18:48:56','2026-04-03 18:48:56'),(59,'API Test Customer','general',NULL,'api-test-customer.1775242418@ati.local',NULL,1,'2026-04-03 18:53:41','2026-04-03 18:53:41'),(61,'API Test Customer','general',NULL,'api-test-customer.1775242661@ati.local',NULL,1,'2026-04-03 18:57:45','2026-04-03 18:57:45'),(63,'API Test Customer','general',NULL,'api-test-customer.1775243091@ati.local',NULL,1,'2026-04-03 19:04:54','2026-04-03 19:04:54'),(65,'API Test Customer','general',NULL,'api-test-customer.1775243256@ati.local',NULL,1,'2026-04-03 19:07:39','2026-04-03 19:07:39'),(67,'API Test Customer','general',NULL,'api-test-customer.1775243874@ati.local',NULL,1,'2026-04-03 19:17:58','2026-04-03 19:17:58'),(69,'API Test Customer','general',NULL,'api-test-customer.1775245511@ati.local',NULL,1,'2026-04-03 19:45:15','2026-04-03 19:45:15'),(71,'API Test Customer','general',NULL,'api-test-customer.1775245651@ati.local',NULL,1,'2026-04-03 19:47:35','2026-04-03 19:47:35'),(73,'API Test Customer','general',NULL,'api-test-customer.1775247044@ati.local',NULL,1,'2026-04-03 20:10:48','2026-04-03 20:10:48'),(75,'API Test Customer','general',NULL,'api-test-customer.1775247167@ati.local',NULL,1,'2026-04-03 20:12:50','2026-04-03 20:12:50'),(77,'API Test Customer','general',NULL,'api-test-customer.1775247257@ati.local',NULL,1,'2026-04-03 20:14:21','2026-04-03 20:14:21'),(79,'API Test Customer','general',NULL,'api-test-customer.1775247708@ati.local',NULL,1,'2026-04-03 20:21:51','2026-04-03 20:21:51'),(81,'API Test Customer','general',NULL,'api-test-customer.1775247955@ati.local',NULL,1,'2026-04-03 20:25:58','2026-04-03 20:25:58'),(83,'API Test Customer','general',NULL,'api-test-customer.1776175965@ati.local',NULL,1,'2026-04-14 14:12:48','2026-04-14 14:12:48'),(85,'API Test Customer','general',NULL,'api-test-customer.1776351874@ati.local',NULL,1,'2026-04-16 15:04:38','2026-04-16 15:04:38');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_log`
--

DROP TABLE IF EXISTS `inventory_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `variant_unit_id` int unsigned NOT NULL,
  `quantity` decimal(14,4) NOT NULL COMMENT 'positive = in, negative = out',
  `action` enum('handover','sold','returned') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `related_id` int unsigned DEFAULT NULL COMMENT 'quotation_id or invoice_id',
  `user_id` int unsigned DEFAULT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_invlog_variant_unit` (`variant_unit_id`),
  KEY `idx_invlog_action` (`action`),
  KEY `idx_invlog_created` (`created_at`),
  KEY `idx_invlog_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=141 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_log`
--

LOCK TABLES `inventory_log` WRITE;
/*!40000 ALTER TABLE `inventory_log` DISABLE KEYS */;
INSERT INTO `inventory_log` VALUES (1,2,-2.0000,'handover',1,1,'Quotation #1 accepted','2026-03-02 15:42:56'),(2,2,2.0000,'returned',1,1,'Quotation #1 returned','2026-03-02 15:42:56'),(3,3,-2.0000,'handover',3,1,'Quotation #3 accepted','2026-03-02 15:43:47'),(4,3,2.0000,'returned',3,1,'Quotation #3 returned','2026-03-02 15:43:47'),(5,4,-2.0000,'handover',5,1,'Quotation #5 accepted','2026-03-02 15:44:52'),(6,4,2.0000,'returned',5,1,'Quotation #5 returned','2026-03-02 15:44:52'),(15,14,-2.0000,'handover',15,1,'Quotation #15 accepted','2026-03-16 07:35:54'),(16,15,-2.0000,'handover',16,1,'Quotation #16 accepted','2026-03-28 11:49:48'),(18,16,-2.0000,'handover',19,1,'Quotation #19 accepted','2026-03-28 11:50:14'),(20,17,-2.0000,'handover',22,1,'Quotation #22 accepted','2026-03-28 11:53:44'),(22,18,-2.0000,'handover',25,1,'Quotation #25 accepted','2026-03-28 12:00:16'),(24,19,-2.0000,'sold',28,1,'Lot #1 (API-LOT-1775211856) sold via quotation #28','2026-04-03 10:24:18'),(25,19,-2.0000,'handover',28,1,'Quotation #28 accepted','2026-04-03 10:24:18'),(27,20,-2.0000,'sold',32,1,'Lot #2 (API-LOT-1775233339) sold via quotation #32','2026-04-03 16:22:21'),(28,20,-2.0000,'handover',32,1,'Quotation #32 accepted','2026-04-03 16:22:21'),(30,21,-2.0000,'sold',36,1,'Lot #3 (API-LOT-1775234030) sold via quotation #36','2026-04-03 16:33:53'),(31,21,-2.0000,'handover',36,1,'Quotation #36 accepted','2026-04-03 16:33:53'),(33,22,-2.0000,'sold',40,1,'Lot #4 (API-LOT-1775236587) sold via quotation #40','2026-04-03 17:16:30'),(34,22,-2.0000,'handover',40,1,'Quotation #40 accepted','2026-04-03 17:16:30'),(36,23,-2.0000,'sold',44,1,'Lot #5 (API-LOT-1775236854) sold via quotation #44','2026-04-03 17:20:56'),(37,23,-2.0000,'handover',44,1,'Quotation #44 accepted','2026-04-03 17:20:56'),(39,24,-2.0000,'sold',48,1,'Lot #7 (API-LOT-1775237014) sold via quotation #48','2026-04-03 17:23:37'),(40,24,-2.0000,'handover',48,1,'Quotation #48 accepted','2026-04-03 17:23:37'),(42,25,-2.0000,'sold',52,1,'Lot #9 (API-LOT-1775237238) sold via quotation #52','2026-04-03 17:27:21'),(43,25,-2.0000,'handover',52,1,'Quotation #52 accepted','2026-04-03 17:27:21'),(45,26,-2.0000,'sold',56,1,'Lot #11 (API-LOT-1775237388) sold via quotation #56','2026-04-03 17:29:51'),(46,26,-2.0000,'handover',56,1,'Quotation #56 accepted','2026-04-03 17:29:51'),(48,27,-2.0000,'sold',60,1,'Lot #13 (API-LOT-1775237642) sold via quotation #60','2026-04-03 17:34:05'),(49,27,-2.0000,'handover',60,1,'Quotation #60 accepted','2026-04-03 17:34:05'),(51,28,-2.0000,'sold',64,1,'Lot #15 (API-LOT-1775238231) sold via quotation #64','2026-04-03 17:43:54'),(52,28,-2.0000,'handover',64,1,'Quotation #64 accepted','2026-04-03 17:43:54'),(54,29,-2.0000,'sold',68,1,'Lot #17 (API-LOT-1775238438) sold via quotation #68','2026-04-03 17:47:21'),(55,29,-2.0000,'handover',68,1,'Quotation #68 accepted','2026-04-03 17:47:21'),(57,30,-2.0000,'sold',72,1,'Lot #19 (API-LOT-1775238714) sold via quotation #72','2026-04-03 17:51:58'),(58,30,-2.0000,'handover',72,1,'Quotation #72 accepted','2026-04-03 17:51:58'),(60,31,-2.0000,'sold',76,1,'Lot #21 (API-LOT-1775239074) sold via quotation #76','2026-04-03 17:57:57'),(61,31,-2.0000,'handover',76,1,'Quotation #76 accepted','2026-04-03 17:57:57'),(63,32,-2.0000,'sold',80,1,'Lot #23 (API-LOT-1775239221) sold via quotation #80','2026-04-03 18:00:24'),(64,32,-2.0000,'handover',80,1,'Quotation #80 accepted','2026-04-03 18:00:24'),(66,33,-2.0000,'sold',84,1,'Lot #25 (API-LOT-1775239466) sold via quotation #84','2026-04-03 18:04:30'),(67,33,-2.0000,'handover',84,1,'Quotation #84 accepted','2026-04-03 18:04:30'),(69,34,-2.0000,'sold',88,1,'Lot #27 (API-LOT-1775239610) sold via quotation #88','2026-04-03 18:06:54'),(70,34,-2.0000,'handover',88,1,'Quotation #88 accepted','2026-04-03 18:06:54'),(72,35,-2.0000,'sold',92,1,'Lot #29 (API-LOT-1775239708) sold via quotation #92','2026-04-03 18:08:31'),(73,35,-2.0000,'handover',92,1,'Quotation #92 accepted','2026-04-03 18:08:31'),(75,36,-2.0000,'sold',96,1,'Lot #31 (API-LOT-1775239788) sold via quotation #96','2026-04-03 18:09:51'),(76,36,-2.0000,'handover',96,1,'Quotation #96 accepted','2026-04-03 18:09:51'),(78,37,-2.0000,'sold',100,1,'Lot #33 (API-LOT-1775239947) sold via quotation #100','2026-04-03 18:12:30'),(79,37,-2.0000,'handover',100,1,'Quotation #100 accepted','2026-04-03 18:12:30'),(81,38,-2.0000,'sold',104,1,'Lot #35 (API-LOT-1775240091) sold via quotation #104','2026-04-03 18:14:55'),(82,38,-2.0000,'handover',104,1,'Quotation #104 accepted','2026-04-03 18:14:55'),(84,39,-2.0000,'sold',108,1,'Lot #37 (API-LOT-1775240268) sold via quotation #108','2026-04-03 18:17:52'),(85,39,-2.0000,'handover',108,1,'Quotation #108 accepted','2026-04-03 18:17:52'),(87,40,-2.0000,'sold',112,1,'Lot #39 (API-LOT-1775240617) sold via quotation #112','2026-04-03 18:23:41'),(88,40,-2.0000,'handover',112,1,'Quotation #112 accepted','2026-04-03 18:23:41'),(90,41,-2.0000,'sold',116,1,'Lot #41 (API-LOT-1775240839) sold via quotation #116','2026-04-03 18:27:23'),(91,41,-2.0000,'handover',116,1,'Quotation #116 accepted','2026-04-03 18:27:23'),(93,42,-2.0000,'sold',120,1,'Lot #43 (API-LOT-1775241137) sold via quotation #120','2026-04-03 18:32:20'),(94,42,-2.0000,'handover',120,1,'Quotation #120 accepted','2026-04-03 18:32:20'),(96,43,-2.0000,'sold',124,1,'Lot #45 (API-LOT-1775242133) sold via quotation #124','2026-04-03 18:48:57'),(97,43,-2.0000,'handover',124,1,'Quotation #124 accepted','2026-04-03 18:48:57'),(99,44,-2.0000,'sold',128,1,'Lot #47 (API-LOT-1775242418) sold via quotation #128','2026-04-03 18:53:42'),(100,44,-2.0000,'handover',128,1,'Quotation #128 accepted','2026-04-03 18:53:42'),(102,45,-2.0000,'sold',132,1,'Lot #49 (API-LOT-1775242661) sold via quotation #132','2026-04-03 18:57:45'),(103,45,-2.0000,'handover',132,1,'Quotation #132 accepted','2026-04-03 18:57:45'),(105,46,-2.0000,'sold',136,1,'Lot #51 (API-LOT-1775243091) sold via quotation #136','2026-04-03 19:04:55'),(106,46,-2.0000,'handover',136,1,'Quotation #136 accepted','2026-04-03 19:04:55'),(108,47,-2.0000,'sold',140,1,'Lot #53 (API-LOT-1775243256) sold via quotation #140','2026-04-03 19:07:40'),(109,47,-2.0000,'handover',140,1,'Quotation #140 accepted','2026-04-03 19:07:40'),(111,48,-2.0000,'sold',144,1,'Lot #55 (API-LOT-1775243874) sold via quotation #144','2026-04-03 19:17:59'),(112,48,-2.0000,'handover',144,1,'Quotation #144 accepted','2026-04-03 19:17:59'),(114,49,-2.0000,'sold',148,1,'Lot #57 (API-LOT-1775245511) sold via quotation #148','2026-04-03 19:45:16'),(115,49,-2.0000,'handover',148,1,'Quotation #148 accepted','2026-04-03 19:45:16'),(117,50,-2.0000,'sold',152,1,'Lot #59 (API-LOT-1775245651) sold via quotation #152','2026-04-03 19:47:35'),(118,50,-2.0000,'handover',152,1,'Quotation #152 accepted','2026-04-03 19:47:35'),(120,51,-2.0000,'sold',156,1,'Lot #61 (API-LOT-1775247044) sold via quotation #156','2026-04-03 20:10:48'),(121,51,-2.0000,'handover',156,1,'Quotation #156 accepted','2026-04-03 20:10:48'),(123,52,-2.0000,'sold',160,1,'Lot #63 (API-LOT-1775247167) sold via quotation #160','2026-04-03 20:12:50'),(124,52,-2.0000,'handover',160,1,'Quotation #160 accepted','2026-04-03 20:12:50'),(126,53,-2.0000,'sold',164,1,'Lot #65 (API-LOT-1775247257) sold via quotation #164','2026-04-03 20:14:21'),(127,53,-2.0000,'handover',164,1,'Quotation #164 accepted','2026-04-03 20:14:21'),(129,54,-2.0000,'sold',168,1,'Lot #67 (API-LOT-1775247708) sold via quotation #168','2026-04-03 20:21:52'),(130,54,-2.0000,'handover',168,1,'Quotation #168 accepted','2026-04-03 20:21:52'),(132,55,-2.0000,'sold',172,1,'Lot #69 (API-LOT-1775247955) sold via quotation #172','2026-04-03 20:25:59'),(133,55,-2.0000,'handover',172,1,'Quotation #172 accepted','2026-04-03 20:25:59'),(135,56,-2.0000,'sold',176,1,'Lot #71 (API-LOT-1776175965) sold via quotation #176','2026-04-14 14:12:49'),(136,56,-2.0000,'handover',176,1,'Quotation #176 accepted','2026-04-14 14:12:49'),(138,57,-2.0000,'sold',180,1,'Lot #73 (API-LOT-1776351874) sold via quotation #180','2026-04-16 15:04:39'),(139,57,-2.0000,'handover',180,1,'Quotation #180 accepted','2026-04-16 15:04:39');
/*!40000 ALTER TABLE `inventory_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lot_assignments`
--

DROP TABLE IF EXISTS `lot_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lot_assignments` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `quotation_item_id` int unsigned NOT NULL,
  `lot_id` int unsigned NOT NULL,
  `quantity` decimal(14,4) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_lot_assignments_qi` (`quotation_item_id`),
  KEY `idx_lot_assignments_lot` (`lot_id`),
  CONSTRAINT `fk_lot_assignments_lot` FOREIGN KEY (`lot_id`) REFERENCES `lots` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_lot_assignments_qi` FOREIGN KEY (`quotation_item_id`) REFERENCES `quotation_items` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=196 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lot_assignments`
--

LOCK TABLES `lot_assignments` WRITE;
/*!40000 ALTER TABLE `lot_assignments` DISABLE KEYS */;
INSERT INTO `lot_assignments` VALUES (2,29,1,2.0000,'2026-04-03 10:24:18'),(7,34,2,2.0000,'2026-04-03 16:22:21'),(12,39,3,2.0000,'2026-04-03 16:33:52'),(17,44,4,2.0000,'2026-04-03 17:16:30'),(22,49,5,2.0000,'2026-04-03 17:20:56'),(27,54,7,2.0000,'2026-04-03 17:23:37'),(32,59,9,2.0000,'2026-04-03 17:27:21'),(37,64,11,2.0000,'2026-04-03 17:29:51'),(42,69,13,2.0000,'2026-04-03 17:34:05'),(47,74,15,2.0000,'2026-04-03 17:43:54'),(52,79,17,2.0000,'2026-04-03 17:47:21'),(57,84,19,2.0000,'2026-04-03 17:51:58'),(62,89,21,2.0000,'2026-04-03 17:57:57'),(67,94,23,2.0000,'2026-04-03 18:00:24'),(72,99,25,2.0000,'2026-04-03 18:04:30'),(77,104,27,2.0000,'2026-04-03 18:06:54'),(82,109,29,2.0000,'2026-04-03 18:08:31'),(87,114,31,2.0000,'2026-04-03 18:09:51'),(92,119,33,2.0000,'2026-04-03 18:12:30'),(97,124,35,2.0000,'2026-04-03 18:14:55'),(102,129,37,2.0000,'2026-04-03 18:17:51'),(107,134,39,2.0000,'2026-04-03 18:23:41'),(112,139,41,2.0000,'2026-04-03 18:27:23'),(117,144,43,2.0000,'2026-04-03 18:32:20'),(122,149,45,2.0000,'2026-04-03 18:48:56'),(127,154,47,2.0000,'2026-04-03 18:53:42'),(132,159,49,2.0000,'2026-04-03 18:57:45'),(137,164,51,2.0000,'2026-04-03 19:04:54'),(142,169,53,2.0000,'2026-04-03 19:07:40'),(147,174,55,2.0000,'2026-04-03 19:17:59'),(152,179,57,2.0000,'2026-04-03 19:45:15'),(157,184,59,2.0000,'2026-04-03 19:47:35'),(162,189,61,2.0000,'2026-04-03 20:10:48'),(167,194,63,2.0000,'2026-04-03 20:12:50'),(172,199,65,2.0000,'2026-04-03 20:14:21'),(177,204,67,2.0000,'2026-04-03 20:21:52'),(182,209,69,2.0000,'2026-04-03 20:25:59'),(187,214,71,2.0000,'2026-04-14 14:12:49'),(192,219,73,2.0000,'2026-04-16 15:04:38');
/*!40000 ALTER TABLE `lot_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lot_stocks`
--

DROP TABLE IF EXISTS `lot_stocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lot_stocks` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `lot_id` int unsigned NOT NULL,
  `variant_unit_id` int unsigned NOT NULL,
  `quantity_total` decimal(14,4) NOT NULL DEFAULT '0.0000',
  `quantity_sold` decimal(14,4) NOT NULL DEFAULT '0.0000',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_lot_stocks_lot_variant_unit` (`lot_id`,`variant_unit_id`),
  KEY `idx_lot_stocks_lot` (`lot_id`),
  KEY `idx_lot_stocks_variant_unit` (`variant_unit_id`),
  CONSTRAINT `fk_lot_stocks_lot` FOREIGN KEY (`lot_id`) REFERENCES `lots` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_lot_stocks_variant_unit` FOREIGN KEY (`variant_unit_id`) REFERENCES `variant_units` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lot_stocks`
--

LOCK TABLES `lot_stocks` WRITE;
/*!40000 ALTER TABLE `lot_stocks` DISABLE KEYS */;
INSERT INTO `lot_stocks` VALUES (1,1,19,100.0000,2.0000,'2026-04-03 10:24:17','2026-04-03 10:24:18'),(2,2,20,100.0000,2.0000,'2026-04-03 16:22:20','2026-04-03 16:22:21'),(3,3,21,100.0000,2.0000,'2026-04-03 16:33:52','2026-04-03 16:33:53'),(4,4,22,100.0000,2.0000,'2026-04-03 17:16:29','2026-04-03 17:16:30'),(5,5,23,100.0000,2.0000,'2026-04-03 17:20:56','2026-04-03 17:20:56'),(6,7,24,100.0000,2.0000,'2026-04-03 17:23:36','2026-04-03 17:23:37'),(7,9,25,100.0000,2.0000,'2026-04-03 17:27:20','2026-04-03 17:27:21'),(8,11,26,100.0000,2.0000,'2026-04-03 17:29:50','2026-04-03 17:29:51'),(9,13,27,100.0000,2.0000,'2026-04-03 17:34:04','2026-04-03 17:34:05'),(10,15,28,100.0000,2.0000,'2026-04-03 17:43:54','2026-04-03 17:43:54'),(11,17,29,100.0000,2.0000,'2026-04-03 17:47:20','2026-04-03 17:47:21'),(12,19,30,100.0000,2.0000,'2026-04-03 17:51:57','2026-04-03 17:51:58'),(13,21,31,100.0000,2.0000,'2026-04-03 17:57:57','2026-04-03 17:57:57'),(14,23,32,100.0000,2.0000,'2026-04-03 18:00:24','2026-04-03 18:00:24'),(15,25,33,100.0000,2.0000,'2026-04-03 18:04:29','2026-04-03 18:04:30'),(16,27,34,100.0000,2.0000,'2026-04-03 18:06:53','2026-04-03 18:06:54'),(17,29,35,100.0000,2.0000,'2026-04-03 18:08:30','2026-04-03 18:08:31'),(18,31,36,100.0000,2.0000,'2026-04-03 18:09:51','2026-04-03 18:09:51'),(19,33,37,100.0000,2.0000,'2026-04-03 18:12:29','2026-04-03 18:12:30'),(20,35,38,100.0000,2.0000,'2026-04-03 18:14:54','2026-04-03 18:14:55'),(21,37,39,100.0000,2.0000,'2026-04-03 18:17:51','2026-04-03 18:17:52'),(22,39,40,100.0000,2.0000,'2026-04-03 18:23:40','2026-04-03 18:23:41'),(23,41,41,100.0000,2.0000,'2026-04-03 18:27:22','2026-04-03 18:27:23'),(24,43,42,100.0000,2.0000,'2026-04-03 18:32:19','2026-04-03 18:32:20'),(25,45,43,100.0000,2.0000,'2026-04-03 18:48:56','2026-04-03 18:48:57'),(26,47,44,100.0000,2.0000,'2026-04-03 18:53:41','2026-04-03 18:53:42'),(27,49,45,100.0000,2.0000,'2026-04-03 18:57:44','2026-04-03 18:57:45'),(28,51,46,100.0000,2.0000,'2026-04-03 19:04:54','2026-04-03 19:04:55'),(29,53,47,100.0000,2.0000,'2026-04-03 19:07:39','2026-04-03 19:07:40'),(30,55,48,100.0000,2.0000,'2026-04-03 19:17:57','2026-04-03 19:17:59'),(31,57,49,100.0000,2.0000,'2026-04-03 19:45:15','2026-04-03 19:45:16'),(32,59,50,100.0000,2.0000,'2026-04-03 19:47:35','2026-04-03 19:47:35'),(33,61,51,100.0000,2.0000,'2026-04-03 20:10:47','2026-04-03 20:10:48'),(34,63,52,100.0000,2.0000,'2026-04-03 20:12:50','2026-04-03 20:12:50'),(35,65,53,100.0000,2.0000,'2026-04-03 20:14:20','2026-04-03 20:14:21'),(36,67,54,100.0000,2.0000,'2026-04-03 20:21:51','2026-04-03 20:21:52'),(37,69,55,100.0000,2.0000,'2026-04-03 20:25:58','2026-04-03 20:25:59'),(38,71,56,100.0000,2.0000,'2026-04-14 14:12:48','2026-04-14 14:12:49'),(39,73,57,100.0000,2.0000,'2026-04-16 15:04:38','2026-04-16 15:04:39');
/*!40000 ALTER TABLE `lot_stocks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lots`
--

DROP TABLE IF EXISTS `lots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lots` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int unsigned NOT NULL,
  `name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_lots_product_name` (`product_id`,`name`),
  KEY `idx_lots_product` (`product_id`),
  KEY `idx_lots_active` (`is_active`),
  KEY `fk_lots_created_by` (`created_by`),
  KEY `idx_lots_expiry_date` (`expiry_date`),
  CONSTRAINT `fk_lots_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_lots_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=75 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lots`
--

LOCK TABLES `lots` WRITE;
/*!40000 ALTER TABLE `lots` DISABLE KEYS */;
INSERT INTO `lots` VALUES (1,21,'API-LOT-1775211856','primary lot',NULL,0,1,'2026-04-03 10:24:17','2026-04-03 10:24:19'),(2,22,'API-LOT-1775233339','primary lot',NULL,0,1,'2026-04-03 16:22:20','2026-04-03 16:22:23'),(3,23,'API-LOT-1775234030','primary lot',NULL,0,1,'2026-04-03 16:33:52','2026-04-03 16:33:54'),(4,24,'API-LOT-1775236587','primary lot',NULL,0,1,'2026-04-03 17:16:29','2026-04-03 17:16:32'),(5,25,'API-LOT-1775236854','primary lot',NULL,0,1,'2026-04-03 17:20:55','2026-04-03 17:20:58'),(6,25,'API-LOT-SECOND-1775236854','secondary lot updated',NULL,0,1,'2026-04-03 17:20:55','2026-04-03 17:20:56'),(7,26,'API-LOT-1775237014','primary lot',NULL,0,1,'2026-04-03 17:23:36','2026-04-03 17:23:39'),(8,26,'API-LOT-SECOND-1775237014','secondary lot updated',NULL,0,1,'2026-04-03 17:23:36','2026-04-03 17:23:36'),(9,28,'API-LOT-1775237238','primary lot',NULL,0,1,'2026-04-03 17:27:20','2026-04-03 17:27:23'),(10,28,'API-LOT-SECOND-1775237238','secondary lot updated',NULL,0,1,'2026-04-03 17:27:20','2026-04-03 17:27:20'),(11,30,'API-LOT-1775237388','primary lot',NULL,0,1,'2026-04-03 17:29:50','2026-04-03 17:29:53'),(12,30,'API-LOT-SECOND-1775237388','secondary lot updated',NULL,0,1,'2026-04-03 17:29:50','2026-04-03 17:29:50'),(13,32,'API-LOT-1775237642','primary lot',NULL,0,1,'2026-04-03 17:34:04','2026-04-03 17:34:07'),(14,32,'API-LOT-SECOND-1775237642','secondary lot updated',NULL,0,1,'2026-04-03 17:34:04','2026-04-03 17:34:04'),(15,34,'API-LOT-1775238231','primary lot',NULL,0,1,'2026-04-03 17:43:53','2026-04-03 17:43:56'),(16,34,'API-LOT-SECOND-1775238231','secondary lot updated',NULL,0,1,'2026-04-03 17:43:53','2026-04-03 17:43:54'),(17,36,'API-LOT-1775238438','primary lot',NULL,0,1,'2026-04-03 17:47:20','2026-04-03 17:47:23'),(18,36,'API-LOT-SECOND-1775238438','secondary lot updated',NULL,0,1,'2026-04-03 17:47:20','2026-04-03 17:47:20'),(19,38,'API-LOT-1775238714','primary lot',NULL,0,1,'2026-04-03 17:51:57','2026-04-03 17:52:00'),(20,38,'API-LOT-SECOND-1775238714','secondary lot updated',NULL,0,1,'2026-04-03 17:51:57','2026-04-03 17:51:57'),(21,40,'API-LOT-1775239074','primary lot',NULL,0,1,'2026-04-03 17:57:56','2026-04-03 17:57:59'),(22,40,'API-LOT-SECOND-1775239074','secondary lot updated',NULL,0,1,'2026-04-03 17:57:56','2026-04-03 17:57:57'),(23,42,'API-LOT-1775239221','primary lot',NULL,0,1,'2026-04-03 18:00:23','2026-04-03 18:00:27'),(24,42,'API-LOT-SECOND-1775239221','secondary lot updated',NULL,0,1,'2026-04-03 18:00:23','2026-04-03 18:00:24'),(25,44,'API-LOT-1775239466','primary lot',NULL,0,1,'2026-04-03 18:04:29','2026-04-03 18:04:32'),(26,44,'API-LOT-SECOND-1775239466','secondary lot updated',NULL,0,1,'2026-04-03 18:04:29','2026-04-03 18:04:29'),(27,46,'API-LOT-1775239610','primary lot',NULL,0,1,'2026-04-03 18:06:53','2026-04-03 18:06:56'),(28,46,'API-LOT-SECOND-1775239610','secondary lot updated',NULL,0,1,'2026-04-03 18:06:53','2026-04-03 18:06:53'),(29,48,'API-LOT-1775239708','primary lot',NULL,0,1,'2026-04-03 18:08:30','2026-04-03 18:08:33'),(30,48,'API-LOT-SECOND-1775239708','secondary lot updated',NULL,0,1,'2026-04-03 18:08:30','2026-04-03 18:08:30'),(31,50,'API-LOT-1775239788','primary lot',NULL,0,1,'2026-04-03 18:09:50','2026-04-03 18:09:53'),(32,50,'API-LOT-SECOND-1775239788','secondary lot updated',NULL,0,1,'2026-04-03 18:09:50','2026-04-03 18:09:51'),(33,52,'API-LOT-1775239947','primary lot',NULL,0,1,'2026-04-03 18:12:29','2026-04-03 18:12:32'),(34,52,'API-LOT-SECOND-1775239947','secondary lot updated',NULL,0,1,'2026-04-03 18:12:29','2026-04-03 18:12:29'),(35,54,'API-LOT-1775240091','primary lot',NULL,0,1,'2026-04-03 18:14:54','2026-04-03 18:14:57'),(36,54,'API-LOT-SECOND-1775240091','secondary lot updated',NULL,0,1,'2026-04-03 18:14:54','2026-04-03 18:14:54'),(37,56,'API-LOT-1775240268','primary lot',NULL,0,1,'2026-04-03 18:17:50','2026-04-03 18:17:54'),(38,56,'API-LOT-SECOND-1775240268','secondary lot updated',NULL,0,1,'2026-04-03 18:17:51','2026-04-03 18:17:51'),(39,58,'API-LOT-1775240617','primary lot',NULL,0,1,'2026-04-03 18:23:40','2026-04-03 18:23:43'),(40,58,'API-LOT-SECOND-1775240617','secondary lot updated',NULL,0,1,'2026-04-03 18:23:40','2026-04-03 18:23:40'),(41,60,'API-LOT-1775240839','primary lot',NULL,0,1,'2026-04-03 18:27:22','2026-04-03 18:27:25'),(42,60,'API-LOT-SECOND-1775240839','secondary lot updated',NULL,0,1,'2026-04-03 18:27:22','2026-04-03 18:27:22'),(43,62,'API-LOT-1775241137','primary lot',NULL,0,1,'2026-04-03 18:32:19','2026-04-03 18:32:22'),(44,62,'API-LOT-SECOND-1775241137','secondary lot updated',NULL,0,1,'2026-04-03 18:32:19','2026-04-03 18:32:19'),(45,64,'API-LOT-1775242133','primary lot',NULL,0,1,'2026-04-03 18:48:55','2026-04-03 18:48:58'),(46,64,'API-LOT-SECOND-1775242133','secondary lot updated',NULL,0,1,'2026-04-03 18:48:56','2026-04-03 18:48:56'),(47,66,'API-LOT-1775242418','primary lot',NULL,0,1,'2026-04-03 18:53:41','2026-04-03 18:53:44'),(48,66,'API-LOT-SECOND-1775242418','secondary lot updated',NULL,0,1,'2026-04-03 18:53:41','2026-04-03 18:53:41'),(49,68,'API-LOT-1775242661','primary lot',NULL,0,1,'2026-04-03 18:57:44','2026-04-03 18:57:47'),(50,68,'API-LOT-SECOND-1775242661','secondary lot updated',NULL,0,1,'2026-04-03 18:57:44','2026-04-03 18:57:44'),(51,70,'API-LOT-1775243091','primary lot',NULL,0,1,'2026-04-03 19:04:53','2026-04-03 19:04:56'),(52,70,'API-LOT-SECOND-1775243091','secondary lot updated',NULL,0,1,'2026-04-03 19:04:53','2026-04-03 19:04:54'),(53,72,'API-LOT-1775243256','primary lot',NULL,0,1,'2026-04-03 19:07:39','2026-04-03 19:07:42'),(54,72,'API-LOT-SECOND-1775243256','secondary lot updated',NULL,0,1,'2026-04-03 19:07:39','2026-04-03 19:07:39'),(55,74,'API-LOT-1775243874','primary lot',NULL,0,1,'2026-04-03 19:17:57','2026-04-03 19:18:01'),(56,74,'API-LOT-SECOND-1775243874','secondary lot updated',NULL,0,1,'2026-04-03 19:17:57','2026-04-03 19:17:57'),(57,76,'API-LOT-1775245511','primary lot',NULL,0,1,'2026-04-03 19:45:14','2026-04-03 19:45:18'),(58,76,'API-LOT-SECOND-1775245511','secondary lot updated',NULL,0,1,'2026-04-03 19:45:14','2026-04-03 19:45:15'),(59,78,'API-LOT-1775245651','primary lot',NULL,0,1,'2026-04-03 19:47:34','2026-04-03 19:47:37'),(60,78,'API-LOT-SECOND-1775245651','secondary lot updated',NULL,0,1,'2026-04-03 19:47:34','2026-04-03 19:47:34'),(61,80,'API-LOT-1775247044','primary lot',NULL,0,1,'2026-04-03 20:10:47','2026-04-03 20:10:50'),(62,80,'API-LOT-SECOND-1775247044','secondary lot updated',NULL,0,1,'2026-04-03 20:10:47','2026-04-03 20:10:47'),(63,82,'API-LOT-1775247167','primary lot',NULL,0,1,'2026-04-03 20:12:49','2026-04-03 20:12:53'),(64,82,'API-LOT-SECOND-1775247167','secondary lot updated',NULL,0,1,'2026-04-03 20:12:49','2026-04-03 20:12:49'),(65,84,'API-LOT-1775247257','primary lot',NULL,0,1,'2026-04-03 20:14:20','2026-04-03 20:14:23'),(66,84,'API-LOT-SECOND-1775247257','secondary lot updated',NULL,0,1,'2026-04-03 20:14:20','2026-04-03 20:14:20'),(67,86,'API-LOT-1775247708','primary lot',NULL,0,1,'2026-04-03 20:21:51','2026-04-03 20:21:54'),(68,86,'API-LOT-SECOND-1775247708','secondary lot updated',NULL,0,1,'2026-04-03 20:21:51','2026-04-03 20:21:51'),(69,88,'API-LOT-1775247955','primary lot',NULL,0,1,'2026-04-03 20:25:58','2026-04-03 20:26:01'),(70,88,'API-LOT-SECOND-1775247955','secondary lot updated',NULL,0,1,'2026-04-03 20:25:58','2026-04-03 20:25:58'),(71,90,'API-LOT-1776175965','primary lot',NULL,0,1,'2026-04-14 14:12:48','2026-04-14 14:12:51'),(72,90,'API-LOT-SECOND-1776175965','secondary lot updated',NULL,0,1,'2026-04-14 14:12:48','2026-04-14 14:12:48'),(73,92,'API-LOT-1776351874','primary lot','2026-07-15',0,1,'2026-04-16 15:04:37','2026-04-16 15:04:40'),(74,92,'API-LOT-SECOND-1776351874','secondary lot updated','2026-06-20',0,1,'2026-04-16 15:04:38','2026-04-16 15:04:38');
/*!40000 ALTER TABLE `lots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `invoice_id` int unsigned NOT NULL,
  `amount_paid` decimal(14,2) NOT NULL,
  `payment_date` date NOT NULL,
  `method` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'cash, bank_transfer…',
  `reference` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `received_by` int unsigned DEFAULT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_payments_invoice` (`invoice_id`),
  KEY `idx_payments_date` (`payment_date`),
  KEY `idx_payments_received_by` (`received_by`),
  CONSTRAINT `fk_payments_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `sales_invoices` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_payments_received_by` FOREIGN KEY (`received_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,1,100.00,'2026-03-02','cash','PAY-T01',1,NULL,'2026-03-02 15:42:56'),(2,2,100.00,'2026-03-02','cash','PAY-T01',1,NULL,'2026-03-02 15:43:47');
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_variants`
--

DROP TABLE IF EXISTS `product_variants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_variants` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int unsigned NOT NULL,
  `attributes` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `sku` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_variants_sku` (`sku`),
  KEY `idx_variants_product` (`product_id`),
  CONSTRAINT `fk_variants_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `product_variants_chk_1` CHECK (json_valid(`attributes`))
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_variants`
--

LOCK TABLES `product_variants` WRITE;
/*!40000 ALTER TABLE `product_variants` DISABLE KEYS */;
INSERT INTO `product_variants` VALUES (9,12,'{\"model\": \"DSP-1\", \"color\": \"black\"}','ATI-SKU-2001',1,'2026-03-16 06:06:11','2026-03-16 06:06:11'),(10,13,'{\"size\": \"M\", \"sterile\": \"yes\"}','ATI-SKU-2002',1,'2026-03-16 06:06:11','2026-03-16 06:06:11'),(11,13,'{\"size\": \"L\", \"sterile\": \"yes\"}','ATI-SKU-2003',1,'2026-03-16 06:06:11','2026-03-16 06:06:11'),(12,14,'{\"strength\": \"500mg\", \"form\": \"tablet\"}','ATI-SKU-2004',1,'2026-03-16 06:06:11','2026-03-16 06:06:11'),(13,15,'{\"model\": \"BPA-2\", \"cuff\": \"adult\"}','ATI-SKU-2005',1,'2026-03-16 06:06:11','2026-03-16 06:06:11'),(14,16,'{\"color\":\"blue\"}','CURLSKU_1773646552',1,'2026-03-16 07:35:52','2026-03-16 07:35:52'),(19,21,'{\"pack\":\"single\"}','API-TEST-SKU-1775211856',1,'2026-04-03 10:24:17','2026-04-03 10:24:17'),(20,22,'{\"pack\":\"single\"}','API-TEST-SKU-1775233339',1,'2026-04-03 16:22:20','2026-04-03 16:22:20'),(21,23,'{\"pack\":\"single\"}','API-TEST-SKU-1775234030',1,'2026-04-03 16:33:52','2026-04-03 16:33:52'),(22,24,'{\"pack\":\"single\"}','API-TEST-SKU-1775236587',1,'2026-04-03 17:16:29','2026-04-03 17:16:29'),(23,25,'{\"pack\":\"single\"}','API-TEST-SKU-1775236854',1,'2026-04-03 17:20:55','2026-04-03 17:20:55'),(24,26,'{\"pack\":\"single\"}','API-TEST-SKU-1775237014',1,'2026-04-03 17:23:36','2026-04-03 17:23:36'),(25,28,'{\"pack\":\"single\"}','API-TEST-SKU-1775237238',1,'2026-04-03 17:27:20','2026-04-03 17:27:20'),(26,30,'{\"pack\":\"single\"}','API-TEST-SKU-1775237388',1,'2026-04-03 17:29:50','2026-04-03 17:29:50'),(27,32,'{\"pack\":\"single\"}','API-TEST-SKU-1775237642',1,'2026-04-03 17:34:04','2026-04-03 17:34:04'),(28,34,'{\"pack\":\"single\"}','API-TEST-SKU-1775238231',1,'2026-04-03 17:43:53','2026-04-03 17:43:53'),(29,36,'{\"pack\":\"single\"}','API-TEST-SKU-1775238438',1,'2026-04-03 17:47:20','2026-04-03 17:47:20'),(30,38,'{\"pack\":\"single\"}','API-TEST-SKU-1775238714',1,'2026-04-03 17:51:56','2026-04-03 17:51:56'),(31,40,'{\"pack\":\"single\"}','API-TEST-SKU-1775239074',1,'2026-04-03 17:57:56','2026-04-03 17:57:56'),(32,42,'{\"pack\":\"single\"}','API-TEST-SKU-1775239221',1,'2026-04-03 18:00:23','2026-04-03 18:00:23'),(33,44,'{\"pack\":\"single\"}','API-TEST-SKU-1775239466',1,'2026-04-03 18:04:29','2026-04-03 18:04:29'),(34,46,'{\"pack\":\"single\"}','API-TEST-SKU-1775239610',1,'2026-04-03 18:06:53','2026-04-03 18:06:53'),(35,48,'{\"pack\":\"single\"}','API-TEST-SKU-1775239708',1,'2026-04-03 18:08:30','2026-04-03 18:08:30'),(36,50,'{\"pack\":\"single\"}','API-TEST-SKU-1775239788',1,'2026-04-03 18:09:50','2026-04-03 18:09:50'),(37,52,'{\"pack\":\"single\"}','API-TEST-SKU-1775239947',1,'2026-04-03 18:12:29','2026-04-03 18:12:29'),(38,54,'{\"pack\":\"single\"}','API-TEST-SKU-1775240091',1,'2026-04-03 18:14:54','2026-04-03 18:14:54'),(39,56,'{\"pack\":\"single\"}','API-TEST-SKU-1775240268',1,'2026-04-03 18:17:50','2026-04-03 18:17:50'),(40,58,'{\"pack\":\"single\"}','API-TEST-SKU-1775240617',1,'2026-04-03 18:23:40','2026-04-03 18:23:40'),(41,60,'{\"pack\":\"single\"}','API-TEST-SKU-1775240839',1,'2026-04-03 18:27:22','2026-04-03 18:27:22'),(42,62,'{\"pack\":\"single\"}','API-TEST-SKU-1775241137',1,'2026-04-03 18:32:19','2026-04-03 18:32:19'),(43,64,'{\"pack\":\"single\"}','API-TEST-SKU-1775242133',1,'2026-04-03 18:48:55','2026-04-03 18:48:55'),(44,66,'{\"pack\":\"single\"}','API-TEST-SKU-1775242418',1,'2026-04-03 18:53:40','2026-04-03 18:53:40'),(45,68,'{\"pack\":\"single\"}','API-TEST-SKU-1775242661',1,'2026-04-03 18:57:44','2026-04-03 18:57:44'),(46,70,'{\"pack\":\"single\"}','API-TEST-SKU-1775243091',1,'2026-04-03 19:04:53','2026-04-03 19:04:53'),(47,72,'{\"pack\":\"single\"}','API-TEST-SKU-1775243256',1,'2026-04-03 19:07:39','2026-04-03 19:07:39'),(48,74,'{\"pack\":\"single\"}','API-TEST-SKU-1775243874',1,'2026-04-03 19:17:57','2026-04-03 19:17:57'),(49,76,'{\"pack\":\"single\"}','API-TEST-SKU-1775245511',1,'2026-04-03 19:45:14','2026-04-03 19:45:14'),(50,78,'{\"pack\":\"single\"}','API-TEST-SKU-1775245651',1,'2026-04-03 19:47:34','2026-04-03 19:47:34'),(51,80,'{\"pack\":\"single\"}','API-TEST-SKU-1775247044',1,'2026-04-03 20:10:47','2026-04-03 20:10:47'),(52,82,'{\"pack\":\"single\"}','API-TEST-SKU-1775247167',1,'2026-04-03 20:12:49','2026-04-03 20:12:49'),(53,84,'{\"pack\":\"single\"}','API-TEST-SKU-1775247257',1,'2026-04-03 20:14:20','2026-04-03 20:14:20'),(54,86,'{\"pack\":\"single\"}','API-TEST-SKU-1775247708',1,'2026-04-03 20:21:50','2026-04-03 20:21:50'),(55,88,'{\"pack\":\"single\"}','API-TEST-SKU-1775247955',1,'2026-04-03 20:25:58','2026-04-03 20:25:58'),(56,90,'{\"pack\":\"single\"}','API-TEST-SKU-1776175965',1,'2026-04-14 14:12:47','2026-04-14 14:12:47'),(57,92,'{\"pack\":\"single\"}','API-TEST-SKU-1776351874',1,'2026-04-16 15:04:37','2026-04-16 15:04:37');
/*!40000 ALTER TABLE `product_variants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category_id` int unsigned DEFAULT NULL,
  `product_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `expiry_date` date DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_products_code` (`product_code`),
  KEY `idx_products_category` (`category_id`),
  KEY `idx_products_expiry_date` (`expiry_date`),
  CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=94 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (12,'Digital Stethoscope Pro',2,'ATI-PRD-1001','High-fidelity auscultation device for cardiology and general practice',NULL,1,'2026-03-16 06:06:11','2026-03-16 06:06:11'),(13,'Latex Surgical Gloves',3,'ATI-PRD-1002','Sterile powder-free gloves for operation theaters',NULL,1,'2026-03-16 06:06:11','2026-03-16 06:06:11'),(14,'Paracetamol 500mg',1,'ATI-PRD-1003','Analgesic and antipyretic tablet strip',NULL,1,'2026-03-16 06:06:11','2026-03-16 06:06:11'),(15,'BP Monitor Auto',2,'ATI-PRD-1004','Automatic blood pressure monitor with digital display',NULL,1,'2026-03-16 06:06:11','2026-03-16 06:06:11'),(16,'CurlProd_1773646552',NULL,'ATI-20260316-84249',NULL,NULL,1,'2026-03-16 07:35:52','2026-03-16 07:35:52'),(21,'API Test Product 1775211856',NULL,'ATI-20260403-A3D41',NULL,NULL,1,'2026-04-03 10:24:17','2026-04-03 10:24:17'),(22,'API Test Product 1775233339',NULL,'ATI-20260403-1AEC4',NULL,NULL,1,'2026-04-03 16:22:20','2026-04-03 16:22:20'),(23,'API Test Product 1775234030',NULL,'ATI-20260403-B39BB',NULL,NULL,1,'2026-04-03 16:33:51','2026-04-03 16:33:51'),(24,'API Test Product 1775236587',NULL,'ATI-20260403-9B2BE',NULL,NULL,1,'2026-04-03 17:16:29','2026-04-03 17:16:29'),(25,'API Test Product 1775236854',NULL,'ATI-20260403-3E7C9',NULL,NULL,1,'2026-04-03 17:20:55','2026-04-03 17:20:55'),(26,'API Test Product 1775237014',NULL,'ATI-20260403-DC759',NULL,NULL,1,'2026-04-03 17:23:36','2026-04-03 17:23:36'),(28,'API Test Product 1775237238',NULL,'ATI-20260403-28649',NULL,NULL,1,'2026-04-03 17:27:20','2026-04-03 17:27:20'),(30,'API Test Product 1775237388',NULL,'ATI-20260403-FAC94',NULL,NULL,1,'2026-04-03 17:29:49','2026-04-03 17:29:49'),(32,'API Test Product 1775237642',NULL,'ATI-20260403-4C9C1',NULL,NULL,1,'2026-04-03 17:34:03','2026-04-03 17:34:03'),(34,'API Test Product 1775238231',NULL,'ATI-20260403-C5B6A',NULL,NULL,1,'2026-04-03 17:43:53','2026-04-03 17:43:53'),(36,'API Test Product 1775238438',NULL,'ATI-20260403-B45E3',NULL,NULL,1,'2026-04-03 17:47:19','2026-04-03 17:47:19'),(38,'API Test Product 1775238714',NULL,'ATI-20260403-6870A',NULL,NULL,1,'2026-04-03 17:51:56','2026-04-03 17:51:56'),(40,'API Test Product 1775239074',NULL,'ATI-20260403-FA004',NULL,NULL,1,'2026-04-03 17:57:56','2026-04-03 17:57:56'),(42,'API Test Product 1775239221',NULL,'ATI-20260404-BDA06',NULL,NULL,1,'2026-04-03 18:00:23','2026-04-03 18:00:23'),(44,'API Test Product 1775239466',NULL,'ATI-20260404-69AA5',NULL,NULL,1,'2026-04-03 18:04:28','2026-04-03 18:04:28'),(46,'API Test Product 1775239610',NULL,'ATI-20260404-CAFA3',NULL,NULL,1,'2026-04-03 18:06:52','2026-04-03 18:06:52'),(48,'API Test Product 1775239708',NULL,'ATI-20260404-030E9',NULL,NULL,1,'2026-04-03 18:08:29','2026-04-03 18:08:29'),(50,'API Test Product 1775239788',NULL,'ATI-20260404-0D98F',NULL,NULL,1,'2026-04-03 18:09:50','2026-04-03 18:09:50'),(52,'API Test Product 1775239947',NULL,'ATI-20260404-1901A',NULL,NULL,1,'2026-04-03 18:12:28','2026-04-03 18:12:28'),(54,'API Test Product 1775240091',NULL,'ATI-20260404-95A73',NULL,NULL,1,'2026-04-03 18:14:53','2026-04-03 18:14:53'),(56,'API Test Product 1775240268',NULL,'ATI-20260404-F804D',NULL,NULL,1,'2026-04-03 18:17:50','2026-04-03 18:17:50'),(58,'API Test Product 1775240617',NULL,'ATI-20260404-2D94E',NULL,NULL,1,'2026-04-03 18:23:39','2026-04-03 18:23:39'),(60,'API Test Product 1775240839',NULL,'ATI-20260404-9C449',NULL,NULL,1,'2026-04-03 18:27:21','2026-04-03 18:27:21'),(62,'API Test Product 1775241137',NULL,'ATI-20260404-0E832',NULL,NULL,1,'2026-04-03 18:32:19','2026-04-03 18:32:19'),(64,'API Test Product 1775242133',NULL,'ATI-20260404-B22FB',NULL,NULL,1,'2026-04-03 18:48:55','2026-04-03 18:48:55'),(66,'API Test Product 1775242418',NULL,'ATI-20260404-CD3BC',NULL,NULL,1,'2026-04-03 18:53:40','2026-04-03 18:53:40'),(68,'API Test Product 1775242661',NULL,'ATI-20260404-43D53',NULL,NULL,1,'2026-04-03 18:57:43','2026-04-03 18:57:43'),(70,'API Test Product 1775243091',NULL,'ATI-20260404-8764A',NULL,NULL,1,'2026-04-03 19:04:53','2026-04-03 19:04:53'),(72,'API Test Product 1775243256',NULL,'ATI-20260404-D9241',NULL,NULL,1,'2026-04-03 19:07:38','2026-04-03 19:07:38'),(74,'API Test Product 1775243874',NULL,'ATI-20260404-F3D00',NULL,NULL,1,'2026-04-03 19:17:56','2026-04-03 19:17:56'),(76,'API Test Product 1775245511',NULL,'ATI-20260404-24A9C',NULL,NULL,1,'2026-04-03 19:45:14','2026-04-03 19:45:14'),(78,'API Test Product 1775245651',NULL,'ATI-20260404-38944',NULL,NULL,1,'2026-04-03 19:47:33','2026-04-03 19:47:33'),(80,'API Test Product 1775247044',NULL,'ATI-20260404-F4CF5',NULL,NULL,1,'2026-04-03 20:10:46','2026-04-03 20:10:46'),(82,'API Test Product 1775247167',NULL,'ATI-20260404-11F7F',NULL,NULL,1,'2026-04-03 20:12:48','2026-04-03 20:12:48'),(84,'API Test Product 1775247257',NULL,'ATI-20260404-88B32',NULL,NULL,1,'2026-04-03 20:14:19','2026-04-03 20:14:19'),(86,'API Test Product 1775247708',NULL,'ATI-20260404-2B19F',NULL,NULL,1,'2026-04-03 20:21:50','2026-04-03 20:21:50'),(88,'API Test Product 1775247955',NULL,'ATI-20260404-C01C5',NULL,NULL,1,'2026-04-03 20:25:57','2026-04-03 20:25:57'),(90,'API Test Product 1776175965',NULL,'ATI-20260414-50A0C',NULL,NULL,1,'2026-04-14 14:12:47','2026-04-14 14:12:47'),(92,'API Test Product 1776351874',NULL,'ATI-20260416-5E014',NULL,'2026-07-10',1,'2026-04-16 15:04:37','2026-04-16 15:04:37');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quotation_items`
--

DROP TABLE IF EXISTS `quotation_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quotation_items` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `quotation_id` int unsigned NOT NULL,
  `variant_unit_id` int unsigned NOT NULL,
  `quantity` decimal(14,4) NOT NULL,
  `unit_price` decimal(14,2) NOT NULL COMMENT 'price snapshotted at quote time',
  PRIMARY KEY (`id`),
  KEY `idx_qi_quotation` (`quotation_id`),
  KEY `idx_qi_variant_unit` (`variant_unit_id`)
) ENGINE=InnoDB AUTO_INCREMENT=223 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quotation_items`
--

LOCK TABLES `quotation_items` WRITE;
/*!40000 ALTER TABLE `quotation_items` DISABLE KEYS */;
INSERT INTO `quotation_items` VALUES (1,1,2,2.0000,150.00),(2,2,2,1.0000,150.00),(3,3,3,2.0000,150.00),(4,4,3,1.0000,150.00),(15,15,14,2.0000,150.00),(16,16,15,2.0000,120.00),(19,19,16,2.0000,120.00),(22,22,17,2.0000,120.00),(25,25,18,2.0000,120.00),(29,28,19,2.0000,120.00),(34,32,20,2.0000,120.00),(39,36,21,2.0000,120.00),(44,40,22,2.0000,120.00),(49,44,23,2.0000,120.00),(54,48,24,2.0000,120.00),(59,52,25,2.0000,120.00),(64,56,26,2.0000,120.00),(69,60,27,2.0000,120.00),(74,64,28,2.0000,120.00),(79,68,29,2.0000,120.00),(84,72,30,2.0000,120.00),(89,76,31,2.0000,120.00),(94,80,32,2.0000,120.00),(99,84,33,2.0000,120.00),(104,88,34,2.0000,120.00),(109,92,35,2.0000,120.00),(114,96,36,2.0000,120.00),(119,100,37,2.0000,120.00),(124,104,38,2.0000,120.00),(129,108,39,2.0000,120.00),(134,112,40,2.0000,120.00),(139,116,41,2.0000,120.00),(144,120,42,2.0000,120.00),(149,124,43,2.0000,120.00),(154,128,44,2.0000,120.00),(159,132,45,2.0000,120.00),(164,136,46,2.0000,120.00),(169,140,47,2.0000,120.00),(174,144,48,2.0000,120.00),(179,148,49,2.0000,120.00),(184,152,50,2.0000,120.00),(189,156,51,2.0000,120.00),(194,160,52,2.0000,120.00),(199,164,53,2.0000,120.00),(204,168,54,2.0000,120.00),(209,172,55,2.0000,120.00),(214,176,56,2.0000,120.00),(219,180,57,2.0000,120.00);
/*!40000 ALTER TABLE `quotation_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quotation_requests`
--

DROP TABLE IF EXISTS `quotation_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quotation_requests` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `salesman_id` int unsigned NOT NULL,
  `customer_id` int unsigned DEFAULT NULL,
  `status` enum('pending','accepted','returned','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `editor_id` int unsigned DEFAULT NULL COMMENT 'editor who acted on this quote',
  `requested_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `processed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_qr_salesman` (`salesman_id`),
  KEY `idx_qr_customer` (`customer_id`),
  KEY `idx_qr_status` (`status`),
  KEY `idx_qr_editor` (`editor_id`),
  KEY `idx_qr_requested` (`requested_at`)
) ENGINE=InnoDB AUTO_INCREMENT=184 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quotation_requests`
--

LOCK TABLES `quotation_requests` WRITE;
/*!40000 ALTER TABLE `quotation_requests` DISABLE KEYS */;
INSERT INTO `quotation_requests` VALUES (1,1,1,'returned','Test quotation',1,'2026-03-02 15:42:56','2026-03-02 15:42:56'),(2,1,1,'rejected','Reject me',1,'2026-03-02 15:42:56','2026-03-02 15:42:56'),(3,1,2,'returned','Test quotation',1,'2026-03-02 15:43:47','2026-03-02 15:43:47'),(4,1,2,'rejected','Reject me',1,'2026-03-02 15:43:47','2026-03-02 15:43:47'),(15,1,11,'accepted','curl quote',1,'2026-03-16 07:35:54','2026-03-16 07:35:54'),(16,1,13,'accepted','Q1 updated',1,'2026-03-28 11:49:48','2026-03-28 11:49:48'),(19,1,14,'accepted','Q1 updated',1,'2026-03-28 11:50:13','2026-03-28 11:50:14'),(22,1,15,'accepted','Q1 updated',1,'2026-03-28 11:53:44','2026-03-28 11:53:44'),(25,1,16,'accepted','Q1 updated',1,'2026-03-28 12:00:16','2026-03-28 12:00:16'),(28,1,17,'accepted','Q1 updated',1,'2026-04-03 10:24:18','2026-04-03 10:24:18'),(32,1,18,'accepted','Q1 updated',1,'2026-04-03 16:22:21','2026-04-03 16:22:21'),(36,1,19,'accepted','Q1 updated',1,'2026-04-03 16:33:52','2026-04-03 16:33:53'),(40,1,20,'accepted','Q1 updated',1,'2026-04-03 17:16:30','2026-04-03 17:16:30'),(44,1,21,'accepted','Q1 updated',1,'2026-04-03 17:20:56','2026-04-03 17:20:56'),(48,1,22,'accepted','Q1 updated',1,'2026-04-03 17:23:37','2026-04-03 17:23:37'),(52,1,23,'accepted','Q1 updated',1,'2026-04-03 17:27:21','2026-04-03 17:27:21'),(56,1,24,'accepted','Q1 updated',1,'2026-04-03 17:29:51','2026-04-03 17:29:51'),(60,1,25,'accepted','Q1 updated',1,'2026-04-03 17:34:05','2026-04-03 17:34:05'),(64,1,27,'accepted','Q1 updated',1,'2026-04-03 17:43:54','2026-04-03 17:43:54'),(68,1,29,'accepted','Q1 updated',1,'2026-04-03 17:47:21','2026-04-03 17:47:21'),(72,1,31,'accepted','Q1 updated',1,'2026-04-03 17:51:57','2026-04-03 17:51:58'),(76,1,33,'accepted','Q1 updated',1,'2026-04-03 17:57:57','2026-04-03 17:57:57'),(80,1,35,'accepted','Q1 updated',1,'2026-04-03 18:00:24','2026-04-03 18:00:24'),(84,1,37,'accepted','Q1 updated',1,'2026-04-03 18:04:30','2026-04-03 18:04:30'),(88,1,39,'accepted','Q1 updated',1,'2026-04-03 18:06:54','2026-04-03 18:06:54'),(92,1,41,'accepted','Q1 updated',1,'2026-04-03 18:08:31','2026-04-03 18:08:31'),(96,1,43,'accepted','Q1 updated',1,'2026-04-03 18:09:51','2026-04-03 18:09:51'),(100,1,45,'accepted','Q1 updated',1,'2026-04-03 18:12:30','2026-04-03 18:12:30'),(104,1,47,'accepted','Q1 updated',1,'2026-04-03 18:14:55','2026-04-03 18:14:55'),(108,1,49,'accepted','Q1 updated',1,'2026-04-03 18:17:51','2026-04-03 18:17:52'),(112,1,51,'accepted','Q1 updated',1,'2026-04-03 18:23:41','2026-04-03 18:23:41'),(116,1,53,'accepted','Q1 updated',1,'2026-04-03 18:27:23','2026-04-03 18:27:23'),(120,1,55,'accepted','Q1 updated',1,'2026-04-03 18:32:20','2026-04-03 18:32:20'),(124,1,57,'accepted','Q1 updated',1,'2026-04-03 18:48:56','2026-04-03 18:48:57'),(128,1,59,'accepted','Q1 updated',1,'2026-04-03 18:53:42','2026-04-03 18:53:42'),(132,1,61,'accepted','Q1 updated',1,'2026-04-03 18:57:45','2026-04-03 18:57:45'),(136,1,63,'accepted','Q1 updated',1,'2026-04-03 19:04:54','2026-04-03 19:04:55'),(140,1,65,'accepted','Q1 updated',1,'2026-04-03 19:07:40','2026-04-03 19:07:40'),(144,1,67,'accepted','Q1 updated',1,'2026-04-03 19:17:58','2026-04-03 19:17:59'),(148,1,69,'accepted','Q1 updated',1,'2026-04-03 19:45:15','2026-04-03 19:45:16'),(152,1,71,'accepted','Q1 updated',1,'2026-04-03 19:47:35','2026-04-03 19:47:35'),(156,1,73,'accepted','Q1 updated',1,'2026-04-03 20:10:48','2026-04-03 20:10:48'),(160,1,75,'accepted','Q1 updated',1,'2026-04-03 20:12:50','2026-04-03 20:12:50'),(164,1,77,'accepted','Q1 updated',1,'2026-04-03 20:14:21','2026-04-03 20:14:21'),(168,1,79,'accepted','Q1 updated',1,'2026-04-03 20:21:52','2026-04-03 20:21:52'),(172,1,81,'accepted','Q1 updated',1,'2026-04-03 20:25:59','2026-04-03 20:25:59'),(176,1,83,'accepted','Q1 updated',1,'2026-04-14 14:12:49','2026-04-14 14:12:49'),(180,1,85,'accepted','Q1 updated',1,'2026-04-16 15:04:38','2026-04-16 15:04:39');
/*!40000 ALTER TABLE `quotation_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sales_invoices`
--

DROP TABLE IF EXISTS `sales_invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sales_invoices` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `quotation_id` int unsigned NOT NULL,
  `customer_id` int unsigned NOT NULL,
  `date` date NOT NULL,
  `total_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `status` enum('active','returned','void') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_invoice_quotation` (`quotation_id`),
  KEY `idx_invoice_customer` (`customer_id`),
  KEY `idx_invoice_date` (`date`),
  KEY `idx_invoice_status` (`status`),
  KEY `idx_invoice_created_by` (`created_by`)
) ENGINE=InnoDB AUTO_INCREMENT=138 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sales_invoices`
--

LOCK TABLES `sales_invoices` WRITE;
/*!40000 ALTER TABLE `sales_invoices` DISABLE KEYS */;
INSERT INTO `sales_invoices` VALUES (1,1,1,'2026-03-02',300.00,'returned',1,'2026-03-02 15:42:56','2026-03-02 15:42:56'),(2,3,2,'2026-03-02',300.00,'returned',1,'2026-03-02 15:43:47','2026-03-02 15:43:47'),(8,15,11,'2026-03-16',300.00,'active',1,'2026-03-16 07:35:54','2026-03-16 07:35:54'),(9,16,13,'2026-03-28',240.00,'active',1,'2026-03-28 11:49:48','2026-03-28 11:49:48'),(12,19,14,'2026-03-28',240.00,'active',1,'2026-03-28 11:50:14','2026-03-28 11:50:14'),(15,22,15,'2026-03-28',240.00,'active',1,'2026-03-28 11:53:44','2026-03-28 11:53:44'),(18,25,16,'2026-03-28',240.00,'active',1,'2026-03-28 12:00:16','2026-03-28 12:00:16'),(21,28,17,'2026-04-03',240.00,'active',1,'2026-04-03 10:24:18','2026-04-03 10:24:18'),(24,32,18,'2026-04-03',240.00,'active',1,'2026-04-03 16:22:21','2026-04-03 16:22:21'),(27,36,19,'2026-04-03',240.00,'active',1,'2026-04-03 16:33:53','2026-04-03 16:33:53'),(30,40,20,'2026-04-03',240.00,'active',1,'2026-04-03 17:16:30','2026-04-03 17:16:30'),(33,44,21,'2026-04-03',240.00,'active',1,'2026-04-03 17:20:56','2026-04-03 17:20:56'),(36,48,22,'2026-04-03',240.00,'active',1,'2026-04-03 17:23:37','2026-04-03 17:23:37'),(39,52,23,'2026-04-03',240.00,'active',1,'2026-04-03 17:27:21','2026-04-03 17:27:21'),(42,56,24,'2026-04-03',240.00,'active',1,'2026-04-03 17:29:51','2026-04-03 17:29:51'),(45,60,25,'2026-04-03',240.00,'active',1,'2026-04-03 17:34:05','2026-04-03 17:34:05'),(48,64,27,'2026-04-03',240.00,'active',1,'2026-04-03 17:43:54','2026-04-03 17:43:54'),(51,68,29,'2026-04-03',240.00,'active',1,'2026-04-03 17:47:21','2026-04-03 17:47:21'),(54,72,31,'2026-04-03',240.00,'active',1,'2026-04-03 17:51:58','2026-04-03 17:51:58'),(57,76,33,'2026-04-03',240.00,'active',1,'2026-04-03 17:57:57','2026-04-03 17:57:57'),(60,80,35,'2026-04-03',240.00,'active',1,'2026-04-03 18:00:24','2026-04-03 18:00:24'),(63,84,37,'2026-04-03',240.00,'active',1,'2026-04-03 18:04:30','2026-04-03 18:04:30'),(66,88,39,'2026-04-03',240.00,'active',1,'2026-04-03 18:06:54','2026-04-03 18:06:54'),(69,92,41,'2026-04-03',240.00,'active',1,'2026-04-03 18:08:31','2026-04-03 18:08:31'),(72,96,43,'2026-04-03',240.00,'active',1,'2026-04-03 18:09:52','2026-04-03 18:09:52'),(75,100,45,'2026-04-03',240.00,'active',1,'2026-04-03 18:12:30','2026-04-03 18:12:30'),(78,104,47,'2026-04-03',240.00,'active',1,'2026-04-03 18:14:55','2026-04-03 18:14:55'),(81,108,49,'2026-04-03',240.00,'active',1,'2026-04-03 18:17:52','2026-04-03 18:17:52'),(84,112,51,'2026-04-03',240.00,'active',1,'2026-04-03 18:23:41','2026-04-03 18:23:41'),(87,116,53,'2026-04-03',240.00,'active',1,'2026-04-03 18:27:23','2026-04-03 18:27:23'),(90,120,55,'2026-04-03',240.00,'active',1,'2026-04-03 18:32:20','2026-04-03 18:32:20'),(93,124,57,'2026-04-03',240.00,'active',1,'2026-04-03 18:48:57','2026-04-03 18:48:57'),(96,128,59,'2026-04-03',240.00,'active',1,'2026-04-03 18:53:42','2026-04-03 18:53:42'),(99,132,61,'2026-04-03',240.00,'active',1,'2026-04-03 18:57:45','2026-04-03 18:57:45'),(102,136,63,'2026-04-03',240.00,'active',1,'2026-04-03 19:04:55','2026-04-03 19:04:55'),(105,140,65,'2026-04-03',240.00,'active',1,'2026-04-03 19:07:40','2026-04-03 19:07:40'),(108,144,67,'2026-04-03',240.00,'active',1,'2026-04-03 19:17:59','2026-04-03 19:17:59'),(111,148,69,'2026-04-03',240.00,'active',1,'2026-04-03 19:45:16','2026-04-03 19:45:16'),(114,152,71,'2026-04-03',240.00,'active',1,'2026-04-03 19:47:35','2026-04-03 19:47:35'),(117,156,73,'2026-04-03',240.00,'active',1,'2026-04-03 20:10:48','2026-04-03 20:10:48'),(120,160,75,'2026-04-03',240.00,'active',1,'2026-04-03 20:12:50','2026-04-03 20:12:50'),(123,164,77,'2026-04-03',240.00,'active',1,'2026-04-03 20:14:21','2026-04-03 20:14:21'),(126,168,79,'2026-04-03',240.00,'active',1,'2026-04-03 20:21:52','2026-04-03 20:21:52'),(129,172,81,'2026-04-03',240.00,'active',1,'2026-04-03 20:25:59','2026-04-03 20:25:59'),(132,176,83,'2026-04-14',240.00,'active',1,'2026-04-14 14:12:49','2026-04-14 14:12:49'),(135,180,85,'2026-04-16',240.00,'active',1,'2026-04-16 15:04:39','2026-04-16 15:04:39');
/*!40000 ALTER TABLE `sales_invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `units`
--

DROP TABLE IF EXISTS `units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `units` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `multiplier` decimal(10,4) NOT NULL DEFAULT '1.0000' COMMENT 'conversion factor to base unit',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_units_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `units`
--

LOCK TABLES `units` WRITE;
/*!40000 ALTER TABLE `units` DISABLE KEYS */;
INSERT INTO `units` VALUES (1,'piece',1.0000,'2026-03-02 14:57:03'),(2,'box of 10',10.0000,'2026-03-02 14:57:03'),(3,'box of 50',50.0000,'2026-03-02 14:57:03'),(4,'carton',100.0000,'2026-03-02 14:57:03'),(5,'dozen',12.0000,'2026-03-02 14:57:03'),(16,'CurlUnit_1773646552',5.0000,'2026-03-16 07:35:53'),(21,'API Test Unit 1775211856',1.0000,'2026-04-03 10:24:17'),(22,'API Test Unit 1775233339',1.0000,'2026-04-03 16:22:20'),(23,'API Test Unit 1775234030',1.0000,'2026-04-03 16:33:52'),(24,'API Test Unit 1775236587',1.0000,'2026-04-03 17:16:29'),(25,'API Test Unit 1775236854',1.0000,'2026-04-03 17:20:55'),(26,'API Test Unit 1775237014',1.0000,'2026-04-03 17:23:36'),(27,'API Test Unit 1775237238',1.0000,'2026-04-03 17:27:20'),(29,'API Test Unit 1775237388',1.0000,'2026-04-03 17:29:50'),(31,'API Test Unit 1775237642',1.0000,'2026-04-03 17:34:04'),(33,'API Test Unit 1775238231',1.0000,'2026-04-03 17:43:53'),(35,'API Test Unit 1775238438',1.0000,'2026-04-03 17:47:20'),(37,'API Test Unit 1775238714',1.0000,'2026-04-03 17:51:56'),(39,'API Test Unit 1775239074',1.0000,'2026-04-03 17:57:56'),(41,'API Test Unit 1775239221',1.0000,'2026-04-03 18:00:23'),(43,'API Test Unit 1775239466',1.0000,'2026-04-03 18:04:28'),(45,'API Test Unit 1775239610',1.0000,'2026-04-03 18:06:53'),(47,'API Test Unit 1775239708',1.0000,'2026-04-03 18:08:30'),(49,'API Test Unit 1775239788',1.0000,'2026-04-03 18:09:50'),(51,'API Test Unit 1775239947',1.0000,'2026-04-03 18:12:29'),(53,'API Test Unit 1775240091',1.0000,'2026-04-03 18:14:54'),(55,'API Test Unit 1775240268',1.0000,'2026-04-03 18:17:50'),(57,'API Test Unit 1775240617',1.0000,'2026-04-03 18:23:40'),(59,'API Test Unit 1775240839',1.0000,'2026-04-03 18:27:22'),(61,'API Test Unit 1775241137',1.0000,'2026-04-03 18:32:19'),(63,'API Test Unit 1775242133',1.0000,'2026-04-03 18:48:55'),(65,'API Test Unit 1775242418',1.0000,'2026-04-03 18:53:40'),(67,'API Test Unit 1775242661',1.0000,'2026-04-03 18:57:44'),(69,'API Test Unit 1775243091',1.0000,'2026-04-03 19:04:53'),(71,'API Test Unit 1775243256',1.0000,'2026-04-03 19:07:39'),(73,'API Test Unit 1775243874',1.0000,'2026-04-03 19:17:57'),(75,'API Test Unit 1775245511',1.0000,'2026-04-03 19:45:14'),(77,'API Test Unit 1775245651',1.0000,'2026-04-03 19:47:34'),(79,'API Test Unit 1775247044',1.0000,'2026-04-03 20:10:47'),(81,'API Test Unit 1775247167',1.0000,'2026-04-03 20:12:49'),(83,'API Test Unit 1775247257',1.0000,'2026-04-03 20:14:20'),(85,'API Test Unit 1775247708',1.0000,'2026-04-03 20:21:50'),(87,'API Test Unit 1775247955',1.0000,'2026-04-03 20:25:57'),(89,'API Test Unit 1776175965',1.0000,'2026-04-14 14:12:47'),(91,'API Test Unit 1776351874',1.0000,'2026-04-16 15:04:37');
/*!40000 ALTER TABLE `units` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('superadmin','editor','viewer','salesman') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'viewer',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'System Admin','admin@ati.local','$2y$12$ALTH6Nu6WEvYD/id.Ft5n.YRUC4/wMAlZMNwcrOwm99SHwDvtae5i','superadmin',1,'2026-03-02 14:57:03','2026-03-02 14:57:03'),(13,'Ali Sales','salesman@ati.local','$2y$12$hnPgvdfDArc5L0VVI21BseW73Nsvc.pwWtXd6LwUPEDH/0WU1uihq','salesman',1,'2026-03-16 05:55:35','2026-04-04 12:38:14'),(15,'Editor User','editor@ati.local','$2y$12$M9AAUzmz5azni3ZiW/MyDOw9v7k8yS3FxGyon0N353m9WUg8cyZO6','editor',1,'2026-03-16 06:06:11','2026-03-16 06:06:11'),(16,'Viewer User','viewer@ati.local','$2y$12$M9AAUzmz5azni3ZiW/MyDOw9v7k8yS3FxGyon0N353m9WUg8cyZO6','viewer',1,'2026-03-16 06:06:11','2026-03-16 06:06:11'),(17,'Curl User 1773646453','curl_user_1773646453@ati.local','$2y$12$BY806xdIBhLAIrGovjsHLegU0ctuFhXWMVLBW3Vwn10ej6/L5UTnq','viewer',1,'2026-03-16 07:34:13','2026-03-16 07:34:13');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `variant_units`
--

DROP TABLE IF EXISTS `variant_units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `variant_units` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `variant_id` int unsigned NOT NULL,
  `unit_id` int unsigned NOT NULL,
  `stock_quantity` decimal(14,4) NOT NULL DEFAULT '0.0000',
  `unit_price` decimal(14,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_variant_unit` (`variant_id`,`unit_id`),
  KEY `idx_vu_variant` (`variant_id`),
  KEY `idx_vu_unit` (`unit_id`),
  CONSTRAINT `fk_vu_unit` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_vu_variant` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `variant_units`
--

LOCK TABLES `variant_units` WRITE;
/*!40000 ALTER TABLE `variant_units` DISABLE KEYS */;
INSERT INTO `variant_units` VALUES (9,9,1,25.0000,8500.00,'2026-03-16 06:06:11','2026-03-16 06:06:11'),(10,10,2,120.0000,450.00,'2026-03-16 06:06:11','2026-03-16 06:06:11'),(11,11,2,110.0000,480.00,'2026-03-16 06:06:11','2026-03-16 06:06:11'),(12,12,3,75.0000,320.00,'2026-03-16 06:06:11','2026-03-16 06:06:11'),(13,13,1,40.0000,5600.00,'2026-03-16 06:06:11','2026-03-16 06:06:11'),(14,14,16,48.0000,150.00,'2026-03-16 07:35:53','2026-03-16 07:35:54'),(19,19,21,98.0000,120.00,'2026-04-03 10:24:17','2026-04-03 10:24:18'),(20,20,22,98.0000,120.00,'2026-04-03 16:22:20','2026-04-03 16:22:21'),(21,21,23,98.0000,120.00,'2026-04-03 16:33:52','2026-04-03 16:33:53'),(22,22,24,98.0000,120.00,'2026-04-03 17:16:29','2026-04-03 17:16:30'),(23,23,25,98.0000,120.00,'2026-04-03 17:20:55','2026-04-03 17:20:56'),(24,24,26,98.0000,120.00,'2026-04-03 17:23:36','2026-04-03 17:23:37'),(25,25,27,98.0000,120.00,'2026-04-03 17:27:20','2026-04-03 17:27:21'),(26,26,29,98.0000,120.00,'2026-04-03 17:29:50','2026-04-03 17:29:51'),(27,27,31,98.0000,120.00,'2026-04-03 17:34:04','2026-04-03 17:34:05'),(28,28,33,98.0000,120.00,'2026-04-03 17:43:53','2026-04-03 17:43:54'),(29,29,35,98.0000,120.00,'2026-04-03 17:47:20','2026-04-03 17:47:21'),(30,30,37,98.0000,120.00,'2026-04-03 17:51:57','2026-04-03 17:51:58'),(31,31,39,98.0000,120.00,'2026-04-03 17:57:56','2026-04-03 17:57:57'),(32,32,41,98.0000,120.00,'2026-04-03 18:00:23','2026-04-03 18:00:24'),(33,33,43,98.0000,120.00,'2026-04-03 18:04:29','2026-04-03 18:04:30'),(34,34,45,98.0000,120.00,'2026-04-03 18:06:53','2026-04-03 18:06:54'),(35,35,47,98.0000,120.00,'2026-04-03 18:08:30','2026-04-03 18:08:31'),(36,36,49,98.0000,120.00,'2026-04-03 18:09:50','2026-04-03 18:09:51'),(37,37,51,98.0000,120.00,'2026-04-03 18:12:29','2026-04-03 18:12:30'),(38,38,53,98.0000,120.00,'2026-04-03 18:14:54','2026-04-03 18:14:55'),(39,39,55,98.0000,120.00,'2026-04-03 18:17:50','2026-04-03 18:17:52'),(40,40,57,98.0000,120.00,'2026-04-03 18:23:40','2026-04-03 18:23:41'),(41,41,59,98.0000,120.00,'2026-04-03 18:27:22','2026-04-03 18:27:23'),(42,42,61,98.0000,120.00,'2026-04-03 18:32:19','2026-04-03 18:32:20'),(43,43,63,98.0000,120.00,'2026-04-03 18:48:55','2026-04-03 18:48:57'),(44,44,65,98.0000,120.00,'2026-04-03 18:53:40','2026-04-03 18:53:42'),(45,45,67,98.0000,120.00,'2026-04-03 18:57:44','2026-04-03 18:57:45'),(46,46,69,98.0000,120.00,'2026-04-03 19:04:53','2026-04-03 19:04:55'),(47,47,71,98.0000,120.00,'2026-04-03 19:07:39','2026-04-03 19:07:40'),(48,48,73,98.0000,120.00,'2026-04-03 19:17:57','2026-04-03 19:17:59'),(49,49,75,98.0000,120.00,'2026-04-03 19:45:14','2026-04-03 19:45:16'),(50,50,77,98.0000,120.00,'2026-04-03 19:47:34','2026-04-03 19:47:35'),(51,51,79,98.0000,120.00,'2026-04-03 20:10:47','2026-04-03 20:10:48'),(52,52,81,98.0000,120.00,'2026-04-03 20:12:49','2026-04-03 20:12:50'),(53,53,83,98.0000,120.00,'2026-04-03 20:14:20','2026-04-03 20:14:21'),(54,54,85,98.0000,120.00,'2026-04-03 20:21:50','2026-04-03 20:21:52'),(55,55,87,98.0000,120.00,'2026-04-03 20:25:58','2026-04-03 20:25:59'),(56,56,89,98.0000,120.00,'2026-04-14 14:12:48','2026-04-14 14:12:49'),(57,57,91,98.0000,120.00,'2026-04-16 15:04:37','2026-04-16 15:04:39');
/*!40000 ALTER TABLE `variant_units` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-17  9:46:29
