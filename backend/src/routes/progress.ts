import express from 'express';
import {
  getProgress,
  updateProgress,
  submitFile,
  getProgressDetails,
  getProgressList,
  sendReminder,
  exportProgress,
  getStatistics,
  updateStageScore,
  getClasses,
  getTeachers,
  getStudentProgress,
  startNextStage,
  getOrCreateLiteratureReview,
  getLiteratureReviews,
  updateLiteratureReview,
  getOrCreateProposalReview,
  getOrCreateMidtermReview,
  createOrUpdateMidtermReview,
  handleThesisSubmit,
  getDefenseInfo
} from '../controllers/progress';
import { authMiddleware, roleMiddleware } from '../middleware/auth';
import { getStages, addStage, updateStage, deleteStage } from '../controllers/progressStage';
import { upload } from '../utils/upload';
import { updateProposalReview } from '../controllers/proposalReview';

const router = express.Router();

// 1. 选项数据路由
router.get('/classes', authMiddleware, getClasses);
router.get('/teachers', authMiddleware, getTeachers);

// 2. 文献综述相关路由
router.get('/literature-review', authMiddleware, getOrCreateLiteratureReview);
router.get('/literature-reviews', authMiddleware, roleMiddleware(['teacher']), getLiteratureReviews);
router.post('/literature-review',
  authMiddleware,
  roleMiddleware(['teacher']),
  updateLiteratureReview
);

// 3. 开题报告相关路由
router.get('/proposal/review', authMiddleware, getOrCreateProposalReview);
router.post('/proposal/review',
  authMiddleware,
  roleMiddleware(['teacher']),
  updateProposalReview
);

// 4. 中期检查相关路由
router.get('/midterm-review', authMiddleware, getOrCreateMidtermReview);
router.post('/midterm-review',
  authMiddleware,
  roleMiddleware(['student']),
  createOrUpdateMidtermReview
);

// 5. 统计接口
router.get('/statistics', authMiddleware, getStatistics);

// 6. 阶段管理路由
router.get('/stages', authMiddleware, getStages);
router.post('/stages', authMiddleware, roleMiddleware(['superadmin']), addStage);
router.put('/stages/:id', authMiddleware, roleMiddleware(['superadmin']), updateStage);
router.delete('/stages/:id', authMiddleware, roleMiddleware(['superadmin']), deleteStage);

// 7. 进度监控相关路由
router.get('/list', authMiddleware, getProgressList);
router.post('/remind/:id', authMiddleware, roleMiddleware(['teacher', 'admin']), sendReminder);
router.get('/export', authMiddleware, roleMiddleware(['teacher', 'admin']), exportProgress);

// 8. 进度管理路由
router.get('/:progress_id', authMiddleware, getProgressDetails);
router.put('/update', authMiddleware, roleMiddleware(['teacher']), updateProgress);
router.post('/submit',
  authMiddleware,
  roleMiddleware(['student']),
  (req, res, next) => {
    upload.single('file')(req, res, (err) => {
      if (err) {
        return res.status(400).json({
          code: 400,
          message: err.message
        });
      }
      next();
    });
  },
  submitFile
);
router.put('/score', authMiddleware, roleMiddleware(['teacher', 'admin']), updateStageScore);
router.post('/start-next-stage', authMiddleware, roleMiddleware(['student']), startNextStage);

// 9. 最后的通用路由
router.get('/', authMiddleware, getProgress);
router.get('/student/:studentId', authMiddleware, getStudentProgress);

// 10. 论文提交相关路由
router.post('/thesis/submit',
  authMiddleware,
  roleMiddleware(['student']),
  upload.single('file'),
  handleThesisSubmit
);

router.post('/update',
  authMiddleware,
  roleMiddleware(['student']),
  updateProgress
);

// 添加答辩相关路由
router.get('/defense-info',
  authMiddleware,
  roleMiddleware(['student']),
  getDefenseInfo
);

export default router;
