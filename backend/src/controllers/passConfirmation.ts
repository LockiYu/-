import { Response } from 'express'
import { AuthRequest } from '../middleware/auth'
import pool from '../utils/db'
import { logUserAction } from '../utils/logger'
import mysql from 'mysql2/promise'
import { dbConfig } from '../utils/db'

// 获取教师负责的学生论文提交列表
export const getTeacherThesisConfirmations = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection()
    try {
        const { teacherId } = req.params

        // 查询论文列表
        const [rows] = await connection.execute(`
            SELECT 
                ts.id,
                ts.student_id,
                ts.title as thesis_title,
                ts.version,
                ts.file_url,
                ts.status,
                ts.advisor_review_status,
                ts.advisor_review_time,
                ts.advisor_comments,
                ts.submit_time,
                t.title as topic_title,
                tsel.student_id,
                u.name as student_name
            FROM thesis_submissions ts
            JOIN topic_selections tsel ON ts.student_id = tsel.student_id
            JOIN topics t ON tsel.topic_id = t.topic_id
            JOIN users u ON ts.student_id = u.user_id
            WHERE t.teacher_id = ?
            AND tsel.final_status = 'approved'
            ORDER BY ts.submit_time DESC
        `, [teacherId])

        // 记录系统日志
        await logUserAction(
            teacherId,
            'thesis.list.view',
            JSON.stringify({
                action: '查看论文确认列表',
                count: (rows as any[]).length,
                timestamp: new Date().toISOString()
            }),
            req
        )

        res.json({
            code: 200,
            message: '获取论文确认列表成功',
            data: rows
        })

    } catch (error) {
        console.error('获取论文确认列表失败:', error)
        // 记录错误日志
        await logUserAction(
            req.user?.userId || '',
            'thesis.list.error',
            JSON.stringify({
                error: error.message,
                timestamp: new Date().toISOString()
            }),
            req
        )
        res.status(500).json({
            code: 500,
            message: '获取列表失败',
            error: process.env.NODE_ENV === 'development' ? error : undefined
        })
    } finally {
        connection.release()
    }
}

// 更新论文确认状态
export const updateThesisConfirmation = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
        const { id } = req.params; // 论文提交记录ID
        const { advisor_review_status, advisor_comments } = req.body;
        const teacherId = req.user?.userId;

        // 1. 参数验证
        if (!teacherId || !id || !advisor_review_status || !advisor_comments) {
            await connection.rollback();
            connection.release();
            return res.status(400).json({
                code: 400,
                message: '缺少必要参数'
            });
        }

        // 2. 验证教师权限并获取学生ID
        const [submissions] = await connection.execute<any[]>(`
            SELECT ts.id, ts.student_id, ts.status, ts.advisor_review_status
            FROM thesis_submissions ts
            JOIN topic_selections tsel ON ts.student_id = tsel.student_id
            JOIN topics t ON tsel.topic_id = t.topic_id
            WHERE ts.id = ? 
            AND t.teacher_id = ?
            LIMIT 1
        `, [id, teacherId]);

        if (!submissions || submissions.length === 0) {
            await connection.rollback();
            connection.release();
            return res.status(403).json({
                code: 403,
                message: '无权限操作此论文'
            });
        }

        const submission = submissions[0];

        // 检查论文状态
        if (submission.advisor_review_status !== 'pending') {
            await connection.rollback();
            connection.release();
            return res.status(400).json({
                code: 400,
                message: '该论文已经被审核过'
            });
        }

        try {
            // 3. 更新论文提交记录
            await connection.execute(`
                UPDATE thesis_submissions 
                SET 
                    advisor_review_status = ?,
                    advisor_comments = ?,
                    advisor_review_time = CURRENT_TIMESTAMP,
                    status = CASE 
                        WHEN ? = 'approved' THEN 'advisor_approved'
                        WHEN ? = 'rejected' THEN 'advisor_rejected'
                        ELSE status 
                    END
                WHERE id = ? 
            `, [
                advisor_review_status,
                advisor_comments,
                advisor_review_status,
                advisor_review_status,
                id
            ]);

            // 4. 更新进度记录
            await connection.execute(`
                UPDATE progress_records 
                SET 
                    status = CASE 
                        WHEN ? = 'approved' THEN 'completed'
                        WHEN ? = 'rejected' THEN 'revision_needed'
                        ELSE 'reviewing'
                    END,
                    teacher_comment = ?,
                    score = CASE 
                        WHEN ? = 'approved' THEN 100.00
                        ELSE score 
                    END,
                    review_time = CURRENT_TIMESTAMP
                WHERE student_id = ? 
                AND stage_type = 'thesis_submit'
            `, [
                advisor_review_status,
                advisor_comments,
                advisor_review_status,
                advisor_review_status,
                submission.student_id
            ]);

            // 5. 记录系统日志
            await connection.execute(`
                INSERT INTO system_logs 
                (user_id, action, ip_address, details)
                VALUES (?, 'thesis.review.update', ?, ?)
            `, [
                teacherId,
                req.ip || '',
                JSON.stringify({
                    thesis_id: id,
                    student_id: submission.student_id,
                    old_status: submission.advisor_review_status,
                    new_status: advisor_review_status,
                    timestamp: new Date().toISOString()
                })
            ]);

            await connection.commit();
            connection.release();
            return res.json({
                code: 200,
                message: '更新成功'
            });

        } catch (error) {
            await connection.rollback();
            throw error;
        }

    } catch (error) {
        await connection.rollback();
        connection.release();
        console.error('更新论文确认状态失败:', error);
        return res.status(500).json({
            code: 500,
            message: '更新确认状态失败',
            error: process.env.NODE_ENV === 'development' ? error : undefined
        });
    }
}; 