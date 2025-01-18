import { Request, Response } from 'express';
import { AuthRequest } from '../middleware/auth';
import pool from '../utils/db';
import { logUserAction } from '../utils/logger';

// 获取答辩安排列表
export const getDefenseArrangements = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        const { pageNum = 1, pageSize = 10, keyword = '', status = '' } = req.query;
        const offset = (Number(pageNum) - 1) * Number(pageSize);

        // 构建查询条件
        let whereClause = '1=1';
        const params: any[] = [];

        if (keyword) {
            whereClause += ` AND (s.student_id LIKE ? OR s.name LIKE ?)`;
            params.push(`%${keyword}%`, `%${keyword}%`);
        }

        if (status) {
            whereClause += ` AND da.status = ?`;
            params.push(status);
        }

        // 查询总数
        const [countResult] = await connection.query(`
            SELECT COUNT(*) as total
            FROM defense_arrangements da
            JOIN students s ON da.student_id = s.student_id
            WHERE ${whereClause}
        `, params);

        // 修改查询，移除 advisor_name 相关的连接
        const [arrangements] = await connection.query(`
            SELECT 
                da.*,
                s.name as student_name,
                s.class_name,
                dc.name as committee_name
            FROM defense_arrangements da
            JOIN students s ON da.student_id = s.student_id
            LEFT JOIN defense_committee dc ON da.committee_id = dc.id
            WHERE ${whereClause}
            ORDER BY da.defense_time ASC
            LIMIT ? OFFSET ?
        `, [...params, Number(pageSize), offset]);

        res.json({
            code: 200,
            data: {
                list: arrangements,
                total: (countResult as any)[0].total,
                pageNum: Number(pageNum),
                pageSize: Number(pageSize)
            }
        });

    } catch (error) {
        console.error('获取答辩安排失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取答辩安排失败'
        });
    } finally {
        connection.release();
    }
};

// 创建答辩安排
export const createDefenseArrangement = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        const {
            student_id,
            committee_id,
            defense_time,
            location,
            duration,
            notes
        } = req.body;

        // 检查是否已存在安排
        const [existing] = await connection.query(
            'SELECT id FROM defense_arrangements WHERE student_id = ?',
            [student_id]
        );

        if ((existing as any[]).length > 0) {
            return res.status(400).json({
                code: 400,
                message: '该学生已有答辩安排'
            });
        }

        // 创建新安排
        const [result] = await connection.query(`
      INSERT INTO defense_arrangements (
        student_id,
        committee_id,
        defense_time,
        location,
        duration,
        notes,
        status
      ) VALUES (?, ?, ?, ?, ?, ?, 'pending')
    `, [student_id, committee_id, defense_time, location, duration, notes]);

        // 记录操作日志
        await logUserAction(
            req.user?.userId,
            'defense.arrange',
            `创建答辩安排: ${student_id}`,
            req
        );

        res.json({
            code: 200,
            message: '创建答辩安排成功',
            data: {
                id: (result as any).insertId
            }
        });

    } catch (error) {
        console.error('创建答辩安排失败:', error);
        res.status(500).json({
            code: 500,
            message: '创建答辩安排失败'
        });
    } finally {
        connection.release();
    }
};

// 更新答辩安排
export const updateDefenseArrangement = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        const { id } = req.params;
        const {
            committee_id,
            defense_time,
            location,
            duration,
            notes,
            status
        } = req.body;

        await connection.query(`
      UPDATE defense_arrangements
      SET 
        committee_id = ?,
        defense_time = ?,
        location = ?,
        duration = ?,
        notes = ?,
        status = ?,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `, [committee_id, defense_time, location, duration, notes, status, id]);

        // 记录操作日志
        await logUserAction(
            req.user?.userId,
            'defense.update',
            `更新答辩安排: ${id}`,
            req
        );

        res.json({
            code: 200,
            message: '更新答辩安排成功'
        });

    } catch (error) {
        console.error('更新答辩安排失败:', error);
        res.status(500).json({
            code: 500,
            message: '更新答辩安排失败'
        });
    } finally {
        connection.release();
    }
};

