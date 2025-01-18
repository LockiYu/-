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
-- Table structure for table `log_relations`
--

DROP TABLE IF EXISTS `log_relations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `log_relations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `log_id` int NOT NULL,
  `relation_type` enum('topic','selection','progress','user','message') NOT NULL,
  `relation_id` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `log_id` (`log_id`),
  CONSTRAINT `log_relations_ibfk_1` FOREIGN KEY (`log_id`) REFERENCES `system_logs` (`log_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `log_relations`
--

LOCK TABLES `log_relations` WRITE;
/*!40000 ALTER TABLE `log_relations` DISABLE KEYS */;
/*!40000 ALTER TABLE `log_relations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `progress`
--

DROP TABLE IF EXISTS `progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `progress` (
  `progress_id` int NOT NULL AUTO_INCREMENT,
  `selection_id` int DEFAULT NULL,
  `task_book_status` enum('pending','submitted','approved') DEFAULT 'pending',
  `literature_review_status` enum('pending','submitted','approved') DEFAULT 'pending',
  `proposal_status` enum('pending','submitted','approved') DEFAULT 'pending',
  `translation_status` enum('pending','submitted','approved') DEFAULT 'pending',
  `midterm_status` enum('pending','submitted','approved') DEFAULT 'pending',
  `thesis_status` enum('pending','submitted','approved') DEFAULT 'pending',
  `defense_status` enum('pending','passed','failed') DEFAULT 'pending',
  `peer_score` decimal(4,1) DEFAULT NULL,
  `peer_comments` text,
  `peer_review_status` enum('pending','reviewed') DEFAULT 'pending',
  `advisor_score` decimal(4,1) DEFAULT NULL,
  `advisor_comments` text,
  `advisor_review_status` enum('pending','reviewed') DEFAULT 'pending',
  `translation_comments` text,
  `translation_file` varchar(255) DEFAULT NULL,
  `deadline` timestamp NULL DEFAULT NULL,
  `reminder_status` enum('pending','sent') DEFAULT 'pending',
  `advisor_weight` decimal(3,2) DEFAULT '0.70',
  `peer_weight` decimal(3,2) DEFAULT '0.30',
  PRIMARY KEY (`progress_id`),
  KEY `idx_progress_status` (`selection_id`,`task_book_status`,`thesis_status`),
  CONSTRAINT `fk_progress_selection` FOREIGN KEY (`selection_id`) REFERENCES `selections` (`selection_id`) ON DELETE CASCADE,
  CONSTRAINT `progress_ibfk_1` FOREIGN KEY (`selection_id`) REFERENCES `selections` (`selection_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `progress`
--

LOCK TABLES `progress` WRITE;
/*!40000 ALTER TABLE `progress` DISABLE KEYS */;
INSERT INTO `progress` VALUES (1,1,'approved','approved','approved','approved','approved','submitted','pending',88.5,'创新点突出，部分内容需要完善','reviewed',90.5,'研究方向明确，论文结构完整','reviewed',NULL,NULL,NULL,'pending',0.70,0.30),(2,2,'approved','approved','approved','submitted','pending','pending','pending',NULL,NULL,'pending',NULL,NULL,'pending',NULL,NULL,NULL,'pending',0.70,0.30),(3,3,'submitted','pending','pending','pending','pending','pending','pending',NULL,NULL,'pending',NULL,NULL,'pending',NULL,NULL,NULL,'pending',0.70,0.30),(4,4,'approved','approved','submitted','pending','pending','pending','pending',NULL,NULL,'pending',NULL,NULL,'pending',NULL,NULL,NULL,'pending',0.70,0.30);
/*!40000 ALTER TABLE `progress` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Table structure for table `selections`
--

DROP TABLE IF EXISTS `selections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `selections` (
  `selection_id` int NOT NULL AUTO_INCREMENT,
  `topic_id` int DEFAULT NULL,
  `student_id` varchar(50) DEFAULT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `selection_start_time` timestamp NULL DEFAULT NULL,
  `selection_end_time` timestamp NULL DEFAULT NULL,
  `selection_reason` text,
  `review_comments` text,
  PRIMARY KEY (`selection_id`),
  UNIQUE KEY `unique_student_active_selection` (`student_id`,`status`),
  KEY `topic_id` (`topic_id`),
  KEY `idx_student_topic` (`student_id`,`topic_id`),
  KEY `idx_selection_time` (`selection_start_time`,`selection_end_time`),
  CONSTRAINT `selections_ibfk_1` FOREIGN KEY (`topic_id`) REFERENCES `topics` (`topic_id`),
  CONSTRAINT `selections_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `selections`
--

LOCK TABLES `selections` WRITE;
/*!40000 ALTER TABLE `selections` DISABLE KEYS */;
INSERT INTO `selections` VALUES (1,1,'S2024001','approved','2024-12-10 03:34:20',NULL,NULL,NULL,NULL),(2,2,'S2024002','approved','2024-12-10 03:34:20',NULL,NULL,NULL,NULL),(3,3,'S2024003','pending','2024-12-10 03:34:20',NULL,NULL,NULL,NULL),(4,4,'S2024004','approved','2024-12-10 03:34:20',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `selections` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_selection_approved` AFTER UPDATE ON `selections` FOR EACH ROW BEGIN
    IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
        INSERT INTO progress (selection_id) VALUES (NEW.selection_id);
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
INSERT INTO `supervisors` VALUES ('T2024001','未命名',NULL,NULL,NULL,'',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024002','王娜',NULL,NULL,NULL,'teacher2@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024003','刘秀英',NULL,NULL,NULL,'teacher3@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024004','陈敏',NULL,NULL,NULL,'teacher4@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024005','杨静',NULL,NULL,NULL,'teacher5@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024006','赵丽',NULL,NULL,NULL,'teacher6@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024007','黄强',NULL,NULL,NULL,'teacher7@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024008','周磊',NULL,NULL,NULL,'teacher8@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024009','吴洋',NULL,NULL,NULL,'teacher9@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024010','张伟',NULL,NULL,NULL,'teacher10@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024011','李芳',NULL,NULL,NULL,'teacher11@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024012','王娜',NULL,NULL,NULL,'teacher12@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024013','刘秀英',NULL,NULL,NULL,'teacher13@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024014','陈敏',NULL,NULL,NULL,'teacher14@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024015','杨静',NULL,NULL,NULL,'teacher15@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024016','赵丽',NULL,NULL,NULL,'teacher16@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024017','黄强',NULL,NULL,NULL,'teacher17@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024018','周磊',NULL,NULL,NULL,'teacher18@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024019','吴洋',NULL,NULL,NULL,'teacher19@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024020','张伟',NULL,NULL,NULL,'teacher20@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024021','李芳',NULL,NULL,NULL,'teacher21@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024022','王娜',NULL,NULL,NULL,'teacher22@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024023','刘秀英',NULL,NULL,NULL,'teacher23@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024024','陈敏',NULL,NULL,NULL,'teacher24@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024025','杨静',NULL,NULL,NULL,'teacher25@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024026','赵丽',NULL,NULL,NULL,'teacher26@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024027','黄强',NULL,NULL,NULL,'teacher27@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024028','周磊',NULL,NULL,NULL,'teacher28@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024029','吴洋',NULL,NULL,NULL,'teacher29@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08'),('T2024030','张伟',NULL,NULL,NULL,'teacher30@test.com',NULL,8,'2024-12-11 14:37:08','2024-12-11 14:37:08');
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
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_logs`
--

LOCK TABLES `system_logs` WRITE;
/*!40000 ALTER TABLE `system_logs` DISABLE KEYS */;
INSERT INTO `system_logs` VALUES (1,'SA2024001','login','192.168.1.100','用户登录','2024-12-10 03:49:23'),(2,'T2024001','login','192.168.1.101','用户登录','2024-12-10 03:49:23'),(3,'S2024001','login','192.168.1.102','用户登录','2024-12-10 03:49:23'),(4,'SA2024001','update_user','192.168.1.100','更新用户信息','2024-12-10 03:49:23'),(5,'SA2024001','system_config','192.168.1.100','修改系统配置','2024-12-10 03:49:23'),(19,'T2024001','login','192.168.1.90','用户登录','2024-12-10 03:55:12'),(20,'S2024001','login','192.168.1.197','用户登录','2024-12-10 03:55:12'),(21,'SA2024001','login','192.168.1.207','用户登录','2024-12-10 03:55:12'),(22,'SA2024001','system_operation','192.168.1.190','系统操作','2024-12-10 03:55:15'),(23,'T2024001','user.login.success','::1','用户 张老师 登录成功','2024-12-12 07:03:25'),(24,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-12 07:03:31'),(25,'SA2024001','stage.update','::1','更新阶段：1，名称：任务书阶段，状态：completed，权重：10%','2024-12-12 07:09:18'),(26,'SA2024001','stage.update','::1','更新阶段：1，名称：任务书阶段，状态：completed，权重：5%','2024-12-12 07:09:23'),(27,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 07:20:02'),(28,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 07:20:37'),(29,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 07:22:27'),(30,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 07:23:30'),(31,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 07:23:56'),(32,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 07:24:07'),(33,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 07:24:19'),(34,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 07:26:22'),(35,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 07:27:18'),(36,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-12 07:28:59'),(37,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-12 07:34:18'),(38,'G9055083583','user.register','::1','用户注册：dfad，角色：guest','2024-12-12 07:37:35'),(39,'G9204049729','user.register','::1','用户注册：asda，角色：guest','2024-12-12 07:40:04'),(40,'G9319052297','user.register','::1','用户注册：ads，角色：guest','2024-12-12 07:41:59'),(41,'G9467326781','user.register','::1','用户注册：asdfgsh，角色：guest','2024-12-12 07:44:27'),(42,'G9876306369','user.register','::1','用户 123456 注册成功','2024-12-12 07:51:16'),(43,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-12 07:51:26'),(44,'SA2024001','user.profile.update','::1','{\"message\":\"用户 刘超管 更新了个人信息\",\"changes\":{\"name\":\"姓名: undefined -> 刘超刘\",\"gender\":\"性别: undefined -> male\",\"department\":\"部门: undefined -> \",\"major\":null,\"title\":\"职称: undefined -> \",\"email\":\"邮箱: undefined -> 2915399378@qq.com\",\"phone\":\"电话: undefined -> 15376959676\"}}','2024-12-12 08:00:54'),(45,'SA2024001','user.password.change','::1','{\"message\":\"用户 刘超管 修改了密码\",\"timestamp\":\"2024-12-12T08:02:57.030Z\"}','2024-12-12 08:02:57'),(46,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-12 08:03:02'),(47,'SA2024001','user.password.change','::1','{\"message\":\"用户 刘超管 修改了密码\",\"timestamp\":\"2024-12-12T08:03:13.681Z\"}','2024-12-12 08:03:13'),(48,'SA2024001','user.login.success','::1','用户 刘超管 登录成功','2024-12-12 08:03:18'),(49,'SA2024001','stage.list','::1','查询阶段列表','2024-12-12 08:03:54'),(50,'SA2024001','system.database.backup','::1','{\"message\":\"数据库备份完成\",\"filename\":\"backup-2024-12-12T08-24-28-130Z.sql\",\"timestamp\":\"2024-12-12T08:24:28.627Z\"}','2024-12-12 08:24:28'),(51,'SA2024001','system.database.backup','::1','{\"message\":\"数据库备份完成\",\"filename\":\"backup-2024-12-12T08-27-18-965Z.sql\",\"timestamp\":\"2024-12-12T08:27:19.157Z\"}','2024-12-12 08:27:19'),(52,'SA2024001','system.database.backup','::1','{\"message\":\"数据库备份完成\",\"filename\":\"backup-2024-12-12T09-08-15-411Z.sql\",\"timestamp\":\"2024-12-12T09:08:15.655Z\"}','2024-12-12 09:08:15'),(53,'SA2024001','system.database.backup','::1','{\"message\":\"数据库备份成功\",\"filename\":\"backup-2024-12-12T13-42-21.sql\",\"path\":\"backups\\\\backup-2024-12-12T13-42-21.sql\",\"timestamp\":\"2024-12-12T13:42:21.721Z\"}','2024-12-12 13:42:21'),(54,'SA2024001','system.database.restore','::1','{\"message\":\"数据库恢复完成\",\"filename\":\"backup-2024-12-12T13-42-21.sql\",\"newDbName\":\"test1\",\"backupPath\":\"D:\\\\VSCODE\\\\Graduation Design Management System\\\\backend\\\\backups\\\\backup-2024-12-12T13-42-21.sql\",\"originalDb\":\"graduation_management\",\"timestamp\":\"2024-12-12T13:49:11.399Z\"}','2024-12-12 13:49:11'),(55,'SA2024001','system.database.backup','::1','{\"message\":\"数据库备份成功\",\"filename\":\"backup-2024-12-12T14-01-55.sql\",\"path\":\"backups\\\\backup-2024-12-12T14-01-55.sql\",\"timestamp\":\"2024-12-12T14:01:55.518Z\"}','2024-12-12 14:01:55'),(56,'SA2024001','system.database.backup','::1','{\"message\":\"数据库备份成功\",\"filename\":\"backup-2024-12-12T14-22-15.sql\",\"path\":\"backups\\\\backup-2024-12-12T14-22-15.sql\",\"timestamp\":\"2024-12-12T14:22:16.217Z\"}','2024-12-12 14:22:16'),(57,'SA2024001','system.database.backup','::1','{\"message\":\"数据库备份成功\",\"filename\":\"backup-2024-12-12T14-33-54.sql\",\"path\":\"backups\\\\backup-2024-12-12T14-33-54.sql\",\"timestamp\":\"2024-12-12T14:33:54.855Z\"}','2024-12-12 14:33:54'),(58,'SA2024001','system.database.backup','::1','{\"message\":\"数据库备份成功\",\"filename\":\"backup-2024-12-12T14-36-04.sql\",\"path\":\"backups\\\\backup-2024-12-12T14-36-04.sql\",\"timestamp\":\"2024-12-12T14:36:05.104Z\"}','2024-12-12 14:36:05');
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
-- Table structure for table `teachers`
--

DROP TABLE IF EXISTS `teachers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teachers` (
  `teacher_id` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `gender` enum('男','女') DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `education` varchar(50) DEFAULT NULL,
  `title` varchar(50) DEFAULT NULL,
  `research_direction` text,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`teacher_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teachers`
--

LOCK TABLES `teachers` WRITE;
/*!40000 ALTER TABLE `teachers` DISABLE KEYS */;
INSERT INTO `teachers` VALUES ('T2024001','张三','男','1980-05-15','博士','教授','人工智能,机器学习','13800138001','zhang@example.com'),('T2024002','李四','女','1985-03-20','博士','副教授','数据挖掘,深度学习','13800138002','li@example.com'),('T2024003','王五','男','1975-11-30','博士','教授','计算机视觉,模式识别','13800138003','wang@example.com'),('T2024004','赵六','女','1982-07-25','博士','副教授','自然语言处理','13800138004','zhao@example.com');
/*!40000 ALTER TABLE `teachers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `topics`
--

DROP TABLE IF EXISTS `topics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `topics` (
  `topic_id` int NOT NULL AUTO_INCREMENT,
  `topic_name` varchar(200) NOT NULL,
  `topic_type` varchar(50) DEFAULT NULL,
  `source` varchar(100) DEFAULT NULL,
  `teacher_id` varchar(50) DEFAULT NULL,
  `description` text,
  `major_requirement` text,
  `student_requirement` text,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`topic_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `topics`
--

LOCK TABLES `topics` WRITE;
/*!40000 ALTER TABLE `topics` DISABLE KEYS */;
INSERT INTO `topics` VALUES (1,'基于深度学习的图像识别系统','理论研究','教师科研','T2024001','运用深度学习技术实现图像识别系统','计算机科学与技术,人工智能','熟悉Python,具有深度学习基础','approved','2024-12-10 03:34:14'),(2,'智能校园APP设计与实现','工程实践','实际应用','T2024002','设计并实现一个智能校园APP','软件工程','熟悉移动开发,具有前端开发经验','approved','2024-12-10 03:34:14'),(3,'基于区块链的学位证书认证系统','创新研究','横向课题','T2024003','利用区块链技术实现学位证书认证','计算机科学与技术','了解区块链技术,熟悉智能合约开发','pending','2024-12-10 03:34:14'),(4,'自然语言处理在线教育平台','工程实践','教师科研','T2024004','开发一个基于NLP的在线教育平台','软件工程,人工智能','熟悉Python,了解NLP技术','approved','2024-12-10 03:34:14');
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
INSERT INTO `users` VALUES ('A2024001','王管理','$2a$10$udP7JcUSRnL0/Hyy6L4SK.s9XKaP.RRGAbWfVoN.FbIK6Y24fD1rW','admin',NULL,NULL,10,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-12 03:49:33','active','2024-12-12 03:49:33','::1',NULL,'2024-12-10 13:37:45'),('A2024002','manager2','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','admin',NULL,NULL,0,'王娜','male','信息安全系',NULL,'部门主管','manager2@test.com','13931493736','王娜的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('A2024003','manager3','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','admin',NULL,NULL,0,'刘秀英','male','人工智能系',NULL,'部门主管','manager3@test.com','13976099696','刘秀英的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('A2024004','manager4','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','admin',NULL,NULL,0,'陈敏','female','数据科学系',NULL,'部门主管','manager4@test.com','13927723187','陈敏的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('A2024005','manager5','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','admin',NULL,NULL,0,'杨静','male','计算机系',NULL,'部门主管','manager5@test.com','13988752689','杨静的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('A2024006','manager6','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','admin',NULL,NULL,0,'赵丽','male','软件工程系',NULL,'部门主管','manager6@test.com','13944299868','赵丽的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('A2024007','manager7','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','admin',NULL,NULL,0,'黄强','female','信息安全系',NULL,'部门主管','manager7@test.com','13964754602','黄强的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('A2024008','manager8','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','admin',NULL,NULL,0,'周磊','male','人工智能系',NULL,'部门主管','manager8@test.com','13959697401','周磊的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('G2024001','guest1','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','guest',NULL,NULL,0,'访客1','female','外部单位',NULL,NULL,'guest1@test.com','13930565037','访客1的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('G2024002','guest2','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','guest',NULL,NULL,0,'访客2','male','外部单位',NULL,NULL,'guest2@test.com','13914182137','访客2的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('G2024003','guest3','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','guest',NULL,NULL,0,'访客3','male','外部单位',NULL,NULL,'guest3@test.com','13931217073','访客3的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('G2024004','guest4','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','guest',NULL,NULL,0,'访客4','male','外部单位',NULL,NULL,'guest4@test.com','13926175341','访客4的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('G2024005','guest5','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','guest',NULL,NULL,0,'访客5','male','外部单位',NULL,NULL,'guest5@test.com','13941162761','访客5的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('G2024006','guest6','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','guest',NULL,NULL,0,'访客6','female','外部单位',NULL,NULL,'guest6@test.com','13907269863','访客6的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('G2024007','guest7','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','guest',NULL,NULL,0,'访客7','female','外部单位',NULL,NULL,'guest7@test.com','13970249980','访客7的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('G2024008','guest8','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','guest',NULL,NULL,0,'访客8','male','外部单位',NULL,NULL,'guest8@test.com','13942807023','访客8的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('G2024009','guest9','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','guest',NULL,NULL,0,'访客9','male','外部单位',NULL,NULL,'guest9@test.com','13996662608','访客9的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('G2024010','guest10','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','guest',NULL,NULL,0,'访客10','female','外部单位',NULL,NULL,'guest10@test.com','13932000979','访客10的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('G2024081','Loki','$2a$10$4PClkmBkJ3nnfwnj.wnXzOMg0..p7Z/5prVpZQTihXk4aFIIMB61S','guest',NULL,NULL,2,'By','male','',NULL,'','2915399378@qq.com','15049051686','','2024-12-10 14:35:57','active','2024-12-10 14:35:57','::1',NULL,'2024-12-10 13:40:17'),('G2024315','test','$2a$10$LylUmxmY6CW45pDw6zIUgOZfV218CNr3/JpWhP5m1OK2qKgi4OObq','guest',NULL,NULL,0,'aufhsgjk','male','',NULL,'','4561237894@qq.com','15376959676','','2024-12-12 07:31:09','active',NULL,NULL,NULL,'2024-12-12 07:31:09'),('G9055083583','dfad','$2a$10$1AolUv903uH6lVL1.69ZauL4i9LypdHCZ9MuRkBWyibjBFDlc1Fne','guest',NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-12 07:37:35','active',NULL,NULL,NULL,'2024-12-12 07:37:35'),('G9204049729','asda','$2a$10$j7BxN2MZz5v5PF5cJSw6R.9hi0amWPosckbx9FxtizYF3lj.eQLG2','guest',NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-12 07:40:04','active',NULL,NULL,NULL,'2024-12-12 07:40:04'),('G9319052297','ads','$2a$10$ZQBoh2/xgwvliRTUA7J7J.AZCRwX1ZRCqF57r6i/rdJBcAx9NyLoW','guest',NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-12 07:41:59','active',NULL,NULL,NULL,'2024-12-12 07:41:59'),('G9467326781','asdfgsh','$2a$10$edID/sPnm9ff6gzPbsWF0ucAsIs64WP9yddfKNMMDR6rLPdHTh24i','guest',NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-12 07:44:27','active',NULL,NULL,NULL,'2024-12-12 07:44:27'),('G9876306369','123456','$2a$10$hxPUfERRqcgzyibLiHNIr.gOKFk0DRKUc85JYqxNMV/KI4fltqTbK','guest',NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-12 07:51:16','active',NULL,NULL,NULL,'2024-12-12 07:51:16'),('S2024001','李同学','$2a$10$udP7JcUSRnL0/Hyy6L4SK.s9XKaP.RRGAbWfVoN.FbIK6Y24fD1rW','student',NULL,'S2024001',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-10 04:13:31','active',NULL,NULL,NULL,'2024-12-10 13:37:45'),('S2024002','student2','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'王娜','female','信息安全系','信息安全',NULL,'student2@test.com','13976328835','王娜的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024003','student3','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'刘秀英','female','人工智能系','人工智能',NULL,'student3@test.com','13958890202','刘秀英的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024004','student4','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'陈敏','female','数据科学系','数据科学',NULL,'student4@test.com','13948050005','陈敏的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024005','student5','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'杨静','female','计算机系','计算机科学与技术',NULL,'student5@test.com','13983854719','杨静的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024006','student6','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'赵丽','female','软件工程系','软件工程',NULL,'student6@test.com','13944296979','赵丽的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024007','student7','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'黄强','male','信息安全系','信息安全',NULL,'student7@test.com','13983364204','黄强的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024008','student8','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'周磊','male','人工智能系','人工智能',NULL,'student8@test.com','13942134133','周磊的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024009','student9','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'吴洋','male','数据科学系','数据科学',NULL,'student9@test.com','13956905893','吴洋的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024010','student10','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'张伟','male','计算机系','计算机科学与技术',NULL,'student10@test.com','13902463723','张伟的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024011','student11','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'李芳','male','软件工程系','软件工程',NULL,'student11@test.com','13998373545','李芳的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024012','student12','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'王娜','male','信息安全系','信息安全',NULL,'student12@test.com','13983702334','王娜的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024013','student13','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'刘秀英','female','人工智能系','人工智能',NULL,'student13@test.com','13973974073','刘秀英的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024014','student14','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'陈敏','female','数据科学系','数据科学',NULL,'student14@test.com','13959634221','陈敏的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024015','student15','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'杨静','female','计算机系','计算机科学与技术',NULL,'student15@test.com','13993053630','杨静的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024016','student16','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'赵丽','female','软件工程系','软件工程',NULL,'student16@test.com','13996796899','赵丽的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024017','student17','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'黄强','male','信息安全系','信息安全',NULL,'student17@test.com','13944954457','黄强的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024018','student18','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'周磊','male','人工智能系','人工智能',NULL,'student18@test.com','13905645545','周磊的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024019','student19','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'吴洋','male','数据科学系','数据科学',NULL,'student19@test.com','13948485143','吴洋的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024020','student20','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'张伟','female','计算机系','计算机科学与技术',NULL,'student20@test.com','13993594311','张伟的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024021','student21','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'李芳','female','软件工程系','软件工程',NULL,'student21@test.com','13911562091','李芳的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024022','student22','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'王娜','female','信息安全系','信息安全',NULL,'student22@test.com','13939407744','王娜的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024023','student23','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'刘秀英','male','人工智能系','人工智能',NULL,'student23@test.com','13963784849','刘秀英的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024024','student24','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'陈敏','female','数据科学系','数据科学',NULL,'student24@test.com','13959844162','陈敏的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024025','student25','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'杨静','female','计算机系','计算机科学与技术',NULL,'student25@test.com','13929144272','杨静的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024026','student26','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'赵丽','male','软件工程系','软件工程',NULL,'student26@test.com','13971386815','赵丽的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024027','student27','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'黄强','male','信息安全系','信息安全',NULL,'student27@test.com','13951589892','黄强的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024028','student28','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'周磊','female','人工智能系','人工智能',NULL,'student28@test.com','13975504506','周磊的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024029','student29','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'吴洋','male','数据科学系','数据科学',NULL,'student29@test.com','13979972800','吴洋的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024030','student30','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'张伟','male','计算机系','计算机科学与技术',NULL,'student30@test.com','13948596540','张伟的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024031','student31','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'李芳','female','软件工程系','软件工程',NULL,'student31@test.com','13917614321','李芳的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024032','student32','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'王娜','male','信息安全系','信息安全',NULL,'student32@test.com','13914491104','王娜的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024033','student33','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'刘秀英','male','人工智能系','人工智能',NULL,'student33@test.com','13965474152','刘秀英的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024034','student34','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'陈敏','female','数据科学系','数据科学',NULL,'student34@test.com','13966140142','陈敏的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024035','student35','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'杨静','male','计算机系','计算机科学与技术',NULL,'student35@test.com','13960808455','杨静的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024036','student36','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'赵丽','female','软件工程系','软件工程',NULL,'student36@test.com','13917288099','赵丽的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024037','student37','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'黄强','female','信息安全系','信息安全',NULL,'student37@test.com','13981273910','黄强的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024038','student38','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'周磊','female','人工智能系','人工智能',NULL,'student38@test.com','13970686151','周磊的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024039','student39','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'吴洋','male','数据科学系','数据科学',NULL,'student39@test.com','13964285381','吴洋的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024040','student40','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'张伟','female','计算机系','计算机科学与技术',NULL,'student40@test.com','13918007465','张伟的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024041','student41','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'李芳','female','软件工程系','软件工程',NULL,'student41@test.com','13974376412','李芳的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024042','student42','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'王娜','male','信息安全系','信息安全',NULL,'student42@test.com','13916677681','王娜的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024043','student43','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'刘秀英','male','人工智能系','人工智能',NULL,'student43@test.com','13906944071','刘秀英的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024044','student44','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'陈敏','female','数据科学系','数据科学',NULL,'student44@test.com','13938458530','陈敏的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024045','student45','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'杨静','male','计算机系','计算机科学与技术',NULL,'student45@test.com','13985017311','杨静的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024046','student46','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'赵丽','female','软件工程系','软件工程',NULL,'student46@test.com','13927758226','赵丽的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024047','student47','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'黄强','female','信息安全系','信息安全',NULL,'student47@test.com','13953921077','黄强的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024048','student48','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'周磊','male','人工智能系','人工智能',NULL,'student48@test.com','13950837754','周磊的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024049','student49','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'吴洋','female','数据科学系','数据科学',NULL,'student49@test.com','13957784629','吴洋的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('S2024050','student50','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','student',NULL,NULL,0,'张伟','male','计算机系','计算机科学与技术',NULL,'student50@test.com','13909649506','张伟的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('SA2024001','刘超管','$2a$10$jxlBlkhXxhUB4kdT4X8QKuzl/Tcxwm2P258aLl8S0jKvc./pK258W','superadmin',NULL,NULL,25,'刘超刘','male','',NULL,'','2915399378@qq.com','15376959676','','2024-12-12 08:03:18','active','2024-12-12 08:03:18','::1',NULL,'2024-12-10 13:37:45'),('SA2024002','admin2','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','superadmin',NULL,NULL,0,'管理员2','female','系统部',NULL,'高级管理员','admin2@test.com','13933587790','管理员2的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024001','张老师','$2a$10$udP7JcUSRnL0/Hyy6L4SK.s9XKaP.RRGAbWfVoN.FbIK6Y24fD1rW','teacher','T2024001',NULL,2,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-12 07:03:25','active','2024-12-12 07:03:25','::1',NULL,'2024-12-10 13:37:45'),('T2024002','teacher2','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'王娜','female','信息安全系',NULL,'讲师','teacher2@test.com','13945578883','王娜的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024003','teacher3','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'刘秀英','male','人工智能系',NULL,'助教','teacher3@test.com','13960497361','刘秀英的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024004','teacher4','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'陈敏','male','数据科学系',NULL,'教授','teacher4@test.com','13906698383','陈敏的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024005','teacher5','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'杨静','male','计算机系',NULL,'副教授','teacher5@test.com','13950317645','杨静的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024006','teacher6','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'赵丽','female','软件工程系',NULL,'讲师','teacher6@test.com','13909991133','赵丽的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024007','teacher7','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'黄强','female','信息安全系',NULL,'助教','teacher7@test.com','13954034024','黄强的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024008','teacher8','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'周磊','female','人工智能系',NULL,'教授','teacher8@test.com','13968727938','周磊的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024009','teacher9','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'吴洋','female','数据科学系',NULL,'副教授','teacher9@test.com','13959359102','吴洋的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024010','teacher10','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'张伟','female','计算机系',NULL,'讲师','teacher10@test.com','13919314521','张伟的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024011','teacher11','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'李芳','male','软件工程系',NULL,'助教','teacher11@test.com','13950372733','李芳的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024012','teacher12','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'王娜','male','信息安全系',NULL,'教授','teacher12@test.com','13960763334','王娜的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024013','teacher13','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'刘秀英','female','人工智能系',NULL,'副教授','teacher13@test.com','13904979334','刘秀英的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024014','teacher14','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'陈敏','male','数据科学系',NULL,'讲师','teacher14@test.com','13979276730','陈敏的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024015','teacher15','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'杨静','female','计算机系',NULL,'助教','teacher15@test.com','13947575303','杨静的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024016','teacher16','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'赵丽','female','软件工程系',NULL,'教授','teacher16@test.com','13961704321','赵丽的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024017','teacher17','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'黄强','female','信息安全系',NULL,'副教授','teacher17@test.com','13945520745','黄强的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024018','teacher18','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'周磊','female','人工智能系',NULL,'讲师','teacher18@test.com','13907324923','周磊的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024019','teacher19','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'吴洋','male','数据科学系',NULL,'助教','teacher19@test.com','13900845702','吴洋的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024020','teacher20','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'张伟','female','计算机系',NULL,'教授','teacher20@test.com','13926071573','张伟的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024021','teacher21','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'李芳','female','软件工程系',NULL,'副教授','teacher21@test.com','13942579785','李芳的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024022','teacher22','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'王娜','female','信息安全系',NULL,'讲师','teacher22@test.com','13920071118','王娜的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024023','teacher23','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'刘秀英','male','人工智能系',NULL,'助教','teacher23@test.com','13975419871','刘秀英的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024024','teacher24','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'陈敏','male','数据科学系',NULL,'教授','teacher24@test.com','13931002450','陈敏的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024025','teacher25','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'杨静','female','计算机系',NULL,'副教授','teacher25@test.com','13939213777','杨静的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024026','teacher26','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'赵丽','male','软件工程系',NULL,'讲师','teacher26@test.com','13931380423','赵丽的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024027','teacher27','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'黄强','female','信息安全系',NULL,'助教','teacher27@test.com','13979349941','黄强的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024028','teacher28','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'周磊','female','人工智能系',NULL,'教授','teacher28@test.com','13987596967','周磊的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024029','teacher29','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'吴洋','male','数据科学系',NULL,'副教授','teacher29@test.com','13990699070','吴洋的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16'),('T2024030','teacher30','$2a$10$CZbv5Wo0tvEWVf6XGFgju.MVl0cebBK/JAHNfdzUV5SmX/nIiRjUa','teacher',NULL,NULL,0,'张伟','male','计算机系',NULL,'讲师','teacher30@test.com','13959424910','张伟的个人简介','2024-12-10 13:54:16','active',NULL,NULL,NULL,'2024-12-10 13:54:16');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_selection_status`
--

DROP TABLE IF EXISTS `v_selection_status`;
/*!50001 DROP VIEW IF EXISTS `v_selection_status`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_selection_status` AS SELECT 
 1 AS `selection_id`,
 1 AS `topic_id`,
 1 AS `topic_name`,
 1 AS `student_id`,
 1 AS `student_name`,
 1 AS `selection_status`,
 1 AS `task_book_status`,
 1 AS `thesis_status`,
 1 AS `defense_status`*/;
SET character_set_client = @saved_cs_client;

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
-- Temporary view structure for view `v_teacher_workload`
--

DROP TABLE IF EXISTS `v_teacher_workload`;
/*!50001 DROP VIEW IF EXISTS `v_teacher_workload`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_teacher_workload` AS SELECT 
 1 AS `teacher_id`,
 1 AS `teacher_name`,
 1 AS `total_topics`,
 1 AS `guided_students`,
 1 AS `completed_projects`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `v_selection_status`
--

/*!50001 DROP VIEW IF EXISTS `v_selection_status`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_selection_status` AS select `s`.`selection_id` AS `selection_id`,`s`.`topic_id` AS `topic_id`,`t`.`topic_name` AS `topic_name`,`s`.`student_id` AS `student_id`,`st`.`name` AS `student_name`,`s`.`status` AS `selection_status`,`p`.`task_book_status` AS `task_book_status`,`p`.`thesis_status` AS `thesis_status`,`p`.`defense_status` AS `defense_status` from (((`selections` `s` left join `topics` `t` on((`s`.`topic_id` = `t`.`topic_id`))) left join `students` `st` on((`s`.`student_id` = `st`.`student_id`))) left join `progress` `p` on((`s`.`selection_id` = `p`.`selection_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

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

--
-- Final view structure for view `v_teacher_workload`
--

/*!50001 DROP VIEW IF EXISTS `v_teacher_workload`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_teacher_workload` AS select `t`.`teacher_id` AS `teacher_id`,`t`.`name` AS `teacher_name`,count(distinct `top`.`topic_id`) AS `total_topics`,count(distinct `s`.`selection_id`) AS `guided_students`,count(distinct (case when (`p`.`defense_status` = 'passed') then `s`.`selection_id` end)) AS `completed_projects` from (((`teachers` `t` left join `topics` `top` on((`t`.`teacher_id` = `top`.`teacher_id`))) left join `selections` `s` on((`top`.`topic_id` = `s`.`topic_id`))) left join `progress` `p` on((`s`.`selection_id` = `p`.`selection_id`))) group by `t`.`teacher_id` */;
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

-- Dump completed on 2024-12-12 22:36:05
