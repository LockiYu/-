import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import pool from '../utils/db';

export const getUsers = async (req: Request, res: Response) => {
    try {
        const [rows] = await pool.execute(`
      SELECT user_id, username, role, status, created_at
      FROM users
      WHERE role != 'system_admin'
      ORDER BY created_at DESC
    `);

        res.json({ data: rows });
    } catch (error) {
        console.error('Get users error:', error);
        res.status(500).json({ message: '服务器错误' });
    }
};

export const createUser = async (req: Request, res: Response) => {
    try {
        const { username, password, role } = req.body;

        // 检查用户名是否已存在
        const [existing]: any = await pool.execute(
            'SELECT * FROM users WHERE username = ?',
            [username]
        );

        if (existing.length > 0) {
            return res.status(400).json({ message: '用户名已存在' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        await pool.execute(
            'INSERT INTO users (username, password, role) VALUES (?, ?, ?)',
            [username, hashedPassword, role]
        );

        res.status(201).json({ message: '用户创建成功' });
    } catch (error) {
        console.error('Create user error:', error);
        res.status(500).json({ message: '服务器错误' });
    }
};

export const updateUserStatus = async (req: Request, res: Response) => {
    try {
        const { user_id, status } = req.body;

        await pool.execute(
            'UPDATE users SET status = ? WHERE user_id = ?',
            [status, user_id]
        );

        res.json({ message: '用户状态更新成功' });
    } catch (error) {
        console.error('Update user status error:', error);
        res.status(500).json({ message: '服务器错误' });
    }
};

export const resetPassword = async (req: Request, res: Response) => {
    try {
        const { user_id, new_password } = req.body;

        const hashedPassword = await bcrypt.hash(new_password, 10);

        await pool.execute(
            'UPDATE users SET password = ? WHERE user_id = ?',
            [hashedPassword, user_id]
        );

        res.json({ message: '密码重置成功' });
    } catch (error) {
        console.error('Reset password error:', error);
        res.status(500).json({ message: '服务器错误' });
    }
};

export const getUserProfile = async (req: Request, res: Response) => {
    try {
        const { user_id } = req.params;

        const [users]: any = await pool.execute(
            'SELECT user_id, username, role, status, created_at FROM users WHERE user_id = ?',
            [user_id]
        );

        if (users.length === 0) {
            return res.status(404).json({ message: '用户不存在' });
        }

        res.json({ data: users[0] });
    } catch (error) {
        console.error('Get user profile error:', error);
        res.status(500).json({ message: '服务器错误' });
    }
};