// 删除答辩安排
export const deleteDefenseArrangement = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        const { id } = req.params;

        await connection.query(
            'DELETE FROM defense_arrangements WHERE id = ?',
            [id]
        );

        // 记录操作日志
        await logUserAction(
            req.user?.userId,
            'defense.delete',
            `删除答辩安排: ${id}`,
            req
        );

        res.json({
            code: 200,
            message: '删除答辩安排成功'
        });

    } catch (error) {
        console.error('删除答辩安排失败:', error);
        res.status(500).json({
            code: 500,
            message: '删除答辩安排失败'
        });
    } finally {
        connection.release();
    }
};

// 获取可安排答辩的学生列表
export const getAvailableStudents = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        const userId = req.user?.userId;
        console.log('当前用户ID:', userId);

        // 先从数据库获取用户信息
        const [userInfo] = await connection.query(`
            SELECT u.department, u.role
            FROM users u
            WHERE u.user_id = ?
        `, [userId]);

        console.log('数据库中的用户信息:', userInfo[0]);

        // 如果是管理员或者没有找到部门信息，不限制部门
        const isAdmin = userInfo[0]?.role === 'admin' || req.user?.role === 'admin';
        const userDepartment = userInfo[0]?.department;

        let sql = `
            SELECT DISTINCT
                s.student_id,
                s.name,
                s.major,
                s.class_name
            FROM students s
            JOIN progress_records pr ON s.student_id = pr.student_id
            LEFT JOIN defense_arrangements da ON s.student_id = da.student_id
            WHERE pr.stage_type = 'peer_review' 
            AND pr.status = 'completed'
            AND da.id IS NULL
        `;
        
        const params = [];
        
        // 非管理员且有部门信息时，添加部门限制
        if (!isAdmin && userDepartment) {
            sql += ` AND s.class_name = ?`;
            params.push(userDepartment);
        }
        
        sql += ` ORDER BY s.student_id`;

        console.log('执行的SQL:', sql);
        console.log('SQL参数:', params);

        const [students] = await connection.query(sql, params);
        
        console.log('查询结果:', students);
        console.log('结果数量:', Array.isArray(students) ? students.length : 0);

        res.json({
            code: 200,
            data: students
        });
    } catch (error) {
        console.error('获取可安排学生列表失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取可安排学生列表失败'
        });
    } finally {
        connection.release();
    }
};

// 获取答辩委员会列表
export const getDefenseCommittees = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        const [committees] = await connection.query(`
      SELECT 
        dc.*,
        u1.name as chairman_name,
        u2.name as secretary_name,
        u3.name as member1_name,
        u4.name as member2_name,
        u5.name as member3_name
      FROM defense_committee dc
      JOIN users u1 ON dc.chairman_id = u1.user_id
      JOIN users u2 ON dc.secretary_id = u2.user_id
      JOIN users u3 ON dc.member1_id = u3.user_id
      JOIN users u4 ON dc.member2_id = u4.user_id
      JOIN users u5 ON dc.member3_id = u5.user_id
      ORDER BY dc.id
    `);

        res.json({
            code: 200,
            data: committees
        });

    } catch (error) {
        console.error('获取答辩委员会列表失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取答辩委员会列表失败'
        });
    } finally {
        connection.release();
    }
};

// 创建答辩委员会
export const createDefenseCommittee = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        const {
            name,
            chairman_id,
            secretary_id,
            member1_id,
            member2_id,
            member3_id
        } = req.body;

        // 检查成员是否重复
        const members = new Set([chairman_id, secretary_id, member1_id, member2_id, member3_id]);
        if (members.size !== 5) {
            return res.status(400).json({
                code: 400,
                message: '委员会成员不能重复'
            });
        }

        const [result] = await connection.query(`
      INSERT INTO defense_committee (
        name,
        chairman_id,
        secretary_id,
        member1_id,
        member2_id,
        member3_id
      ) VALUES (?, ?, ?, ?, ?, ?)
    `, [name, chairman_id, secretary_id, member1_id, member2_id, member3_id]);

        await logUserAction(
            req.user?.userId,
            'defense.committee.create',
            `创建答辩委员会: ${name}`,
            req
        );

        res.json({
            code: 200,
            message: '创建答辩委员会成功',
            data: {
                id: (result as any).insertId
            }
        });

    } catch (error) {
        console.error('创建答辩委员会失败:', error);
        res.status(500).json({
            code: 500,
            message: '创建答辩委员会失败'
        });
    } finally {
        connection.release();
    }
};

