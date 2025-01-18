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
-- Table structure for table `literature_reviews`
--

DROP TABLE IF EXISTS `literature_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `literature_reviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(50) NOT NULL,
  `teacher_id` varchar(20) NOT NULL,
  `file_url` varchar(255) DEFAULT NULL COMMENT '文献综述文件路径',
  `status` enum('not_started','in_progress','reviewing','revision_needed','completed') DEFAULT 'not_started',
  `submit_time` datetime DEFAULT NULL COMMENT '提交时间',
  `review_time` datetime DEFAULT NULL COMMENT '评阅时间',
  `content_score` decimal(5,2) DEFAULT NULL COMMENT '内容完整性分数',
  `analysis_score` decimal(5,2) DEFAULT NULL COMMENT '分析深度分数',
  `structure_score` decimal(5,2) DEFAULT NULL COMMENT '结构逻辑分数',
  `writing_score` decimal(5,2) DEFAULT NULL COMMENT '写作规范分数',
  `total_score` decimal(5,2) DEFAULT NULL COMMENT '总分',
  `content_comment` text COMMENT '内容评价',
  `improvement_suggestions` text COMMENT '改进建议',
  `general_comment` text COMMENT '总体评语',
  `version` int DEFAULT '1' COMMENT '提交版本',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_student_version` (`student_id`,`version`),
  KEY `idx_teacher` (`teacher_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_literature_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_literature_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='文献综述评阅表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `literature_reviews`
--

LOCK TABLES `literature_reviews` WRITE;
/*!40000 ALTER TABLE `literature_reviews` DISABLE KEYS */;
INSERT INTO `literature_reviews` VALUES (2,'S2024105','T2024017','uploads\\literature\\S2024105_1734364294623.pdf','completed','2024-12-16 23:51:34','2024-12-16 23:35:56',90.00,92.00,90.00,95.00,91.75,'一般','下次努力','善！',1,'2024-12-16 22:17:52','2024-12-29 20:57:38');
/*!40000 ALTER TABLE `literature_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `midterm_reports`
--

DROP TABLE IF EXISTS `midterm_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `midterm_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(50) NOT NULL,
  `file_url` varchar(255) DEFAULT NULL COMMENT '文件URL',
  `file_size` bigint DEFAULT NULL COMMENT '文件大小(字节)',
  `submit_time` datetime DEFAULT NULL COMMENT '提交时间',
  `version` int NOT NULL DEFAULT '1' COMMENT '版本号',
  `research_progress_score` decimal(5,2) DEFAULT NULL COMMENT '研究进度分数',
  `technical_ability_score` decimal(5,2) DEFAULT NULL COMMENT '技术掌握分数',
  `work_attitude_score` decimal(5,2) DEFAULT NULL COMMENT '工作态度分数',
  `total_score` decimal(5,2) DEFAULT NULL COMMENT '总分',
  `progress_comment` text COMMENT '进度评语',
  `technical_comment` text COMMENT '技术评语',
  `attitude_comment` text COMMENT '态度评语',
  `improvement_suggestions` text COMMENT '改进建议',
  `status` enum('pending','reviewing','revision_needed','completed') DEFAULT 'pending',
  `teacher_id` varchar(20) DEFAULT NULL COMMENT '评审教师ID',
  `review_time` datetime DEFAULT NULL COMMENT '评审时间',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_student_status` (`student_id`,`status`),
  KEY `idx_teacher_id` (`teacher_id`),
  CONSTRAINT `midterm_reports_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE,
  CONSTRAINT `midterm_reports_ibfk_2` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='中期报告表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `midterm_reports`
--

LOCK TABLES `midterm_reports` WRITE;
/*!40000 ALTER TABLE `midterm_reports` DISABLE KEYS */;
INSERT INTO `midterm_reports` VALUES (3,'S2024105','uploads/midterm/S2024105_midterm.docx',12262,'2024-12-19 11:02:01',3,85.00,87.00,94.00,88.67,'akshbfskijg','fsghlidgnsliek','dfkgisbgiej','','completed','T2024017','2024-12-28 18:30:35','2024-12-19 10:56:15','2024-12-28 18:30:35');
/*!40000 ALTER TABLE `midterm_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `next_stage_queue`
--

DROP TABLE IF EXISTS `next_stage_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `next_stage_queue` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(50) NOT NULL,
  `current_stage_type` varchar(50) NOT NULL,
  `next_stage_type` varchar(50) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `processed` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `processed` (`processed`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `next_stage_queue`
--

LOCK TABLES `next_stage_queue` WRITE;
/*!40000 ALTER TABLE `next_stage_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `next_stage_queue` ENABLE KEYS */;
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
  `stage_type` enum('task_book','literature','proposal','translation','midterm','thesis_submit','advisor_review','peer_review','defense') NOT NULL COMMENT '阶段类型',
  `status` enum('not_started','in_progress','reviewing','revision_needed','completed','overdue') DEFAULT 'not_started' COMMENT '状态',
  `file_url` varchar(255) DEFAULT NULL COMMENT '提交的文件URL',
  `teacher_comment` text COMMENT '教师评语',
  `score` decimal(5,2) DEFAULT NULL COMMENT '分数',
  `submit_time` datetime DEFAULT NULL COMMENT '提交时间',
  `review_time` datetime DEFAULT NULL COMMENT '审核时间',
  `deadline` datetime DEFAULT NULL COMMENT '截止时间',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_student_stage` (`student_id`,`stage_type`),
  CONSTRAINT `progress_records_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4406 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生进度记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `progress_records`
