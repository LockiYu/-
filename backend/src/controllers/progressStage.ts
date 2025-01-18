import { Request, Response } from 'express';
import pool from '../utils/db';
import { RowDataPacket, ResultSetHeader } from 'mysql2';
import { logUserAction } from '../utils/logger'

// 获取所有阶段
export const getStages = async (req: AuthRequest, res: Response) => {
    try {
        console.log('开始获取阶段列表...');

        // 添加日志记录
        await logUserAction(
            req.user.userId,
            'stage.list',
            '查询阶段列表',
            req
        );

        const [rows] = await pool.execute(`
            SELECT 
                id,
                name,
                type,
                sequence,
                weight,
                description,
                status,
                start_time,
                end_time,
                created_at,
                updated_at
            FROM progress_stages 
            ORDER BY sequence ASC
        `);

        // 转换日期格式和数据处理
        const formattedRows = (rows as any[]).map(row => ({
            ...row,
            start_time: row.start_time ? new Date(row.start_time).toISOString() : null,
            end_time: row.end_time ? new Date(row.end_time).toISOString() : null,
            created_at: row.created_at ? new Date(row.created_at).toISOString() : null,
            updated_at: row.updated_at ? new Date(row.updated_at).toISOString() : null,
            status: row.status || 'not_started'
        }));

        console.log('查询结果:', formattedRows);

        res.json({
            code: 200,
            data: formattedRows,
            message: '获取成功'
        });
    } catch (error: any) {
        console.error('获取阶段列表失败:', error);
        console.error('错误详情:', {
            message: error.message,
            stack: error.stack,
            sqlMessage: error.sqlMessage
        });

        res.status(500).json({
            code: 500,
            message: '获取阶段列表失败',
            error: process.env.NODE_ENV === 'development' ? {
                message: error.message,
                sqlMessage: error.sqlMessage
            } : undefined
        });
    }
};

// 确保数据库连接正常
pool.getConnection()
    .then(connection => {
        console.log('数据库连接成功');
        connection.release();
    })
    .catch(err => {
        console.error('数据库连接失败:', err);
    });

// 添加阶段
export const addStage = async (req: Request, res: Response) => {
    try {
        const { name, type, timeRange, weight, description } = req.body;
        const [startTime, endTime] = timeRange;

        // 转换日期格式
        const formatDate = (date: string) => {
            return new Date(date).toISOString().slice(0, 19).replace('T', ' ');
        };

        const [result] = await pool.execute<ResultSetHeader>(
            `INSERT INTO progress_stages 
            (name, type, start_time, end_time, weight, description) 
            VALUES (?, ?, ?, ?, ?, ?)`,
            [
                name,
                type,
                formatDate(startTime),
                formatDate(endTime),
                weight,
                description
            ]
        );

        // 添加日志记录
        await logUserAction(
            req.user.userId,
            'stage.create',
            `创建新阶段：${name}，类型：${type}，权重：${weight}%`,
            req
        );

        res.json({
            code: 200,
            data: { id: result.insertId },
            message: '添加成功'
        });
    } catch (error: any) {
        res.status(500).json({
            code: 500,
            message: '添加阶段失败',
            error: error.message
        });
    }
};

// 添加状态类型定义
type StageStatus = 'not_started' | 'in_progress' | 'completed' | 'cancelled';

// 更新阶段
export const updateStage = async (req: Request, res: Response) => {
    try {
        const { id } = req.params;
        const { name, type, timeRange, weight, description, status } = req.body;
        const [startTime, endTime] = timeRange;

        // 验证状态值
        const validStatuses: StageStatus[] = ['not_started', 'in_progress', 'completed', 'cancelled'];
        if (!validStatuses.includes(status as StageStatus)) {
            return res.status(400).json({
                code: 400,
                message: '无效的状态值'
            });
        }

        // 转换日期格式
        const formatDate = (date: string) => {
            return new Date(date).toISOString().slice(0, 19).replace('T', ' ');
        };

        await pool.execute(
            `UPDATE progress_stages 
            SET name = ?, type = ?, start_time = ?, end_time = ?, 
                weight = ?, description = ?, status = ? 
            WHERE id = ?`,
            [
                name,
                type,
                formatDate(startTime),
                formatDate(endTime),
                weight,
                description,
                status,
                id
            ]
        );

        // 添加日志记录
        await logUserAction(
            req.user.userId,
            'stage.update',
            `更新阶段：${id}，名称：${name}，状态：${status}，权重：${weight}%`,
            req
        );

        res.json({
            code: 200,
            message: '更新成功'
        });
    } catch (error: any) {
        console.error('更新阶段失败:', error);
        res.status(500).json({
            code: 500,
            message: '更新阶段失败',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

// 删除阶段
export const deleteStage = async (req: Request, res: Response) => {
    try {
        const { id } = req.params;

        // 检查是否有相关的进度记录
        const [records] = await pool.execute<RowDataPacket[]>(
            'SELECT COUNT(*) as count FROM progress_records WHERE stage_id = ?',
            [id]
        );

        if (records[0].count > 0) {
            return res.status(400).json({
                code: 400,
                message: '该阶段已有提交记录，无法删除'
            });
        }

        await pool.execute(
            'DELETE FROM progress_stages WHERE id = ?',
            [id]
        );

        // 添加日志记录
        await logUserAction(
            req.user.userId,
            'stage.delete',
            `删除阶段：${id}`,
            req
        );

        res.json({
            code: 200,
            message: '删除成功'
        });
    } catch (error: any) {
        console.error('删除阶段失败:', error);
        res.status(500).json({
            code: 500,
            message: '删除阶段失败',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

// 确保所有函数都被正确导出
export {
    getStages,
    addStage,
    updateStage,
    deleteStage
};
