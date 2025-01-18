/*
 * @Author: test abc@163.com
 * @Date: 2024-12-08 21:12:44
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-15 14:46:39
 * @FilePath: \Graduation Design Management System\backend\src\utils\db.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import mysql from 'mysql2/promise'
import dotenv from 'dotenv'

dotenv.config()

// 创建数据库连接池
const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'graduation_design',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
})

// 测试连接
pool.getConnection()
    .then(connection => {
        console.log('数据库连接成功')
        connection.release()
    })
    .catch(err => {
        console.error('数据库连接失败:', err)
        process.exit(1)
    })

export default pool 