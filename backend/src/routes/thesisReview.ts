/*
 * @Author: test abc@163.com
 * @Date: 2024-12-29 19:06:48
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-29 20:37:14
 * @FilePath: \Graduation Design Management System\backend\src\routes\thesisReview.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import express from 'express';
import { authMiddleware } from '../middleware/auth';
import { getReviewList, submitReview, getPeerReviewProgress } from '../controllers/thesisReview';

const router = express.Router();

// 获取评阅列表
router.get('/list', authMiddleware, getReviewList);

// 提交评阅
router.post('/submit', authMiddleware, submitReview);

// 添加获取评阅进度的路由
router.get('/progress', authMiddleware, getPeerReviewProgress);

export default router;