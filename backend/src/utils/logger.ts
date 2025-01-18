import { Request } from 'express'
import pool from './db'

export const logUserAction = async (
  userId: string,
  action: string,
  details: string,
  req: Request
) => {
  try {
    // 获取IP地址
    const ipAddress = req.ip || 
      req.headers['x-forwarded-for'] || 
      req.socket.remoteAddress || 
      'unknown'

    const query = `
      INSERT INTO system_logs 
        (user_id, action, ip_address, details) 
      VALUES 
        (?, ?, ?, ?)
    `
    
    await pool.query(query, [userId, action, ipAddress, details])
  } catch (error) {
    console.error('记录用户操作失败:', error)
  }
} 