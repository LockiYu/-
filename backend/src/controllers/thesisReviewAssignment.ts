import { Request, Response } from 'express';
import pool from '../utils/db';
import { AuthRequest } from '../middleware/auth';
import { logUserAction } from '../utils/logger';

// 获取当前管理员学院的论文列表
export const getThesisList = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        const adminId = req.user?.userId;

        // 获取管理员所属学院
        const [adminInfo] = await connection.query(`
      SELECT department FROM users WHERE user_id = ?
    `, [adminId]);

        const department = adminInfo[0]?.department;

        // 获取该学院的论文列表
        const [theses] = await connection.query(`
      SELECT 
        ts.*,
        u_student.name as student_name,
        u_student.major as student_major,
        u_student.department as student_department,
        u_teacher.name as teacher_name,
        u_teacher.title as teacher_title,
        topics.teacher_id,
        topics.title as topic_title,
        (
          SELECT COUNT(*)
          FROM thesis_reviews_assignment tra
          WHERE tra.student_id = ts.student_id
        ) as review_assigned_count
      FROM thesis_submissions ts
      JOIN users u_student ON ts.student_id = u_student.user_id
      JOIN topic_selections tsel ON ts.student_id = tsel.student_id
      JOIN topics ON tsel.topic_id = topics.topic_id
      JOIN users u_teacher ON topics.teacher_id = u_teacher.user_id
      WHERE u_student.department = ?
        AND tsel.final_status = 'approved'
      ORDER BY ts.submit_time DESC
    `, [department]);

        res.json({
            code: 200,
            data: theses,
            message: '获取成功'
        });

    } catch (error) {
        console.error('获取论文列表失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取论文列表失败'
        });
    } finally {
        connection.release();
    }
};

// 获取可用的评阅教师列表
export const getAvailableReviewers = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        const adminId = req.user?.userId;

        // 获取管理员所属学院
        const [adminInfo] = await connection.query(`
      SELECT department FROM users WHERE user_id = ?
    `, [adminId]);

        const department = adminInfo[0]?.department;
        console.log('当前管理员所属学院:', department); // 添加日志

        // 获取同一学院的所有导师信息
        const [reviewers] = await connection.query(`
      SELECT DISTINCT
        u.user_id,
        COALESCE(s.name, u.name) as name,
        COALESCE(s.title, u.title) as title,
        COALESCE(s.department, u.department) as department,
        s.research_area
      FROM users u
      LEFT JOIN supervisors s ON u.user_id = s.supervisor_id
      WHERE u.role = 'teacher'
        AND COALESCE(s.department, u.department) = ?
        AND u.status = 'active'
      ORDER BY name ASC
    `, [department]);

        console.log('查询到的评阅教师:', reviewers); // 添加日志

        res.json({
            code: 200,
            data: reviewers,
            message: '获取成功'
        });

    } catch (error) {
        console.error('获取评阅教师列表失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取评阅教师列表失败'
        });
    } finally {
        connection.release();
    }
};

// 分配评阅人
export const assignReviewer = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const { thesis_id, advisor_reviewer, peer_reviewer_ids } = req.body;
        const adminId = req.user?.userId;

        // 验证参数
        if (!thesis_id || !advisor_reviewer || !peer_reviewer_ids || peer_reviewer_ids.length !== 3) {
            throw new Error('参数不完整');
        }

        // 获取论文信息
        const [thesisInfo] = await connection.query(`
      SELECT student_id, status FROM thesis_submissions
      WHERE id = ?
    `, [thesis_id]);

        if (!thesisInfo[0] || thesisInfo[0].status !== 'advisor_approved') {
            throw new Error('论文状态不符合分配条件');
        }

        // 删除已有的分配记录（如果有）
        await connection.query(`
      DELETE FROM thesis_reviews_assignment
      WHERE student_id = ?
    `, [thesisInfo[0].student_id]);

        // 分配导师评阅
        await connection.query(`
      INSERT INTO thesis_reviews_assignment (
        student_id,
        reviewer_id,
        review_type,
        status,
        assigned_at
      ) VALUES (?, ?, 'advisor', 'pending', NOW())
    `, [thesisInfo[0].student_id, advisor_reviewer]);

        // 分配同行评阅
        for (const reviewerId of peer_reviewer_ids) {
            if (!reviewerId) {
                throw new Error('评阅人ID不能为空');
            }

            await connection.query(`
        INSERT INTO thesis_reviews_assignment (
          student_id,
          reviewer_id,
          review_type,
          status,
          assigned_at
        ) VALUES (?, ?, 'peer', 'pending', NOW())
      `, [thesisInfo[0].student_id, reviewerId]);
        }

        // 更新论文状态
        await connection.query(`
      UPDATE thesis_submissions
      SET status = 'review_assigned'
      WHERE id = ?
    `, [thesis_id]);

        // 记录日志
        await logUserAction(
            adminId,
            'thesis.assign_reviewers',
            `分配论文评阅人 - 论文ID: ${thesis_id}, 导师评阅: ${advisor_reviewer}, 同行评阅: ${peer_reviewer_ids.join(',')}`,
            req
        );

        await connection.commit();

        res.json({
            code: 200,
            message: '分配成功'
        });

    } catch (error) {
        await connection.rollback();
        console.error('分配评阅人失败:', error);
        res.status(500).json({
            code: 500,
            message: error.message || '分配评阅人失败'
        });
    } finally {
        connection.release();
    }
};

// 获取论文评阅分配信息
export const getAssignmentInfo = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        const { thesisId } = req.params;
        console.log('正在查询论文ID:', thesisId);

        // 先查询论文基本信息
        const [thesisInfo] = await connection.query(`
      SELECT 
        ts.id,
        ts.title as thesis_title,
        ts.student_id,
        u.name as student_name
      FROM thesis_submissions ts
      JOIN users u ON ts.student_id = u.user_id
      WHERE ts.id = ?
    `, [thesisId]);

        console.log('论文基本信息:', thesisInfo);

        if (!thesisInfo.length) {
            return res.status(404).json({
                code: 404,
                message: '未找到论文信息'
            });
        }

        // 查询评阅分配信息
        const [assignments] = await connection.query(`
      SELECT 
        tra.reviewer_id,
        tra.review_type,
        tra.status,
        tra.assigned_at,
        u.name as reviewer_name,
        u.title as reviewer_title,
        s.research_area
      FROM thesis_reviews_assignment tra
      JOIN users u ON tra.reviewer_id = u.user_id
      LEFT JOIN supervisors s ON tra.reviewer_id = s.supervisor_id
      WHERE tra.student_id = ?
      ORDER BY 
        CASE tra.review_type 
          WHEN 'advisor' THEN 1 
          WHEN 'peer' THEN 2 
          ELSE 3 
        END,
        tra.assigned_at ASC
    `, [thesisInfo[0].student_id]);

        console.log('评阅分配信息:', assignments);

        // 即使没有分配信息，也返回论文基本信息
        res.json({
            code: 200,
            data: {
                thesis_title: thesisInfo[0].thesis_title,
                student_name: thesisInfo[0].student_name,
                assignments: assignments.map(a => ({
                    reviewer_id: a.reviewer_id,
                    reviewer_name: a.reviewer_name,
                    reviewer_title: a.reviewer_title,
                    research_area: a.research_area,
                    review_type: a.review_type,
                    status: a.status,
                    assigned_at: a.assigned_at
                }))
            },
            message: assignments.length ? '获取成功' : '该论文暂无评阅分配信息'
        });

    } catch (error) {
        console.error('获取评阅分配信息失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取评阅分配信息失败'
        });
    } finally {
        connection.release();
    }
}; 