// 更新答辩委员会
export const updateDefenseCommittee = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        const { id } = req.params;
        const {
            name,
            chairman_id,
            secretary_id,
            member1_id,
            member2_id,
            member3_id
        } = req.body;

        // 检查成员是否重复
        const members = new Set([chairman_id, secretary_id, member1_id, member2_id, member3_id]);
        if (members.size !== 5) {
            return res.status(400).json({
                code: 400,
                message: '委员会成员不能重复'
            });
        }

        await connection.query(`
      UPDATE defense_committee
      SET 
        name = ?,
        chairman_id = ?,
        secretary_id = ?,
        member1_id = ?,
        member2_id = ?,
        member3_id = ?,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `, [name, chairman_id, secretary_id, member1_id, member2_id, member3_id, id]);

        await logUserAction(
            req.user?.userId,
            'defense.committee.update',
            `更新答辩委员会: ${id}`,
            req
        );

        res.json({
            code: 200,
            message: '更新答辩委员会成功'
        });

    } catch (error) {
        console.error('更新答辩委员会失败:', error);
        res.status(500).json({
            code: 500,
            message: '更新答辩委员会失败'
        });
    } finally {
        connection.release();
    }
};

// 删除答辩委员会
export const deleteDefenseCommittee = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        const { id } = req.params;
        await connection.query('DELETE FROM defense_committee WHERE id = ?', [id]);

        await logUserAction(
            req.user?.userId,
            'defense.committee.delete',
            `删除答辩委员会: ${id}`,
            req
        );

        res.json({
            code: 200,
            message: '删除答辩委员会成功'
        });
    } catch (error) {
        console.error('删除答辩委员会失败:', error);
        res.status(500).json({
            code: 500,
            message: '删除答辩委员会失败'
        });
    } finally {
        connection.release();
    }
};

// 获取可用教师列表
export const getAvailableTeachers = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        const [teachers] = await connection.query(`
      SELECT user_id, name, title
      FROM users
      WHERE role = 'teacher'
      AND status = 'active'
      ORDER BY name
    `);

        res.json({
            code: 200,
            data: teachers
        });

    } catch (error) {
        console.error('获取教师列表失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取教师列表失败'
        });
    } finally {
        connection.release();
    }
};

// 获取答辩评分列表
export const getDefenseScores = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        const { pageNum = 1, pageSize = 10, status = '' } = req.query;
        const offset = (Number(pageNum) - 1) * Number(pageSize);
        const currentUserId = req.user?.userId;

        // 构建查询条件
        let whereClause = `
            (dc.chairman_id = ? OR dc.secretary_id = ? 
            OR dc.member1_id = ? OR dc.member2_id = ? OR dc.member3_id = ?)
        `;
        const params = [currentUserId, currentUserId, currentUserId, currentUserId, currentUserId];

        if (status) {
            whereClause += ` AND da.status = ?`;
            params.push(status);
        }

        // 查询总数
        const [countResult] = await connection.query(`
            SELECT COUNT(DISTINCT da.id) as total
            FROM defense_arrangements da
            JOIN defense_committee dc ON da.committee_id = dc.id
            WHERE ${whereClause}
        `, params);

        // 查询列表
        const [arrangements] = await connection.query(`
            SELECT 
                da.*,
                s.name as student_name,
                s.student_id,
                dc.name as committee_name,
                CASE 
                    WHEN ds.id IS NOT NULL THEN 'scored'
                    WHEN da.status = 'completed' THEN 'closed'
                    ELSE 'pending'
                END as score_status
            FROM defense_arrangements da
            JOIN students s ON da.student_id = s.student_id
            JOIN defense_committee dc ON da.committee_id = dc.id
            LEFT JOIN defense_scores ds ON da.id = ds.arrangement_id 
                AND ds.teacher_id = ?
            WHERE ${whereClause}
            ORDER BY da.defense_time DESC
            LIMIT ? OFFSET ?
        `, [...params, currentUserId, Number(pageSize), offset]);

        res.json({
            code: 200,
            data: {
                list: arrangements,
                total: (countResult as any)[0].total,
                pageNum: Number(pageNum),
                pageSize: Number(pageSize)
            }
        });

    } catch (error) {
        console.error('获取答辩评分列表失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取答辩评分列表失败'
        });
    } finally {
        connection.release();
    }
};

