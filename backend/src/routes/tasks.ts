import express from 'express';
import { authMiddleware } from '../middleware/auth';
import {
    getTaskList,
    assignTask,
    updateTask,
    getTaskDetail,
    getStudentList,
    getLatestStudentTask
} from '../controllers/tasks';
import { Router } from 'express';
import { pool } from '../db';
import { RowDataPacket } from 'mysql2';

const router = express.Router();

// 使用认证中间件
router.use(authMiddleware);

// 获取任务书列表
router.get('/list', getTaskList);

// 获取学生列表
router.get('/students', getStudentList);

// 获取任务书详情
router.get('/:id', getTaskDetail);

// 下达任务书
router.post('/assign', assignTask);

// 更新任务书
router.put('/:taskId', async (req, res) => {
    try {
        const taskId = req.params.taskId;
        const teacherId = (req as any).user?.userId;
        const { title, content, requirements, deadline, status } = req.body;

        console.log('更新请求参数:', {
            taskId,
            teacherId,
            body: req.body
        });

        // 先检查任务是否存在
        const [tasks] = await pool.execute(
            'SELECT * FROM task_assignments WHERE task_id = ?',
            [taskId]
        ) as [RowDataPacket[], any];

        if (tasks.length === 0) {
            return res.status(404).json({
                message: '任务书不存在'
            });
        }

        const task = tasks[0];
        console.log('当前任务信息:', task);

        // 检查权限
        if (task.teacher_id !== teacherId) {
            return res.status(403).json({
                message: '无权限修改此任务书'
            });
        }

        // 更新任务书 - 添加 title 字段
        const [updateResult] = await pool.execute(
            `UPDATE task_assignments 
             SET title = ?,
                 content = ?,
                 requirements = ?,
                 deadline = ?,
                 status = ?
             WHERE task_id = ? AND teacher_id = ?`,
            [
                title,
                content,
                requirements || null,
                deadline || null,
                status || task.status,
                taskId,
                teacherId
            ]
        );

        console.log('更新结果:', updateResult);

        res.json({
            code: 200,
            message: '任务书更新成功',
            data: {
                task_id: taskId,
                title,
                content,
                requirements,
                deadline,
                status: status || task.status
            }
        });

    } catch (error) {
        console.error('更新任务书失败:', error);
        res.status(500).json({
            code: 500,
            message: '更新任务书失败',
            error: error.message
        });
    }
});

// 创建任务书
router.post('/', async (req, res) => {
    try {
        // 从请求体中提取需要的字段
        const {
            student_id,
            title,
            content,
            requirements,
            deadline,
            status,
            topic_id,
            selection_id
        } = req.body;

        // 从认证中间件获取 teacher_id
        const teacher_id = (req as any).user?.userId;

        console.log('Current user:', (req as any).user);
        console.log('Teacher ID:', teacher_id);

        // 验证必填字段
        if (!teacher_id || !student_id || !title || !content) {
            return res.status(400).json({
                message: '缺少必要字段',
                required: ['teacher_id', 'student_id', 'title', 'content'],
                received: {
                    teacher_id,
                    student_id,
                    title,
                    content
                }
            });
        }

        // 验证状态值
        const validStatus = ['draft', 'published', 'completed'];
        const finalStatus = validStatus.includes(status) ? status : 'draft';

        // 准备插入数据
        const params = [
            teacher_id,
            student_id,
            topic_id || null,
            selection_id || null,
            title,
            content,
            requirements || null,
            deadline || null,
            finalStatus
        ];

        console.log('准备插入的参数:', params);

        const [result] = await pool.execute(
            `INSERT INTO task_assignments 
       (teacher_id, student_id, topic_id, selection_id, title, content, requirements, deadline, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            params
        );

        res.status(201).json({
            message: '任务书创建成功',
            data: result
        });
    } catch (error) {
        console.error('创建任务书失败:', error);
        res.status(500).json({
            message: '创建任务书失败',
            error: error.message,
            details: error
        });
    }
});

// 添加获取学生选题信息的路由
router.get('/student/:studentId', async (req, res) => {
    try {
        const studentId = req.params.studentId;

        // 先查询该学生的所有选题记录，用于调试
        const [allSelections] = await pool.execute(
            `SELECT ts.*, t.title as topic_title, t.description as topic_description
       FROM topic_selections ts
       JOIN topics t ON ts.topic_id = t.topic_id
       WHERE ts.student_id = ?`,
            [studentId]
        ) as [RowDataPacket[], any];

        console.log('学生所有选题记录:', allSelections);

        // 查询已通过的选题
        const [rows] = await pool.execute(
            `SELECT ts.*, t.title as topic_title, t.description as topic_description
       FROM topic_selections ts
       JOIN topics t ON ts.topic_id = t.topic_id
       WHERE ts.student_id = ?
       AND ts.final_status = 'approved'
       LIMIT 1`,
            [studentId]
        ) as [RowDataPacket[], any];

        console.log('符合条件的选题记录:', rows);

        if (rows.length === 0) {
            // 返回更详细的错误信息
            return res.status(404).json({
                message: '未找到该学生已通过的选题信息',
                debug: {
                    totalSelections: allSelections.length,
                    studentId: studentId,
                    selections: allSelections.map(s => ({
                        selection_id: s.selection_id,
                        final_status: s.final_status,
                        teacher_status: s.teacher_approval_status,
                        director_status: s.director_approval_status
                    }))
                }
            });
        }

        res.json({
            message: '获取选题信息成功',
            data: {
                selection_id: rows[0].selection_id,
                topic_id: rows[0].topic_id,
                topic_title: rows[0].topic_title,
                topic_description: rows[0].topic_description,
                student_id: rows[0].student_id,
                final_status: rows[0].final_status,
                teacher_status: rows[0].teacher_approval_status,
                director_status: rows[0].director_approval_status,
                created_at: rows[0].created_at
            }
        });

    } catch (error) {
        console.error('获取学生选题信息失败:', error);
        res.status(500).json({
            message: '获取学生选题信息失败',
            error: error.message
        });
    }
});

// 获取学生最新任务书
router.get('/student/:studentId/latest', getLatestStudentTask);

// 完成任务并评分
router.post('/:taskId/complete', async (req, res) => {
    const connection = await pool.getConnection();
    try {
        const { taskId } = req.params;
        const { score, teacherComment, studentId } = req.body;
        const teacherId = (req as any).user?.userId;

        await connection.beginTransaction();

        // 1. 更新任务书状态
        await connection.execute(
            `UPDATE task_assignments 
             SET status = 'completed' 
             WHERE task_id = ? AND teacher_id = ?`,
            [taskId, teacherId]
        );

        // 2. 更新进度记录
        await connection.execute(
            `UPDATE progress_records 
             SET status = 'completed',
                 score = ?,
                 teacher_comment = ?,
                 review_time = NOW()
             WHERE student_id = ? AND stage_type = 'task_book'`,
            [score, teacherComment, studentId]
        );

        // 3. 更新学生阶段分数
        await connection.execute(
            `UPDATE student_stage_scores 
             SET task_book_score = ?
             WHERE student_id = ?`,
            [score, studentId]
        );

        await connection.commit();

        res.json({
            code: 200,
            message: '任务完成评分成功'
        });

    } catch (error) {
        await connection.rollback();
        console.error('完成任务评分失败:', error);
        res.status(500).json({
            code: 500,
            message: '完成任务评分失败',
            error: error.message
        });
    } finally {
        connection.release();
    }
});

export default router;  // 确保使用 export default