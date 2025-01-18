/*
 * @Author: test abc@163.com
 * @Date: 2024-12-29 21:33:42
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-30 00:00:54
 * @FilePath: \Graduation Design Management System\backend\src\routes\defense.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import express from 'express';
import { authMiddleware, roleMiddleware } from '../middleware/auth';
import {
    getDefenseArrangements,
    createDefenseArrangement,
    updateDefenseArrangement,
    deleteDefenseArrangement,
    getAvailableStudents,
    getDefenseCommittees,
    createDefenseCommittee,
    updateDefenseCommittee,
    deleteDefenseCommittee,
    getAvailableTeachers,
    getDefenseScores,
    submitDefenseScore,
    getDefenseScoreDetail
} from '../controllers/defense';
import { getDefenseInfo } from '../controllers/progress';

const router = express.Router();

// 答辩安排管理路由
router.get('/arrangements',
    authMiddleware,
    roleMiddleware(['admin', 'teacher']),
    getDefenseArrangements
);

router.post('/arrangements',
    authMiddleware,
    roleMiddleware(['admin', 'teacher']),
    createDefenseArrangement
);

router.put('/arrangements/:id',
    authMiddleware,
    roleMiddleware(['admin', 'teacher']),
    updateDefenseArrangement
);

router.delete('/arrangements/:id',
    authMiddleware,
    roleMiddleware(['admin', 'teacher']),
    deleteDefenseArrangement
);

// 基础数据路由
router.get('/available-students',
    authMiddleware,
    roleMiddleware(['admin', 'teacher']),
    getAvailableStudents
);

router.get('/committees',
    authMiddleware,
    roleMiddleware(['admin', 'teacher']),
    getDefenseCommittees
);

// 委员会管理路由
router.post('/committees',
    authMiddleware,
    roleMiddleware(['admin', 'teacher']),
    createDefenseCommittee
);

router.put('/committees/:id',
    authMiddleware,
    roleMiddleware(['admin', 'teacher']),
    updateDefenseCommittee
);

router.delete('/committees/:id',
    authMiddleware,
    roleMiddleware(['admin', 'teacher']),
    deleteDefenseCommittee
);

// 获取可用教师列表
router.get('/available-teachers',
    authMiddleware,
    roleMiddleware(['admin', 'teacher']),
    getAvailableTeachers
);

// 获取答辩信息
router.get('/info',
    authMiddleware,
    roleMiddleware(['student', 'teacher']),
    getDefenseInfo
);

// 获取答辩评分列表
router.get('/scores',
    authMiddleware,
    roleMiddleware(['admin', 'teacher']),
    getDefenseScores
);

// 提交答辩评分
router.post('/scores',
    authMiddleware,
    roleMiddleware(['teacher']),
    submitDefenseScore
);

// 获取答辩评分详情
router.get('/scores/:arrangementId',
    authMiddleware,
    roleMiddleware(['admin', 'teacher']),
    getDefenseScoreDetail
);

export default router;