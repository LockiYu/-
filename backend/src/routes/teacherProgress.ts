import express from 'express';
import { getTeacherProgressStatistics, getStudentProgressList, downloadProgressFile } from '../controllers/teacherProgress';
import { auth } from '../middleware/auth';

const router = express.Router();

router.get('/statistics', auth(['teacher']), getTeacherProgressStatistics);
router.get('/list', auth(['teacher']), getStudentProgressList);
router.get('/download', auth(['teacher']), downloadProgressFile);

export default router;