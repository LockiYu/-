import { Request, Response } from 'express';
import pool from '../utils/db';

// 获取公开统计数据
export const getPublicStats = async (req: Request, res: Response) => {
    try {
        const [topicsCount] = await pool.query('SELECT COUNT(*) as count FROM topics WHERE status = "approved"');
        const [supervisorsCount] = await pool.query('SELECT COUNT(*) as count FROM supervisors');
        
        res.json({
            code: 200,
            data: {
                topicsCount: topicsCount[0].count,
                teachersCount: supervisorsCount[0].count
            }
        });
    } catch (error) {
        console.error('获取公开统计数据失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取统计数据失败'
        });
    }
};

// 获取公开教师信息
export const getPublicTeachers = async (req: Request, res: Response) => {
    try {
        const [supervisors] = await pool.query(
            'SELECT supervisor_id as teacher_id, name, title, research_area as research_direction FROM supervisors'
        );
        
        res.json({
            code: 200,
            data: supervisors
        });
    } catch (error) {
        console.error('获取教师信息失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取教师信息失败'
        });
    }
};

// 获取公开题目列表
export const getPublicTopics = async (req: Request, res: Response) => {
    try {
        const [topics] = await pool.query(
            `SELECT t.topic_id, t.title, t.type, t.source, 
            s.name as teacher_name, s.title as teacher_title
            FROM topics t
            LEFT JOIN supervisors s ON t.teacher_id = s.supervisor_id
            WHERE t.status = "approved"
            ORDER BY t.created_at DESC`
        );
        
        res.json({
            code: 200,
            data: topics
        });
    } catch (error) {
        console.error('获取题目列表失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取题目列表失败'
        });
    }
};

// 获取公开公告
export const getPublicAnnouncements = async (req: Request, res: Response) => {
    try {
        const [announcements] = await pool.query(
            'SELECT message_id as id, title, content, created_at FROM system_messages WHERE type = "announcement" ORDER BY created_at DESC LIMIT 10'
        );
        
        res.json({
            code: 200,
            data: announcements
        });
    } catch (error) {
        console.error('获取公告失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取公告失败'
        });
    }
};

// 获取公开答辩安排
export const getPublicDefenseArrangements = async (req: Request, res: Response) => {
    try {
        const [arrangements] = await pool.query(
            `SELECT da.defense_time, da.location, da.duration,
            s.name as student_name, s.major,
            dc.name as committee_name
            FROM defense_arrangements da
            LEFT JOIN students s ON da.student_id = s.student_id
            LEFT JOIN defense_committee dc ON da.committee_id = dc.id
            WHERE da.status != 'cancelled'
            ORDER BY da.defense_time ASC`
        );
        
        res.json({
            code: 200,
            data: arrangements
        });
    } catch (error) {
        console.error('获取答辩安排失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取答辩安排失败'
        });
    }
};