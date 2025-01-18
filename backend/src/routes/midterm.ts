import express from 'express'
import { getTeacherMidterms, reviewMidterm, getMidtermDetail } from '../controllers/midtermReview'
import { authMiddleware } from '../middleware/auth'

const router = express.Router()

router.get('/teacher/:teacherId', authMiddleware, getTeacherMidterms)
router.post('/review/:id', authMiddleware, reviewMidterm)
router.get('/detail/:id', authMiddleware, getMidtermDetail)

export default router