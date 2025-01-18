-- MySQL dump 10.13  Distrib 8.3.0, for Win64 (x86_64)
--
-- Host: localhost    Database: graduation_management
-- ------------------------------------------------------
-- Server version	8.3.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `progress_records`
--

DROP TABLE IF EXISTS `progress_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `progress_records` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(50) NOT NULL,
  `stage_id` int NOT NULL,
  `file_url` varchar(255) DEFAULT NULL,
  `comment` text,
  `status` enum('pending','submitted','reviewing','revision_needed','approved','rejected','overdue') DEFAULT 'pending',
  `review_comment` text,
  `reviewer_id` varchar(20) DEFAULT NULL,
  `submit_time` datetime DEFAULT NULL,
  `review_time` datetime DEFAULT NULL,
  `score` decimal(5,2) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_student_stage` (`student_id`,`stage_id`)
) ENGINE=InnoDB AUTO_INCREMENT=107 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `progress_records`
--

LOCK TABLES `progress_records` WRITE;
/*!40000 ALTER TABLE `progress_records` DISABLE KEYS */;
INSERT INTO `progress_records` VALUES (6,'S2024101',1,'/files/S2024101/proposal.pdf','开题报告进行中','submitted',NULL,'T2024001','2024-03-01 10:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(7,'S2024102',1,'/files/S2024102/proposal.pdf','开题报告已提交','reviewing',NULL,'T2024002','2024-03-02 11:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(8,'S2024103',2,'/files/S2024103/literature.pdf','文献综述进行中','approved',NULL,'T2024003','2024-03-03 12:00:00','2024-03-10 14:00:00',85.00,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(9,'S2024104',2,'/files/S2024104/literature.pdf','文献综述已提交','revision_needed',NULL,'T2024004','2024-03-04 13:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(10,'S2024105',3,'/files/S2024105/proposal.pdf','开题报告已提交','pending',NULL,'T2024005','2024-03-05 14:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(11,'S2024106',3,'/files/S2024106/proposal.pdf','开题报告进行中','submitted',NULL,'T2024006','2024-03-06 15:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(12,'S2024107',1,'/files/S2024107/proposal.pdf','开题报告已提交','reviewing',NULL,'T2024007','2024-03-07 16:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(13,'S2024108',2,'/files/S2024108/literature.pdf','文献综述进行中','approved',NULL,'T2024008','2024-03-08 17:00:00','2024-03-15 18:00:00',90.00,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(14,'S2024109',2,'/files/S2024109/literature.pdf','文献综述已提交','revision_needed',NULL,'T2024009','2024-03-09 18:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(15,'S2024110',3,'/files/S2024110/proposal.pdf','开题报告已提交','pending',NULL,'T2024010','2024-03-10 19:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(16,'S2024111',1,'/files/S2024111/proposal.pdf','开题报告进行中','submitted',NULL,'T2024011','2024-03-11 10:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(17,'S2024112',1,'/files/S2024112/proposal.pdf','开题报告已提交','reviewing',NULL,'T2024012','2024-03-12 11:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(18,'S2024113',2,'/files/S2024113/literature.pdf','文献综述进行中','approved',NULL,'T2024013','2024-03-13 12:00:00','2024-03-20 14:00:00',87.00,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(19,'S2024114',2,'/files/S2024114/literature.pdf','文献综述已提交','revision_needed',NULL,'T2024014','2024-03-14 13:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(20,'S2024115',3,'/files/S2024115/proposal.pdf','开题报告已提交','pending',NULL,'T2024015','2024-03-15 14:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(21,'S2024116',3,'/files/S2024116/proposal.pdf','开题报告进行中','submitted',NULL,'T2024016','2024-03-16 15:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(22,'S2024117',1,'/files/S2024117/proposal.pdf','开题报告已提交','reviewing',NULL,'T2024017','2024-03-17 16:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(23,'S2024118',2,'/files/S2024118/literature.pdf','文献综述进行中','approved',NULL,'T2024018','2024-03-18 17:00:00','2024-03-25 18:00:00',92.00,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(24,'S2024119',2,'/files/S2024119/literature.pdf','文献综述已提交','revision_needed',NULL,'T2024019','2024-03-19 18:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(25,'S2024120',3,'/files/S2024120/proposal.pdf','开题报告已提交','pending',NULL,'T2024020','2024-03-20 19:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(26,'S2024121',1,'/files/S2024121/proposal.pdf','开题报告进行中','submitted',NULL,'T2024021','2024-03-21 10:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(27,'S2024122',1,'/files/S2024122/proposal.pdf','开题报告已提交','reviewing',NULL,'T2024022','2024-03-22 11:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(28,'S2024123',2,'/files/S2024123/literature.pdf','文献综述进行中','approved',NULL,'T2024023','2024-03-23 12:00:00','2024-03-30 14:00:00',89.00,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(29,'S2024124',2,'/files/S2024124/literature.pdf','文献综述已提交','revision_needed',NULL,'T2024024','2024-03-24 13:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(30,'S2024125',3,'/files/S2024125/proposal.pdf','开题报告已提交','pending',NULL,'T2024025','2024-03-25 14:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(31,'S2024126',3,'/files/S2024126/proposal.pdf','开题报告进行中','submitted',NULL,'T2024026','2024-03-26 15:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(32,'S2024127',1,'/files/S2024127/proposal.pdf','开题报告已提交','reviewing',NULL,'T2024027','2024-03-27 16:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(33,'S2024128',2,'/files/S2024128/literature.pdf','文献综述进行中','approved',NULL,'T2024028','2024-03-28 17:00:00','2024-04-04 18:00:00',91.00,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(34,'S2024129',2,'/files/S2024129/literature.pdf','文献综述已提交','revision_needed',NULL,'T2024029','2024-03-29 18:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(35,'S2024130',3,'/files/S2024130/proposal.pdf','开题报告已提交','pending',NULL,'T2024030','2024-03-30 19:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(36,'S2024131',1,'/files/S2024131/proposal.pdf','开题报告进行中','submitted',NULL,'T2024001','2024-03-31 10:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(37,'S2024132',1,'/files/S2024132/proposal.pdf','开题报告已提交','reviewing',NULL,'T2024002','2024-04-01 11:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(38,'S2024133',2,'/files/S2024133/literature.pdf','文献综述进行中','approved',NULL,'T2024003','2024-04-02 12:00:00','2024-04-09 14:00:00',86.00,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(39,'S2024134',2,'/files/S2024134/literature.pdf','文献综述已提交','revision_needed',NULL,'T2024004','2024-04-03 13:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(40,'S2024135',3,'/files/S2024135/proposal.pdf','开题报告已提交','pending',NULL,'T2024005','2024-04-04 14:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(41,'S2024136',3,'/files/S2024136/proposal.pdf','开题报告进行中','submitted',NULL,'T2024006','2024-04-05 15:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(42,'S2024137',1,'/files/S2024137/proposal.pdf','开题报告已提交','reviewing',NULL,'T2024007','2024-04-06 16:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(43,'S2024138',2,'/files/S2024138/literature.pdf','文献综述进行中','approved',NULL,'T2024008','2024-04-07 17:00:00','2024-04-14 18:00:00',93.00,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(44,'S2024139',2,'/files/S2024139/literature.pdf','文献综述已提交','revision_needed',NULL,'T2024009','2024-04-08 18:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(45,'S2024140',3,'/files/S2024140/proposal.pdf','开题报告已提交','pending',NULL,'T2024010','2024-04-09 19:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(46,'S2024141',1,'/files/S2024141/proposal.pdf','开题报告进行中','submitted',NULL,'T2024011','2024-04-10 10:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(47,'S2024142',1,'/files/S2024142/proposal.pdf','开题报告已提交','reviewing',NULL,'T2024012','2024-04-11 11:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(48,'S2024143',2,'/files/S2024143/literature.pdf','文献综述进行中','approved',NULL,'T2024013','2024-04-12 12:00:00','2024-04-19 14:00:00',88.00,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(49,'S2024144',2,'/files/S2024144/literature.pdf','文献综述已提交','revision_needed',NULL,'T2024014','2024-04-13 13:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(50,'S2024145',3,'/files/S2024145/proposal.pdf','开题报告已提交','pending',NULL,'T2024015','2024-04-14 14:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(51,'S2024146',3,'/files/S2024146/proposal.pdf','开题报告进行中','submitted',NULL,'T2024016','2024-04-15 15:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(52,'S2024147',1,'/files/S2024147/proposal.pdf','开题报告已提交','reviewing',NULL,'T2024017','2024-04-16 16:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(53,'S2024148',2,'/files/S2024148/literature.pdf','文献综述进行中','approved',NULL,'T2024018','2024-04-17 17:00:00','2024-04-24 18:00:00',94.00,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(54,'S2024149',2,'/files/S2024149/literature.pdf','文献综述已提交','revision_needed',NULL,'T2024019','2024-04-18 18:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(55,'S2024150',3,'/files/S2024150/proposal.pdf','开题报告已提交','pending',NULL,'T2024020','2024-04-19 19:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(56,'S2024151',1,'/files/S2024151/proposal.pdf','开题报告进行中','submitted',NULL,'T2024021','2024-04-20 10:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(57,'S2024152',1,'/files/S2024152/proposal.pdf','开题报告已提交','reviewing',NULL,'T2024022','2024-04-21 11:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(58,'S2024153',2,'/files/S2024153/literature.pdf','文献综述进行中','approved',NULL,'T2024023','2024-04-22 12:00:00','2024-04-29 14:00:00',90.00,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(59,'S2024154',2,'/files/S2024154/literature.pdf','文献综述已提交','revision_needed',NULL,'T2024024','2024-04-23 13:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(60,'S2024155',3,'/files/S2024155/proposal.pdf','开题报告已提交','pending',NULL,'T2024025','2024-04-24 14:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(61,'S2024156',3,'/files/S2024156/proposal.pdf','开题报告进行中','submitted',NULL,'T2024026','2024-04-25 15:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(62,'S2024157',1,'/files/S2024157/proposal.pdf','开题报告已提交','reviewing',NULL,'T2024027','2024-04-26 16:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(63,'S2024158',2,'/files/S2024158/literature.pdf','文献综述进行中','approved',NULL,'T2024028','2024-04-27 17:00:00','2024-05-04 18:00:00',95.00,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(64,'S2024159',2,'/files/S2024159/literature.pdf','文献综述已提交','revision_needed',NULL,'T2024029','2024-04-28 18:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(65,'S2024160',3,'/files/S2024160/proposal.pdf','开题报告已提交','pending',NULL,'T2024030','2024-04-29 19:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(66,'S2024161',1,'/files/S2024161/proposal.pdf','开题报告进行中','submitted',NULL,'T2024001','2024-04-30 10:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(67,'S2024162',1,'/files/S2024162/proposal.pdf','开题报告已提交','reviewing',NULL,'T2024002','2024-05-01 11:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(68,'S2024163',2,'/files/S2024163/literature.pdf','文献综述进行中','approved',NULL,'T2024003','2024-05-02 12:00:00','2024-05-09 14:00:00',89.00,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(69,'S2024164',2,'/files/S2024164/literature.pdf','文献综述已提交','revision_needed',NULL,'T2024004','2024-05-03 13:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(70,'S2024165',3,'/files/S2024165/proposal.pdf','开题报告已提交','pending',NULL,'T2024005','2024-05-04 14:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(71,'S2024166',3,'/files/S2024166/proposal.pdf','开题报告进行中','submitted',NULL,'T2024006','2024-05-05 15:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(72,'S2024167',1,'/files/S2024167/proposal.pdf','开题报告已提交','reviewing',NULL,'T2024007','2024-05-06 16:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(73,'S2024168',2,'/files/S2024168/literature.pdf','文献综述进行中','approved',NULL,'T2024008','2024-05-07 17:00:00','2024-05-14 18:00:00',92.00,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(74,'S2024169',2,'/files/S2024169/literature.pdf','文献综述已提交','revision_needed',NULL,'T2024009','2024-05-08 18:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(75,'S2024170',3,'/files/S2024170/proposal.pdf','开题报告已提交','pending',NULL,'T2024010','2024-05-09 19:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(76,'S2024171',1,'/files/S2024171/proposal.pdf','开题报告进行中','submitted',NULL,'T2024011','2024-05-10 10:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(77,'S2024172',1,'/files/S2024172/proposal.pdf','开题报告已提交','reviewing',NULL,'T2024012','2024-05-11 11:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(78,'S2024173',2,'/files/S2024173/literature.pdf','文献综述进行中','approved',NULL,'T2024013','2024-05-12 12:00:00','2024-05-19 14:00:00',90.00,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(79,'S2024174',2,'/files/S2024174/literature.pdf','文献综述已提交','revision_needed',NULL,'T2024014','2024-05-13 13:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(80,'S2024175',3,'/files/S2024175/proposal.pdf','开题报告已提交','pending',NULL,'T2024015','2024-05-14 14:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(81,'S2024176',3,'/files/S2024176/proposal.pdf','开题报告进行中','submitted',NULL,'T2024016','2024-05-15 15:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(82,'S2024177',1,'/files/S2024177/proposal.pdf','开题报告已提交','reviewing',NULL,'T2024017','2024-05-16 16:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(83,'S2024178',2,'/files/S2024178/literature.pdf','文献综述进行中','approved',NULL,'T2024018','2024-05-17 17:00:00','2024-05-24 18:00:00',93.00,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(84,'S2024179',2,'/files/S2024179/literature.pdf','文献综述已提交','revision_needed',NULL,'T2024019','2024-05-18 18:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(85,'S2024180',3,'/files/S2024180/proposal.pdf','开题报告已提交','pending',NULL,'T2024020','2024-05-19 19:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(86,'S2024181',1,'/files/S2024181/proposal.pdf','开题报告进行中','submitted',NULL,'T2024021','2024-05-20 10:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(87,'S2024182',1,'/files/S2024182/proposal.pdf','开题报告已提交','reviewing',NULL,'T2024022','2024-05-21 11:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(88,'S2024183',2,'/files/S2024183/literature.pdf','文献综述进行中','approved',NULL,'T2024023','2024-05-22 12:00:00','2024-05-29 14:00:00',91.00,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(89,'S2024184',2,'/files/S2024184/literature.pdf','文献综述已提交','revision_needed',NULL,'T2024024','2024-05-23 13:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(90,'S2024185',3,'/files/S2024185/proposal.pdf','开题报告已提交','pending',NULL,'T2024025','2024-05-24 14:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(91,'S2024186',3,'/files/S2024186/proposal.pdf','开题报告进行中','submitted',NULL,'T2024026','2024-05-25 15:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(92,'S2024187',1,'/files/S2024187/proposal.pdf','开题报告已提交','reviewing',NULL,'T2024027','2024-05-26 16:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(93,'S2024188',2,'/files/S2024188/literature.pdf','文献综述进行中','approved',NULL,'T2024028','2024-05-27 17:00:00','2024-06-03 18:00:00',94.00,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(94,'S2024189',2,'/files/S2024189/literature.pdf','文献综述已提交','revision_needed',NULL,'T2024029','2024-05-28 18:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(95,'S2024190',3,'/files/S2024190/proposal.pdf','开题报告已提交','pending',NULL,'T2024030','2024-05-29 19:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(96,'S2024191',1,'/files/S2024191/proposal.pdf','开题报告进行中','submitted',NULL,'T2024001','2024-05-30 10:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(97,'S2024192',1,'/files/S2024192/proposal.pdf','开题报告已提交','reviewing',NULL,'T2024002','2024-06-01 11:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(98,'S2024193',2,'/files/S2024193/literature.pdf','文献综述进行中','approved',NULL,'T2024003','2024-06-02 12:00:00','2024-06-09 14:00:00',88.00,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(99,'S2024194',2,'/files/S2024194/literature.pdf','文献综述已提交','revision_needed',NULL,'T2024004','2024-06-03 13:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(100,'S2024195',3,'/files/S2024195/proposal.pdf','开题报告已提交','pending',NULL,'T2024005','2024-06-04 14:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(101,'S2024196',3,'/files/S2024196/proposal.pdf','开题报告进行中','submitted',NULL,'T2024006','2024-06-05 15:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(102,'S2024197',1,'/files/S2024197/proposal.pdf','开题报告已提交','reviewing',NULL,'T2024007','2024-06-06 16:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(103,'S2024198',2,'/files/S2024198/literature.pdf','文献综述进行中','approved',NULL,'T2024008','2024-06-07 17:00:00','2024-06-14 18:00:00',95.00,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(104,'S2024199',2,'/files/S2024199/literature.pdf','文献综述已提交','revision_needed',NULL,'T2024009','2024-06-08 18:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19'),(105,'S2024200',3,'/files/S2024200/proposal.pdf','开题报告已提交','pending',NULL,'T2024010','2024-06-09 19:00:00',NULL,NULL,'2024-12-11 16:30:19','2024-12-11 16:30:19');
/*!40000 ALTER TABLE `progress_records` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_progress_insert` AFTER INSERT ON `progress_records` FOR EACH ROW BEGIN
    -- 当状态为 approved 时，更新对应的成绩
    IF NEW.status = 'approved' THEN
        CASE NEW.stage_id
            -- 任务书阶段
            WHEN 1 THEN
                INSERT INTO student_stage_scores
                (student_id, task_book_score)
                VALUES (NEW.student_id, NEW.score)
                ON DUPLICATE KEY UPDATE task_book_score = NEW.score;

            -- 文献综述阶段
            WHEN 2 THEN
                UPDATE student_stage_scores
                SET literature_score = NEW.score
                WHERE student_id = NEW.student_id;

            -- 开题报告阶段
            WHEN 3 THEN
                UPDATE student_stage_scores
                SET proposal_score = NEW.score
                WHERE student_id = NEW.student_id;

            -- 外文翻译阶段
            WHEN 4 THEN
                UPDATE student_stage_scores
                SET translation_score = NEW.score
                WHERE student_id = NEW.student_id;

            -- 中期检查阶段
            WHEN 5 THEN
                UPDATE student_stage_scores
                SET midterm_score = NEW.score
                WHERE student_id = NEW.student_id;

            -- 论文初稿阶段
            WHEN 6 THEN
                UPDATE student_stage_scores
                SET thesis_draft_score = NEW.score
                WHERE student_id = NEW.student_id;

            -- 论文评阅阶段
            WHEN 7 THEN
                UPDATE student_stage_scores
                SET thesis_review_score = NEW.score
                WHERE student_id = NEW.student_id;

            -- 答辩准备阶段
            WHEN 8 THEN
                UPDATE student_stage_scores
                SET defense_prep_score = NEW.score
                WHERE student_id = NEW.student_id;

            -- 论文答辩阶段
            WHEN 9 THEN
                UPDATE student_stage_scores
                SET defense_score = NEW.score
                WHERE student_id = NEW.student_id;
        END CASE;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_progress_update` AFTER UPDATE ON `progress_records` FOR EACH ROW BEGIN
    -- 当状态变更为 approved 时，更新对应的成绩
    IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
        CASE NEW.stage_id
            -- 任务书阶段
            WHEN 1 THEN
                INSERT INTO student_stage_scores
                (student_id, task_book_score)
                VALUES (NEW.student_id, NEW.score)
                ON DUPLICATE KEY UPDATE task_book_score = NEW.score;

            -- 文献综述阶段
            WHEN 2 THEN
                UPDATE student_stage_scores
                SET literature_score = NEW.score
                WHERE student_id = NEW.student_id;

            -- 开题报告阶段
            WHEN 3 THEN
                UPDATE student_stage_scores
                SET proposal_score = NEW.score
                WHERE student_id = NEW.student_id;

            -- 外文翻译阶段
            WHEN 4 THEN
                UPDATE student_stage_scores
                SET translation_score = NEW.score
                WHERE student_id = NEW.student_id;

            -- 中期检查阶段
            WHEN 5 THEN
                UPDATE student_stage_scores
                SET midterm_score = NEW.score
                WHERE student_id = NEW.student_id;

            -- 论文初稿阶段
            WHEN 6 THEN
                UPDATE student_stage_scores
                SET thesis_draft_score = NEW.score
                WHERE student_id = NEW.student_id;

            -- 论文评阅阶段
            WHEN 7 THEN
                UPDATE student_stage_scores
                SET thesis_review_score = NEW.score
                WHERE student_id = NEW.student_id;

            -- 答辩准备阶段
            WHEN 8 THEN
                UPDATE student_stage_scores
                SET defense_prep_score = NEW.score
                WHERE student_id = NEW.student_id;

            -- 论文答辩阶段
            WHEN 9 THEN
                UPDATE student_stage_scores
                SET defense_score = NEW.score
                WHERE student_id = NEW.student_id;
        END CASE;

        -- 更新总加权分数
        UPDATE student_stage_scores
        SET total_weighted_score = (
            IFNULL(task_book_score * 0.1, 0) +
            IFNULL(literature_score * 0.1, 0) +
            IFNULL(proposal_score * 0.1, 0) +
            IFNULL(translation_score * 0.1, 0) +
            IFNULL(midterm_score * 0.1, 0) +
            IFNULL(thesis_draft_score * 0.1, 0) +
            IFNULL(thesis_review_score * 0.1, 0) +
            IFNULL(defense_prep_score * 0.1, 0) +
            IFNULL(defense_score * 0.2, 0)
        )
        WHERE student_id = NEW.student_id;
    END IF;

    -- 当状态从 approved 变更为其他状态时，清除对应的成绩
    IF OLD.status = 'approved' AND NEW.status != 'approved' THEN
        CASE NEW.stage_id
            WHEN 1 THEN
                UPDATE student_stage_scores
                SET task_book_score = NULL
                WHERE student_id = NEW.student_id;
            WHEN 2 THEN
                UPDATE student_stage_scores
                SET literature_score = NULL
                WHERE student_id = NEW.student_id;
            WHEN 3 THEN
                UPDATE student_stage_scores
                SET proposal_score = NULL
                WHERE student_id = NEW.student_id;
            WHEN 4 THEN
                UPDATE student_stage_scores
                SET translation_score = NULL
                WHERE student_id = NEW.student_id;
            WHEN 5 THEN
                UPDATE student_stage_scores
                SET midterm_score = NULL
                WHERE student_id = NEW.student_id;
            WHEN 6 THEN
                UPDATE student_stage_scores
                SET thesis_draft_score = NULL
                WHERE student_id = NEW.student_id;
            WHEN 7 THEN
                UPDATE student_stage_scores
                SET thesis_review_score = NULL
                WHERE student_id = NEW.student_id;
            WHEN 8 THEN
                UPDATE student_stage_scores
                SET defense_prep_score = NULL
                WHERE student_id = NEW.student_id;
            WHEN 9 THEN
                UPDATE student_stage_scores
                SET defense_score = NULL
                WHERE student_id = NEW.student_id;
        END CASE;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `progress_stages`
--

DROP TABLE IF EXISTS `progress_stages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `progress_stages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT '阶段名称',
  `type` enum('task_book','literature','proposal','translation','midterm','thesis_draft','thesis_review','defense_prep','defense') NOT NULL COMMENT '阶段类型',
  `sequence` int NOT NULL COMMENT '阶段顺序',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime NOT NULL COMMENT '截止时间',
  `weight` int NOT NULL COMMENT '评分权重(百分比)',
  `description` text COMMENT '阶段说明',
  `status` enum('not_started','in_progress','completed','cancelled') DEFAULT 'not_started' COMMENT '阶段状态',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `type` (`type`),
  UNIQUE KEY `uk_sequence` (`sequence`),
  KEY `idx_stage_dates` (`start_time`,`end_time`),
  CONSTRAINT `progress_stages_chk_1` CHECK ((`weight` between 0 and 100)),
  CONSTRAINT `progress_stages_chk_2` CHECK ((`start_time` < `end_time`))
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `progress_stages`
--

LOCK TABLES `progress_stages` WRITE;
/*!40000 ALTER TABLE `progress_stages` DISABLE KEYS */;
INSERT INTO `progress_stages` VALUES (1,'任务书阶段','task_book',1,'2024-02-29 08:00:00','2024-03-10 07:59:59',5,'确定研究方向和任务','completed','2024-12-11 13:13:58','2024-12-12 15:09:23'),(2,'文献综述阶段','literature',2,'2024-03-11 00:00:00','2024-03-20 23:59:59',10,'完成文献阅读和综述','completed','2024-12-11 13:13:58','2024-12-11 13:30:32'),(3,'开题报告阶段','proposal',3,'2024-03-20 08:00:00','2024-03-31 07:59:59',10,'提交开题报告并通过审核','in_progress','2024-12-11 13:13:58','2024-12-12 10:49:53'),(4,'外文翻译阶段','translation',4,'2024-04-01 08:00:00','2024-04-14 08:00:00',10,'完成外文文献翻译','not_started','2024-12-11 13:13:58','2024-12-12 10:49:39'),(5,'中期检查阶段','midterm',5,'2024-04-14 16:00:00','2024-04-29 15:59:59',15,'提交中期检查报告','not_started','2024-12-11 13:13:58','2024-12-12 10:49:36'),(6,'论文初稿阶段','thesis_draft',6,'2024-04-29 16:00:00','2024-05-14 15:59:59',15,'完成论文初稿','not_started','2024-12-11 13:13:58','2024-12-11 15:15:22'),(7,'论文评审阶段','thesis_review',7,'2024-05-14 00:00:00','2024-05-29 23:59:59',20,'论文评审和修改','not_started','2024-12-11 13:13:58','2024-12-11 15:14:33'),(8,'答辩准备阶段','defense_prep',8,'2024-05-31 08:00:00','2024-06-15 07:59:59',15,'准备答辩材料','cancelled','2024-12-11 13:13:58','2024-12-11 14:14:50'),(9,'论文答辩阶段','defense',9,'2024-06-15 16:00:00','2024-06-30 15:59:59',15,'参加论文答辩','not_started','2024-12-11 13:13:58','2024-12-11 14:25:00');
/*!40000 ALTER TABLE `progress_stages` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `before_progress_stage_update` BEFORE UPDATE ON `progress_stages` FOR EACH ROW BEGIN
    DECLARE current_in_progress INT;
    DECLARE current_in_progress_seq INT;

    -- 如果要将状态改为 in_progress
    IF NEW.status = 'in_progress' AND OLD.status != 'in_progress' THEN
        -- 检查是否已有其他正在进行的阶段
        SELECT COUNT(*), MAX(sequence)
        INTO current_in_progress, current_in_progress_seq
        FROM progress_stages
        WHERE status = 'in_progress' AND id != NEW.id;

        IF current_in_progress > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '已有正在进行的阶段，不能同时开始新阶段';
        END IF;

        -- 检查所有在当前阶段之前的阶段状态
        IF EXISTS (
            SELECT 1
            FROM progress_stages
            WHERE sequence < NEW.sequence
            AND status NOT IN ('completed', 'cancelled')
            AND id != NEW.id
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '在当前阶段之前存在未完成或未取消的阶段';
        END IF;
    END IF;

    -- 如果已经有一个进行中的阶段，检查其他阶段状态的变更是否合法
    IF EXISTS (
        SELECT 1
        FROM progress_stages
        WHERE status = 'in_progress'
        AND id != NEW.id
    ) THEN
        -- 获取当前进行中阶段的序号
        SELECT sequence INTO current_in_progress_seq
        FROM progress_stages
        WHERE status = 'in_progress'
        AND id != NEW.id;

        -- 如果修改的是进行中阶段之前的阶段，只允许改为completed或cancelled
        IF NEW.sequence < current_in_progress_seq
        AND NEW.status NOT IN ('completed', 'cancelled') THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '进行中阶段之前的阶段只能是已完成或已取消状态';
        END IF;

        -- 如果修改的是进行中阶段之后的阶段，不允许改为completed
        IF NEW.sequence > current_in_progress_seq
        AND NEW.status = 'completed' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '不能将进行中阶段之后的阶段标记为已完成';
        END IF;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `student_stage_scores`
--

DROP TABLE IF EXISTS `student_stage_scores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_stage_scores` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(50) NOT NULL,
  `task_book_score` decimal(5,2) DEFAULT NULL COMMENT '任务书阶段分数',
  `literature_score` decimal(5,2) DEFAULT NULL COMMENT '文献综述阶段分数',
  `proposal_score` decimal(5,2) DEFAULT NULL COMMENT '开题报告阶段分数',
  `translation_score` decimal(5,2) DEFAULT NULL COMMENT '外文翻译阶段分数',
  `midterm_score` decimal(5,2) DEFAULT NULL COMMENT '中期检查阶段分数',
  `thesis_draft_score` decimal(5,2) DEFAULT NULL COMMENT '论文初稿阶段分数',
  `thesis_review_score` decimal(5,2) DEFAULT NULL COMMENT '论文评审阶段分数',
  `defense_prep_score` decimal(5,2) DEFAULT NULL COMMENT '答辩准备阶段分数',
  `defense_score` decimal(5,2) DEFAULT NULL COMMENT '论文答辩阶段分数',
  `total_weighted_score` decimal(5,2) DEFAULT NULL COMMENT '总加权分数',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_total_score` (`total_weighted_score` DESC),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_updated_at` (`updated_at`),
  KEY `idx_student_score` (`student_id`,`total_weighted_score`),
  KEY `idx_student_all_scores` (`student_id`,`total_weighted_score`,`task_book_score`,`literature_score`,`proposal_score`,`translation_score`,`midterm_score`),
  CONSTRAINT `student_stage_scores_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`)
) ENGINE=InnoDB AUTO_INCREMENT=201 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_stage_scores`
--

LOCK TABLES `student_stage_scores` WRITE;
/*!40000 ALTER TABLE `student_stage_scores` DISABLE KEYS */;
INSERT INTO `student_stage_scores` VALUES (101,'S2024103',85.00,85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(102,'S2024108',88.00,90.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(103,'S2024113',86.00,87.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(104,'S2024118',89.00,92.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(105,'S2024123',87.00,89.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(106,'S2024128',90.00,91.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(107,'S2024133',85.00,86.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(108,'S2024138',91.00,93.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(109,'S2024143',86.00,88.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(110,'S2024148',92.00,94.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(111,'S2024153',88.00,90.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(112,'S2024158',93.00,95.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(113,'S2024163',87.00,89.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(114,'S2024168',90.00,92.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(115,'S2024173',88.00,90.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(116,'S2024178',91.00,93.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(117,'S2024183',89.00,91.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(118,'S2024188',92.00,94.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(119,'S2024193',86.00,88.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(120,'S2024198',93.00,95.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(121,'S2024101',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(122,'S2024102',86.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(123,'S2024104',84.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(124,'S2024105',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(125,'S2024106',86.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(126,'S2024107',87.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(127,'S2024109',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(128,'S2024110',84.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(129,'S2024111',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(130,'S2024112',86.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(131,'S2024114',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(132,'S2024115',84.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(133,'S2024116',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(134,'S2024117',86.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(135,'S2024119',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(136,'S2024120',84.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(137,'S2024121',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(138,'S2024122',86.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(139,'S2024124',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(140,'S2024125',84.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(141,'S2024126',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(142,'S2024127',86.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(143,'S2024129',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(144,'S2024130',84.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(145,'S2024131',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(146,'S2024132',86.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(147,'S2024134',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(148,'S2024135',84.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(149,'S2024136',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(150,'S2024137',86.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(151,'S2024139',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(152,'S2024140',84.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(153,'S2024141',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(154,'S2024142',86.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(155,'S2024144',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(156,'S2024145',84.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(157,'S2024146',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(158,'S2024147',86.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(159,'S2024149',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(160,'S2024150',84.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(161,'S2024151',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(162,'S2024152',86.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(163,'S2024154',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(164,'S2024155',84.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(165,'S2024156',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(166,'S2024157',86.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(167,'S2024159',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(168,'S2024160',84.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(169,'S2024161',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(170,'S2024162',86.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(171,'S2024164',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(172,'S2024165',84.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(173,'S2024166',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(174,'S2024167',86.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(175,'S2024169',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(176,'S2024170',84.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(177,'S2024171',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(178,'S2024172',86.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(179,'S2024174',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(180,'S2024175',84.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(181,'S2024176',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(182,'S2024177',86.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(183,'S2024179',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(184,'S2024180',84.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(185,'S2024181',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(186,'S2024182',86.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(187,'S2024184',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(188,'S2024185',84.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(189,'S2024186',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(190,'S2024187',86.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(191,'S2024189',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(192,'S2024190',84.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(193,'S2024191',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(194,'S2024192',86.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(195,'S2024194',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(196,'S2024195',84.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(197,'S2024196',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(198,'S2024197',86.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(199,'S2024199',85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22'),(200,'S2024200',84.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-11 17:18:22','2024-12-11 17:18:22');
/*!40000 ALTER TABLE `student_stage_scores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `students`
--

DROP TABLE IF EXISTS `students`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `students` (
  `student_id` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `gender` enum('男','女') DEFAULT NULL,
  `major` varchar(100) DEFAULT NULL,
  `class_name` varchar(50) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `students`
--

LOCK TABLES `students` WRITE;
/*!40000 ALTER TABLE `students` DISABLE KEYS */;
INSERT INTO `students` VALUES ('S2024001','小明','男','计算机科学与技术','计科2001','13900139001','xiaoming@example.com','班长'),('S2024002','小红','女','软件工程','软工2001','13900139002','xiaohong@example.com',NULL),('S2024003','小张','男','人工智能','智能2001','13900139003','xiaozhang@example.com',NULL),('S2024004','小李','女','计算机科学与技术','计科2001','13900139004','xiaoli@example.com','学习委员'),('S2024005','小王','男','软件工程','软工2001','13900139005','xiaowang@example.com',NULL),('S2024101','李明','男','计算机科学与技术','计算机1班','13900000001','liming1@test.com','李明的个人简介'),('S2024102','王芳','女','软件工程','软件1班','13900000002','wangfang2@test.com','王芳的个人简介'),('S2024103','张伟','男','信息安全','信息1班','13900000003','zhangwei3@test.com','张伟的个人简介'),('S2024104','刘洋','女','人工智能','人工1班','13900000004','liuyang4@test.com','刘洋的个人简介'),('S2024105','陈强','男','数据科学','数据1班','13900000005','chenqiang5@test.com','陈强的个人简介'),('S2024106','赵敏','女','计算机科学与技术','计算机2班','13900000006','zhaomin6@test.com','赵敏的个人简介'),('S2024107','孙丽','女','软件工程','软件2班','13900000007','sunli7@test.com','孙丽的个人简介'),('S2024108','周杰','男','信息安全','信息2班','13900000008','zhoujie8@test.com','周杰的个人简介'),('S2024109','吴婷','女','人工智能','人工2班','13900000009','wuting9@test.com','吴婷的个人简介'),('S2024110','郑浩','男','数据科学','数据2班','13900000010','zhenghao10@test.com','郑浩的个人简介'),('S2024111','王强','男','计算机科学与技术','计算机3班','13900000011','wangqiang11@test.com','王强的个人简介'),('S2024112','李娜','女','软件工程','软件3班','13900000012','lina12@test.com','李娜的个人简介'),('S2024113','张敏','女','信息安全','信息3班','13900000013','zhangmin13@test.com','张敏的个人简介'),('S2024114','刘伟','男','人工智能','人工3班','13900000014','liuwei14@test.com','刘伟的个人简介'),('S2024115','陈丽','女','数据科学','数据3班','13900000015','chenli15@test.com','陈丽的个人简介'),('S2024116','赵强','男','计算机科学与技术','计算机4班','13900000016','zhaoqiang16@test.com','赵强的个人简介'),('S2024117','孙娜','女','软件工程','软件4班','13900000017','sunna17@test.com','孙娜的个人简介'),('S2024118','周敏','女','信息安全','信息4班','13900000018','zhoumin18@test.com','周敏的个人简介'),('S2024119','吴伟','男','人工智能','人工4班','13900000019','wuwei19@test.com','吴伟的个人简介'),('S2024120','郑丽','女','数据科学','数据4班','13900000020','zhengli20@test.com','郑丽的个人简介'),('S2024121','王洋','男','计算机科学与技术','计算机5班','13900000021','wangyang21@test.com','王洋的个人简介'),('S2024122','李强','男','软件工程','软件5班','13900000022','liqiang22@test.com','李强的个人简介'),('S2024123','张娜','女','信息安全','信息5班','13900000023','zhangna23@test.com','张娜的个人简介'),('S2024124','刘敏','女','人工智能','人工5班','13900000024','liumin24@test.com','刘敏的个人简介'),('S2024125','陈伟','男','数据科学','数据5班','13900000025','chenwei25@test.com','陈伟的个人简介'),('S2024126','赵丽','女','计算机科学与技术','计算机6班','13900000026','zhaoli26@test.com','赵丽的个人简介'),('S2024127','孙强','男','软件工程','软件6班','13900000027','sunqiang27@test.com','孙强的个人简介'),('S2024128','周娜','女','信息安全','信息6班','13900000028','zhouna28@test.com','周娜的个人简介'),('S2024129','吴敏','女','人工智能','人工6班','13900000029','wumin29@test.com','吴敏的个人简介'),('S2024130','郑伟','男','数据科学','数据6班','13900000030','zhengwei30@test.com','郑伟的个人简介'),('S2024131','王丽','女','计算机科学与技术','计算机7班','13900000031','wangli31@test.com','王丽的个人简介'),('S2024132','李洋','男','软件工程','软件7班','13900000032','liyang32@test.com','李洋的个人简介'),('S2024133','张强','男','信息安全','信息7班','13900000033','zhangqiang33@test.com','张强的个人简介'),('S2024134','刘娜','女','人工智能','人工7班','13900000034','liuna34@test.com','刘娜的个人简介'),('S2024135','陈敏','女','数据科学','数据7班','13900000035','chenmin35@test.com','陈敏的个人简介'),('S2024136','赵伟','男','计算机科学与技术','计算机8班','13900000036','zhaowei36@test.com','赵伟的个人简介'),('S2024137','孙丽','女','软件工程','软件8班','13900000037','sunli37@test.com','孙丽的个人简介'),('S2024138','周强','男','信息安全','信息8班','13900000038','zhouqiang38@test.com','周强的个人简介'),('S2024139','吴娜','女','人工智能','人工8班','13900000039','wuna39@test.com','吴娜的个人简介'),('S2024140','郑敏','女','数据科学','数据8班','13900000040','zhengmin40@test.com','郑敏的个人简介'),('S2024141','王伟','男','计算机科学与技术','计算机9班','13900000041','wangwei41@test.com','王伟的个人简介'),('S2024142','李丽','女','软件工程','软件9班','13900000042','lili42@test.com','李丽的个人简介'),('S2024143','张洋','男','信息安全','信息9班','13900000043','zhangyang43@test.com','张洋的个人简介'),('S2024144','刘强','男','人工智能','人工9班','13900000044','liuqang44@test.com','刘强的个人简介'),('S2024145','陈娜','女','数据科学','数据9班','13900000045','chenna45@test.com','陈娜的个人简介'),('S2024146','赵敏','女','计算机科学与技术','计算机10班','13900000046','zhaomin46@test.com','赵敏的个人简介'),('S2024147','孙伟','男','软件工程','软件10班','13900000047','sunwei47@test.com','孙伟的个人简介'),('S2024148','周丽','女','信息安全','信息10班','13900000048','zhouli48@test.com','周丽的个人简介'),('S2024149','吴强','男','人工智能','人工10班','13900000049','wuqiang49@test.com','吴强的个人简介'),('S2024150','郑娜','女','数据科学','数据10班','13900000050','zhengna50@test.com','郑娜的个人简介'),('S2024151','王敏','女','计算机科学与技术','计算机11班','13900000051','wangmin51@test.com','王敏的个人简介'),('S2024152','李伟','男','软件工程','软件11班','13900000052','liwei52@test.com','李伟的个人简介'),('S2024153','张丽','女','信息安全','信息11班','13900000053','zhangli53@test.com','张丽的个人简介'),('S2024154','刘洋','男','人工智能','人工11班','13900000054','liuyang54@test.com','刘洋的个人简介'),('S2024155','陈强','男','数据科学','数据11班','13900000055','chenqiang55@test.com','陈强的个人简介'),('S2024156','赵丽','女','计算机科学与技术','计算机12班','13900000056','zhaoli56@test.com','赵丽的个人简介'),('S2024157','孙娜','女','软件工程','软件12班','13900000057','sunna57@test.com','孙娜的个人简介'),('S2024158','周敏','女','信息安全','信息12班','13900000058','zhoumin58@test.com','周敏的个人简介'),('S2024159','吴伟','男','人工智能','人工12班','13900000059','wuwei59@test.com','吴伟的个人简介'),('S2024160','郑丽','女','数据科学','数据12班','13900000060','zhengli60@test.com','郑丽的个人简介'),('S2024161','王洋','男','计算机科学与技术','计算机13班','13900000061','wangyang61@test.com','王洋的个人简介'),('S2024162','李强','男','软件工程','软件13班','13900000062','liqiang62@test.com','李强的个人简介'),('S2024163','张娜','女','信息安全','信息13班','13900000063','zhangna63@test.com','张娜的个人简介'),('S2024164','刘敏','女','人工智能','人工13班','13900000064','liumin64@test.com','刘敏的个人简介'),('S2024165','陈伟','男','数据科学','数据13班','13900000065','chenwei65@test.com','陈伟的个人简介'),('S2024166','赵丽','女','计算机科学与技术','计算机14班','13900000066','zhaoli66@test.com','赵丽的个人简介'),('S2024167','孙强','男','软件工程','软件14班','13900000067','sunqiang67@test.com','孙强的个人简介'),('S2024168','周娜','女','信息安全','信息14班','13900000068','zhouna68@test.com','周娜的个人简介'),('S2024169','吴敏','女','人工智能','人工14班','13900000069','wumin69@test.com','吴敏的个人简介'),('S2024170','郑伟','男','数据科学','数据14班','13900000070','zhengwei70@test.com','郑伟的个人简介'),('S2024171','王丽','女','计算机科学与技术','计算机15班','13900000071','wangli71@test.com','王丽的个人简介'),('S2024172','李洋','男','软件工程','软件15班','13900000072','liyang72@test.com','李洋的个人简介'),('S2024173','张强','男','信息安全','信息15班','13900000073','zhangqiang73@test.com','张强的个人简介'),('S2024174','刘娜','女','人工智能','人工15班','13900000074','liuna74@test.com','刘娜的个人简介'),('S2024175','陈敏','女','数据科学','数据15班','13900000075','chenmin75@test.com','陈敏的个人简介'),('S2024176','赵伟','男','计算机科学与技术','计算机16班','13900000076','zhaowei76@test.com','赵伟的个人简介'),('S2024177','孙丽','女','软件工程','软件16班','13900000077','sunli77@test.com','孙丽的个人简介'),('S2024178','周强','男','信息安全','信息16班','13900000078','zhouqiang78@test.com','周强的个人简介'),('S2024179','吴娜','女','人工智能','人工16班','13900000079','wuna79@test.com','吴娜的个人简介'),('S2024180','郑敏','女','数据科学','数据16班','13900000080','zhengmin80@test.com','郑敏的个人简介'),('S2024181','王伟','男','计算机科学与技术','计算机17班','13900000081','wangwei81@test.com','王伟的个人简介'),('S2024182','李丽','女','软件工程','软件17班','13900000082','lili82@test.com','李丽的个人简介'),('S2024183','张洋','男','信息安全','信息17班','13900000083','zhangyang83@test.com','张洋的个人简介'),('S2024184','刘强','男','人工智能','人工17班','13900000084','liuqang84@test.com','刘强的个人简介'),('S2024185','陈娜','女','数据科学','数据17班','13900000085','chenna85@test.com','陈娜的个人简介'),('S2024186','赵敏','女','计算机科学与技术','计算机18班','13900000086','zhaomin86@test.com','赵敏的个人简介'),('S2024187','孙伟','男','软件工程','软件18班','13900000087','sunwei87@test.com','孙伟的个人简介'),('S2024188','周丽','女','信息安全','信息18班','13900000088','zhouli88@test.com','周丽的个人简介'),('S2024189','吴强','男','人工智能','人工18班','13900000089','wuqiang89@test.com','吴强的个人简介'),('S2024190','郑娜','女','数据科学','数据18班','13900000090','zhengna90@test.com','郑娜的个人简介'),('S2024191','王敏','女','计算机科学与技术','计算机19班','13900000091','wangmin91@test.com','王敏的个人简介'),('S2024192','李伟','男','软件工程','软件19班','13900000092','liwei92@test.com','李伟的个人简介'),('S2024193','张丽','女','信息安全','信息19班','13900000093','zhangli93@test.com','张丽的个人简介'),('S2024194','刘洋','男','人工智能','人工19班','13900000094','liuyang94@test.com','刘洋的个人简介'),('S2024195','陈强','男','数据科学','数据19班','13900000095','chenqiang95@test.com','陈强的个人简介'),('S2024196','赵丽','女','计算机科学与技术','计算机20班','13900000096','zhaoli96@test.com','赵丽的个人简介'),('S2024197','孙娜','女','软件工程','软件20班','13900000097','sunna97@test.com','孙娜的个人简介'),('S2024198','周敏','女','信息安全','信息20班','13900000098','zhoumin98@test.com','周敏的个人简介'),('S2024199','吴伟','男','人工智能','人工20班','13900000099','wuwei99@test.com','吴伟的个人简介'),('S2024200','郑丽','女','数据科学','数据20班','13900000100','zhengli100@test.com','郑丽的个人简介');
/*!40000 ALTER TABLE `students` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supervisors`
--

DROP TABLE IF EXISTS `supervisors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `supervisors` (
  `supervisor_id` varchar(20) NOT NULL,
  `name` varchar(50) NOT NULL DEFAULT '未命名',
  `title` varchar(50) DEFAULT NULL,
  `department` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `research_area` text,
  `max_students` int DEFAULT '8',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`supervisor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supervisors`
--

LOCK TABLES `supervisors` WRITE;
/*!40000 ALTER TABLE `supervisors` DISABLE KEYS */;
INSERT INTO `supervisors` VALUES ('T2024001','刘勇','教授','计算机科学与技术学院','13800138001','','人工智能,机器学习,深度学习',8,'2024-12-11 14:37:08','2024-12-13 00:48:25'),('T2024002','王娜','副教授','计算机科学与技术学院','13800138002','teacher2@test.com','软件工程,软件测试,软件架构',8,'2024-12-11 14:37:08','2024-12-13 00:53:38'),('T2024003','刘秀英','教授','软件工程学院','13800138003','teacher3@test.com','数据库系统,分布式系统,云计算',8,'2024-12-11 14:37:08','2024-12-13 00:53:38'),('T2024004','陈敏','副教授','软件工程学院','13800138004','teacher4@test.com','计算机网络,网络安全,物联网',8,'2024-12-11 14:37:08','2024-12-13 00:53:38'),('T2024005','杨静','讲师','人工智能学院','13800138005','teacher5@test.com','图像处理,计算机视觉,模式识别',8,'2024-12-11 14:37:08','2024-12-13 00:53:38'),('T2024006','赵丽','教授','人工智能学院','13800138006','teacher6@test.com','自然语言处理,知识图谱,语音识别',8,'2024-12-11 14:37:08','2024-12-13 00:50:17'),('T2024007','黄强','副教授','计算机科学与技术学院','13800138007','teacher7@test.com','大数据分析,数据挖掘,机器学习',8,'2024-12-11 14:37:08','2024-12-13 00:50:17'),('T2024008','周磊','教授','计算机科学与技术学院','13800138008','teacher8@test.com','并行计算,高性能计算,分布式系统',8,'2024-12-11 14:37:08','2024-12-13 00:50:17'),('T2024009','吴洋','副教授','软件工程学院','13800138009','teacher9@test.com','软件工程,需求工程,软件质量保证',8,'2024-12-11 14:37:08','2024-12-13 00:50:18'),('T2024010','张伟','教授','软件工程学院','13800138010','teacher10@test.com','人工智能,深度学习,强化学习',8,'2024-12-11 14:37:08','2024-12-13 00:50:18'),('T2024011','李芳','副教授','人工智能学院','13800138011','teacher11@test.com','计算机图形学,虚拟现实,增强现实',8,'2024-12-11 14:37:08','2024-12-13 00:50:18'),('T2024012','王娜','讲师','人工智能学院','13800138012','teacher12@test.com','嵌入式系统,物联网,实时系统',8,'2024-12-11 14:37:08','2024-12-13 00:50:18'),('T2024013','刘秀英','教授','计算机科学与技术学院','13800138013','teacher13@test.com','信息安全,密码学,区块链技术',8,'2024-12-11 14:37:08','2024-12-13 00:50:18'),('T2024014','陈敏','副教授','计算机科学与技术学院','13800138014','teacher14@test.com','软件工程,软件复用,软件维护',8,'2024-12-11 14:37:08','2024-12-13 00:50:18'),('T2024015','杨静','教授','软件工程学院','13800138015','teacher15@test.com','数据库系统,数据仓库,大数据处理',8,'2024-12-11 14:37:08','2024-12-13 00:50:18'),('T2024016','赵丽','副教授','软件工程学院','13800138016','teacher16@test.com','计算机网络,网络协议,网络优化',8,'2024-12-11 14:37:08','2024-12-13 00:50:18'),('T2024017','黄强','教授','人工智能学院','13800138017','teacher17@test.com','人工智能,机器视觉,图像识别',8,'2024-12-11 14:37:08','2024-12-13 00:50:18'),('T2024018','周磊','副教授','人工智能学院','13800138018','teacher18@test.com','自然语言处理,机器翻译,文本挖掘',8,'2024-12-11 14:37:08','2024-12-13 00:50:18'),('T2024019','吴洋','讲师','计算机科学与技术学院','13800138019','teacher19@test.com','软件测试,软件验证,形式化方法',8,'2024-12-11 14:37:08','2024-12-13 00:50:18'),('T2024020','张伟','教授','计算机科学与技术学院','13800138020','teacher20@test.com','云计算,边缘计算,雾计算',8,'2024-12-11 14:37:08','2024-12-13 00:50:18'),('T2024021','李芳','副教授','软件工程学院','13800138021','teacher21@test.com','人机交互,用户界面设计,交互设计',8,'2024-12-11 14:37:08','2024-12-13 00:52:02'),('T2024022','王娜','教授','软件工程学院','13800138022','teacher22@test.com','移动计算,无线网络,移动应用开发',8,'2024-12-11 14:37:08','2024-12-13 00:52:02'),('T2024023','刘秀英','副教授','人工智能学院','13800138023','teacher23@test.com','数据挖掘,知识发现,商业智能',8,'2024-12-11 14:37:08','2024-12-13 00:52:02'),('T2024024','陈敏','讲师','人工智能学院','13800138024','teacher24@test.com','并行算法,分布式计算,网格计算',8,'2024-12-11 14:37:08','2024-12-13 00:52:02'),('T2024025','杨静','教授','计算机科学与技术学院','13800138025','teacher25@test.com','计算机视觉,图像处理,视频分析',8,'2024-12-11 14:37:08','2024-12-13 00:52:02'),('T2024026','赵丽','副教授','计算机科学与技术学院','13800138026','teacher26@test.com','软件架构,设计模式,系统建模',8,'2024-12-11 14:37:08','2024-12-13 00:52:02'),('T2024027','黄强','教授','软件工程学院','13800138027','teacher27@test.com','人工智能,专家系统,知识工程',8,'2024-12-11 14:37:08','2024-12-13 00:52:02'),('T2024028','周磊','副教授','软件工程学院','13800138028','teacher28@test.com','信息检索,搜索引擎,推荐系统',8,'2024-12-11 14:37:08','2024-12-13 00:52:02'),('T2024029','吴洋','讲师','人工智能学院','13800138029','teacher29@test.com','数据库优化,查询处理,事务处理',8,'2024-12-11 14:37:08','2024-12-13 00:52:02'),('T2024030','张伟','教授','人工智能学院','13800138030','teacher30@test.com','机器学习,深度学习,神经网络',8,'2024-12-11 14:37:08','2024-12-13 00:52:02');
/*!40000 ALTER TABLE `supervisors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_logs`
--

DROP TABLE IF EXISTS `system_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_logs` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(20) DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `ip_address` varchar(50) DEFAULT NULL,
  `details` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `idx_user_action_time` (`user_id`,`action`,`created_at`),
  CONSTRAINT `system_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=116 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_logs`
--

LOCK TABLES `system_logs` WRITE;
/*!40000 ALTER TABLE `system_logs` DISABLE KEYS */;
INSERT INTO `system_logs` VALUES (1,'SA2024001','login','192.168.1.100','用户登录','2024-12-10 03:49:23'),(2,'T2024001','login','192.168.1.101','用户登录','2024-12-10 03:49:23'),(3,'S2024001','login','192.168.1.102','用户登录','2024-12-10 03:49:23'),(4,'SA2024001','update_user','192.168.1.100','更新用户信息','2024-12-10 03:49:23'),(5,'SA2024001','system_config','192.168.1.100','修改系统配置','2024-12-10 03:49:23'),(19,'T2024001','login','192.168.1.90','用户登录','2024-12-10 03:55:12'),(20,'S2024001','login','192.168.1.197','用户登录','2024-12-10 03:55:12'),(21,'SA2024001','login','192.168.1.207','用户登录','2024-12-10 03:55:12'),(22,'SA2024001','system_operation','192.168.1.190','系统操作','2024-12-10 03:55:15'),(23,'T2024001','user.login.success','::1','用户 张老师 登录成功','2024-12-12 07:03:25'),(24,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-12 07:03:31'),(25,'SA2024001','stage.update','::1','更新阶段：1，名称：任务书阶段，状态：completed，权重：10%','2024-12-12 07:09:18'),(26,'SA2024001','stage.update','::1','更新阶段：1，名称：任务书阶段，状态：completed，权重：5%','2024-12-12 07:09:23'),(27,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 07:20:02'),(28,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 07:20:37'),(29,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 07:22:27'),(30,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 07:23:30'),(31,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 07:23:56'),(32,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 07:24:07'),(33,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 07:24:19'),(34,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 07:26:22'),(35,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 07:27:18'),(36,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-12 07:28:59'),(37,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-12 07:34:18'),(38,'G9055083583','user.register','::1','用户注册：dfad，角色：guest','2024-12-12 07:37:35'),(39,'G9204049729','user.register','::1','用户注册：asda，角色：guest','2024-12-12 07:40:04'),(40,'G9319052297','user.register','::1','用户注册：ads，角色：guest','2024-12-12 07:41:59'),(41,'G9467326781','user.register','::1','用户注册：asdfgsh，角色：guest','2024-12-12 07:44:27'),(42,'G9876306369','user.register','::1','用户 123456 注册成功','2024-12-12 07:51:16'),(43,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-12 07:51:26'),(44,'SA2024001','user.profile.update','::1','{\"message\":\"用户 刘超管 更新了个人信息\",\"changes\":{\"name\":\"姓名: undefined -> 刘超刘\",\"gender\":\"性别: undefined -> male\",\"department\":\"部门: undefined -> \",\"major\":null,\"title\":\"职称: undefined -> \",\"email\":\"邮箱: undefined -> 2915399378@qq.com\",\"phone\":\"电话: undefined -> 15376959676\"}}','2024-12-12 08:00:54'),(45,'SA2024001','user.password.change','::1','{\"message\":\"用户 刘超管 修改了密码\",\"timestamp\":\"2024-12-12T08:02:57.030Z\"}','2024-12-12 08:02:57'),(46,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-12 08:03:02'),(47,'SA2024001','user.password.change','::1','{\"message\":\"用户 刘超管 修改了密码\",\"timestamp\":\"2024-12-12T08:03:13.681Z\"}','2024-12-12 08:03:13'),(48,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-12 08:03:18'),(49,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 08:03:54'),(50,'SA2024001','system.database.backup','::1','{\"message\":\"数据库备份完成\",\"filename\":\"backup-2024-12-12T08-24-28-130Z.sql\",\"timestamp\":\"2024-12-12T08:24:28.627Z\"}','2024-12-12 08:24:28'),(51,'SA2024001','system.database.backup','::1','{\"message\":\"数据库备份完成\",\"filename\":\"backup-2024-12-12T08-27-18-965Z.sql\",\"timestamp\":\"2024-12-12T08:27:19.157Z\"}','2024-12-12 08:27:19'),(52,'SA2024001','system.database.backup','::1','{\"message\":\"数据库备份完成\",\"filename\":\"backup-2024-12-12T09-08-15-411Z.sql\",\"timestamp\":\"2024-12-12T09:08:15.655Z\"}','2024-12-12 09:08:15'),(53,'SA2024001','system.database.backup','::1','{\"message\":\"数据库备份成功\",\"filename\":\"backup-2024-12-12T13-42-21.sql\",\"path\":\"backups\\\\backup-2024-12-12T13-42-21.sql\",\"timestamp\":\"2024-12-12T13:42:21.721Z\"}','2024-12-12 13:42:21'),(54,'SA2024001','system.database.restore','::1','{\"message\":\"数据库恢复完成\",\"filename\":\"backup-2024-12-12T13-42-21.sql\",\"newDbName\":\"test1\",\"backupPath\":\"D:\\\\VSCODE\\\\Graduation Design Management System\\\\backend\\\\backups\\\\backup-2024-12-12T13-42-21.sql\",\"originalDb\":\"graduation_management\",\"timestamp\":\"2024-12-12T13:49:11.399Z\"}','2024-12-12 13:49:11'),(55,'SA2024001','system.database.backup','::1','{\"message\":\"数据库备份成功\",\"filename\":\"backup-2024-12-12T14-01-55.sql\",\"path\":\"backups\\\\backup-2024-12-12T14-01-55.sql\",\"timestamp\":\"2024-12-12T14:01:55.518Z\"}','2024-12-12 14:01:55'),(56,'SA2024001','system.database.backup','::1','{\"message\":\"数据库备份成功\",\"filename\":\"backup-2024-12-12T14-22-15.sql\",\"path\":\"backups\\\\backup-2024-12-12T14-22-15.sql\",\"timestamp\":\"2024-12-12T14:22:16.217Z\"}','2024-12-12 14:22:16'),(57,'SA2024001','system.database.backup','::1','{\"message\":\"数据库备份成功\",\"filename\":\"backup-2024-12-12T14-33-54.sql\",\"path\":\"backups\\\\backup-2024-12-12T14-33-54.sql\",\"timestamp\":\"2024-12-12T14:33:54.855Z\"}','2024-12-12 14:33:54'),(58,'SA2024001','system.database.backup','::1','{\"message\":\"数据库备份成功\",\"filename\":\"backup-2024-12-12T14-36-04.sql\",\"path\":\"backups\\\\backup-2024-12-12T14-36-04.sql\",\"timestamp\":\"2024-12-12T14:36:05.104Z\"}','2024-12-12 14:36:05'),(59,'SA2024001','system.database.backup','::1','{\"message\":\"数据库备份成功\",\"filename\":\"backup-2024-12-12T14-36-05.sql\",\"path\":\"backups\\\\backup-2024-12-12T14-36-05.sql\",\"timestamp\":\"2024-12-12T14:36:05.819Z\"}','2024-12-12 14:36:05'),(60,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 15:21:40'),(61,'S2024001','user.login.success','::1','用户 李同学 登录成功','2024-12-12 15:26:00'),(62,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-12 15:27:21'),(63,'SA2024001','system.data.export.start','::1','{\"tables\":[\"progress\"],\"format\":\"sql\",\"timestamp\":\"2024-12-12T15:27:44.584Z\",\"status\":\"started\"}','2024-12-12 15:27:44'),(64,'SA2024001','system.data.export.success','::1','{\"tables\":[\"progress\"],\"format\":\"sql\",\"timestamp\":\"2024-12-12T15:27:44.794Z\",\"status\":\"completed\",\"fileSize\":4136,\"tablesCount\":1}','2024-12-12 15:27:44'),(65,'SA2024001','system.data.export.start','::1','{\"tables\":[\"progress_records\"],\"format\":\"csv\",\"timestamp\":\"2024-12-12T15:28:13.209Z\",\"status\":\"started\"}','2024-12-12 15:28:13'),(66,'SA2024001','system.data.export.success','::1','{\"tables\":[\"progress_records\"],\"format\":\"csv\",\"timestamp\":\"2024-12-12T15:28:13.227Z\",\"status\":\"completed\",\"fileSize\":27709,\"tablesCount\":1}','2024-12-12 15:28:13'),(67,'A2024001','user.login.success','::1','用户 王管理 登录成功','2024-12-12 15:28:31'),(68,'A2024001','stage.list','::1','查询阶段列表','2024-12-12 15:28:34'),(69,'A2024001','user.update','::1','{\"updatedBy\":\"A2024001\",\"updatedUser\":\"S2024001\",\"changes\":{\"name\":\"李同学\",\"role\":\"student\",\"email\":\"dsfva@qq.com\",\"department\":\"adf\",\"position\":\"\"}}','2024-12-12 15:40:34'),(70,'A2024001','user.update','::1','{\"updatedBy\":\"A2024001\",\"updatedUser\":\"G9319052297\",\"changes\":{\"name\":\"ads\",\"role\":\"guest\",\"email\":\"asgsh@qq.com\",\"department\":\"\",\"position\":\"\"}}','2024-12-12 15:40:57'),(71,'A2024001','user.create','::1','{\"createdBy\":\"A2024001\",\"newUser\":{\"userId\":\"U1734018715169729\",\"username\":\"sgd\",\"role\":\"guest\",\"department\":\"sddgd65\"}}','2024-12-12 15:51:55'),(72,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-12 15:52:14'),(73,'A2024001','user.login.success','::1','用户 王管理 登录成功','2024-12-12 15:52:58'),(74,'A2024001','stage.list','::1','查询阶段列表','2024-12-12 15:53:00'),(75,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-12 16:10:51'),(76,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 16:10:53'),(77,'A2024001','user.login.success','::1','用户 王管理 登录成功','2024-12-12 16:11:17'),(78,'A2024001','stage.list','::1','查询阶段列表','2024-12-12 16:11:19'),(79,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-12 16:11:35'),(80,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-12 16:11:50'),(81,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 16:11:52'),(82,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-12 16:24:56'),(83,'SA2024001','user.delete','::1','{\"action\":\"user.delete\",\"targetUser\":{\"userId\":\"S2024021\",\"username\":\"student21\",\"role\":\"student\"},\"operator\":\"刘超管\",\"timestamp\":\"2024-12-12T16:28:10.276Z\"}','2024-12-12 16:28:10'),(84,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 16:28:18'),(85,'SA2024001','user.update','::1','{\"action\":\"user.update\",\"targetUser\":\"S2024032\",\"operator\":\"刘超管\",\"changes\":{\"gender\":\"male -> female\"}}','2024-12-12 16:28:28'),(86,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 16:34:38'),(87,'A2024001','user.login.success','::1','用户 王管理 登录成功','2024-12-12 16:34:48'),(88,'A2024001','stage.list','::1','查询阶段列表','2024-12-12 16:34:51'),(89,'T2024001','user.login.success','::1','用户 张老师 登录成功','2024-12-12 16:35:05'),(90,'A2024001','user.login.success','::1','用户 王管理 登录成功','2024-12-12 16:35:23'),(91,'A2024001','stage.list','::1','查询阶段列表','2024-12-12 16:55:23'),(92,'A2024001','stage.list','::1','查询阶段列表','2024-12-13 06:05:30'),(93,'A2024001','user.login.success','::1','用户 王管理 登录成功','2024-12-13 06:10:53'),(94,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-13 06:21:19'),(95,'SA2024001','system.database.backup.error','::1','{\"message\":\"数据库备份失败\",\"error\":\"Command failed: mysqldump -hlocalhost -uroot -p66176488 graduation_management > backups\\\\backup-2024-12-13T06-21-24.sql\\nmysqldump: [Warning] Using a password on the command line interface can be insecure.\\r\\nmysqldump: Got error: 1356: View \'graduation_management.v_selection_status\' references invalid table(s) or column(s) or function(s) or definer/invoker of view lack rights to use them when using LOCK TABLES\\r\\n\",\"timestamp\":\"2024-12-13T06:21:24.193Z\"}','2024-12-13 06:21:24'),(96,'SA2024001','system.database.backup','::1','{\"message\":\"数据库备份成功\",\"filename\":\"backup-2024-12-13T06-22-11.sql\",\"path\":\"backups\\\\backup-2024-12-13T06-22-11.sql\",\"timestamp\":\"2024-12-13T06:22:11.555Z\"}','2024-12-13 06:22:11'),(97,'A2024001','user.login.success','::1','用户 王管理 登录成功','2024-12-13 06:27:18'),(98,'A2024001','stage.list','::1','查询阶段列表','2024-12-13 06:27:34'),(99,'T2024001','user.login.success','::1','用户 张老师 登录成功','2024-12-13 06:40:15'),(100,'A2024001','user.login.success','::1','用户 王管理 登录成功','2024-12-13 06:45:50'),(101,'A2024001','stage.list','::1','查询阶段列表','2024-12-13 06:52:40'),(102,'A2024001','stage.list','::1','查询阶段列表','2024-12-13 07:03:05'),(103,'A2024001','stage.list','::1','查询阶段列表','2024-12-13 14:02:14'),(104,'A2024001','stage.list','::1','查询阶段列表','2024-12-13 14:16:52'),(105,'T2024001','user.login.success','::1','用户 张老师 登录成功','2024-12-13 14:17:37'),(106,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-13 14:19:51'),(107,'A2024001','user.login.success','::1','用户 王管理 登录成功','2024-12-13 14:21:25'),(108,'A2024001','update_topic_status','::1','{\"topic_id\":\"5\",\"topic_title\":\"云计算平台性能优化研究\",\"old_status\":\"approved\",\"new_status\":\"rejected\"}','2024-12-13 14:24:54'),(109,'A2024001','update_topic_status','::1','{\"topic_id\":\"7\",\"topic_title\":\"自然语言处理在智能客服中的应用\",\"old_status\":\"approved\",\"new_status\":\"rejected\"}','2024-12-13 14:24:58'),(110,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-13 14:25:07'),(111,'A2024001','user.login.success','::1','用户 王管理 登录成功','2024-12-13 14:25:46'),(112,'A2024001','user.login.success','::1','用户 王管理 登录成功','2024-12-13 14:26:06'),(113,'admin_ai_001','user.login.success','::1','用户 aiadmin 登录成功','2024-12-13 14:43:03'),(114,'admin_cs_001','user.login.success','::1','用户 csadmin 登录成功','2024-12-13 14:44:01'),(115,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-13 14:46:33');
/*!40000 ALTER TABLE `system_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_messages`
--

DROP TABLE IF EXISTS `system_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_messages` (
  `message_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `content` text NOT NULL,
  `type` enum('notice','warning','error') DEFAULT 'notice',
  `status` enum('active','archived') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` varchar(20) DEFAULT NULL,
  `priority` enum('low','medium','high') DEFAULT 'medium',
  `expires_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`message_id`),
  KEY `created_by` (`created_by`),
  KEY `idx_message_status_priority` (`status`,`priority`),
  CONSTRAINT `system_messages_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_messages`
--

LOCK TABLES `system_messages` WRITE;
/*!40000 ALTER TABLE `system_messages` DISABLE KEYS */;
INSERT INTO `system_messages` VALUES (1,'系统升级通知','系统将于今晚进行升级维护','notice','active','2024-12-10 03:49:24','SA2024001','medium',NULL),(2,'安全警告','发现异常登录尝试','warning','active','2024-12-10 03:49:24','SA2024001','medium',NULL),(3,'系统错误','数据库连接异常','error','active','2024-12-10 03:49:24','SA2024001','medium',NULL),(4,'功能更新','新增论文查重功能','notice','active','2024-12-10 03:49:24','SA2024001','medium',NULL),(11,'系统更新通知','系统将于今晚进行维护更新','notice','active','2024-12-10 03:55:10','SA2024001','medium',NULL),(12,'安全提醒','请注意账号安全','warning','active','2024-12-10 03:55:10','SA2024001','medium',NULL),(13,'功能更新','新增论文查重功能','notice','active','2024-12-10 03:55:10','SA2024001','medium',NULL);
/*!40000 ALTER TABLE `system_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `topic_selections`
--

DROP TABLE IF EXISTS `topic_selections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `topic_selections` (
  `selection_id` int NOT NULL AUTO_INCREMENT,
  `topic_id` int NOT NULL,
  `student_id` varchar(20) NOT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`selection_id`),
  UNIQUE KEY `unique_student_topic` (`student_id`,`topic_id`),
  KEY `topic_id` (`topic_id`),
  CONSTRAINT `topic_selections_ibfk_1` FOREIGN KEY (`topic_id`) REFERENCES `topics` (`topic_id`),
  CONSTRAINT `topic_selections_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=250 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `topic_selections`
--

LOCK TABLES `topic_selections` WRITE;
/*!40000 ALTER TABLE `topic_selections` DISABLE KEYS */;
INSERT INTO `topic_selections` VALUES (201,1,'S2024001','approved','2024-12-13 14:44:38','2024-12-13 14:44:38'),(202,1,'S2024002','pending','2024-12-13 14:44:38','2024-12-13 14:44:38'),(203,2,'S2024003','rejected','2024-12-13 14:44:38','2024-12-13 14:44:38'),(204,2,'S2024004','pending','2024-12-13 14:44:38','2024-12-13 14:44:38'),(205,3,'S2024005','approved','2024-12-13 14:44:38','2024-12-13 14:44:38'),(206,3,'S2024006','pending','2024-12-13 14:44:38','2024-12-13 14:44:38'),(207,4,'S2024007','approved','2024-12-13 14:44:38','2024-12-13 14:44:38'),(208,4,'S2024008','rejected','2024-12-13 14:44:38','2024-12-13 14:44:38'),(209,5,'S2024009','approved','2024-12-13 14:44:38','2024-12-13 14:44:38'),(210,5,'S2024010','pending','2024-12-13 14:44:38','2024-12-13 14:44:38'),(211,6,'S2024011','approved','2024-12-13 14:44:38','2024-12-13 14:44:38'),(212,6,'S2024012','rejected','2024-12-13 14:44:38','2024-12-13 14:44:38'),(213,7,'S2024013','pending','2024-12-13 14:44:38','2024-12-13 14:44:38'),(214,7,'S2024014','approved','2024-12-13 14:44:38','2024-12-13 14:44:38'),(215,8,'S2024015','pending','2024-12-13 14:44:38','2024-12-13 14:44:38'),(216,8,'S2024016','approved','2024-12-13 14:44:38','2024-12-13 14:44:38'),(217,9,'S2024017','rejected','2024-12-13 14:44:38','2024-12-13 14:44:38'),(218,9,'S2024018','pending','2024-12-13 14:44:38','2024-12-13 14:44:38'),(219,10,'S2024019','approved','2024-12-13 14:44:38','2024-12-13 14:44:38'),(220,10,'S2024020','pending','2024-12-13 14:44:38','2024-12-13 14:44:38'),(221,11,'S2024022','approved','2024-12-13 14:44:38','2024-12-13 14:44:38'),(222,11,'S2024023','rejected','2024-12-13 14:44:38','2024-12-13 14:44:38'),(223,12,'S2024024','pending','2024-12-13 14:44:38','2024-12-13 14:44:38'),(224,12,'S2024025','approved','2024-12-13 14:44:38','2024-12-13 14:44:38'),(225,13,'S2024026','pending','2024-12-13 14:44:38','2024-12-13 14:44:38'),(226,13,'S2024027','approved','2024-12-13 14:44:38','2024-12-13 14:44:38'),(227,14,'S2024028','rejected','2024-12-13 14:44:38','2024-12-13 14:44:38'),(228,14,'S2024029','pending','2024-12-13 14:44:38','2024-12-13 14:44:38'),(229,15,'S2024030','approved','2024-12-13 14:44:38','2024-12-13 14:44:38'),(230,15,'S2024031','pending','2024-12-13 14:44:38','2024-12-13 14:44:38'),(231,16,'S2024032','approved','2024-12-13 14:44:38','2024-12-13 14:44:38'),(232,16,'S2024033','rejected','2024-12-13 14:44:38','2024-12-13 14:44:38'),(233,17,'S2024034','pending','2024-12-13 14:44:38','2024-12-13 14:44:38'),(234,17,'S2024035','approved','2024-12-13 14:44:38','2024-12-13 14:44:38'),(235,18,'S2024036','pending','2024-12-13 14:44:38','2024-12-13 14:44:38'),(236,18,'S2024037','approved','2024-12-13 14:44:38','2024-12-13 14:44:38'),(237,19,'S2024038','rejected','2024-12-13 14:44:38','2024-12-13 14:44:38'),(238,19,'S2024039','pending','2024-12-13 14:44:38','2024-12-13 14:44:38'),(239,20,'S2024040','approved','2024-12-13 14:44:38','2024-12-13 14:44:38'),(240,20,'S2024041','pending','2024-12-13 14:44:38','2024-12-13 14:44:38'),(241,21,'S2024042','approved','2024-12-13 14:44:38','2024-12-13 14:44:38'),(242,21,'S2024043','rejected','2024-12-13 14:44:38','2024-12-13 14:44:38'),(243,22,'S2024044','pending','2024-12-13 14:44:38','2024-12-13 14:44:38'),(244,22,'S2024045','approved','2024-12-13 14:44:38','2024-12-13 14:44:38'),(245,23,'S2024046','pending','2024-12-13 14:44:38','2024-12-13 14:44:38'),(246,23,'S2024047','approved','2024-12-13 14:44:38','2024-12-13 14:44:38'),(247,24,'S2024048','rejected','2024-12-13 14:44:38','2024-12-13 14:44:38'),(248,24,'S2024049','pending','2024-12-13 14:44:38','2024-12-13 14:44:38'),(249,25,'S2024050','approved','2024-12-13 14:44:38','2024-12-13 14:44:38');
/*!40000 ALTER TABLE `topic_selections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `topics`
--

DROP TABLE IF EXISTS `topics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `topics` (
  `topic_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `type` varchar(50) NOT NULL,
  `source` varchar(100) DEFAULT NULL,
  `teacher_id` varchar(20) NOT NULL,
  `description` text,
  `major_requirements` text,
  `student_requirements` text,
  `status` enum('draft','pending','approved','rejected','selected') DEFAULT 'draft',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`topic_id`),
  KEY `idx_teacher_status` (`teacher_id`,`status`),
  CONSTRAINT `topics_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `topics`
--

LOCK TABLES `topics` WRITE;
/*!40000 ALTER TABLE `topics` DISABLE KEYS */;
INSERT INTO `topics` VALUES (1,'基于深度学习的图像识别系统设计','应用研究','教师科研','T2024001','本课题旨在设计和实现一个基于深度学习的图像识别系统,探索CNN等深度学习模型在图像识别领域的应用。','计算机科学与技术、人工智能等相关专业','熟悉Python编程,了解深度学习基础理论,有相关项目经验者优先','rejected','2024-12-13 14:37:01','2024-12-13 22:02:08'),(2,'区块链技术在供应链金融中的应用研究','理论研究','横向项目','T2024013','研究区块链技术如何在供应链金融领域发挥作用,解决信任与效率问题。','信息安全、金融科技相关专业','对区块链技术有浓厚兴趣,具备良好的编程能力','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(3,'智能物联网家居系统开发','工程实践','纵向项目','T2024012','开发基于物联网技术的智能家居控制系统,实现家电智能化控制。','物联网工程、嵌入式系统相关专业','熟悉嵌入式开发,有单片机开发经验','pending','2024-12-13 14:37:01','2024-12-13 14:37:01'),(4,'机器学习在网络安全中的应用','应用研究','教师科研','T2024007','探索机器学习算法在网络安全领域的应用,提高安全防护能力。','网络安全、人工智能相关专业','具备机器学习基础,熟悉网络安全知识','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(5,'云计算平台性能优化研究','工程实践','企业合作','T2024020','针对云计算平台的性能瓶颈进行分析和优化,提升系统效率。','云计算、软件工程相关专业','熟悉云计算技术,具有较强的编程能力','rejected','2024-12-13 14:37:01','2024-12-13 22:24:54'),(6,'分布式系统性能优化研究','工程实践','教师科研','T2024008','研究分布式系统的性能瓶颈，提出优化方案并实现。','计算机科学与技术、软件工程相关专业','熟悉分布式系统原理，具有良好的编程能力','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(7,'自然语言处理在智能客服中的应用','应用研究','企业合作','T2024006','基于NLP技术开发智能客服系统，提升服务效率。','人工智能、计算机科学相关专业','熟悉NLP相关算法，有项目开发经验','rejected','2024-12-13 14:37:01','2024-12-13 22:24:58'),(8,'大数据分析平台设计与实现','工程实践','横向项目','T2024015','设计并实现一个大数据分析平台，支持数据采集、处理和可视化。','大数据、软件工程相关专业','熟悉大数据技术栈，具有平台开发经验','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(9,'智能推荐算法研究与应用','应用研究','企业合作','T2024028','研究智能推荐算法，并在电商平台中实现应用。','人工智能、数据科学相关专业','熟悉推荐算法，具有实践经验','pending','2024-12-13 14:37:01','2024-12-13 14:37:01'),(10,'区块链智能合约安全性分析','理论研究','教师科研','T2024013','研究智能合约的安全漏洞，提出防护方案。','信息安全、区块链技术相关专业','了解智能合约开发，具有安全意识','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(11,'移动边缘计算研究与应用','理论研究','纵向项目','T2024020','研究移动边缘计算技术，优化资源调度策略。','计算机科学、通信工程相关专业','熟悉边缘计算概念，有相关研究经验','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(12,'工业物联网数据分析系统','工程实践','企业合作','T2024012','开发工业物联网数据分析系统，实现设备监控和预测维护。','物联网工程、自动化相关专业','熟悉物联网技术，了解工业协议','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(13,'人工智能在医疗影像中的应用','应用研究','横向项目','T2024001','研究AI技术在医疗影像诊断中的应用。','人工智能、生物医学工程相关专业','熟悉深度学习，了解医学影像基础','pending','2024-12-13 14:37:01','2024-12-13 14:37:01'),(14,'5G网络切片技术研究','理论研究','教师科研','T2024004','研究5G网络切片技术，提升网络资源利用效率。','通信工程、网络工程相关专业','熟悉5G网络架构，具有编程能力','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(15,'智能交通系统设计与实现','工程实践','纵向项目','T2024017','设计基于AI的智能交通系统，优化交通调度。','人工智能、交通工程相关专业','熟悉计算机视觉，了解交通系统','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(16,'量子密码通信技术研究','理论研究','教师科研','T2024013','研究量子密码通信原理与应用。','信息安全、量子计算相关专业','具有扎实的数学基础，了解量子计算','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(17,'智能机器人控制系统开发','工程实践','企业合作','T2024005','开发智能机器人控制系统，实现自主导航。','机器人工程、自动化相关专业','熟悉ROS系统，有机器人开发经验','pending','2024-12-13 14:37:01','2024-12-13 14:37:01'),(18,'区块链溯源系统设计与实现','工程实践','横向项目','T2024013','设计基于区块链的商品溯源系统。','区块链技术、软件工程相关专业','熟悉区块链开发，了解溯源业务','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(19,'网络入侵检测系统研究','应用研究','教师科研','T2024007','研究基于AI的网络入侵检测方法。','网络安全、人工智能相关专业','熟悉网络安全，了解机器学习','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(20,'虚拟现实教育平台开发','工程实践','企业合作','T2024030','开发基于VR技术的教育平台。','虚拟现实、教育技术相关专业','熟悉Unity3D，了解教育领域需求','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(21,'智能制造系统优化研究','应用研究','横向项目','T2024017','研究智能制造系统的优化方法。','工业工程、自动化相关专业','了解智能制造，熟悉优化算法','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(22,'区块链电子证书系统','工程实践','纵向项目','T2024013','开发基于区块链的电子证书管理系统。','区块链技术、信息安全相关专业','熟悉区块链开发，了解密码学','pending','2024-12-13 14:37:01','2024-12-13 14:37:01'),(23,'智能家居语音交互系统','工程实践','企业合作','T2024006','开发智能家居语音控制系统。','人工智能、物联网相关专业','熟悉语音识别，了解物联网协议','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(24,'深度学习框架优化研究','理论研究','教师科研','T2024001','研究深度学习框架的性能优化方法。','人工智能、高性能计算相关专业','熟悉深度学习框架，了解并行计算','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(25,'智能电网监控系统开发','工程实践','横向项目','T2024024','开发智能电网监控与管理系统。','电气工程、自动化相关专业','了解电力系统，熟悉SCADA开发','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(26,'生物特征识别系统研究','应用研究','教师科研','T2024001','研究多模态生物特征识别技术。','人工智能、信息安全相关专业','熟悉图像处理，了解生物特征','pending','2024-12-13 14:37:01','2024-12-13 14:37:01'),(27,'智能仓储机器人系统','工程实践','企业合作','T2024005','开发智能仓储机器人控制系统。','机器人工程、物流工程相关专业','熟悉机器人控制，了解仓储物流','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(28,'区块链共识算法研究','理论研究','教师科研','T2024013','研究区块链共识算法的性能与安全性。','区块链技术、密码学相关专业','熟悉共识算法，了解分布式系统','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(29,'智能视频分析系统开发','工程实践','横向项目','T2024001','开发基于AI的视频分析系统。','计算机视觉、人工智能相关专业','熟悉视频处理，了解深度学习','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(30,'物联网安全防护研究','应用研究','教师科研','T2024007','研究物联网设备的安全防护方法。','物联网、信息安全相关专业','了解物联网协议，熟悉安全技术','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(31,'智能医疗辅助诊断系统','工程实践','横向项目','T2024001','开发基于AI的医疗辅助诊断系统。','人工智能、生物医学工程相关专业','熟悉医学图像处理，了解临床诊断','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(32,'区块链跨链技术研究','理论研究','教师科研','T2024013','研究区块链跨链互操作技术。','区块链技术、分布式系统相关专业','熟悉区块链原理，了解跨链协议','pending','2024-12-13 14:37:01','2024-12-13 14:37:01'),(33,'智能农业监控系统','工程实践','企业合作','T2024012','开发智能农业环境监控系统。','物联网、农业工程相关专业','熟悉传感器网络，了解农业生产','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(34,'深度强化学习研究','理论研究','教师科研','T2024001','研究深度强化学习算法及应用。','人工智能、控制科学相关专业','熟悉强化学习，了解深度学习','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(35,'智能建筑管理系统','工程实践','横向项目','T2024012','开发智能建筑综合管理系统。','物联网、建筑智能化相关专业','熟悉楼宇自动化，了解物联网技术','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(36,'网络空间安全态势感知','应用研究','教师科研','T2024007','研究网络安全态势感知技术。','网络安全、人工智能相关专业','熟悉网络安全，了解态势感知','pending','2024-12-13 14:37:01','2024-12-13 14:37:01'),(37,'智能无人机控制系统','工程实践','企业合作','T2024005','开发智能无人机飞行控制系统。','自动化、航空航天相关专业','熟悉飞行控制，了解无人机技术','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(38,'区块链隐私保护研究','理论研究','教师科研','T2024013','研究区块链系统的隐私保护技术。','信息安全、区块链技术相关专业','熟悉密码学，了解隐私计算','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(39,'智能客服机器人开发','工程实践','横向项目','T2024006','开发智能客服机器人系统。','人工智能、软件工程相关专业','熟悉自然语言处理，了解对话系统','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(40,'工业互联网平台研究','应用研究','企业合作','T2024012','研究工业互联网平台架构与实现。','物联网、工业工程相关专业','了解工业互联网，熟悉平台开发','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(41,'智能风控系统开发','工程实践','横向项目','T2024007','开发金融风险智能控制系统。','金融科技、人工智能相关专业','熟悉机器学习，了解金融风控','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(42,'量子计算模拟器研究','理论研究','教师科研','T2024013','研究量子计算模拟器的设计与实现。','量子计算、计算机科学相关专业','熟悉量子计算原理，了解模拟技术','pending','2024-12-13 14:37:01','2024-12-13 14:37:01'),(43,'智能停车管理系统','工程实践','企业合作','T2024017','开发智能停车场管理系统。','物联网、交通工程相关专业','熟悉计算机视觉，了解停车场管理','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(44,'边缘智能计算研究','理论研究','教师科研','T2024020','研究边缘计算中的智能处理技术。','计算机科学、人工智能相关专业','熟悉边缘计算，了解机器学习','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(45,'智能环境监测系统','工程实践','横向项目','T2024012','开发环境参数智能监测系统。','物联网、环境工程相关专业','熟悉传感器网络，了解环境监测','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(46,'网络攻击检测研究','应用研究','教师科研','T2024007','研究基于AI的网络攻击检测方法。','网络安全、人工智能相关专业','熟悉网络安全，了解异常检测','pending','2024-12-13 14:37:01','2024-12-13 14:37:01'),(47,'智能机械臂控制系统','工程实践','企业合作','T2024005','开发工业机械臂智能控制系统。','机器人工程、自动化相关专业','熟悉机械臂控制，了解工业机器人','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(48,'区块链存储优化研究','理论研究','教师科研','T2024013','研究区块链系统的存储优化方法。','区块链技术、存储技术相关专业','熟悉分布式存储，了解区块链','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(49,'智能翻译系统开发','工程实践','横向项目','T2024006','开发基于神经网络的翻译系统。','人工智能、计算语言学相关专业','熟悉自然语言处理，了解机器翻译','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(50,'工业设备预测维护','应用研究','企业合作','T2024017','研究工业设备预测性维护方法。','工业工程、人工智能相关专业','了解设备维护，熟悉预测算法','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(51,'智能安防系统开发','工程实践','横向项目','T2024007','开发智能视频安防监控系统。','计算机视觉、安防工程相关专业','熟悉视频分析，了解安防系统','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(52,'量子通信协议研究','理论研究','教师科研','T2024013','研究量子通信协议的安全性。','量子通信、密码学相关专业','熟悉量子力学，了解密码学原理','pending','2024-12-13 14:37:01','2024-12-13 14:37:01'),(53,'智能物流配送系统','工程实践','企业合作','T2024017','开发智能物流配送管理系统。','物流工程、人工智能相关专业','熟悉路径规划，了解物流管理','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(54,'联邦学习系统研究','理论研究','教师科研','T2024001','研究联邦学习系统的实现方法。','人工智能、分布式系统相关专业','熟悉机器学习，了解联邦学习','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(55,'智能能源管理系统','工程实践','横向项目','T2024024','开发智能能源监控管理系统。','电气工程、自动化相关专业','熟悉能源系统，了解智能控制','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(56,'网络流量分析研究','应用研究','教师科研','T2024007','研究网络流量智能分析方法。','网络工程、人工智能相关专业','熟悉流量分析，了解机器学习','pending','2024-12-13 14:37:01','2024-12-13 14:37:01'),(57,'智能排产系统开发','工程实践','企业合作','T2024017','开发智能生产排程系统。','工业工程、人工智能相关专业','熟悉排程算法，了解生产管理','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(58,'区块链性能优化研究','理论研究','教师科研','T2024013','研究区块链系统的性能优化方法。','区块链技术、分布式系统相关专业','熟悉区块链原理，了解性能优化','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(59,'智能问答系统开发','工程实践','横向项目','T2024006','开发基于知识图谱的问答系统。','人工智能、知识工程相关专业','熟悉自然语言处理，了解知识图谱','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(60,'工业数据分析平台','应用研究','企业合作','T2024015','开发工业大数据分析平台。','大数据、工业工程相关专业','熟悉数据分析，了解工业生产','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(61,'智能门禁系统开发','工程实践','横向项目','T2024007','开发人脸识别门禁管理系统。','人工智能、安防工程相关专业','熟悉人脸识别，了解门禁系统','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(62,'量子加密系统研究','理论研究','教师科研','T2024013','研究量子加密系统的实现方法。','量子计算、密码学相关专业','熟悉量子密码，了解系统安全','pending','2024-12-13 14:37:01','2024-12-13 14:37:01'),(63,'智能仓储管理系统','工程实践','企业合作','T2024017','开发智能仓储管理与调度系统。','物流工程、自动化相关专业','熟悉仓储管理，了解智能调度','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(64,'迁移学习算法研究','理论研究','教师科研','T2024001','研究迁移学习算法及其应用。','人工智能、模式识别相关专业','熟悉机器学习，了解迁移学习','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(65,'智能电梯控制系统','工程实践','横向项目','T2024024','开发智能电梯群控系统。','自动化、机电工程相关专业','熟悉电梯控制，了解群控算法','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(66,'网络异常检测研究','应用研究','教师科研','T2024007','研究网络异常行为检测方法。','网络安全、人工智能相关专业','熟悉异常检测，了解网络安全','pending','2024-12-13 14:37:01','2024-12-13 14:37:01'),(67,'智能质检系统开发','工程实践','企业合作','T2024017','开发产品智能质量检测系统。','计算机视觉、质量工程相关专业','熟悉图像处理，了解质量控制','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(68,'区块链监管技术研究','理论研究','教师科研','T2024013','研究区块链系统的监管技术。','区块链技术、金融科技相关专业','熟悉区块链原理，了解金融监管','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(69,'智能教学系统开发','工程实践','横向项目','T2024006','开发智能在线教学系统。','教育技术、人工智能相关专业','熟悉教育技术，了解智能教学','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(70,'工业机器视觉系统','应用研究','企业合作','T2024001','开发工业产品视觉检测系统。','计算机视觉、自动化相关专业','熟悉机器视觉，了解工业检测','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(71,'智能消防系统开发','工程实践','横向项目','T2024012','开发智能消防监控预警系统。','物联网、安全工程相关专业','熟悉消防系统，了解物联网技术','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(72,'量子算法优化研究','理论研究','教师科研','T2024013','研究量子算法的优化方法。','量子计算、计算机科学相关专业','熟悉量子计算，了解算法优化','pending','2024-12-13 14:37:01','2024-12-13 14:37:01'),(73,'智能巡检机器人系统','工程实践','企业合作','T2024005','开发智能巡检机器人控制系统。','机器人工程、自动化相关专业','熟悉机器人控制，了解巡检业务','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(74,'深度图网络研究','理论研究','教师科研','T2024001','研究深度图神经网络及应用。','人工智能、图计算相关专业','熟悉图神经网络，了解深度学习','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(75,'智能水务管理系统','工程实践','横向项目','T2024024','开发智能水务监控管理系统。','物联网、水利工程相关专业','熟悉水务系统，了解物联网技术','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(76,'网络威胁情报研究','应用研究','教师科研','T2024007','研究网络威胁情报分析方法。','网络安全、数据分析相关专业','熟悉威胁情报，了解安全分析','pending','2024-12-13 14:37:01','2024-12-13 14:37:01'),(77,'智能装配系统开发','工程实践','企业合作','T2024017','开发智能化产品装配系统。','机器人工程、制造工程相关专业','熟悉装配工艺，了解智能控制','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(78,'区块链治理研究','理论研究','教师科研','T2024013','研究区块链系统的治理机制。','区块链技术、管理科学相关专业','熟悉区块链原理，了解治理理论','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(79,'智能招聘系统开发','工程实践','横向项目','T2024006','开发智能化招聘筛选系统。','人工智能、人力资源相关专业','熟悉自然语言处理，了解招聘流程','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(80,'工业控制系统优化','应用研究','企业合作','T2024024','研究工业控制系统优化方法。','自动化、控制工程相关专业','熟悉控制理论，了解工业自动化','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(81,'智能门店管理系统','工程实践','横向项目','T2024017','开发智能零售店铺管理系统。','物联网、零售工程相关专业','熟悉零售业务，了解物联网技术','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(82,'量子网络协议研究','理论研究','教师科研','T2024013','研究量子网络通信协议。','量子通信、网络工程相关专业','熟悉量子通信，了解网络协议','pending','2024-12-13 14:37:01','2024-12-13 14:37:01'),(83,'智能农业系统开发','工程实践','企业合作','T2024012','开发智能农业监控管理系统。','物联网、农业工程相关专业','熟悉农业技术，了解物联网应用','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(84,'深度强化学习研究','理论研究','教师科研','T2024001','研究深度强化学习算法及应用。','人工智能、控制科学相关专业','熟悉强化学习，了解深度学习','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(85,'智能物流配送系统','工程实践','横向项目','T2024020','开发智能物流路径规划系统。','物流工程、运筹学相关专业','熟悉物流系统，了解优化算法','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(86,'网络入侵检测研究','应用研究','教师科研','T2024007','研究网络入侵检测新方法。','网络安全、人工智能相关专业','熟悉入侵检测，了解机器学习','pending','2024-12-13 14:37:01','2024-12-13 14:37:01'),(87,'智能停车系统开发','工程实践','企业合作','T2024015','开发智能化停车管理系统。','物联网、交通工程相关专业','熟悉停车场景，了解物联网技术','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(88,'区块链隐私保护研究','理论研究','教师科研','T2024013','研究区块链系统的隐私保护机制。','信息安全、区块链技术相关专业','熟悉密码学，了解区块链原理','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(89,'智能客流分析系统','工程实践','横向项目','T2024006','开发智能客流监测分析系统。','计算机视觉、数据分析相关专业','熟悉视觉算法，了解客流分析','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(90,'工业数字孪生系统','应用研究','企业合作','T2024024','研究工业数字孪生建模方法。','虚拟现实、自动化相关专业','熟悉数字孪生，了解工业建模','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(91,'智能环境监测系统','工程实践','横向项目','T2024012','开发智能环境监测预警系统。','物联网、环境工程相关专业','熟悉环境监测，了解物联网技术','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(92,'量子密码系统研究','理论研究','教师科研','T2024013','研究量子密码协议及应用。','量子通信、密码学相关专业','熟悉量子密码，了解密码学原理','pending','2024-12-13 14:37:01','2024-12-13 14:37:01'),(93,'智能医疗系统开发','工程实践','企业合作','T2024001','开发智能医疗辅助诊断系统。','医学信息、人工智能相关专业','熟悉医疗领域，了解机器学习','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(94,'深度图生成网络','理论研究','教师科研','T2024005','研究深度图生成网络及应用。','人工智能、图计算相关专业','熟悉生成模型，了解图神经网络','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(95,'智能电网管理系统','工程实践','横向项目','T2024020','开发智能电网监控管理系统。','电气工程、物联网相关专业','熟悉电网系统，了解物联网技术','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(96,'网络攻防技术研究','应用研究','教师科研','T2024007','研究网络攻防对抗技术。','网络安全、信息安全相关专业','熟悉网络安全，了解攻防技术','pending','2024-12-13 14:37:01','2024-12-13 14:37:01'),(97,'智能交通系统开发','工程实践','企业合作','T2024015','开发智能交通管控系统。','交通工程、物联网相关专业','熟悉交通系统，了解智能控制','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(98,'区块链共识机制研究','理论研究','教师科研','T2024013','研究区块链共识算法优化。','区块链技术、分布式计算相关专业','熟悉共识算法，了解分布式系统','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(99,'智能安防系统开发','工程实践','横向项目','T2024006','开发智能安防监控系统。','计算机视觉、安防工程相关专业','熟悉视觉算法，了解安防技术','approved','2024-12-13 14:37:01','2024-12-13 14:37:01'),(100,'元宇宙技术研究与应用','理论研究','横向项目','T2024030','探索元宇宙关键技术，研究其在教育领域的应用。','虚拟现实、计算机图形学相关专业','具备3D建模经验，熟悉Unity开发','pending','2024-12-13 14:37:01','2024-12-13 14:37:01');
/*!40000 ALTER TABLE `topics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_progress`
--

DROP TABLE IF EXISTS `user_progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_progress` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(50) NOT NULL,
  `supervisor_id` varchar(20) NOT NULL,
  `topic_id` int DEFAULT NULL,
  `current_stage_id` int DEFAULT NULL,
  `overall_progress` decimal(5,2) DEFAULT '0.00',
  `status` enum('normal','warning','overdue') DEFAULT 'normal',
  `last_update` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `student_id` (`student_id`),
  KEY `supervisor_id` (`supervisor_id`),
  KEY `current_stage_id` (`current_stage_id`),
  CONSTRAINT `user_progress_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
  CONSTRAINT `user_progress_ibfk_2` FOREIGN KEY (`supervisor_id`) REFERENCES `supervisors` (`supervisor_id`),
  CONSTRAINT `user_progress_ibfk_3` FOREIGN KEY (`current_stage_id`) REFERENCES `progress_stages` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_progress`
--

LOCK TABLES `user_progress` WRITE;
/*!40000 ALTER TABLE `user_progress` DISABLE KEYS */;
INSERT INTO `user_progress` VALUES (1,'S2024001','T2024001',NULL,2,25.00,'normal','2024-03-15 16:45:00','2024-12-11 14:39:07','2024-12-11 14:39:07'),(2,'S2024002','T2024001',NULL,2,10.00,'warning','2024-12-11 13:14:03','2024-12-11 14:39:07','2024-12-11 14:39:07'),(3,'S2024003','T2024002',NULL,2,20.00,'normal','2024-03-16 10:30:00','2024-12-11 14:39:07','2024-12-11 14:39:07'),(4,'S2024004','T2024002',NULL,3,15.00,'warning','2024-12-11 13:14:03','2024-12-11 14:39:07','2024-12-11 14:39:07'),(5,'S2024005','T2024003',NULL,3,35.00,'normal','2024-03-25 09:15:00','2024-12-11 14:39:07','2024-12-11 14:39:07');
/*!40000 ALTER TABLE `user_progress` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` varchar(20) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('superadmin','admin','teacher','student','guest') NOT NULL,
  `staff_id` varchar(20) DEFAULT NULL COMMENT '职工号',
  `student_id` varchar(20) DEFAULT NULL COMMENT '学号',
  `login_count` int DEFAULT '0',
  `name` varchar(50) DEFAULT NULL,
  `gender` enum('male','female') DEFAULT NULL,
  `department` varchar(100) DEFAULT NULL,
  `major` varchar(100) DEFAULT NULL COMMENT '学生专业',
  `title` varchar(100) DEFAULT NULL COMMENT '教师职称',
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `introduction` text,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` enum('active','inactive','locked') DEFAULT 'active',
  `last_login_time` timestamp NULL DEFAULT NULL,
  `last_login_ip` varchar(50) DEFAULT NULL,
  `avatar_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `idx_staff_id` (`staff_id`),
  UNIQUE KEY `idx_student_id` (`student_id`),
  KEY `idx_role` (`role`),
  KEY `idx_username_status` (`username`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES ('A2024001','王管理','$2a$10$udP7JcUSRnL0/Hyy6L4SK.s9XKaP.RRGAbWfVoN.FbIK6Y24fD1rW','admin',NULL,NULL,21,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-13 14:26:06','active','2024-12-13 14:26:06','::1',NULL,'2024-12-10 13:37:45'),('A2024002','manager2','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','admin',NULL,NULL,0,'王娜','male','信息安全系',NULL,'部门主管','manager2@test.com','13931493736','王娜的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('A2024003','manager3','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','admin',NULL,NULL,0,'刘秀英','male','人工智能系',NULL,'部门主管','manager3@test.com','13976099696','刘秀英的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('A2024004','manager4','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','admin',NULL,NULL,0,'陈敏','female','数据科学系',NULL,'部门主管','manager4@test.com','13927723187','陈敏的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('A2024005','manager5','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','admin',NULL,NULL,0,'杨静','male','计算机系',NULL,'部门主管','manager5@test.com','13988752689','杨静的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('A2024006','manager6','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','admin',NULL,NULL,0,'赵丽','male','软件工程系',NULL,'部门主管','manager6@test.com','13944299868','赵丽的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('A2024007','manager7','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','admin',NULL,NULL,0,'黄强','female','信息安全系',NULL,'部门主管','manager7@test.com','13964754602','黄强的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('A2024008','manager8','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','admin',NULL,NULL,0,'周磊','male','人工智能系',NULL,'部门主管','manager8@test.com','13959697401','周磊的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('admin_ai_001','aiadmin','$2a$10$udP7JcUSRnL0/Hyy6L4SK.s9XKaP.RRGAbWfVoN.FbIK6Y24fD1rW','admin','AI20240103',NULL,1,'王强','male','人工智能学院',NULL,'教授','aiadmin@university.edu','13800000003','人工智能学院系主任，深耕计算机视觉与深度学习领域。','2024-12-13 14:43:03','active','2024-12-13 14:43:03','::1',NULL,'2024-12-13 14:32:09'),('admin_cs_001','csadmin','$2a$10$udP7JcUSRnL0/Hyy6L4SK.s9XKaP.RRGAbWfVoN.FbIK6Y24fD1rW','admin','CS20240101',NULL,1,'张明','male','计算机科学与技术学院',NULL,'教授','csadmin@university.edu','13800000001','计算机科学与技术学院系主任，主要研究方向为人工智能与机器学习。','2024-12-13 14:44:01','active','2024-12-13 14:44:01','::1',NULL,'2024-12-13 14:32:09'),('admin_ee_001','eeadmin','$2a$10$udP7JcUSRnL0/Hyy6L4SK.s9XKaP.RRGAbWfVoN.FbIK6Y24fD1rW','admin','EE20240104',NULL,0,'刘芳','female','电子信息工程学院',NULL,'教授','eeadmin@university.edu','13800000004','电子信息工程学院系主任，专注于通信技术与信息处理研究。','2024-12-13 14:32:09','active',NULL,NULL,NULL,'2024-12-13 14:32:09'),('admin_se_001','seadmin','$2a$10$udP7JcUSRnL0/Hyy6L4SK.s9XKaP.RRGAbWfVoN.FbIK6Y24fD1rW','admin','SE20240102',NULL,0,'李华','female','软件工程学院',NULL,'教授','seadmin@university.edu','13800000002','软件工程学院系主任，专注于软件工程方法学和软件质量保证研究。','2024-12-13 14:32:09','active',NULL,NULL,NULL,'2024-12-13 14:32:09'),('G2024001','guest1','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','guest',NULL,NULL,0,'访客1','female','外部单位',NULL,NULL,'guest1@test.com','13930565037','访客1的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('G2024002','guest2','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','guest',NULL,NULL,0,'访客2','male','外部单位',NULL,NULL,'guest2@test.com','13914182137','访客2的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('G2024003','guest3','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','guest',NULL,NULL,0,'访客3','male','外部单位',NULL,NULL,'guest3@test.com','13931217073','访客3的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('G2024004','guest4','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','guest',NULL,NULL,0,'访客4','male','外部单位',NULL,NULL,'guest4@test.com','13926175341','访客4的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('G2024005','guest5','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','guest',NULL,NULL,0,'访客5','male','外部单位',NULL,NULL,'guest5@test.com','13941162761','访客5的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('G2024006','guest6','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','guest',NULL,NULL,0,'访客6','female','外部单位',NULL,NULL,'guest6@test.com','13907269863','访客6的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('G2024007','guest7','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','guest',NULL,NULL,0,'访客7','female','外部单位',NULL,NULL,'guest7@test.com','13970249980','访客7的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('G2024008','guest8','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','guest',NULL,NULL,0,'访客8','male','外部单位',NULL,NULL,'guest8@test.com','13942807023','访客8的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('G2024009','guest9','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','guest',NULL,NULL,0,'访客9','male','外部单位',NULL,NULL,'guest9@test.com','13996662608','访客9的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('G2024010','guest10','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','guest',NULL,NULL,0,'访客10','female','外部单位',NULL,NULL,'guest10@test.com','13932000979','访客10的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('G2024081','Loki','$2a$10$4PClkmBkJ3nnfwnj.wnXzOMg0..p7Z/5prVpZQTihXk4aFIIMB61S','guest',NULL,NULL,2,'By','male','',NULL,'','2915399378@qq.com','15049051686','','2024-12-10 14:35:57','active','2024-12-10 14:35:57','::1',NULL,'2024-12-10 13:40:17'),('G2024315','test','$2a$10$LylUmxmY6CW45pDw6zIUgOZfV218CNr3/JpWhP5m1OK2qKgi4OObq','guest',NULL,NULL,0,'aufhsgjk','male','',NULL,'','4561237894@qq.com','15376959676','','2024-12-12 07:31:09','active',NULL,NULL,NULL,'2024-12-12 07:31:09'),('G9055083583','dfad','$2a$10$1AolUv903uH6lVL1.69ZauL4i9LypdHCZ9MuRkBWyibjBFDlc1Fne','guest',NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-12 07:37:35','active',NULL,NULL,NULL,'2024-12-12 07:37:35'),('G9204049729','asda','$2a$10$j7BxN2MZz5v5PF5cJSw6R.9hi0amWPosckbx9FxtizYF3lj.eQLG2','guest',NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-12 07:40:04','active',NULL,NULL,NULL,'2024-12-12 07:40:04'),('G9319052297','ads','$2a$10$ZQBoh2/xgwvliRTUA7J7J.AZCRwX1ZRCqF57r6i/rdJBcAx9NyLoW','guest',NULL,NULL,0,'ads','male','',NULL,'','asgsh@qq.com','15376959676','','2024-12-12 15:40:57','active',NULL,NULL,NULL,'2024-12-12 07:41:59'),('G9467326781','asdfgsh','$2a$10$edID/sPnm9ff6gzPbsWF0ucAsIs64WP9yddfKNMMDR6rLPdHTh24i','guest',NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-12 07:44:27','active',NULL,NULL,NULL,'2024-12-12 07:44:27'),('G9876306369','123456','$2a$10$hxPUfERRqcgzyibLiHNIr.gOKFk0DRKUc85JYqxNMV/KI4fltqTbK','guest',NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-12 07:51:16','active',NULL,NULL,NULL,'2024-12-12 07:51:16'),('S2024001','李同学','$2a$10$udP7JcUSRnL0/Hyy6L4SK.s9XKaP.RRGAbWfVoN.FbIK6Y24fD1rW','student',NULL,'S2024001',2,'李同学','male','adf','',NULL,'dsfva@qq.com','15376959676','','2024-12-12 15:40:34','active','2024-12-12 15:26:00','::1',NULL,'2024-12-10 13:37:45'),('S2024002','student2','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'王娜','female','信息安全系','信息安全',NULL,'student2@test.com','13976328835','王娜的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024003','student3','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'刘秀英','female','人工智能系','人工智能',NULL,'student3@test.com','13958890202','刘秀英的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024004','student4','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'陈敏','female','数据科学系','数据科学',NULL,'student4@test.com','13948050005','陈敏的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024005','student5','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'杨静','female','计算机系','计算机科学与技术',NULL,'student5@test.com','13983854719','杨静的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024006','student6','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'赵丽','female','软件工程系','软件工程',NULL,'student6@test.com','13944296979','赵丽的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024007','student7','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'黄强','male','信息安全系','信息安全',NULL,'student7@test.com','13983364204','黄强的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024008','student8','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'周磊','male','人工智能系','人工智能',NULL,'student8@test.com','13942134133','周磊的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024009','student9','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'吴洋','male','数据科学系','数据科学',NULL,'student9@test.com','13956905893','吴洋的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024010','student10','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'张伟','male','计算机系','计算机科学与技术',NULL,'student10@test.com','13902463723','张伟的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024011','student11','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'李芳','male','软件工程系','软件工程',NULL,'student11@test.com','13998373545','李芳的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024012','student12','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'王娜','male','信息安全系','信息安全',NULL,'student12@test.com','13983702334','王娜的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024013','student13','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'刘秀英','female','人工智能系','人工智能',NULL,'student13@test.com','13973974073','刘秀英的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024014','student14','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'陈敏','female','数据科学系','数据科学',NULL,'student14@test.com','13959634221','陈敏的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024015','student15','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'杨静','female','计算机系','计算机科学与技术',NULL,'student15@test.com','13993053630','杨静的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024016','student16','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'赵丽','female','软件工程系','软件工程',NULL,'student16@test.com','13996796899','赵丽的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024017','student17','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'黄强','male','信息安全系','信息安全',NULL,'student17@test.com','13944954457','黄强的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024018','student18','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'周磊','male','人工智能系','人工智能',NULL,'student18@test.com','13905645545','周磊的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024019','student19','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'吴洋','male','数据科学系','数据科学',NULL,'student19@test.com','13948485143','吴洋的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024020','student20','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'张伟','female','计算机系','计算机科学与技术',NULL,'student20@test.com','13993594311','张伟的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024022','student22','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'王娜','female','信息安全系','信息安全',NULL,'student22@test.com','13939407744','王娜的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024023','student23','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'刘秀英','male','人工智能系','人工智能',NULL,'student23@test.com','13963784849','刘秀英的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024024','student24','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'陈敏','female','数据科学系','数据科学',NULL,'student24@test.com','13959844162','陈敏的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024025','student25','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'杨静','female','计算机系','计算机科学与技术',NULL,'student25@test.com','13929144272','杨静的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024026','student26','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'赵丽','male','软件工程系','软件工程',NULL,'student26@test.com','13971386815','赵丽的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024027','student27','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'黄强','male','信息安全系','信息安全',NULL,'student27@test.com','13951589892','黄强的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024028','student28','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'周磊','female','人工智能系','人工智能',NULL,'student28@test.com','13975504506','周磊的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024029','student29','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'吴洋','male','数据科学系','数据科学',NULL,'student29@test.com','13979972800','吴洋的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024030','student30','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'张伟','male','计算机系','计算机科学与技术',NULL,'student30@test.com','13948596540','张伟的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024031','student31','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'李芳','female','软件工程系','软件工程',NULL,'student31@test.com','13917614321','李芳的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024032','student32','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'王娜','female','信息安全系','信息安全',NULL,'student32@test.com','13914491104','王娜的个人简介','2024-12-12 16:28:28','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024033','student33','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'刘秀英','male','人工智能系','人工智能',NULL,'student33@test.com','13965474152','刘秀英的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024034','student34','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'陈敏','female','数据科学系','数据科学',NULL,'student34@test.com','13966140142','陈敏的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024035','student35','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'杨静','male','计算机系','计算机科学与技术',NULL,'student35@test.com','13960808455','杨静的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024036','student36','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'赵丽','female','软件工程系','软件工程',NULL,'student36@test.com','13917288099','赵丽的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024037','student37','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'黄强','female','信息安全系','信息安全',NULL,'student37@test.com','13981273910','黄强的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024038','student38','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'周磊','female','人工智能系','人工智能',NULL,'student38@test.com','13970686151','周磊的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024039','student39','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'吴洋','male','数据科学系','数据科学',NULL,'student39@test.com','13964285381','吴洋的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024040','student40','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'张伟','female','计算机系','计算机科学与技术',NULL,'student40@test.com','13918007465','张伟的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024041','student41','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'李芳','female','软件工程系','软件工程',NULL,'student41@test.com','13974376412','李芳的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024042','student42','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'王娜','male','信息安全系','信息安全',NULL,'student42@test.com','13916677681','王娜的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024043','student43','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'刘秀英','male','人工智能系','人工智能',NULL,'student43@test.com','13906944071','刘秀英的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024044','student44','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'陈敏','female','数据科学系','数据科学',NULL,'student44@test.com','13938458530','陈敏的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024045','student45','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'杨静','male','计算机系','计算机科学与技术',NULL,'student45@test.com','13985017311','杨静的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024046','student46','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'赵丽','female','软件工程系','软件工程',NULL,'student46@test.com','13927758226','赵丽的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024047','student47','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'黄强','female','信息安全系','信息安全',NULL,'student47@test.com','13953921077','黄强的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024048','student48','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'周磊','male','人工智能系','人工智能',NULL,'student48@test.com','13950837754','周磊的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024049','student49','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'吴洋','female','数据科学系','数据科学',NULL,'student49@test.com','13957784629','吴洋的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024050','student50','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'张伟','male','计算机系','计算机科学与技术',NULL,'student50@test.com','13909649506','张伟的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('SA2024001','刘超管','$2a$10$jxlBlkhXxhUB4kdT4X8QKuzl/Tcxwm2P258aLl8S0jKvc./pK258W','superadmin',NULL,NULL,35,'刘超刘','male','',NULL,'','2915399378@qq.com','15376959676','','2024-12-13 14:46:33','active','2024-12-13 14:46:33','::1',NULL,'2024-12-10 13:37:45'),('SA2024002','admin2','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','superadmin',NULL,NULL,0,'管理员2','female','系统部',NULL,'高级管理员','admin2@test.com','13933587790','管理员2的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024001','张老师','$2a$10$udP7JcUSRnL0/Hyy6L4SK.s9XKaP.RRGAbWfVoN.FbIK6Y24fD1rW','teacher','T2024001',NULL,5,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-13 14:17:37','active','2024-12-13 14:17:37','::1',NULL,'2024-12-10 13:37:45'),('T2024002','teacher2','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'王娜','female','信息安全系',NULL,'讲师','teacher2@test.com','13945578883','王娜的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024003','teacher3','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'刘秀英','male','人工智能系',NULL,'助教','teacher3@test.com','13960497361','刘秀英的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024004','teacher4','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'陈敏','male','数据科学系',NULL,'教授','teacher4@test.com','13906698383','陈敏的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024005','teacher5','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'杨静','male','计算机系',NULL,'副教授','teacher5@test.com','13950317645','杨静的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024006','teacher6','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'赵丽','female','软件工程系',NULL,'讲师','teacher6@test.com','13909991133','赵丽的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024007','teacher7','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'黄强','female','信息安全系',NULL,'助教','teacher7@test.com','13954034024','黄强的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024008','teacher8','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'周磊','female','人工智能系',NULL,'教授','teacher8@test.com','13968727938','周磊的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024009','teacher9','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'吴洋','female','数据科学系',NULL,'副教授','teacher9@test.com','13959359102','吴洋的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024010','teacher10','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'张伟','female','计算机系',NULL,'讲师','teacher10@test.com','13919314521','张伟的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024011','teacher11','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'李芳','male','软件工程系',NULL,'助教','teacher11@test.com','13950372733','李芳的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024012','teacher12','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'王娜','male','信息安全系',NULL,'教授','teacher12@test.com','13960763334','王娜的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024013','teacher13','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'刘秀英','female','人工智能系',NULL,'副教授','teacher13@test.com','13904979334','刘秀英的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024014','teacher14','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'陈敏','male','数据科学系',NULL,'讲师','teacher14@test.com','13979276730','陈敏的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024015','teacher15','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'杨静','female','计算机系',NULL,'助教','teacher15@test.com','13947575303','杨静的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024016','teacher16','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'赵丽','female','软件工程系',NULL,'教授','teacher16@test.com','13961704321','赵丽的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024017','teacher17','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'黄强','female','信息安全系',NULL,'副教授','teacher17@test.com','13945520745','黄强的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024018','teacher18','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'周磊','female','人工智能系',NULL,'讲师','teacher18@test.com','13907324923','周磊的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024019','teacher19','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'吴洋','male','数据科学系',NULL,'助教','teacher19@test.com','13900845702','吴洋的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024020','teacher20','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'张伟','female','计算机系',NULL,'教授','teacher20@test.com','13926071573','张伟的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024021','teacher21','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'李芳','female','软件工程系',NULL,'副教授','teacher21@test.com','13942579785','李芳的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024022','teacher22','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'王娜','female','信息安全系',NULL,'讲师','teacher22@test.com','13920071118','王娜的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024023','teacher23','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'刘秀英','male','人工智能系',NULL,'助教','teacher23@test.com','13975419871','刘秀英的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024024','teacher24','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'陈敏','male','数据科学系',NULL,'教授','teacher24@test.com','13931002450','陈敏的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024025','teacher25','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'杨静','female','计算机系',NULL,'副教授','teacher25@test.com','13939213777','杨静的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024026','teacher26','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'赵丽','male','软件工程系',NULL,'讲师','teacher26@test.com','13931380423','赵丽的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024027','teacher27','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'黄强','female','信息安全系',NULL,'助教','teacher27@test.com','13979349941','黄强的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024028','teacher28','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'周磊','female','人工智能系',NULL,'教授','teacher28@test.com','13987596967','周磊的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024029','teacher29','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'吴洋','male','数据科学系',NULL,'副教授','teacher29@test.com','13990699070','吴洋的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024030','teacher30','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'张伟','male','计算机系',NULL,'讲师','teacher30@test.com','13959424910','张伟的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('U1734018715169729','sgd','$2a$10$wXu30YONzJoc7E6FMvlvXeg8vKvI1AYrhR0eSL2gXX7cvg6c5VhuK','guest',NULL,NULL,0,'fg4s3','male','sddgd65',NULL,'fgb\'d','afss@qq.com','15376959676','','2024-12-12 15:51:55','active',NULL,NULL,NULL,'2024-12-12 15:51:55');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_student_progress`
--

DROP TABLE IF EXISTS `v_student_progress`;
/*!50001 DROP VIEW IF EXISTS `v_student_progress`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_student_progress` AS SELECT 
 1 AS `record_id`,
 1 AS `student_id`,
 1 AS `student_name`,
 1 AS `stage_name`,
 1 AS `stage_type`,
 1 AS `progress_status`,
 1 AS `submit_time`,
 1 AS `review_time`,
 1 AS `score`,
 1 AS `reviewer_name`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `v_student_progress`
--

/*!50001 DROP VIEW IF EXISTS `v_student_progress`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_student_progress` AS select `pr`.`id` AS `record_id`,`s`.`student_id` AS `student_id`,`s`.`name` AS `student_name`,`ps`.`name` AS `stage_name`,`ps`.`type` AS `stage_type`,`pr`.`status` AS `progress_status`,`pr`.`submit_time` AS `submit_time`,`pr`.`review_time` AS `review_time`,`pr`.`score` AS `score`,`u`.`username` AS `reviewer_name` from (((`progress_records` `pr` join `students` `s` on((`pr`.`student_id` = `s`.`student_id`))) join `progress_stages` `ps` on((`pr`.`stage_id` = `ps`.`id`))) left join `users` `u` on((`pr`.`reviewer_id` = `u`.`user_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-12-13 22:46:47
