import { Request, Response } from 'express';
import pool from '../utils/db';

// 获取评阅人待评阅的论文列表
export const getReviewList = async (req: Request, res: Response) => {
    try {
        const reviewerId = req.user?.userId;
        const { studentName, thesisTitle, status, pageNum = 1, pageSize = 10 } = req.query;

        // 构建基础查询，包含导师评阅状态
        let sql = `
            SELECT 
                tra.id as assignment_id,
                tra.student_id,
                tra.review_type,
                tra.status as review_status,
                tra.assigned_at,
                ts.id as submission_id,
                ts.title as thesis_title,
                ts.submit_time,
                ts.file_url,
                u.name as student_name,
                trd.score_innovation,
                trd.score_quality,
                trd.score_workload,
                trd.score_writing,
                trd.total_score,
                trd.review_comments,
                trd.review_time,
                -- 修改导师评阅状态查询
                (
                    SELECT COALESCE(
                        (
                            SELECT 'completed'
                            FROM thesis_reviews_assignment tra2
                            JOIN thesis_review_details trd2 ON tra2.id = trd2.assignment_id
                            WHERE tra2.student_id = tra.student_id
                            AND tra2.review_type = 'advisor'
                            LIMIT 1
                        ),
                        'pending'
                    )
                ) as advisor_review_status
            FROM thesis_reviews_assignment tra
            JOIN thesis_submissions ts ON tra.student_id = ts.student_id
            JOIN users u ON tra.student_id = u.user_id
            LEFT JOIN thesis_review_details trd ON tra.id = trd.assignment_id
            WHERE tra.reviewer_id = ?
        `;

        const params: any[] = [reviewerId];

        // 添加筛选条件
        if (studentName) {
            sql += ` AND u.name LIKE ?`;
            params.push(`%${studentName}%`);
        }
        if (thesisTitle) {
            sql += ` AND ts.title LIKE ?`;
            params.push(`%${thesisTitle}%`);
        }
        if (status) {
            sql += ` AND tra.status = ?`;
            params.push(status);
        }

        // 计算总数
        const [countResult] = await pool.query(
            `SELECT COUNT(*) as total FROM (${sql}) as t`,
            params
        );
        const total = (countResult as any)[0].total;

        // 添加分页
        sql += ` ORDER BY tra.assigned_at DESC LIMIT ? OFFSET ?`;
        params.push(Number(pageSize), (Number(pageNum) - 1) * Number(pageSize));

        // 执行查询
        const [reviews] = await pool.query(sql, params);

        // 处理返回数据，添加评阅权限标志
        const processedReviews = (reviews as any[]).map(review => ({
            ...review,
            can_review: review.review_type === 'advisor' ||
                (review.review_type === 'peer' && review.advisor_review_status === 'completed')
        }));

        // 添加系统日志
        const logDetails = {
            action: '查看论文评阅列表',
            count: (reviews as any[]).length,
            timestamp: new Date().toISOString()
        };

        await pool.query(
            `INSERT INTO system_logs 
            (user_id, action, ip_address, details)
            VALUES (?, ?, ?, ?)`,
            [
                reviewerId,
                'thesis.review.list.view',
                req.ip,
                JSON.stringify(logDetails)
            ]
        );

        res.json({
            code: 200,
            data: {
                list: processedReviews,
                total,
                pageNum: Number(pageNum),
                pageSize: Number(pageSize)
            },
            message: '获取评阅列表成功'
        });
    } catch (error) {
        console.error('获取评阅列表失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取评阅列表失败'
        });
    }
};