// 提交答辩评分
export const submitDefenseScore = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction(); // 开启事务

        const {
            arrangement_id,
            presentation_score,
            qa_score,
            innovation_score,
            completion_score,
            comments,
            revision_requirements
        } = req.body;
        const teacher_id = req.user?.userId;

        // 验证是否为委员会成员
        const [committeeResult] = await connection.query(`
            SELECT dc.*, da.student_id 
            FROM defense_arrangements da
            JOIN defense_committee dc ON da.committee_id = dc.id
            WHERE da.id = ?
        `, [arrangement_id]);

        const committee = committeeResult[0];
        if (!committee || ![
            committee.chairman_id,
            committee.secretary_id,
            committee.member1_id,
            committee.member2_id,
            committee.member3_id
        ].includes(teacher_id)) {
            await connection.rollback();
            return res.status(403).json({
                code: 403,
                message: '您不是该答辩委员会成员'
            });
        }

        // 检查是否已评分
        const [existing] = await connection.query(
            'SELECT id FROM defense_scores WHERE arrangement_id = ? AND teacher_id = ?',
            [arrangement_id, teacher_id]
        );

        if ((existing as any[]).length > 0) {
            await connection.rollback();
            return res.status(400).json({
                code: 400,
                message: '您已经提交过评分'
            });
        }

        // 计算总分
        const total_score = (
            Number(presentation_score) +
            Number(qa_score) +
            Number(innovation_score) +
            Number(completion_score)
        ) / 4;

        // 提交评分
        await connection.query(`
            INSERT INTO defense_scores (
                arrangement_id,
                teacher_id,
                presentation_score,
                qa_score,
                innovation_score,
                completion_score,
                total_score,
                comments,
                revision_requirements
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        `, [
            arrangement_id,
            teacher_id,
            presentation_score,
            qa_score,
            innovation_score,
            completion_score,
            total_score,
            comments,
            revision_requirements
        ]);

        // 检查是否所有委员都已评分
        const [scoresCount] = await connection.query(`
            SELECT COUNT(*) as count
            FROM defense_scores
            WHERE arrangement_id = ?
        `, [arrangement_id]);

        if ((scoresCount[0] as any).count === 5) { // 所有委员都已评分
            // 获取所有评分结果，包括评定结果
            const [finalScores] = await connection.query(`
                SELECT 
                    AVG(total_score) as final_score,
                    GROUP_CONCAT(comments SEPARATOR '\n') as all_comments,
                    GROUP_CONCAT(revision_requirements SEPARATOR '\n') as all_requirements,
                    GROUP_CONCAT(result) as all_results
                FROM defense_scores
                WHERE arrangement_id = ?
            `, [arrangement_id]);

            // 检查是否所有评委都给出了通过的结果
            const allResults = finalScores[0].all_results.split(',');
            const allPassed = allResults.every(result => result === 'pass');

            // 组合最终评语
            let finalComment = '答辩评分意见：\n' + finalScores[0].all_comments;
            if (finalScores[0].all_requirements) {
                finalComment += '\n\n修改要求：\n' + finalScores[0].all_requirements;
            }
            finalComment += '\n\n最终结果：' + (allPassed ? '通过' : '需要修改');

            // 使用存储过程或直接SQL来更新，跳过触发器
            await connection.query(`
                UPDATE progress_records 
                SET 
                    status = ?,
                    score = ?,
                    teacher_comment = ?,
                    review_time = CURRENT_TIMESTAMP,
                    updated_at = CURRENT_TIMESTAMP
                WHERE student_id = ? AND stage_type = 'defense'
                AND EXISTS (
                    SELECT 1 FROM defense_arrangements da
                    WHERE da.student_id = ? AND da.id = ?
                )
            `, [
                allPassed ? 'completed' : 'revision_needed',
                finalScores[0].final_score,
                finalComment,
                committee.student_id,
                committee.student_id,
                arrangement_id
            ]);

            // 如果没有更新任何记录，说明需要插入
            if (connection.affectedRows === 0) {
                await connection.query(`
                    INSERT INTO progress_records (
                        student_id,
                        stage_type,
                        status,
                        score,
                        teacher_comment,
                        review_time,
                        created_at,
                        updated_at
                    ) VALUES (?, 'defense', ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
                `, [
                    committee.student_id,
                    allPassed ? 'completed' : 'revision_needed',
                    finalScores[0].final_score,
                    finalComment
                ]);
            }

            // 更新答辩安排状态
            await connection.query(`
                UPDATE defense_arrangements
                SET status = 'completed'
                WHERE id = ?
            `, [arrangement_id]);

            // 在返回结果中添加最终评审结果
            res.json({
                code: 200,
                message: '提交评分成功',
                data: {
                    isCompleted: true,
                    allPassed: allPassed,
                    finalScore: finalScores[0].final_score
                }
            });
        } else {
            // 未完成全部评分时的返回
            res.json({
                code: 200,
                message: '提交评分成功',
                data: {
                    isCompleted: false
                }
            });
        }

        await connection.commit();
        await logUserAction(
            teacher_id,
            'defense.score.submit',
            `提交答辩评分: ${arrangement_id}`,
            req
        );

    } catch (error) {
        await connection.rollback();
        console.error('提交答辩评分失败:', error);
        res.status(500).json({
            code: 500,
            message: '提交答辩评分失败'
        });
    } finally {
        connection.release();
    }
};

