import { Request, Response } from 'express';
import pool from '../utils/db';
import { AuthRequest } from '../middleware/auth';
import { logUserAction } from '../utils/logger';

// 获取教师负责的学生开题报告列表
export const getTeacherProposals = async (req: AuthRequest, res: Response) => {
    try {
        const { teacherId } = req.params;
        const [rows] = await pool.execute(`
            SELECT 
                pr.id,
                pr.student_id,
                pr.version,
                pr.file_url,
                pr.status,
                pr.research_background_score,
                pr.technical_route_score,
                pr.feasibility_score,
                pr.innovation_score,
                pr.total_score,
                pr.submit_time,
                pr.review_time,
                s.name as student_name
            FROM proposal_reviews pr
            JOIN students s ON pr.student_id = s.student_id
            WHERE pr.teacher_id = ?
            ORDER BY pr.submit_time DESC
        `, [teacherId]);

        // 记录查看列表日志
        await logUserAction(
            teacherId,
            'proposal.list.view',
            JSON.stringify({
                message: '教师查看开题报告列表',
                timestamp: new Date().toISOString()
            }),
            req
        );

        res.json({ code: 200, data: rows });
    } catch (error) {
        console.error('获取开题报告列表失败:', error);
        res.status(500).json({ code: 500, message: '服务器错误' });
    }
};

// 评审开题报告
export const reviewProposal = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        const { id } = req.params;
        const reviewData = req.body;
        const teacherId = req.user.userId;

        await connection.beginTransaction();

        // 获取学生信息
        const [studentRows] = await connection.execute(
            'SELECT s.name, pr.* FROM proposal_reviews pr JOIN students s ON pr.student_id = s.student_id WHERE pr.id = ?',
            [id]
        );
        const proposalInfo = studentRows[0];

        if (!proposalInfo) {
            await connection.rollback();
            return res.status(404).json({
                code: 404,
                message: '未找到开题报告'
            });
        }

        // 更新评审结果
        await connection.execute(`
            UPDATE proposal_reviews SET 
                research_background_score = ?,
                technical_route_score = ?,
                feasibility_score = ?,
                innovation_score = ?,
                total_score = ?,
                research_background_comment = ?,
                technical_route_comment = ?,
                feasibility_comment = ?,
                innovation_comment = ?,
                general_comment = ?,
                improvement_suggestions = ?,
                status = ?,
                review_time = CURRENT_TIMESTAMP
            WHERE id = ? AND teacher_id = ?
        `, [
            reviewData.researchBackgroundScore,
            reviewData.technicalRouteScore,
            reviewData.feasibilityScore,
            reviewData.innovationScore,
            reviewData.totalScore,
            reviewData.researchBackgroundComment,
            reviewData.technicalRouteComment,
            reviewData.feasibilityComment,
            reviewData.innovationComment,
            reviewData.generalComment,
            reviewData.improvementSuggestions,
            reviewData.status,
            id,
            teacherId
        ]);

        // 记录评审操作日志
        await logUserAction(
            teacherId,
            'proposal.review.submit',
            JSON.stringify({
                proposal_id: id,
                student_name: proposalInfo.name,
                total_score: reviewData.totalScore,
                status: reviewData.status,
                message: `教师完成了学生${proposalInfo.name}的开题报告评审`
            }),
            req
        );

        // 如果评审结果为通过，更新进度记录表
        if (reviewData.status === 'completed') {
            await connection.execute(`
                UPDATE progress_records 
                SET 
                    status = 'completed',
                    score = ?,
                    teacher_comment = ?,
                    review_time = CURRENT_TIMESTAMP
                WHERE student_id = ? AND stage_type = 'proposal'
            `, [
                reviewData.totalScore,
                reviewData.generalComment,
                proposalInfo.student_id
            ]);

            // 更新学生阶段分数表
            await connection.execute(`
                INSERT INTO student_stage_scores (student_id, proposal_score)
                VALUES (?, ?)
                ON DUPLICATE KEY UPDATE
                proposal_score = ?
            `, [
                proposalInfo.student_id,
                reviewData.totalScore,
                reviewData.totalScore
            ]);

            // 重新计算总加权分数
            await connection.execute(`
                UPDATE student_stage_scores sss
                JOIN (
                    SELECT 
                        ss.student_id,
                        COALESCE(SUM(
                            CASE 
                                WHEN ps.type = 'task_book' THEN ss.task_book_score * ps.weight
                                WHEN ps.type = 'literature' THEN ss.literature_score * ps.weight
                                WHEN ps.type = 'proposal' THEN ss.proposal_score * ps.weight
                                WHEN ps.type = 'translation' THEN ss.translation_score * ps.weight
                                WHEN ps.type = 'midterm' THEN ss.midterm_score * ps.weight
                                WHEN ps.type = 'thesis_submit' THEN ss.thesis_submit_score * ps.weight
                                WHEN ps.type = 'advisor_review' THEN ss.advisor_review_score * ps.weight
                                WHEN ps.type = 'peer_review' THEN ss.peer_review_score * ps.weight
                                WHEN ps.type = 'defense' THEN ss.defense_score * ps.weight
                                ELSE 0
                            END
                        ), 0) as total_weighted_score
                    FROM student_stage_scores ss
                    CROSS JOIN progress_stages ps
                    WHERE ps.status = 'active'
                    GROUP BY ss.student_id
                ) as calculated_scores
                ON sss.student_id = calculated_scores.student_id
                SET sss.total_weighted_score = calculated_scores.total_weighted_score
                WHERE sss.student_id = ?
            `, [proposalInfo.student_id]);
        }

        await connection.commit();

        res.json({
            code: 200,
            message: '评审结果已保存'
        });

    } catch (error) {
        await connection.rollback();
        console.error('保存评审结果失败:', error);
        res.status(500).json({
            code: 500,
            message: '保存评审结果失败'
        });
    } finally {
        connection.release();
    }
};