--

LOCK TABLES `progress_records` WRITE;
/*!40000 ALTER TABLE `progress_records` DISABLE KEYS */;
INSERT INTO `progress_records` VALUES (21,'S2024104','task_book','completed','files/S2024104/task_book.pdf','123456',100.00,'2024-03-01 10:00:00','2024-12-16 18:59:37','2024-03-05 23:59:59','2024-12-16 16:10:28','2024-12-16 18:59:37'),(22,'S2024104','literature','completed','files/S2024104/literature.pdf','文献综述全面,分析到位',88.00,'2024-03-10 10:00:00','2024-03-11 14:00:00','2024-03-15 23:59:59','2024-12-16 16:10:28','2024-12-16 16:10:28'),(23,'S2024104','proposal','completed','files/S2024104/proposal.pdf','开题报告思路清晰,可行性强',90.00,'2024-03-20 10:00:00','2024-03-21 14:00:00','2024-03-25 23:59:59','2024-12-16 16:10:28','2024-12-16 16:10:28'),(24,'S2024104','translation','in_progress','files/S2024104/translation.pdf',NULL,NULL,'2024-04-01 10:00:00',NULL,'2024-04-05 23:59:59','2024-12-16 16:10:28','2024-12-16 16:10:28'),(25,'S2024105','task_book','completed',NULL,'123456',100.00,NULL,'2024-12-16 21:07:14','2024-03-20 23:59:59','2024-12-16 16:26:49','2024-12-16 21:07:14'),(26,'S2024105','literature','completed','uploads\\literature\\S2024105_1734364294623.pdf','善！',91.75,'2024-12-16 23:51:34','2024-12-16 23:51:42',NULL,'2024-12-16 21:07:59','2024-12-16 23:51:42'),(40,'S2024105','proposal','completed','uploads/proposal/S2024105_1734525570922.pdf','dhgk',84.25,'2024-12-18 20:39:30','2024-12-18 22:07:06',NULL,'2024-12-16 23:26:19','2024-12-18 22:07:06'),(3948,'S2024105','translation','completed','uploads/translation/S2024105_translation_1734536498995.docx','fthydtkdmd',83.33,'2024-12-18 23:44:11','2024-12-19 10:13:41',NULL,'2024-12-18 21:32:49','2024-12-19 10:13:41'),(4371,'S2024105','midterm','completed','uploads/midterm/S2024105_midterm.docx','研究进度(85分)：akshbfskijg\n技术掌握(87分)：fsghlidgnsliek\n工作态度(94分)：dfkgisbgiej',88.67,'2024-12-19 11:02:01','2024-12-28 18:30:35',NULL,'2024-12-19 10:06:19','2024-12-28 20:09:27'),(4377,'S2024105','thesis_submit','completed','uploads/thesis_submit/S2024105_thesis_submit.docx','approved',100.00,'2024-12-28 23:07:26','2024-12-29 13:57:32',NULL,'2024-12-28 18:31:19','2024-12-29 14:01:47'),(4392,'S2024105','advisor_review','completed',NULL,'gdhfjgkhjhgdtxhck',75.75,NULL,'2024-12-29 20:38:18',NULL,'2024-12-29 12:06:51','2024-12-29 20:38:18'),(4395,'S2024105','peer_review','completed',NULL,'代发染色体答复看过，j\n\nsglnsjtgkstrj\n\n6451615sdkagusinhl',64.17,NULL,'2024-12-29 20:48:46',NULL,'2024-12-29 19:48:10','2024-12-29 20:48:46'),(4397,'S2024105','defense','in_progress',NULL,NULL,NULL,NULL,NULL,NULL,'2024-12-29 20:01:30','2024-12-29 20:01:30');
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_progress_record_insert` AFTER INSERT ON `progress_records` FOR EACH ROW BEGIN
    IF NEW.score IS NOT NULL THEN
        INSERT INTO student_stage_scores (
            student_id,
            task_book_score,
            literature_score,
            proposal_score,
            translation_score,
            midterm_score,
            thesis_submit_score,
            advisor_review_score,
            peer_review_score,
            defense_score
        )
        VALUES (
            NEW.student_id,
            IF(NEW.stage_type = 'task_book', NEW.score, NULL),
            IF(NEW.stage_type = 'literature', NEW.score, NULL),
            IF(NEW.stage_type = 'proposal', NEW.score, NULL),
            IF(NEW.stage_type = 'translation', NEW.score, NULL),
            IF(NEW.stage_type = 'midterm', NEW.score, NULL),
            IF(NEW.stage_type = 'thesis_submit', NEW.score, NULL),
            IF(NEW.stage_type = 'advisor_review', NEW.score, NULL),
            IF(NEW.stage_type = 'peer_review', NEW.score, NULL),
            IF(NEW.stage_type = 'defense', NEW.score, NULL)
        )
        ON DUPLICATE KEY UPDATE
            task_book_score = IF(NEW.stage_type = 'task_book', NEW.score, task_book_score),
            literature_score = IF(NEW.stage_type = 'literature', NEW.score, literature_score),
            proposal_score = IF(NEW.stage_type = 'proposal', NEW.score, proposal_score),
            translation_score = IF(NEW.stage_type = 'translation', NEW.score, translation_score),
            midterm_score = IF(NEW.stage_type = 'midterm', NEW.score, midterm_score),
            thesis_submit_score = IF(NEW.stage_type = 'thesis_submit', NEW.score, thesis_submit_score),
            advisor_review_score = IF(NEW.stage_type = 'advisor_review', NEW.score, advisor_review_score),
            peer_review_score = IF(NEW.stage_type = 'peer_review', NEW.score, peer_review_score),
            defense_score = IF(NEW.stage_type = 'defense', NEW.score, defense_score);
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `before_progress_update` BEFORE UPDATE ON `progress_records` FOR EACH ROW BEGIN
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        SET NEW.review_time = CURRENT_TIMESTAMP;
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
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        CASE NEW.stage_type
            WHEN 'task_book' THEN
                INSERT INTO progress_stage_queue (student_id, next_stage_type)
                VALUES (NEW.student_id, 'literature');
            WHEN 'literature' THEN
                INSERT INTO progress_stage_queue (student_id, next_stage_type)
                VALUES (NEW.student_id, 'proposal');
            WHEN 'proposal' THEN
                INSERT INTO progress_stage_queue (student_id, next_stage_type)
                VALUES (NEW.student_id, 'translation');
            WHEN 'translation' THEN
                INSERT INTO progress_stage_queue (student_id, next_stage_type)
                VALUES (NEW.student_id, 'midterm');
            WHEN 'midterm' THEN
                INSERT INTO progress_stage_queue (student_id, next_stage_type)
                VALUES (NEW.student_id, 'thesis_submit');
            WHEN 'thesis_submit' THEN
                INSERT INTO progress_stage_queue (student_id, next_stage_type)
                VALUES (NEW.student_id, 'advisor_review');
            WHEN 'advisor_review' THEN
                INSERT INTO progress_stage_queue (student_id, next_stage_type)
                VALUES (NEW.student_id, 'peer_review');
            WHEN 'peer_review' THEN
                INSERT INTO progress_stage_queue (student_id, next_stage_type)
                VALUES (NEW.student_id, 'defense');
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `update_stage_score` AFTER UPDATE ON `progress_records` FOR EACH ROW BEGIN
    IF NEW.score IS NOT NULL AND NEW.score != OLD.score THEN
        -- 先获取所有活跃阶段的权重
        WITH stage_weights AS (
            SELECT type, weight
            FROM progress_stages
            WHERE status = 'active'
        )
        -- 更新分数和计算总分
        UPDATE student_stage_scores ss
        SET
            -- 更新对应阶段分数
            task_book_score = IF(NEW.stage_type = 'task_book', NEW.score, ss.task_book_score),
            literature_score = IF(NEW.stage_type = 'literature', NEW.score, ss.literature_score),
            proposal_score = IF(NEW.stage_type = 'proposal', NEW.score, ss.proposal_score),
            translation_score = IF(NEW.stage_type = 'translation', NEW.score, ss.translation_score),
            midterm_score = IF(NEW.stage_type = 'midterm', NEW.score, ss.midterm_score),
            thesis_submit_score = IF(NEW.stage_type = 'thesis_submit', NEW.score, ss.thesis_submit_score),
            advisor_review_score = IF(NEW.stage_type = 'advisor_review', NEW.score, ss.advisor_review_score),
            peer_review_score = IF(NEW.stage_type = 'peer_review', NEW.score, ss.peer_review_score),
            defense_score = IF(NEW.stage_type = 'defense', NEW.score, ss.defense_score),

            -- 计算总加权分数
            total_weighted_score = (
                COALESCE(IF(NEW.stage_type = 'task_book', NEW.score, ss.task_book_score) *
                    (SELECT weight FROM stage_weights WHERE type = 'task_book'), 0) +
                COALESCE(IF(NEW.stage_type = 'literature', NEW.score, ss.literature_score) *
                    (SELECT weight FROM stage_weights WHERE type = 'literature'), 0) +
                COALESCE(IF(NEW.stage_type = 'proposal', NEW.score, ss.proposal_score) *
                    (SELECT weight FROM stage_weights WHERE type = 'proposal'), 0) +
                COALESCE(IF(NEW.stage_type = 'translation', NEW.score, ss.translation_score) *
                    (SELECT weight FROM stage_weights WHERE type = 'translation'), 0) +
                COALESCE(IF(NEW.stage_type = 'midterm', NEW.score, ss.midterm_score) *
                    (SELECT weight FROM stage_weights WHERE type = 'midterm'), 0) +
                COALESCE(IF(NEW.stage_type = 'thesis_submit', NEW.score, ss.thesis_submit_score) *
                    (SELECT weight FROM stage_weights WHERE type = 'thesis_submit'), 0) +
                COALESCE(IF(NEW.stage_type = 'advisor_review', NEW.score, ss.advisor_review_score) *
                    (SELECT weight FROM stage_weights WHERE type = 'advisor_review'), 0) +
                COALESCE(IF(NEW.stage_type = 'peer_review', NEW.score, ss.peer_review_score) *
                    (SELECT weight FROM stage_weights WHERE type = 'peer_review'), 0) +
                COALESCE(IF(NEW.stage_type = 'defense', NEW.score, ss.defense_score) *
                    (SELECT weight FROM stage_weights WHERE type = 'defense'), 0)
            ) / 100
        WHERE ss.student_id = NEW.student_id;

        -- 如果记录不存在则插入
        IF ROW_COUNT() = 0 THEN
            INSERT INTO student_stage_scores (
                student_id,
                task_book_score,
                literature_score,
                proposal_score,
                translation_score,
                midterm_score,
                thesis_submit_score,
                advisor_review_score,
                peer_review_score,
                defense_score,
                total_weighted_score
            )
            SELECT
                NEW.student_id,
                IF(NEW.stage_type = 'task_book', NEW.score, NULL),
                IF(NEW.stage_type = 'literature', NEW.score, NULL),
                IF(NEW.stage_type = 'proposal', NEW.score, NULL),
                IF(NEW.stage_type = 'translation', NEW.score, NULL),
                IF(NEW.stage_type = 'midterm', NEW.score, NULL),
                IF(NEW.stage_type = 'thesis_submit', NEW.score, NULL),
                IF(NEW.stage_type = 'advisor_review', NEW.score, NULL),
                IF(NEW.stage_type = 'peer_review', NEW.score, NULL),
                IF(NEW.stage_type = 'defense', NEW.score, NULL),
                (SELECT
                    COALESCE(
                        IF(NEW.stage_type = 'task_book', NEW.score, NULL) *
                        (SELECT weight FROM stage_weights WHERE type = 'task_book'), 0
                    )
                ) / 100;
        END IF;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `progress_stage_queue`
--

DROP TABLE IF EXISTS `progress_stage_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `progress_stage_queue` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(50) NOT NULL,
  `next_stage_type` enum('task_book','literature','proposal','translation','midterm','thesis_submit','advisor_review','peer_review','defense') NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `progress_stage_queue`
