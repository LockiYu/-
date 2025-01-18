import express from 'express'
import { getTranslationReview, createOrUpdateTranslationReview, getTeacherTranslations, reviewTranslation } from '../controllers/translationReview'
import { authMiddleware } from '../middleware/auth'

const router = express.Router()

router.get('/review', authMiddleware, getTranslationReview)
router.post('/review', authMiddleware, createOrUpdateTranslationReview)
router.get('/teacher/:teacherId', authMiddleware, getTeacherTranslations)
router.post('/review/:id', authMiddleware, reviewTranslation)

export default router