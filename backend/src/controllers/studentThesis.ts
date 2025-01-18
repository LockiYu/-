import { Response } from 'express';
import { AuthRequest } from '../middleware/auth';
import pool from '../utils/db';

export const getStudentThesisHistory = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        const studentId = req.user?.userId;

        const [submissions] = await connection.query(`
      SELECT 
        ts.*,
        u.name as advisor_name,
        u.title as advisor_title
      FROM thesis_submissions ts
      LEFT JOIN users u ON ts.advisor_id = u.user_id
      WHERE ts.student_id = ?
      ORDER BY ts.submit_time DESC
      LIMIT 1`,
            [studentId]
        );

        if (!submissions || submissions.length === 0) {
            return res.json({
                code: 200,
                data: null
            });
        }

        const submission = submissions[0];
        if (submission.submit_time) {
            submission.submit_time = new Date(submission.submit_time)
                .toISOString()
                .slice(0, 19)
                .replace('T', ' ');
        }
        if (submission.advisor_review_time) {
            submission.advisor_review_time = new Date(submission.advisor_review_time)
                .toISOString()
                .slice(0, 19)
                .replace('T', ' ');
        }

        res.json({
            code: 200,
            data: submission
        });

    } catch (error) {
        console.error('获取论文提交历史失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取论文提交历史失败'
        });
    } finally {
        connection.release();
    }
};

export const getStudentThesisReviews = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        const studentId = req.params.studentId;

        // 获取评阅分配信息和详情
        const [reviews] = await connection.query(`
      SELECT 
        tra.id as assignment_id,
        tra.review_type,
        tra.status as assignment_status,
        tra.assigned_at,
        tra.completed_at,
        trd.score_innovation,
        trd.score_quality,
        trd.score_workload,
        trd.score_writing,
        trd.total_score,
        trd.review_comments,
        trd.review_time,
        u.name as reviewer_name
      FROM thesis_reviews_assignment tra
      LEFT JOIN thesis_review_details trd ON tra.id = trd.assignment_id
      LEFT JOIN users u ON tra.reviewer_id = u.user_id
      WHERE tra.student_id = ?
      ORDER BY tra.review_type, tra.assigned_at DESC
    `, [studentId]);

        // 整理数据结构
        const result = {
            advisor_review: null,
            peer_reviews: []
        };

        reviews.forEach((review: any) => {
            const reviewData = {
                assignment_id: review.assignment_id,
                status: review.assignment_status,
                assigned_at: review.assigned_at,
                completed_at: review.completed_at,
                reviewer_name: review.reviewer_name,
                score_innovation: review.score_innovation,
                score_quality: review.score_quality,
                score_workload: review.score_workload,
                score_writing: review.score_writing,
                total_score: review.total_score,
                review_comments: review.review_comments,
                review_time: review.review_time
            };

            if (review.review_type === 'advisor') {
                result.advisor_review = reviewData;
            } else {
                result.peer_reviews.push(reviewData);
            }
        });

        res.json({
            code: 200,
            data: result,
            message: '获取论文评阅详情成功'
        });

    } catch (error) {
        console.error('获取论文评阅详情失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取论文评阅详情失败'
        });
    } finally {
        connection.release();
    }
};