--

LOCK TABLES `progress_stage_queue` WRITE;
/*!40000 ALTER TABLE `progress_stage_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `progress_stage_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `progress_stages`
--

DROP TABLE IF EXISTS `progress_stages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `progress_stages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT '阶段名称',
  `type` enum('task_book','literature','proposal','translation','midterm','thesis_submit','advisor_review','peer_review','defense') NOT NULL COMMENT '阶段类型',
  `sequence` int NOT NULL COMMENT '阶段顺序',
  `required_files` tinyint(1) DEFAULT '1' COMMENT '是否需要提交文件',
  `requires_review` tinyint(1) DEFAULT '1' COMMENT '是否需要审核',
  `weight` decimal(5,2) NOT NULL DEFAULT '0.00' COMMENT '分数权重',
  `description` text COMMENT '阶段说明',
  `status` enum('active','inactive') DEFAULT 'active' COMMENT '阶段状态',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `type` (`type`),
  UNIQUE KEY `sequence` (`sequence`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='论文阶段定义表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `progress_stages`
--

LOCK TABLES `progress_stages` WRITE;
/*!40000 ALTER TABLE `progress_stages` DISABLE KEYS */;
INSERT INTO `progress_stages` VALUES (19,'任务书下达','task_book',1,1,1,0.05,'导师下达毕业设计任务书','active','2024-12-16 16:10:16','2024-12-16 16:10:16'),(20,'文献综述','literature',2,1,1,0.10,'完成文献阅读和综述','active','2024-12-16 16:10:16','2024-12-16 16:10:16'),(21,'开题报告','proposal',3,1,1,0.10,'完成开题报告和答辩','active','2024-12-16 16:10:16','2024-12-16 16:10:16'),(22,'原文翻译','translation',4,1,1,0.10,'完成外文文献翻译','active','2024-12-16 16:10:16','2024-12-16 16:10:16'),(23,'中期检查','midterm',5,1,1,0.15,'完成中期检查报告','active','2024-12-16 16:10:16','2024-12-16 16:10:16'),(32,'论文提交','thesis_submit',6,1,1,0.15,'提交毕业论文完整版','active','2024-12-28 21:02:09','2024-12-28 21:02:09'),(33,'导师评阅','advisor_review',7,1,1,0.15,'指导教师评阅论文','active','2024-12-28 21:02:09','2024-12-28 21:02:09'),(34,'同行评阅','peer_review',8,1,1,0.10,'同行专家评阅论文','active','2024-12-28 21:02:09','2024-12-28 21:02:09'),(35,'论文答辩','defense',9,1,1,0.10,'完成最终答辩','active','2024-12-28 21:02:09','2024-12-28 21:02:09');
/*!40000 ALTER TABLE `progress_stages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proposal_reviews`
--

DROP TABLE IF EXISTS `proposal_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `proposal_reviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(50) NOT NULL,
  `teacher_id` varchar(50) NOT NULL,
  `version` int NOT NULL DEFAULT '1' COMMENT '版本号',
  `file_url` varchar(255) DEFAULT NULL COMMENT '开题报告文件路径',
  `status` enum('not_started','in_progress','reviewing','revision_needed','completed') DEFAULT 'not_started' COMMENT '状态',
  `research_background_score` decimal(5,2) DEFAULT NULL COMMENT '研究背景分数',
  `technical_route_score` decimal(5,2) DEFAULT NULL COMMENT '技术路线分数',
  `feasibility_score` decimal(5,2) DEFAULT NULL COMMENT '可行性分析分数',
  `innovation_score` decimal(5,2) DEFAULT NULL COMMENT '创新点分数',
  `total_score` decimal(5,2) DEFAULT NULL COMMENT '总分',
  `research_background_comment` text COMMENT '研究背景评语',
  `technical_route_comment` text COMMENT '技术路线评语',
  `feasibility_comment` text COMMENT '可行性分析评语',
  `innovation_comment` text COMMENT '创新点评语',
  `general_comment` text COMMENT '总体评语',
  `improvement_suggestions` text COMMENT '改进建议',
  `submit_time` datetime DEFAULT NULL COMMENT '提交时间',
  `review_time` datetime DEFAULT NULL COMMENT '评审时间',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `student_id` (`student_id`),
  KEY `teacher_id` (`teacher_id`),
  CONSTRAINT `proposal_reviews_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE,
  CONSTRAINT `proposal_reviews_ibfk_2` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='开题报告评审表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proposal_reviews`
--

LOCK TABLES `proposal_reviews` WRITE;
/*!40000 ALTER TABLE `proposal_reviews` DISABLE KEYS */;
INSERT INTO `proposal_reviews` VALUES (1,'S2024105','T2024017',9,'uploads/proposal/S2024105_1734525570922.pdf','completed',80.00,85.00,90.00,82.00,84.25,'qre','aeg','dggd','fhfy','dhgk','trdtrh','2024-12-18 20:39:30','2024-12-18 23:58:32','2024-12-17 00:03:32','2024-12-18 23:58:32');
/*!40000 ALTER TABLE `proposal_reviews` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `proposal_review_version_update` BEFORE UPDATE ON `proposal_reviews` FOR EACH ROW BEGIN
    -- 当状态变更为 revision_needed 时，版本号加1
    IF NEW.status = 'revision_needed' AND OLD.status != 'revision_needed' THEN
        SET NEW.version = OLD.version + 1;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary view structure for view `student_progress_view`
--

DROP TABLE IF EXISTS `student_progress_view`;
