/*
 * @Author: test abc@163.com
 * @Date: 2024-12-10 11:48:44
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-16 14:21:33
 * @FilePath: \Graduation Design Management System\backend\src\routes\dashboard.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import express from 'express';
import {
  getSuperAdminStats,
  getSystemMessages,
  getSystemLogs,
  getAdminStats,
  getAdminTopics,
  getTeacherStats,
  getSupervisionList,
  getPendingSelections,
  updateSelectionStatus,
  getDirectorPendingSelections,
  updateDirectorSelectionStatus,
  getDirectorPendingDetails,
  updateTopicStatus,
  getPendingCountForTopic,
  getSelectionDetail,
  getAdminSelectionsList,
  getTeacherPendingSelections,
  approveTeacherSelection,
  rejectTeacherSelection,
  getSelectionDetails,
  getTeacherApprovedSelections
} from '../controllers/dashboard';
import { authMiddleware, roleMiddleware } from '../middleware/auth';

const router = express.Router();

router.get('/superadmin/stats',
  authMiddleware,
  roleMiddleware(['superadmin']),  // 只允许超级管理员访问
  getSuperAdminStats
);

router.get('/system-messages',
  authMiddleware,
  roleMiddleware(['superadmin']),
  getSystemMessages
);

router.get('/system-logs',
  authMiddleware,
  roleMiddleware(['superadmin']),
  getSystemLogs
);

router.get('/admin/stats',
  authMiddleware,
  roleMiddleware(['admin']),  // 只允许管理员访问
  getAdminStats
);

router.get('/admin/topics',
  authMiddleware,
  roleMiddleware(['admin']),
  getAdminTopics
);

router.get('/teacher/stats',
  authMiddleware,
  roleMiddleware(['teacher']),
  getTeacherStats
);

router.get('/teacher/supervision-list',
  authMiddleware,
  roleMiddleware(['teacher']),
  getSupervisionList
);

router.get('/teacher/pending-selections',
  authMiddleware,
  roleMiddleware(['teacher']),
  getTeacherPendingSelections
);

router.put('/teacher/selection/:selectionId/status',
  authMiddleware,
  roleMiddleware(['teacher']),
  updateSelectionStatus
);

router.get('/director/pending-selections',
  authMiddleware,
  roleMiddleware(['admin']), // 允许所有管理员访问
  getDirectorPendingSelections
);

router.put('/director/selection/:selectionId/status',
  authMiddleware,
  roleMiddleware(['admin']),
  updateDirectorSelectionStatus
);

router.get('/director/pending/:selectionId/details',
  authMiddleware,
  roleMiddleware(['admin']),
  getDirectorPendingDetails
);

router.put('/admin/topics/:id/status',
  authMiddleware,
  roleMiddleware(['admin']),
  updateTopicStatus
);

router.get('/director/topic/:topicId/pending-count',
  authMiddleware,
  roleMiddleware(['admin']),
  getPendingCountForTopic
);

router.get('/director/selection/:selectionId/detail',
  authMiddleware,
  roleMiddleware(['admin']), // 确保只有系主任可以访问
  getSelectionDetail
);

router.get('/admin/selections',
  authMiddleware,
  roleMiddleware(['admin']), // 允许所有管理员访问
  getAdminSelectionsList
);

router.post('/teacher/selection/:selectionId/approve',
  authMiddleware,
  roleMiddleware(['teacher']),
  approveTeacherSelection
);

router.post('/teacher/selection/:selectionId/reject',
  authMiddleware,
  roleMiddleware(['teacher']),
  rejectTeacherSelection
);

router.get('/director/selection/:selectionId/details',
  authMiddleware,
  roleMiddleware(['admin']),
  getSelectionDetails
);

router.get('/teacher/approved-selections', authMiddleware, getTeacherApprovedSelections);

export default router; 