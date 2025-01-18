import express from 'express'
import { auth } from '../middleware/auth'
import {
    getStudentDefenseInfo,
    getStudentDefenseScores
} from '../controllers/defenseStudent'

const router = express.Router()

// 获取学生答辩信息
router.get('/info', auth(['student']), getStudentDefenseInfo)

// 获取答辩评分详情
router.get('/scores', auth(['student']), getStudentDefenseScores)

export default router