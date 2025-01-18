import { Request, Response } from 'express'
import pool from '../utils/db'

// 获取学生答辩信息
export const getStudentDefenseInfo = async (req: Request, res: Response) => {
    const studentId = req.user?.userId // 从token中获取学生ID
    
    try {
        const connection = await pool.getConnection()
        
        try {
            // 获取答辩安排信息
            const [arrangements] = await connection.query(`
                SELECT 
                    da.*,
                    GROUP_CONCAT(
                        JSON_OBJECT(
                            'teacher_id', dc.teacher_id,
                            'role', dc.role,
                            'name', u.name,
                            'title', u.title
                        )
                    ) as committee_members
                FROM defense_arrangements da
                LEFT JOIN defense_committees dc ON da.id = dc.arrangement_id
                LEFT JOIN users u ON dc.teacher_id = u.user_id
                WHERE da.student_id = ?
                GROUP BY da.id
            `, [studentId])

            // 如果有答辩安排，获取评分信息
            if (arrangements[0]) {
                const [scores] = await connection.query(`
                    SELECT 
                        ds.*,
                        u.name as teacher_name,
                        u.title as teacher_title
                    FROM defense_scores ds
                    LEFT JOIN users u ON ds.teacher_id = u.user_id
                    WHERE ds.arrangement_id = ?
                `, [arrangements[0].id])

                // 计算平均分
                if (scores.length > 0) {
                    const totalScore = scores.reduce((sum: number, score: any) =>
                        sum + Number(score.total_score), 0)
                    arrangements[0].average_score = (totalScore / scores.length).toFixed(2)
                }

                arrangements[0].scores = scores
                arrangements[0].committee_members = arrangements[0].committee_members ?
                    JSON.parse(`[${arrangements[0].committee_members}]`) : []
            }

            res.json({
                code: 200,
                message: '获取答辩信息成功',
                data: arrangements[0] || null
            })
        } finally {
            connection.release() // 释放连接回连接池
        }
    } catch (error) {
        console.error('获取答辩信息失败:', error)
        res.status(500).json({
            code: 500,
            message: '获取答辩信息失败'
        })
    }
}

// 获取答辩评分详情
export const getStudentDefenseScores = async (req: Request, res: Response) => {
    const studentId = req.user?.userId
    
    try {
        const connection = await pool.getConnection()
        
        try {
            // 先获取学生的答辩安排ID
            const [arrangement] = await connection.query(`
                SELECT id 
                FROM defense_arrangements 
                WHERE student_id = ? 
                AND status = 'completed'
            `, [studentId])

            if (!arrangement[0]) {
                return res.status(404).json({
                    code: 404,
                    message: '未找到已完成的答辩记录'
                })
            }

            // 获取答辩评分详情
            const [scores] = await connection.query(`
                SELECT 
                    ds.*,
                    u.name as teacher_name,
                    u.title as teacher_title
                FROM defense_scores ds
                LEFT JOIN users u ON ds.teacher_id = u.user_id
                WHERE ds.arrangement_id = ?
            `, [arrangement[0].id])

            // 获取最终评审结果
            const [finalResult] = await connection.query(`
                SELECT 
                    status,
                    score,
                    teacher_comment,
                    review_time
                FROM progress_records
                WHERE student_id = ? 
                AND stage_type = 'defense'
            `, [studentId])

            res.json({
                code: 200,
                message: '获取答辩评分成功',
                data: {
                    scores,
                    finalResult: finalResult[0] || null
                }
            })
        } finally {
            connection.release() // 释放连接回连接池
        }
    } catch (error) {
        console.error('获取答辩评分失败:', error)
        res.status(500).json({
            code: 500,
            message: '获取答辩评分失败'
        })
    }
}