import { Request, Response } from 'express'
import pool from '../utils/db'
import { AuthRequest } from '../middleware/auth'
import { logUserAction } from '../utils/logger'

// 获取教师负责的学生中期报告列表
export const getTeacherMidterms = async (req: AuthRequest, res: Response) => {
    try {
        const { teacherId } = req.params;

        // 添加详细的日志
        console.log('Getting midterms for teacher:', teacherId);

        const [rows] = await pool.execute(`
            SELECT 
                mr.*,
                s.name as student_name,
                s.student_id,
                COALESCE(mr.status, 'pending') as status,
                mr.total_score as score
            FROM midterm_reports mr
            JOIN students s ON mr.student_id = s.student_id
            JOIN topic_selections ts ON s.student_id = ts.student_id
            JOIN topics t ON ts.topic_id = t.topic_id
            WHERE t.teacher_id = ?
            AND ts.final_status = 'approved'
            ORDER BY mr.submit_time DESC
        `, [teacherId]);

        // 记录查看列表的操作
        await logUserAction(
            teacherId,
            'midterm.list.view',
            JSON.stringify({
                message: '教师查看中期检查列表',
                timestamp: new Date().toISOString()
            }),
            req
        );

        res.json({
            code: 200,
            message: '获取中期报告列表成功',
            data: rows
        });
    } catch (error) {
        console.error('获取中期报告列表失败:', error);
        res.status(500).json({
            code: 500,
            message: '服务器错误',
            error: process.env.NODE_ENV === 'development' ? error : undefined
        });
    }
};

// 评阅中期报告
export const reviewMidterm = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection()
    try {
        await connection.beginTransaction()

        const { id } = req.params
        const teacherId = req.user.userId
        const {
            research_progress_score,
            technical_ability_score,
            work_attitude_score,
            total_score,
            progress_comment,
            technical_comment,
            attitude_comment,
            improvement_suggestions,
            status
        } = req.body

        // 验证教师权限并获取学生信息和文件信息
        const [authCheck] = await connection.execute(`
            SELECT 
                mr.*,
                s.name as student_name,
                s.student_id,
                pr.id as progress_record_id,
                pr.file_url,
                pr.submit_time,
                pr.deadline
            FROM midterm_reports mr
            JOIN students s ON mr.student_id = s.student_id
            JOIN topic_selections ts ON s.student_id = ts.student_id
            JOIN topics t ON ts.topic_id = t.topic_id
            LEFT JOIN progress_records pr ON s.student_id = pr.student_id AND pr.stage_type = 'midterm'
            WHERE mr.id = ? AND t.teacher_id = ?
        `, [id, teacherId])

        if (!authCheck.length) {
            await connection.rollback()
            return res.status(403).json({
                code: 403,
                message: '无权评阅此中期报告'
            })
        }

        const studentId = authCheck[0].student_id
        const progressRecordId = authCheck[0].progress_record_id
        const fileUrl = authCheck[0].file_url
        const submitTime = authCheck[0].submit_time
        const deadline = authCheck[0].deadline

        // 更新中期报告评阅信息
        await connection.execute(`
            UPDATE midterm_reports 
            SET 
                research_progress_score = ?,
                technical_ability_score = ?,
                work_attitude_score = ?,
                total_score = ?,
                progress_comment = ?,
                technical_comment = ?,
                attitude_comment = ?,
                improvement_suggestions = ?,
                status = ?,
                teacher_id = ?,
                review_time = CURRENT_TIMESTAMP
            WHERE id = ?
        `, [
            research_progress_score,
            technical_ability_score,
            work_attitude_score,
            total_score,
            progress_comment,
            technical_comment,
            attitude_comment,
            improvement_suggestions,
            status,
            teacherId,
            id
        ])

        // 更新进度记录表
        if (progressRecordId) {
            // 如果评阅通过
            if (status === 'completed') {
                await connection.execute(`
                    UPDATE progress_records 
                    SET 
                        status = 'completed',
                        score = ?,
                        teacher_comment = ?,
                        review_time = CURRENT_TIMESTAMP,
                        file_url = ?,
                        submit_time = ?,
                        deadline = ?
                    WHERE id = ?
                `, [
                    total_score,
                    `研究进度(${research_progress_score}分)：${progress_comment}\n技术掌握(${technical_ability_score}分)：${technical_comment}\n工作态度(${work_attitude_score}分)：${attitude_comment}`,
                    fileUrl,
                    submitTime,
                    deadline,
                    progressRecordId
                ])
            } else if (status === 'revision_needed') {
                // 如果需要修改
                await connection.execute(`
                    UPDATE progress_records 
                    SET 
                        status = 'revision_needed',
                        teacher_comment = ?,
                        review_time = CURRENT_TIMESTAMP,
                        file_url = ?,
                        submit_time = ?,
                        deadline = ?
                    WHERE id = ?
                `, [
                    improvement_suggestions,
                    fileUrl,
                    submitTime,
                    deadline,
                    progressRecordId
                ])
            }
        }

        // 记录评阅操作
        await logUserAction(
            teacherId,
            'midterm.review',
            JSON.stringify({
                midterm_id: id,
                student_name: authCheck[0].student_name,
                student_id: studentId,
                status,
                total_score,
                message: `教师完成了中期报告评阅`
            }),
            req
        )

        await connection.commit()
        res.json({
            code: 200,
            message: '评阅完成'
        })

    } catch (error) {
        await connection.rollback()
        console.error('评阅中期报告失败:', error)
        res.status(500).json({
            code: 500,
            message: '评阅失败',
            error: process.env.NODE_ENV === 'development' ? error : undefined
        })
    } finally {
        connection.release()
    }
}

// 获取评阅详情
export const getMidtermDetail = async (req: AuthRequest, res: Response) => {
    try {
        const { id } = req.params;
        const teacherId = req.user.userId;

        const [rows] = await pool.execute(`
            SELECT 
                mr.*,
                s.name as student_name,
                s.student_id
            FROM midterm_reports mr
            JOIN students s ON mr.student_id = s.student_id
            JOIN topic_selections ts ON s.student_id = ts.student_id
            JOIN topics t ON ts.topic_id = t.topic_id
            WHERE mr.id = ? AND t.teacher_id = ?
        `, [id, teacherId]);

        if (!rows.length) {
            return res.status(404).json({
                code: 404,
                message: '未找到中期报告记录'
            });
        }

        // 记录查看详情的操作
        await logUserAction(
            teacherId,
            'midterm.detail.view',
            JSON.stringify({
                midterm_id: id,
                student_name: rows[0].student_name,
                message: '教师查看中期报告详情',
                timestamp: new Date().toISOString()
            }),
            req
        );

        res.json({
            code: 200,
            data: rows[0]
        });
    } catch (error) {
        console.error('获取中期报告详情失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取详情失败'
        });
    }
};