// 获取开题报告详情
export const getProposalDetail = async (req: AuthRequest, res: Response) => {
    try {
        const { id } = req.params;
        const teacherId = req.user.userId;

        const [rows] = await pool.execute(`
            SELECT 
                pr.id,
                pr.student_id,
                pr.version,
                pr.file_url,
                pr.status,
                pr.research_background_score,
                pr.technical_route_score,
                pr.feasibility_score,
                pr.innovation_score,
                pr.total_score,
                pr.research_background_comment,
                pr.technical_route_comment,
                pr.feasibility_comment,
                pr.innovation_comment,
                pr.general_comment,
                pr.improvement_suggestions,
                pr.submit_time,
                pr.review_time,
                s.name as student_name
            FROM proposal_reviews pr
            JOIN students s ON pr.student_id = s.student_id
            WHERE pr.id = ? AND pr.teacher_id = ?
        `, [id, teacherId]);

        if (!rows.length) {
            return res.status(404).json({
                code: 404,
                message: '未找到开题报告'
            });
        }

        // 记录查看详情日志
        await logUserAction(
            teacherId,
            'proposal.detail.view',
            JSON.stringify({
                proposal_id: id,
                student_name: rows[0].student_name,
                message: `教师查看了学生${rows[0].student_name}的开题报告详情`
            }),
            req
        );

        res.json({ code: 200, data: rows[0] });
    } catch (error) {
        console.error('获取开题报告详情失败:', error);
        res.status(500).json({ code: 500, message: '服务器错误' });
    }
};

export const updateProposalReview = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction(); // 开启事务

        const { studentId, ...reviewData } = req.body;
        const teacherId = req.user?.userId;

        // 1. 更新开题报告评审记录
        await connection.query(`
      UPDATE proposal_reviews 
      SET 
        status = ?,
        research_background_score = ?,
        technical_route_score = ?,
        feasibility_score = ?,
        innovation_score = ?,
        total_score = ?,
        research_background_comment = ?,
        technical_route_comment = ?,
        feasibility_comment = ?,
        innovation_comment = ?,
        general_comment = ?,
        improvement_suggestions = ?,
        review_time = NOW()
      WHERE student_id = ? AND teacher_id = ?
      AND version = (
        SELECT max_version FROM (
          SELECT MAX(version) as max_version 
          FROM proposal_reviews 
          WHERE student_id = ?
        ) as t
      )
    `, [
            reviewData.status,
            reviewData.researchBackgroundScore,
            reviewData.technicalRouteScore,
            reviewData.feasibilityScore,
            reviewData.innovationScore,
            reviewData.totalScore,
            reviewData.researchBackgroundComment,
            reviewData.technicalRouteComment,
            reviewData.feasibilityComment,
            reviewData.innovationComment,
            reviewData.generalComment,
            reviewData.improvementSuggestions,
            studentId,
            teacherId,
            studentId
        ]);

        // 2. 如果评审结果为通过，更新进度记录表
        if (reviewData.status === 'completed') {
            await connection.query(`
        UPDATE progress_records 
        SET 
          status = 'completed',
          score = ?,
          teacher_comment = ?,
          review_time = NOW()
        WHERE student_id = ? AND stage_type = 'proposal'
      `, [
                reviewData.totalScore,
                reviewData.generalComment,
                studentId
            ]);

            // 3. 更新学生阶段分数表
            await connection.query(`
        INSERT INTO student_stage_scores (student_id, proposal_score)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE
        proposal_score = ?
      `, [
                studentId,
                reviewData.totalScore,
                reviewData.totalScore
            ]);

            // 4. 重新计算总加权分数
            await connection.query(`
        UPDATE student_stage_scores sss
        JOIN (
          SELECT 
            ss.student_id,
            COALESCE(SUM(
              CASE 
                WHEN ps.type = 'task_book' THEN ss.task_book_score * ps.weight
                WHEN ps.type = 'literature' THEN ss.literature_score * ps.weight
                WHEN ps.type = 'proposal' THEN ss.proposal_score * ps.weight
                WHEN ps.type = 'translation' THEN ss.translation_score * ps.weight
                WHEN ps.type = 'midterm' THEN ss.midterm_score * ps.weight
                WHEN ps.type = 'thesis_draft' THEN ss.thesis_draft_score * ps.weight
                WHEN ps.type = 'thesis_review' THEN ss.thesis_review_score * ps.weight
                WHEN ps.type = 'defense_prep' THEN ss.defense_prep_score * ps.weight
                WHEN ps.type = 'defense' THEN ss.defense_score * ps.weight
                ELSE 0
              END
            ), 0) as total_weighted_score
          FROM student_stage_scores ss
          CROSS JOIN progress_stages ps
          WHERE ps.status = 'active'
          GROUP BY ss.student_id
        ) as calculated_scores
        ON sss.student_id = calculated_scores.student_id
        SET sss.total_weighted_score = calculated_scores.total_weighted_score
        WHERE sss.student_id = ?
      `, [studentId]);
        }

        await connection.commit(); // 提交事务

        res.json({
            code: 200,
            message: '评审结果已保存'
        });

    } catch (error) {
        await connection.rollback(); // 发生错误时回滚事务
        console.error('保存评审结果失败:', error);
        res.status(500).json({
            code: 500,
            message: '保存评审结果失败'
        });
    } finally {
        connection.release();
    }
}; 