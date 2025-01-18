/*
 * @Author: test abc@163.com
 * @Date: 2024-12-08 21:18:34
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-14 16:42:13
 * @FilePath: \Graduation Design Management System\backend\src\routes\users.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import express from 'express';
import {
    getUsers,
    createUser,
    updateUserStatus,
    resetPassword,
    getUserProfile,
    updateUserProfile,
    changePassword,
    getUserById,
    updateUserById,
    deleteUser
} from '../controllers/user';
import { authMiddleware, roleMiddleware } from '../middleware/auth';
import pool from '../utils/db';
import { Response } from 'express';
import { AuthRequest } from '../middleware/auth';

const router = express.Router();

// 用户个人资料路由
router.get('/profile', authMiddleware, getUserProfile);
router.put('/profile', authMiddleware, updateUserProfile);

// 修改密码路由
router.put('/change-password', authMiddleware, changePassword);

// 用户管理路由 - 允许 superadmin 和 admin 访问
router.get('/', authMiddleware, roleMiddleware(['superadmin', 'admin']), getUsers);
router.get('/:userId', authMiddleware, async (req: AuthRequest, res: Response, next) => {
    try {
        // 检查是否是获取自己的信息
        if (req.params.userId === req.user?.userId) {
            const [rows] = await pool.execute(`
                SELECT 
                    user_id,
                    username,
                    role,
                    email,
                    name,
                    department,
                    staff_id,
                    student_id,
                    gender,
                    phone,
                    introduction,
                    login_count
                FROM users 
                WHERE user_id = ?
            `, [req.user.userId]);

            if (!rows[0]) {
                return res.status(404).json({
                    code: 404,
                    message: '用户不存在'
                });
            }

            return res.json({
                code: 200,
                data: rows[0]
            });
        }

        // 如果不是获取自己的信息，则需要管理员权限
        return roleMiddleware(['superadmin', 'admin'])(req, res, next);
    } catch (error) {
        console.error('获取用户信息失败:', error);
        return res.status(500).json({
            code: 500,
            message: '获取用户信息失败'
        });
    }
}, getUserById);
router.put('/:userId', authMiddleware, roleMiddleware(['superadmin', 'admin']), updateUserById);

// 只允许 superadmin 的操作
router.post('/', authMiddleware, roleMiddleware(['superadmin', 'admin']), createUser);
router.put('/status', authMiddleware, roleMiddleware(['superadmin']), updateUserStatus);
router.put('/reset-password', authMiddleware, roleMiddleware(['superadmin']), resetPassword);
router.delete('/:userId', authMiddleware, roleMiddleware(['superadmin', 'admin']), deleteUser);

export default router;