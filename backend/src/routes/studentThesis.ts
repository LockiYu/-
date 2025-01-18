import express from 'express';
import { authMiddleware } from '../middleware/auth';
import {
    getStudentThesisHistory,
    getStudentThesisReviews
} from '../controllers/studentThesis';

const router = express.Router();

router.get('/history', authMiddleware, getStudentThesisHistory);
router.get('/reviews/:studentId', authMiddleware, getStudentThesisReviews);

export default router;