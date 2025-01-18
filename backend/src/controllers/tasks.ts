import { Request, Response } from 'express';
import pool from '../utils/db';
import { AuthRequest } from '../middleware/auth';
import { RowDataPacket } from 'mysql2';

// 获取任务书列表
export const getTaskList = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        const { pageNum = 1, pageSize = 10, keyword = '', status = '' } = req.query;
        const offset = (Number(pageNum) - 1) * Number(pageSize);
        const teacherId = req.user?.userId; // 获取当前登录教师ID

        let whereClause = 'WHERE ta.teacher_id = ?' // 添加教师ID筛选
        if (keyword) {
            whereClause += ` AND (s.name LIKE ? OR s.student_id LIKE ?)`
        }
        if (status) {
            whereClause += ` AND ta.status = ?`
        }

        // 获取总数
        const countSql = `
            SELECT COUNT(*) as total
            FROM task_assignments ta
            JOIN students s ON ta.student_id = s.student_id
            ${whereClause}
        `

        // 获取列表数据
        const listSql = `
            SELECT 
                ta.*,
                s.name as student_name,
                s.student_id,
                s.major,
                s.class_name
            FROM task_assignments ta
            JOIN students s ON ta.student_id = s.student_id
            ${whereClause}
            ORDER BY ta.created_at DESC
            LIMIT ? OFFSET ?
        `

        const params = [teacherId] // 添加教师ID作为第一个参数
        if (keyword) {
            params.push(`%${keyword}%`, `%${keyword}%`)
        }
        if (status) {
            params.push(status)
        }
        params.push(Number(pageSize), offset)

        const [[{ total }]] = await connection.query(countSql, params.slice(0, -2))
        const [list] = await connection.query(listSql, params)

        res.json({
            code: 200,
            data: {
                list,
                total,
                pageNum: Number(pageNum),
                pageSize: Number(pageSize)
            },
            message: '获取成功'
        })

    } catch (error) {
        console.error('获取任务书列表失败:', error)
        res.status(500).json({
            code: 500,
            message: '获取任务书列表失败'
        })
    } finally {
        connection.release()
    }
}

// 下达任务书
export const assignTask = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection()
    try {
        const { student_id, title, content, requirements, deadline } = req.body
        const teacher_id = req.user?.userId

        await connection.beginTransaction()

        // 创建任务书记录
        await connection.query(`
      INSERT INTO progress_records (
        student_id,
        stage_type,
        status,
        title,
        content,
        requirements,
        deadline,
        teacher_id,
        created_at
      ) VALUES (?, 'task_book', 'in_progress', ?, ?, ?, ?, ?, NOW())
    `, [student_id, title, content, requirements, deadline, teacher_id])

        // 初始化学生阶段分数记录
        await connection.query(`
      INSERT INTO student_stage_scores (student_id)
      VALUES (?)
      ON DUPLICATE KEY UPDATE updated_at = NOW()
    `, [student_id])

        await connection.commit()

        res.json({
            code: 200,
            message: '任务书下达成功'
        })

    } catch (error) {
        await connection.rollback()
        console.error('下达任务书失败:', error)
        res.status(500).json({
            code: 500,
            message: '下达任务书失败'
        })
    } finally {
        connection.release()
    }
}

// 更新任务书
export const updateTask = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection()
    try {
        const taskId = req.params.taskId
        const teacherId = req.user?.userId
        const { title, content, requirements, deadline, status } = req.body

        console.log('更新请求参数:', {
            taskId,
            teacherId,
            body: req.body
        })

        // 更新 task_assignments 表，包含 title 字段
        const [updateResult] = await connection.execute(
            `UPDATE task_assignments 
             SET title = ?,
                 content = ?,
                 requirements = ?,
                 deadline = ?,
                 status = ?,
                 updated_at = CURRENT_TIMESTAMP
             WHERE task_id = ? AND teacher_id = ?`,
            [title, content, requirements, deadline, status, taskId, teacherId]
        )

        if (updateResult.affectedRows === 0) {
            throw new Error('无权更新此任务书或任务书不存在')
        }

        res.json({
            code: 200,
            message: '任务书更新成功'
        })

    } catch (error) {
        console.error('更新任务书失败:', error)
        res.status(500).json({
            code: 500,
            message: '更新任务书失败',
            error: error.message
        })
    } finally {
        connection.release()
    }
}

// 获取任务书详情
export const getTaskDetail = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection()
    try {
        const { id } = req.params
        console.log('请求的任务书ID:', id)

        const [task] = await connection.query(`
      SELECT 
        pr.*,
        s.name as student_name,
        s.student_id,
        s.major,
        s.class_name
      FROM progress_records pr
      JOIN students s ON pr.student_id = s.student_id
      WHERE pr.id = ? AND pr.stage_type = 'task_book'
    `, [id])

        if (!task[0]) {
            return res.status(404).json({
                code: 404,
                message: '任务书不存在'
            })
        }

        res.json({
            code: 200,
            data: task[0],
            message: '获取成功'
        })

    } catch (error) {
        console.error('获取任务书详情失败:', error)
        res.status(500).json({
            code: 500,
            message: '获取任务书详情失败'
        })
    } finally {
        connection.release()
    }
}

// 获取学生列表
export const getStudentList = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection()
    try {
        const [students] = await connection.query(`
            SELECT 
                s.student_id,
                s.name,
                s.major,
                s.class_name
            FROM students s
            LEFT JOIN progress_records pr ON 
                s.student_id = pr.student_id AND 
                pr.stage_type = 'task_book'
            WHERE pr.id IS NULL
            ORDER BY s.student_id
        `)

        res.json({
            code: 200,
            data: students,
            message: '获取成功'
        })

    } catch (error) {
        console.error('获取学生列表失败:', error)
        res.status(500).json({
            code: 500,
            message: '获取学生列表失败'
        })
    } finally {
        connection.release()
    }
}

// 获取学生已通过的选题信息
export const getStudentTopicInfo = async (req: AuthRequest, res: Response) => {
    try {
        const studentId = req.params.studentId;

        const [rows] = await pool.execute(
            `SELECT ts.*, t.title as topic_title, t.description as topic_description
       FROM topic_selections ts
       JOIN topics t ON ts.topic_id = t.topic_id
       WHERE ts.student_id = ?
       AND ts.teacher_approval_status = 'approved'
       AND ts.director_approval_status = 'approved'
       AND ts.final_status = 'approved'
       LIMIT 1`,
            [studentId]
        ) as [RowDataPacket[], any];

        if (rows.length === 0) {
            return res.status(404).json({
                message: '未找到该学生已通过的选题信息'
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
};

// 获取学生最新任务书
export const getLatestStudentTask = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        const { studentId } = req.params;

        const [tasks] = await connection.execute(`
            SELECT * FROM task_assignments 
            WHERE student_id = ? 
            ORDER BY created_at DESC 
            LIMIT 1
        `, [studentId]);

        if (!tasks[0]) {
            return res.status(404).json({
                code: 404,
                message: '未找到任务书'
            });
        }

        res.json({
            code: 200,
            message: '获取成功',
            data: tasks[0]
        });
    } catch (error) {
        console.error('获取最新任务书失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取最新任务书失败'
        });
    } finally {
        connection.release();
    }
}; 