import express from 'express';
import { getPublicStats, getPublicTeachers, getPublicTopics, getPublicAnnouncements, getPublicDefenseArrangements } from '../controllers/visitor';

const router = express.Router();

// 获取公开统计数据
router.get('/stats', getPublicStats);

// 获取公开教师信息
router.get('/teachers', getPublicTeachers);

// 获取公开题目列表
router.get('/topics', getPublicTopics);

// 获取公开公告
router.get('/announcements', getPublicAnnouncements);

// 获取公开答辩安排
router.get('/defense-arrangements', getPublicDefenseArrangements);

export default router; 