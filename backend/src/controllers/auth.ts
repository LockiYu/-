/*
 * @Author: test abc@163.com
 * @Date: 2024-12-08 21:17:30
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-10 22:35:23
 * @FilePath: \Graduation Design Management System\backend\src\controllers\auth.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import * as bcrypt from 'bcryptjs';
import * as jwt from 'jsonwebtoken';
import { Request, Response } from 'express';
import { pool } from '../db';
import { logUserAction } from '../utils/logger'

export const login = async (req: Request, res: Response) => {
    try {
        console.log('Login request body:', req.body);
        const { username, password } = req.body;

        if (!username || !password) {
            console.log('Missing credentials');
            return res.status(400).json({
                code: 400,
                message: '用户名和密码不能为空'
            });
        }

        console.log('Querying user:', username);
        const [users] = await pool.execute(
            'SELECT * FROM users WHERE username = ?',
            [username]
        );

        console.log('Query result:', users);

        if (!Array.isArray(users) || users.length === 0) {
            console.log('User not found');
            return res.status(401).json({
                code: 401,
                message: '用户不存在'
            });
        }

        const user = users[0];

        console.log('Verifying password');
        const validPassword = await bcrypt.compare(password, user.password);
        if (!validPassword) {
            // 记录登录失败
            await logUserAction(
                user.user_id,
                'user.login.failed',
                `用户 ${user.username} 登录失败：密码错误`,
                req
            )
            return res.status(401).json({
                code: 401,
                message: '用户名或密码错误'
            });
        }

        // 更新登录次数和登录信息
        const newLoginCount = (user.login_count || 0) + 1;
        await pool.execute(
            `UPDATE users 
             SET login_count = ?,
                 last_login_time = NOW(),
                 last_login_ip = ?
             WHERE user_id = ?`,
            [newLoginCount, req.ip || '未知', user.user_id]
        );

        // 记录登录成功
        await logUserAction(
            user.user_id,
            'user.login.success',
            `用户 ${user.username} 登录成功`,
            req
        )

        // 生成 token
        const token = jwt.sign(
            {
                userId: user.user_id,
                username: user.username,
                role: user.role
            },
            process.env.JWT_SECRET || 'your-secret-key',
            { expiresIn: '1d' }
        );

        // 返回用户信息和token
        res.json({
            code: 200,
            message: '登录成功',
            data: {
                token,
                userInfo: {
                    userId: user.user_id,
                    username: user.username,
                    role: user.role,
                    staffId: user.staff_id,
                    studentId: user.student_id,
                    loginCount: newLoginCount,
                    lastLoginTime: new Date(), // 添加最后登录时间
                    lastLoginIp: req.ip || '未知' // 添加最后登录IP
                }
            }
        });

    } catch (error) {
        console.error('Login error:', error)
        // 记录系统错误
        if (req.body.username) {
            const [users] = await pool.execute(
                'SELECT user_id FROM users WHERE username = ?',
                [req.body.username]
            )
            if (Array.isArray(users) && users.length > 0) {
                await logUserAction(
                    users[0].user_id,
                    'user.login.error',
                    `用户 ${req.body.username} 登录时发生系统错误: ${error.message}`,
                    req
                )
            }
        }
        res.status(500).json({
            code: 500,
            message: '服务器错误',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        })
    }
};

export const register = async (req: Request, res: Response) => {
    try {
        console.log('Register request received:', req.body);
        const { username, password, role, studentId, staffId } = req.body;

        // 验证必填字段
        if (!username || !password || !role) {
            return res.status(400).json({
                code: 400,
                message: '用户名、密码和角色不能为空'
            });
        }

        // 验证角色特定字段
        if (role === 'student' && !studentId) {
            return res.status(400).json({
                code: 400,
                message: '学生注册需要提供学号'
            });
        }

        if (role === 'teacher' && !staffId) {
            return res.status(400).json({
                code: 400,
                message: '教师注册需要提供职工号'
            });
        }

        // 检查用户名是否已存在
        const [existingUsers] = await pool.execute(
            'SELECT * FROM users WHERE username = ?',
            [username]
        );

        if (Array.isArray(existingUsers) && existingUsers.length > 0) {
            return res.status(409).json({
                code: 409,
                message: '该用户名已被注册'
            });
        }

        // 如果是教师，检查职工号
        if (role === 'teacher' && staffId) {
            const [existingStaff] = await pool.execute(
                'SELECT * FROM users WHERE staff_id = ?',
                [staffId]
            );
            if (Array.isArray(existingStaff) && existingStaff.length > 0) {
                return res.status(409).json({
                    code: 409,
                    message: 'staff_id_exists'
                });
            }
        }

        // 如果是学生，检查学号
        if (role === 'student' && studentId) {
            const [existingStudent] = await pool.execute(
                'SELECT * FROM users WHERE student_id = ?',
                [studentId]
            );
            if (Array.isArray(existingStudent) && existingStudent.length > 0) {
                return res.status(409).json({
                    code: 409,
                    message: 'student_id_exists'
                });
            }
        }

        // 生成密码的哈希值
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // 生成用户ID
        const generateUserId = () => {
            const prefix = role === 'teacher' ? 'T' : role === 'student' ? 'S' : 'G';
            const timestamp = Date.now().toString().slice(-7);  // 使用时间戳后7位
            const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');  // 3位随机数
            return `${prefix}${timestamp}${random}`;
        };

        const userId = generateUserId();

        // 插入新用户
        await pool.execute(
            'INSERT INTO users (user_id, username, password, role, staff_id, student_id) VALUES (?, ?, ?, ?, ?, ?)',
            [userId, username, hashedPassword, role, staffId || null, studentId || null]
        );

        // 添加日志记录
        await logUserAction(
            userId,
            'user.register',
            `用户 ${username} 注册成功`,
            req
        )

        res.status(200).json({
            code: 200,
            message: '注册成功'
        });

    } catch (error) {
        console.error('Register error details:', {
            error,
            stack: error.stack,
            body: req.body
        });
        res.status(500).json({
            code: 500,
            message: '服务器错误',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

export const logout = async (req: Request, res: Response) => {
    try {
        const user = (req as any).user // 从JWT中获取的用户信息

        if (user?.userId) {
            // 记录退出登录
            await logUserAction(
                user.userId,
                'user.logout',
                `用户 ${user.username} 退出登录`,
                req
            )
        }

        res.status(200).json({
            code: 200,
            message: '退出成功'
        })
    } catch (error) {
        console.error('Logout error:', error)
        res.status(200).json({
            code: 200,
            message: '退出成功'
        })
    }
}