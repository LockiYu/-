import { Request, Response } from 'express'
import pool from '../utils/db'

export const getPublicTopics = async (req: Request, res: Response) => {
    try {
        const { title, type, source } = req.query

        // 构建 WHERE 子句
        let whereClause = 'WHERE t.status = "approved"'
        const params: any[] = []

        if (title) {
            whereClause += ' AND t.title LIKE ?'
            params.push(`%${title}%`)
        }
        if (type) {
            whereClause += ' AND t.type = ?'
            params.push(type)
        }
        if (source) {
            whereClause += ' AND t.source = ?'
            params.push(source)
        }

        // 查询数据
        const [topics] = await pool.execute(
            `SELECT 
                t.*,
                u.username as teacher_name 
            FROM topics t
            LEFT JOIN users u ON t.teacher_id = u.user_id
            ${whereClause}
            ORDER BY t.created_at DESC`,
            params
        )

        res.json({
            code: 200,
            data: topics,
            message: '获取成功'
        })
    } catch (error) {
        console.error('获取公开题目失败:', error)
        res.status(500).json({
            code: 500,
            message: '获取题目失败'
        })
    }
}