// 获取答辩评分详情
export const getDefenseScoreDetail = async (req: AuthRequest, res: Response) => {
    const connection = await pool.getConnection();
    try {
        const { arrangementId } = req.params;
        const currentUserId = req.user?.userId;

        // 检查权限并获取学生信息
        const [committee] = await connection.query(`
            SELECT dc.*, da.student_id 
            FROM defense_arrangements da
            JOIN defense_committee dc ON da.committee_id = dc.id
            WHERE da.id = ?
        `, [arrangementId]);

        if (!committee[0] || ![
            committee[0].chairman_id,
            committee[0].secretary_id,
            committee[0].member1_id,
            committee[0].member2_id,
            committee[0].member3_id
        ].includes(currentUserId)) {
            return res.status(403).json({
                code: 403,
                message: '您不是该答辩委员会成员'
            });
        }

        // 获取评分
        const [scores] = await connection.query(`
            SELECT 
                ds.*,
                u.name as teacher_name
            FROM defense_scores ds
            JOIN users u ON ds.teacher_id = u.user_id
            WHERE ds.arrangement_id = ?
            ${committee[0].chairman_id !== currentUserId ? 'AND ds.teacher_id = ?' : ''}
        `, committee[0].chairman_id !== currentUserId ? [arrangementId, currentUserId] : [arrangementId]);

        // 获取进度记录中的最终评分
        const [finalScore] = await connection.query(`
            SELECT 
                status,
                score,
                teacher_comment,
                review_time
            FROM progress_records
            WHERE student_id = ? AND stage_type = 'defense'
        `, [committee[0].student_id]);

        res.json({
            code: 200,
            data: {
                scores: scores,
                final: finalScore[0] || {
                    status: 'in_progress',
                    score: null,
                    teacher_comment: null,
                    review_time: null
                },
                isChairman: committee[0].chairman_id === currentUserId
            }
        });

    } catch (error) {
        console.error('获取答辩评分详情失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取答辩评分详情失败'
        });
    } finally {
        connection.release();
    }
}; 