// 提交论文评阅
export const submitReview = async (req: Request, res: Response) => {
    try {
        const reviewerId = req.user?.userId;
        const ipAddress = req.ip; // 获取IP地址
        const {
            assignmentId,
            scoreInnovation,
            scoreQuality,
            scoreWorkload,
            scoreWriting,
            reviewComments
        } = req.body;

        // 开启事务
        const connection = await pool.getConnection();
        await connection.beginTransaction();

        try {
            // 1. 验证评阅分配记录
            const [assignments] = await connection.query(
                `SELECT tra.*, ts.student_id, u.name as student_name, ts.title as thesis_title
                 FROM thesis_reviews_assignment tra
                 JOIN thesis_submissions ts ON tra.student_id = ts.student_id
                 JOIN users u ON ts.student_id = u.user_id
                 WHERE tra.id = ? AND tra.reviewer_id = ? AND tra.status = 'pending'`,
                [assignmentId, reviewerId]
            );

            if (!assignments || (assignments as any[]).length === 0) {
                throw new Error('未找到有效的评阅分配记录');
            }

            const assignment = (assignments as any[])[0];

            // 2. 计算总分
            const totalScore = (
                Number(scoreInnovation) +
                Number(scoreQuality) +
                Number(scoreWorkload) +
                Number(scoreWriting)
            ) / 4;

            // 3. 插入评阅详情
            await connection.query(
                `INSERT INTO thesis_review_details 
                (assignment_id, score_innovation, score_quality, score_workload, 
                score_writing, total_score, review_comments, review_time)
                VALUES (?, ?, ?, ?, ?, ?, ?, NOW())`,
                [
                    assignmentId,
                    scoreInnovation,
                    scoreQuality,
                    scoreWorkload,
                    scoreWriting,
                    totalScore,
                    reviewComments
                ]
            );

            // 4. 更新评阅分配状态
            await connection.query(
                `UPDATE thesis_reviews_assignment 
                SET status = 'completed', completed_at = NOW()
                WHERE id = ?`,
                [assignmentId]
            );

            // 5. 更新进度记录
            if (assignment.review_type === 'advisor') {
                // 导师评阅直接更新进度记录
                await connection.query(
                    `INSERT INTO progress_records 
                    (student_id, stage_type, status, score, teacher_comment, review_time)
                    VALUES (?, 'advisor_review', 'completed', ?, ?, NOW())
                    ON DUPLICATE KEY UPDATE 
                    status = 'completed', 
                    score = ?,
                    teacher_comment = ?,
                    review_time = NOW()`,
                    [
                        assignment.student_id,
                        totalScore,
                        reviewComments,
                        totalScore,
                        reviewComments
                    ]
                );
            } else {
                // 同行评阅需要检查是否所有评阅都已完成
                const [peerReviews] = await connection.query(
                    `SELECT 
                        tra.id,
                        trd.total_score,
                        trd.review_comments,
                        trd.review_time
                     FROM thesis_reviews_assignment tra
                     LEFT JOIN thesis_review_details trd ON tra.id = trd.assignment_id
                     WHERE tra.student_id = ?
                     AND tra.review_type = 'peer'`,
                    [assignment.student_id]
                );

                const completedReviews = (peerReviews as any[]).filter(
                    review => review.total_score !== null
                );

                // 如果已有3个同行评阅完成
                if (completedReviews.length === 3) {
                    // 计算平均分
                    const averageScore = completedReviews.reduce(
                        (sum, review) => sum + Number(review.total_score),
                        0
                    ) / 3;

                    // 获取最后评阅时间
                    const lastReviewTime = new Date(Math.max(
                        ...completedReviews.map(
                            review => new Date(review.review_time).getTime()
                        )
                    ));

                    // 合并所有评语
                    const allComments = completedReviews
                        .map(review => review.review_comments)
                        .filter(Boolean)
                        .join('\n\n');

                    // 更新进度记录
                    await connection.query(
                        `INSERT INTO progress_records 
                        (student_id, stage_type, status, score, teacher_comment, review_time)
                        VALUES (?, 'peer_review', 'completed', ?, ?, ?)
                        ON DUPLICATE KEY UPDATE 
                        status = 'completed', 
                        score = ?,
                        teacher_comment = ?,
                        review_time = ?`,
                        [
                            assignment.student_id,
                            averageScore,
                            allComments,
                            lastReviewTime,
                            averageScore,
                            allComments,
                            lastReviewTime
                        ]
                    );
                }
            }

            // 6. 记录系统日志
            const logDetails = {
                action: '提交论文评阅',
                student: assignment.student_name,
                thesis: assignment.thesis_title,
                type: assignment.review_type === 'advisor' ? '导师评阅' : '同行评阅',
                score: totalScore,
                timestamp: new Date().toISOString()
            };

            await connection.query(
                `INSERT INTO system_logs 
                (user_id, action, ip_address, details)
                VALUES (?, ?, ?, ?)`,
                [
                    reviewerId,
                    'thesis.review.submit',
                    ipAddress,
                    JSON.stringify(logDetails)
                ]
            );

            await connection.commit();
            res.json({
                code: 200,
                message: '评阅提交成功'
            });
        } catch (error) {
            await connection.rollback();
            throw error;
        } finally {
            connection.release();
        }
    } catch (error) {
        console.error('评阅提交失败:', error);
        res.status(500).json({
            code: 500,
            message: error instanceof Error ? error.message : '评阅提交失败'
        });
    }
};

// 获取同行评阅进度
export const getPeerReviewProgress = async (req: Request, res: Response) => {
    try {
        const { studentId } = req.query;
        
        // 添加日志调试
        console.log('查询学生评阅进度:', studentId);

        const [reviews] = await pool.query(
            `SELECT COUNT(*) as count
             FROM thesis_reviews_assignment tra
             JOIN thesis_review_details trd ON tra.id = trd.assignment_id
             WHERE tra.student_id = ?
             AND tra.review_type = 'peer'
             AND tra.status = 'completed'`,  // 添加状态条件
            [studentId]
        );

        console.log('查询结果:', reviews);  // 添加日志

        res.json({
            code: 200,
            data: {
                completedCount: (reviews as any[])[0].count
            },
            message: '获取评阅进度成功'
        });
    } catch (error) {
        console.error('获取评阅进度失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取评阅进度失败'
        });
    }
}; 