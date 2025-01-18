import { Request, Response } from 'express';
import pool from '../utils/db';
import { RowDataPacket } from 'mysql2';
import { AuthRequest } from '../middleware/auth';
import path from 'path';
import fs from 'fs';
import { logUserAction } from '../utils/logger';

// 获取教师指导的学生进度统计
export const getTeacherProgressStatistics = async (req: AuthRequest, res: Response) => {
    try {
        const teacherId = req.user?.userId;

        const [statistics] = await pool.execute<RowDataPacket[]>(`
            SELECT 
                COUNT(DISTINCT ts.student_id) as totalStudents,
                SUM(CASE WHEN pr.status = 'reviewing' THEN 1 ELSE 0 END) as pendingTasks,
                SUM(CASE 
                    WHEN pr.status IN ('completed', 'in_progress') 
                    AND pr.deadline > NOW() THEN 1 
                    ELSE 0 
                END) as normalProgress,
                SUM(CASE 
                    WHEN pr.status = 'overdue' 
                    OR (pr.deadline < NOW() AND pr.status != 'completed') 
                    THEN 1 
                    ELSE 0 
                END) as abnormalProgress
            FROM topic_selections ts
            INNER JOIN topics t ON ts.topic_id = t.topic_id
            LEFT JOIN progress_records pr ON ts.student_id = pr.student_id
            WHERE t.teacher_id = ?
            AND ts.final_status = 'approved'
        `, [teacherId]);

        res.json({
            code: 200,
            data: statistics[0] || {
                totalStudents: 0,
                pendingTasks: 0,
                normalProgress: 0,
                abnormalProgress: 0
            }
        });
    } catch (error) {
        console.error('获取教师进度统计失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取统计数据失败'
        });
    }
};

// 获取学生进度列表
export const getStudentProgressList = async (req: AuthRequest, res: Response) => {
    try {
        const teacherId = req.user?.userId;
        const pageNum = Math.max(1, parseInt(req.query.pageNum as string) || 1);
        const pageSize = Math.max(1, parseInt(req.query.pageSize as string) || 10);

        // 1. 获取总数
        const [totalResult] = await pool.execute<RowDataPacket[]>(
            'SELECT COUNT(DISTINCT ts.student_id) as total FROM topic_selections ts ' +
            'INNER JOIN topics t ON ts.topic_id = t.topic_id ' +
            'WHERE t.teacher_id = ? AND ts.final_status = "approved"',
            [teacherId]
        );

        // 2. 获取学生列表 - 使用字符串拼接处理 LIMIT
        const [students] = await pool.execute<RowDataPacket[]>(
            'SELECT u.name as studentName, u.user_id as studentId, t.title as topicTitle ' +
            'FROM topic_selections ts ' +
            'INNER JOIN topics t ON ts.topic_id = t.topic_id ' +
            'INNER JOIN users u ON ts.student_id = u.user_id ' +
            'WHERE t.teacher_id = ? AND ts.final_status = "approved" ' +
            'ORDER BY ts.created_at DESC ' +
            'LIMIT ' + pageSize + ' OFFSET ' + ((pageNum - 1) * pageSize),
            [teacherId]
        );

        // 3. 获取每个学生的进度
        const studentList = await Promise.all(students.map(async (student) => {
            const [records] = await pool.execute<RowDataPacket[]>(
                'SELECT * FROM progress_records WHERE student_id = ? ' +
                'ORDER BY FIELD(stage_type, "task_book", "literature", "proposal", "translation", ' +
                '"midterm", "thesis_submit", "advisor_review", "peer_review", "defense")',
                [student.studentId]
            );

            // 检查是否所有阶段都完成
            const isAllCompleted = records.length > 0 &&
                records.every(r => r.status === 'completed') &&
                records.some(r => r.stage_type === 'defense');

            // 如果全部完成，设置特殊状态
            if (isAllCompleted) {
                return {
                    ...student,
                    currentStage: 'completed',
                    status: 'completed',
                    stages: records.map(record => ({
                        id: record.id,
                        type: record.stage_type,
                        status: record.status,
                        file_url: record.file_url,
                        teacher_comment: record.teacher_comment,
                        score: record.score,
                        submit_time: record.submit_time,
                        review_time: record.review_time,
                        deadline: record.deadline,
                        created_at: record.created_at,
                        updated_at: record.updated_at
                    }))
                };
            }

            // 找到第一个未完成的阶段
            const currentStage = records.find(r => r.status !== 'completed');

            return {
                ...student,
                currentStage: currentStage?.stage_type || null,
                status: currentStage?.status || null,
                stages: records.map(record => ({
                    id: record.id,
                    type: record.stage_type,
                    status: record.status,
                    file_url: record.file_url,
                    teacher_comment: record.teacher_comment,
                    score: record.score,
                    submit_time: record.submit_time,
                    review_time: record.review_time,
                    deadline: record.deadline,
                    created_at: record.created_at,
                    updated_at: record.updated_at
                }))
            };
        }));

        res.json({
            code: 200,
            data: {
                total: totalResult[0].total,
                list: studentList
            }
        });

    } catch (error) {
        console.error('获取学生进度列表失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取进度列表失败'
        });
    }
};

// 修改文件下载处理函数
export const downloadProgressFile = async (req: AuthRequest, res: Response) => {
    try {
        const { studentId, stageType } = req.query;
        const teacherId = req.user?.userId;

        // 验证参数
        if (!studentId || !stageType) {
            return res.status(400).json({
                code: 400,
                message: '缺少必要参数'
            });
        }

        // 获取文件记录
        const [fileRecord] = await pool.execute<RowDataPacket[]>(
            `SELECT file_url FROM progress_records 
             WHERE student_id = ? AND stage_type = ?
             ORDER BY created_at DESC LIMIT 1`,
            [studentId, stageType]
        );

        if (!fileRecord || fileRecord.length === 0 || !fileRecord[0].file_url) {
            return res.status(404).json({
                code: 404,
                message: '文件记录不存在'
            });
        }

        // 构建文件路径
        const baseDir = path.join(__dirname, '../../../backend/uploads');
        const fileName = path.basename(fileRecord[0].file_url);
        const filePath = path.join(baseDir, stageType as string, fileName);

        // 添加调试日志
        console.log('尝试访问文件:', {
            baseDir,
            stageType,
            fileName,
            fileUrl: fileRecord[0].file_url,
            fullPath: filePath
        });

        // 检查文件是否存在
        if (!fs.existsSync(filePath)) {
            return res.status(404).json({
                code: 404,
                message: '文件不存在'
            });
        }

        // 获取文件信息
        const stat = fs.statSync(filePath);
        const ext = path.extname(fileName).toLowerCase();

        // 设置响应头
        const contentType = {
            '.pdf': 'application/pdf',
            '.docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            '.doc': 'application/msword'
        }[ext] || 'application/octet-stream';

        res.setHeader('Content-Type', contentType);
        res.setHeader('Content-Length', stat.size);
        res.setHeader('Content-Disposition', `attachment; filename*=UTF-8''${encodeURIComponent(fileName)}`);

        // 使用流式传输
        const fileStream = fs.createReadStream(filePath);
        fileStream.pipe(res);

        // 记录下载日志
        await logUserAction(teacherId, 'progress.file.download', {
            student_id: studentId,
            stage_type: stageType,
            file_name: fileName
        }, req);  // 添加 req 参数

    } catch (error) {
        console.error('文件下载失败:', error);
        if (!res.headersSent) {
            res.status(500).json({
                code: 500,
                message: '文件下载失败',
                error: error instanceof Error ? error.message : '未知错误'
            });
        }
    }
}; 