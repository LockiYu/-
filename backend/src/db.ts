import mysql from 'mysql2/promise';

export const pool = mysql.createPool({
    host: 'localhost',
    user: 'root',  // 你的 MySQL 用户名
    password: '66176488',  // 你的 MySQL 密码
    database: 'graduation_management',  // 修改为你的数据库名
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// 测试数据库连接
pool.getConnection()
    .then(connection => {
        console.log('数据库连接成功');
        connection.release();
    })
    .catch(err => {
        console.error('数据库连接失败:', err);
    });