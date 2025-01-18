import { Router } from 'express'
import {
    getStudentSelectionStatus,
    getAvailableTopics,
    getCurrentSelection,
    submitSelection,
    cancelSelection,
    getRejectedSelections
} from '../controllers/selection'
import { auth } from '../middleware/auth'

const router = Router()

// 获取可选题目列表
router.get('/available', auth(), getAvailableTopics)

// 获取当前选题
router.get('/current', auth(), getCurrentSelection)

// 获取选题状态
router.get('/status', auth(), getStudentSelectionStatus)

// 提交选题申请
router.post('/submit', auth(['student']), submitSelection)

// 取消选题
router.delete('/:selectionId', auth(['student']), cancelSelection)

// 获取被拒绝的历史申请记录
router.get('/rejected', auth(['student']), getRejectedSelections)

export default router