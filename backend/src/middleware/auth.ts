/*
 * @Author: test abc@163.com
 * @Date: 2024-12-08 21:13:07
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-15 14:35:52
 * @FilePath: \Graduation Design Management System\backend\src\middleware\auth.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import { Request, Response, NextFunction } from 'express'
import jwt from 'jsonwebtoken'

export interface AuthRequest extends Request {
    user?: any;
}

export const authMiddleware = (req: Request, res: Response, next: NextFunction) => {
    try {
        const authHeader = req.headers.authorization

        if (!authHeader) {
            return res.status(401).json({
                code: 401,
                message: '未提供认证令牌'
            })
        }

        // 处理 Bearer token
        const token = authHeader.startsWith('Bearer ')
            ? authHeader.slice(7)
            : authHeader

        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key')
        req.user = decoded
        next()
    } catch (error) {
        console.error('认证失败:', error)
        res.status(401).json({
            code: 401,
            message: '认证失败'
        })
    }
}

export const roleMiddleware = (roles: string[]) => {
    return (req: AuthRequest, res: Response, next: NextFunction) => {
        if (!req.user) {
            return res.status(401).json({
                code: 401,
                message: '未经过身份验证'
            })
        }

        if (!roles.includes(req.user.role)) {
            return res.status(403).json({
                code: 403,
                message: '权限不足'
            })
        }

        next()
    }
}

export const auth = (allowedRoles?: string[]) => {
    return async (req: Request, res: Response, next: NextFunction) => {
        try {
            const authHeader = req.headers.authorization
            console.log('Auth Header:', authHeader) // 添加调试日志

            if (!authHeader) {
                console.log('No auth header provided') // 添加调试日志
                return res.status(401).json({
                    code: 401,
                    message: '未提供认证令牌'
                })
            }

            // 处理 Bearer token
            const token = authHeader.startsWith('Bearer ')
                ? authHeader.slice(7)
                : authHeader
            
            console.log('Token being verified:', token) // 添加调试日志

            try {
                const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key') as {
                    userId: string
                    username: string
                    role: string
                }
                console.log('Decoded token:', decoded) // 添加调试日志
                
                // 将用户信息添加到请求对象
                req.user = decoded
                
                // 如果指定了角色限制，则验证角色
                if (allowedRoles && !allowedRoles.includes(decoded.role)) {
                    console.log('Role not allowed:', decoded.role, 'Allowed roles:', allowedRoles) // 添加调试日志
                    return res.status(403).json({
                        code: 403,
                        message: '权限不足'
                    })
                }

                next()
            } catch (jwtError) {
                console.error('JWT verification failed:', jwtError) // 添加详细的 JWT 错误日志
                throw jwtError
            }
        } catch (error) {
            console.error('认证失败:', error)
            res.status(401).json({
                code: 401,
                message: '认证失败'
            })
        }
    }
}