/*
 * @Author: test abc@163.com
 * @Date: 2024-12-14 18:11:53
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-30 13:59:59
 * @FilePath: \Graduation Design Management System\backend\src\routes\thesis.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import express from 'express'
import { authMiddleware } from '../middleware/auth'
import {
  getTopicList,
  getTopicTypes,
  addTopic,
  exportTopics,
  updateTopicStatus,
  importTopics,
  downloadTemplate,
  getStudentThesisReviews,
  updateTopic,
  deleteTopic
} from '../controllers/thesis'

const router = express.Router()

// 题目相关路由
router.get('/topics', authMiddleware, getTopicList)
router.post('/topics', authMiddleware, addTopic)
router.get('/topics/export', authMiddleware, exportTopics)
router.get('/types', authMiddleware, getTopicTypes)
router.put('/topics/:id/status', authMiddleware, updateTopicStatus)
router.post('/topics/import', authMiddleware, importTopics)
router.get('/topics/template', authMiddleware, downloadTemplate)
router.get('/reviews/student', authMiddleware, (req, res, next) => {
    console.log('收到评阅信息请求');
    next();
}, getStudentThesisReviews)
router.put('/topics/:id', authMiddleware, updateTopic)
router.delete('/topics/:id', authMiddleware, deleteTopic)

export default router