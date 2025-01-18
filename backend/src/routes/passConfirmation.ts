import express from 'express'
import {
    getTeacherThesisConfirmations,
    updateThesisConfirmation
} from '../controllers/passConfirmation'
import { auth } from '../middleware/auth'

const router = express.Router()

// 使用 auth 中间件进行角色验证
router.get(
    '/teacher/:teacherId',
    auth(['teacher']),
    getTeacherThesisConfirmations
)

router.post(
    '/update/:id',
    auth(['teacher']),
    updateThesisConfirmation
)

export default router