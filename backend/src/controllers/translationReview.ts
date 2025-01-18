/*
 * @Author: test abc@163.com
 * @Date: 2024-12-18 22:24:53
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2025-01-02 09:02:56
 * @FilePath: \Graduation Design Management System\backend\src\controllers\translationReview.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import { Request, Response } from 'express'
import pool from '../utils/db'
import { AuthRequest } from '../middleware/auth'
import { logUserAction } from '../utils/logger'

// 获取翻译评审记录
export const getTranslationReview = async (req: Request, res: Response) => {
    try {
        const studentId = req.user.userId

        const [reviews] = await pool.execute(
            `SELECT tr.*, u.name as teacher_name, u.title as teacher_title,
       ps.weight as translation_weight,
       t.teacher_id
       FROM translation_reviews tr
       LEFT JOIN topic_selections ts ON tr.student_id = ts.student_id
       LEFT JOIN topics t ON ts.topic_id = t.topic_id
       LEFT JOIN users u ON t.teacher_id = u.user_id
       LEFT JOIN progress_stages ps ON ps.type = 'translation'
       WHERE tr.student_id = ?
       AND ts.final_status = 'approved'
       ORDER BY tr.version DESC
       LIMIT 1`,
            [studentId]
        )

        res.json({
            code: 200,
            data: reviews[0] || null
        })
    } catch (error) {
        console.error('Error in getTranslationReview:', error)
        res.status(500).json({
            code: 500,
            message: '获取翻译评审记录失败'
        })
    }
}

// 创建或更新翻译评审记录
export const createOrUpdateTranslationReview = async (req: Request, res: Response) => {
    try {
        const studentId = req.user.userId
        const { file_url, file_size } = req.body

        if (!file_url || !file_size) {
            return res.status(400).json({
                code: 400,
                message: '缺少必要参数'
            })
        }

        // 转换为相对路径
        const relativePath = file_url.split('uploads')[1] // 获取 uploads 之后的路径部分
        const normalizedPath = 'uploads' + relativePath.replace(/\\/g, '/') // 统一使用正斜杠

        // 检查是否存在记录
        const [existing] = await pool.execute(
            'SELECT id, version, status FROM translation_reviews WHERE student_id = ? ORDER BY version DESC LIMIT 1',
            [studentId]
        )

        if (existing.length === 0) {
            // 创建新记录
            await pool.execute(
                `INSERT INTO translation_reviews 
                (student_id, file_url, file_size, status, version, submit_time)
                VALUES (?, ?, ?, 'pending', 1, NOW())`,
                [studentId, normalizedPath, file_size]
            )
        } else {
            // 如果当前状态是 completed 或 revision_needed，创建新版本
            if (existing[0].status === 'completed' || existing[0].status === 'revision_needed') {
                // 创建新版本
                await pool.execute(
                    `INSERT INTO translation_reviews 
                    (student_id, file_url, file_size, status, version, submit_time)
                    VALUES (?, ?, ?, 'pending', ?, NOW())`,
                    [studentId, normalizedPath, file_size, existing[0].version + 1]
                )
            } else {
                // 更新现有记录
                await pool.execute(
                    `UPDATE translation_reviews 
                    SET file_url = ?, 
                        file_size = ?, 
                        status = 'pending',
                        submit_time = NOW()
                    WHERE id = ?`,
                    [normalizedPath, file_size, existing[0].id]
                )
            }
        }

        res.json({
            code: 200,
            message: '提交成功'
        })
    } catch (error) {
        console.error('Error in createOrUpdateTranslationReview:', error)
        res.status(500).json({
            code: 500,
            message: '提交翻译评审失败'
        })
    }
}

// 获取教师负责的学生翻译列表
export const getTeacherTranslations = async (req: AuthRequest, res: Response) => {
    try {
        const { teacherId } = req.params;
        const [rows] = await pool.execute(`
            SELECT 
                tr.*,
                s.name as student_name,
                s.student_id,
                tr.total_score as score
            FROM translation_reviews tr
            JOIN students s ON tr.student_id = s.student_id
            JOIN topic_selections ts ON s.student_id = ts.student_id
            JOIN topics t ON ts.topic_id = t.topic_id
            WHERE t.teacher_id = ?
            AND ts.final_status = 'approved'
            ORDER BY tr.submit_time DESC
        `, [teacherId]);

        // 记录查看列表日志
        await logUserAction(
            teacherId,
            'translation.list.view',
            JSON.stringify({
                message: '教师查看外文翻译列表',
                timestamp: new Date().toISOString()
            }),
            req
        );

        res.json({ code: 200, data: rows });
    } catch (error) {
        console.error('获取外文翻译列表失败:', error);
        res.status(500).json({ code: 500, message: '服务器错误' });
    }
};

// 评阅翻译
export const reviewTranslation = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();
        const { id } = req.params;
        const teacherId = req.user.userId;
        const {
            language_accuracy_score,
            content_integrity_score,
            format_score,
            total_score,
            language_accuracy_comment,
            content_integrity_comment,
            format_comment,
            general_comment,
            improvement_suggestions,
            status
        } = req.body;

        // 首先验证教师权限...
        const [authCheck] = await connection.execute(`
            SELECT tr.id, tr.student_id, tr.file_url 
            FROM translation_reviews tr
            JOIN topic_selections ts ON tr.student_id = ts.student_id
            JOIN topics t ON ts.topic_id = t.topic_id
            WHERE tr.id = ? AND t.teacher_id = ? AND ts.final_status = 'approved'
        `, [id, teacherId]);

        if (!Array.isArray(authCheck) || authCheck.length === 0) {
            return res.status(403).json({
                code: 403,
                message: '您没有权限评阅此翻译'
            });
        }

        // 更新翻译评阅结果...
        await connection.execute(`
            UPDATE translation_reviews SET 
                language_accuracy_score = ?,
                content_integrity_score = ?,
                format_score = ?,
                total_score = ?,
                language_accuracy_comment = ?,
                content_integrity_comment = ?,
                format_comment = ?,
                general_comment = ?,
                improvement_suggestions = ?,
                status = ?
            WHERE id = ?
        `, [
            language_accuracy_score,
            content_integrity_score,
            format_score,
            total_score,
            language_accuracy_comment,
            content_integrity_comment,
            format_comment,
            general_comment,
            improvement_suggestions,
            status,
            id
        ]);

        const studentId = authCheck[0].student_id;
        const fileUrl = authCheck[0].file_url;

        // 检查 progress_records 是否存在记录
        const [existingRecord] = await connection.execute(
            'SELECT id FROM progress_records WHERE student_id = ? AND stage_type = ?',
            [studentId, 'translation']
        );

        if (status === 'completed') {
            // 构建更新数据
            const progressData = {
                status: 'completed',
                score: total_score,
                teacher_comment: general_comment,
                file_url: fileUrl,
                review_time: new Date()
            };

            if (existingRecord.length > 0) {
                // 更新现有记录
                await connection.execute(`
                    UPDATE progress_records 
                    SET status = ?,
                        score = ?,
                        teacher_comment = ?,
                        file_url = ?,
                        review_time = CURRENT_TIMESTAMP
                    WHERE student_id = ? AND stage_type = 'translation'
                `, [
                    progressData.status,
                    progressData.score,
                    progressData.teacher_comment,
                    progressData.file_url,
                    studentId
                ]);
            } else {
                // 插入新记录
                await connection.execute(`
                    INSERT INTO progress_records 
                    (student_id, stage_type, status, score, teacher_comment, file_url, submit_time, review_time)
                    VALUES (?, 'translation', ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
                `, [
                    studentId,
                    progressData.status,
                    progressData.score,
                    progressData.teacher_comment,
                    progressData.file_url
                ]);
            }
        } else if (status === 'revision_needed') {
            // 更新为需要修改状态
            const updateQuery = existingRecord.length > 0
                ? `UPDATE progress_records 
                   SET status = 'revision_needed',
                       teacher_comment = ?,
                       review_time = CURRENT_TIMESTAMP
                   WHERE student_id = ? AND stage_type = 'translation'`
                : `INSERT INTO progress_records 
                   (student_id, stage_type, status, teacher_comment, review_time)
                   VALUES (?, 'translation', 'revision_needed', ?, CURRENT_TIMESTAMP)`;

            const params = existingRecord.length > 0
                ? [improvement_suggestions, studentId]
                : [studentId, improvement_suggestions];

            await connection.execute(updateQuery, params);
        }

        await connection.commit();
        res.json({ code: 200, message: '评阅结果已保存' });

    } catch (error) {
        await connection.rollback();
        console.error('保存评阅结果失败:', error);
        res.status(500).json({ code: 500, message: '保存评阅结果失败' });
    } finally {
        connection.release();
    }
};

// 获取翻译详情
export const getTranslationDetail = async (req: AuthRequest, res: Response) => {
    try {
        const { id } = req.params;
        const teacherId = req.user.userId;

        const [rows] = await pool.execute(`
            SELECT tr.*, s.name as student_name
            FROM translation_reviews tr
            JOIN students s ON tr.student_id = s.student_id
            WHERE tr.id = ? AND tr.teacher_id = ?
        `, [id, teacherId]);

        if (!rows.length) {
            return res.status(404).json({
                code: 404,
                message: '未找到翻译记录'
            });
        }

        // 记录查看详情日志
        await logUserAction(
            teacherId,
            'translation.detail.view',
            JSON.stringify({
                translation_id: id,
                student_name: rows[0].student_name,
                message: `教师查看了学生${rows[0].student_name}的外文翻译详情`
            }),
            req
        );

        res.json({ code: 200, data: rows[0] });
    } catch (error) {
        console.error('获取翻译详情失败:', error);
        res.status(500).json({ code: 500, message: '服务器错误' });
    }
};