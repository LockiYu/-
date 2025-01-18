/*
 * @Author: test abc@163.com
 * @Date: 2024-03-15 16:13:52
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-29 21:06:43
 * @FilePath: \Graduation Design Management System\backend\src\controllers\system.ts
 * @Description: 系统控制器
 */

import { Request, Response } from 'express';
import { exec } from 'child_process';
import path from 'path';
import fs from 'fs';
import util from 'util';
import pool from '../utils/db';
import * as XLSX from 'xlsx';

const execPromise = util.promisify(exec);

export const backupDatabase = async (req: Request, res: Response) => {
  try {
    // 1. 确保备份目录存在
    const backupDir = './backups';
    if (!fs.existsSync(backupDir)) {
      fs.mkdirSync(backupDir);
    }

    // 2. 生成备份文件名
    const date = new Date().toISOString().slice(0, 19).replace(/[:.]/g, '-');
    const filename = `backup-${date}.sql`;
    const filePath = path.join(backupDir, filename);

    // 3. 创建临时配置文件
    const tempConfigPath = path.join(backupDir, '.temp.cnf');
    const configContent = `
[client]
host=${process.env.DB_HOST}
user=${process.env.DB_USER}
password=${process.env.DB_PASSWORD}
`;
    fs.writeFileSync(tempConfigPath, configContent, { mode: 0o600 });

    // 4. 先检查并处理视图问题
    const connection = await pool.getConnection();
    try {
      // 获取所有视图
      const [views] = await connection.query(`
        SELECT TABLE_NAME 
        FROM information_schema.VIEWS 
        WHERE TABLE_SCHEMA = ?
      `, [process.env.DB_NAME]);

      // 临时禁用可能有问题的视图
      for (const view of views as any[]) {
        await connection.query(`
          DROP VIEW IF EXISTS ${view.TABLE_NAME}
        `).catch(err => console.warn(`Warning: Could not drop view ${view.TABLE_NAME}:`, err));
      }

      // 5. 执行备份命令（使用配置文件）
      const command = `mysqldump --defaults-file="${tempConfigPath}" --skip-comments --single-transaction --routines --triggers ${process.env.DB_NAME} > "${filePath}"`;
      console.log('开始备份数据库...');
      const { stdout, stderr } = await execPromise(command);

      if (stderr && !stderr.includes('Warning')) {
        throw new Error(stderr);
      }

      // 6. 重建视图（如果需要）
      // 这里可以添加重建视图的逻辑

      console.log('备份完成');

      // 7. 记录成功日志
      await pool.execute(`
        INSERT INTO system_logs (user_id, action, ip_address, details)
        VALUES (?, ?, ?, ?)
      `, [
        req.user?.userId,
        'system.database.backup',
        req.ip,
        JSON.stringify({
          message: '数据库备份成功',
          filename,
          path: filePath,
          timestamp: new Date().toISOString()
        })
      ]);

      res.json({
        code: 200,
        message: '数据库备份成功',
        data: {
          filename,
          path: filePath,
          time: date
        }
      });

    } finally {
      // 8. 清理临时文件
      if (fs.existsSync(tempConfigPath)) {
        fs.unlinkSync(tempConfigPath);
      }
      connection.release();
    }

  } catch (error: any) {
    // 记录错误日志
    await pool.execute(`
      INSERT INTO system_logs (user_id, action, ip_address, details)
      VALUES (?, ?, ?, ?)
    `, [
      req.user?.userId,
      'system.database.backup.error',
      req.ip,
      JSON.stringify({
        message: '数据库备份失败',
        error: error.message,
        timestamp: new Date().toISOString()
      })
    ]);

    console.error('备份失败:', error);
    res.status(500).json({
      code: 500,
      message: '备份失败: ' + error.message
    });
  }
};

// 添加数据恢复控制器
export const restoreDatabase = async (req: AuthRequest, res: Response) => {
  try {
    const { filename, newDbName } = req.body;
    const backupDir = path.join(__dirname, '../../backups');
    const filePath = path.join(backupDir, filename);

    // 检查文件是否存在
    if (!fs.existsSync(filePath)) {
      throw new Error('备份文件不存在');
    }

    // 验证新数据库名称
    if (!/^[a-zA-Z][a-zA-Z0-9_]*$/.test(newDbName)) {
      throw new Error('数据库名称格式不正确');
    }

    // 创建新数据库
    const createDbCommand = `mysql -h${process.env.DB_HOST} -u${process.env.DB_USER} -p${process.env.DB_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${newDbName}"`;

    // 先创建数据库
    await execPromise(createDbCommand);

    // 执行恢复命令到新数据库
    const mysqlRestore = `mysql -h${process.env.DB_HOST} -u${process.env.DB_USER} -p${process.env.DB_PASSWORD} ${newDbName} < "${filePath}"`;
    await execPromise(mysqlRestore);

    // 记录恢复操作到系统日志
    await pool.execute(`
      INSERT INTO system_logs (user_id, action, ip_address, details)
      VALUES (?, ?, ?, ?)
    `, [
      req.user?.userId,
      'system.database.restore',
      req.ip,
      JSON.stringify({
        message: '数据库恢复完成',
        filename,
        newDbName,
        backupPath: filePath,
        originalDb: process.env.DB_NAME,
        timestamp: new Date().toISOString()
      })
    ]);

    res.json({
      code: 200,
      message: '数据恢复成功',
      data: {
        newDbName,
        backupPath: filePath,
        originalDb: process.env.DB_NAME,
        restoreCommand: `mysql -h${process.env.DB_HOST} -u${process.env.DB_USER} -p${process.env.DB_PASSWORD} ${process.env.DB_NAME} < "${filePath}"`
      }
    });

  } catch (error: any) {
    // 记录错误日志
    await pool.execute(`
      INSERT INTO system_logs (user_id, action, ip_address, details)
      VALUES (?, ?, ?, ?)
    `, [
      req.user?.userId,
      'system.database.restore.error',
      req.ip,
      JSON.stringify({
        message: '数据库恢复失败',
        error: error.message,
        timestamp: new Date().toISOString()
      })
    ]);

    console.error('恢复过程出错:', error);
    res.status(500).json({
      code: 500,
      message: '恢复失败: ' + error.message
    });
  }
};

// 获取备份文件列表
export const getBackupFiles = async (req: Request, res: Response) => {
  try {
    const backupDir = path.join(__dirname, '../../backups');
    const files = fs.readdirSync(backupDir)
      .filter(file => file.endsWith('.sql'))
      .map(file => ({
        filename: file,
        path: path.join(backupDir, file),
        size: fs.statSync(path.join(backupDir, file)).size,
        createdAt: fs.statSync(path.join(backupDir, file)).birthtime
      }))
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());

    res.json({
      code: 200,
      data: files
    });
  } catch (error) {
    console.error('获取备份文件列表失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取备份文件列表失败'
    });
  }
};

// 获取数据库信息
export const getDatabaseInfo = async (req: Request, res: Response) => {
  try {
    // 获取数据库名称
    const [dbNameResult] = await pool.execute('SELECT DATABASE() as name')
    const dbName = dbNameResult[0].name

    // 获取表数量
    const [tableResult] = await pool.execute(`
      SELECT COUNT(*) as count 
      FROM information_schema.tables 
      WHERE table_schema = ?
    `, [dbName])

    // 获取数据库大小
    const [sizeResult] = await pool.execute(`
      SELECT SUM(data_length + index_length) / 1024 / 1024 as size
      FROM information_schema.tables
      WHERE table_schema = ?
      GROUP BY table_schema
    `, [dbName])

    // 获取当前连接数
    const [threadsResult] = await pool.execute('SHOW STATUS LIKE "Threads_connected"')

    // 获取最大连接数
    const [maxConnResult] = await pool.execute('SHOW VARIABLES LIKE "max_connections"')

    // 获取MySQL版本
    const [versionResult] = await pool.execute('SELECT VERSION() as version')

    res.json({
      code: 200,
      data: {
        name: dbName,
        tableCount: parseInt(tableResult[0].count),
        status: 'running',
        size: `${Math.round(sizeResult[0]?.size || 0)} MB`,
        connections: parseInt(threadsResult[0].Value),
        maxConnections: parseInt(maxConnResult[0].Value),
        version: versionResult[0].version
      }
    })
  } catch (error) {
    console.error('获取数据库信息失败:', error)
    res.status(500).json({
      code: 500,
      message: '获取数据库信息失败'
    })
  }
}

// 获取数据库表列表及其信息
export const getTables = async (req: Request, res: Response) => {
  try {
    const [rows] = await pool.execute(`
      SELECT 
        TABLE_NAME as \`name\`,
        TABLE_ROWS as \`rows\`,
        (DATA_LENGTH + INDEX_LENGTH) as \`size\`,
        TABLE_COMMENT as \`comment\`
      FROM INFORMATION_SCHEMA.TABLES 
      WHERE TABLE_SCHEMA = ?
    `, [process.env.DB_NAME || 'graduation_management'])
    
    // 格式化返回数据
    const tables = rows.map((row: any) => ({
      name: row.name,
      rows: row.rows || 0,
      size: formatSize(row.size || 0),
      comment: row.comment || ''
    }))

    res.json({
      code: 200,
      data: tables
    })
  } catch (error) {
    console.error('获取表列表失败:', error)
    res.status(500).json({
      code: 500,
      message: '获取表列表失败'
    })
  }
}

// 添加文件大小格式化函数
function formatSize(bytes: number): string {
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

// 导出数据
export const exportData = async (req: Request, res: Response) => {
  const { tables, format } = req.body
  
  try {
    // 验证参数
    if (!tables || !Array.isArray(tables) || tables.length === 0) {
      return res.status(400).json({
        code: 400,
        message: '请选择要导出的表'
      })
    }

    if (!['sql', 'csv', 'xlsx'].includes(format)) {
      return res.status(400).json({
        code: 400,
        message: '不支持的导出格式'
      })
    }

    // 记录开始导出的日志
    await pool.execute(
      `INSERT INTO system_logs (user_id, action, ip_address, details) VALUES (?, ?, ?, ?)`,
      [
        req.user?.userId,
        'system.data.export.start',
        req.ip,
        JSON.stringify({
          tables,
          format,
          timestamp: new Date().toISOString(),
          status: 'started'
        })
      ]
    );

    let exportResult;
    switch (format) {
      case 'sql':
        // SQL 导出...
        const tableList = tables.join(' ')
        const command = `mysqldump -h${process.env.DB_HOST} -u${process.env.DB_USER} -p${process.env.DB_PASSWORD} ${process.env.DB_NAME} ${tableList}`
        const { stdout } = await execPromise(command)
        exportResult = stdout;
        break;

      case 'csv':
        // CSV 导出...
        const csvData = await Promise.all(tables.map(async (table) => {
          const [rows] = await pool.execute(`SELECT * FROM ${table}`)
          if (rows.length === 0) return ''
          
          const headers = Object.keys(rows[0]).join(',')
          const values = rows.map(row => 
            Object.values(row).map(val => 
              typeof val === 'string' ? `"${val.replace(/"/g, '""')}"` : val
            ).join(',')
          ).join('\n')
          
          return `-- ${table}\n${headers}\n${values}\n\n`
        }))
        exportResult = csvData.join('');
        break;

      case 'xlsx':
        // Excel 导出...
        const workbook = XLSX.utils.book_new()
        let totalRows = 0;
        
        for (const table of tables) {
          const [rows] = await pool.execute(`SELECT * FROM ${table}`)
          if (rows.length > 0) {
            totalRows += rows.length;
            const processedRows = rows.map((row: any) => {
              const newRow = { ...row }
              Object.keys(newRow).forEach(key => {
                if (newRow[key] instanceof Date) {
                  newRow[key] = newRow[key].toISOString().split('T')[0]
                }
              })
              return newRow
            })
            
            const worksheet = XLSX.utils.json_to_sheet(processedRows)
            XLSX.utils.book_append_sheet(workbook, worksheet, table.substring(0, 31))
          }
        }
        
        exportResult = XLSX.write(workbook, { 
          type: 'buffer', 
          bookType: 'xlsx',
          bookSST: false
        })
        break;
    }

    // 设置响应头
    res.setHeader('Content-Type', format === 'sql' ? 'application/sql' :
                                format === 'csv' ? 'text/csv' : 
                                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    res.setHeader('Content-Disposition', `attachment; filename=export_${Date.now()}.${format}`)

    // 记录导出成功的日志
    await pool.execute(
      `INSERT INTO system_logs (user_id, action, ip_address, details) VALUES (?, ?, ?, ?)`,
      [
        req.user?.userId,
        'system.data.export.success',
        req.ip,
        JSON.stringify({
          tables,
          format,
          timestamp: new Date().toISOString(),
          status: 'completed',
          fileSize: Buffer.from(exportResult).length,
          tablesCount: tables.length
        })
      ]
    );

    return res.send(exportResult)

  } catch (error) {
    // 记录导出失败的日志
    await pool.execute(
      `INSERT INTO system_logs (user_id, action, ip_address, details) VALUES (?, ?, ?, ?)`,
      [
        req.user?.userId,
        'system.data.export.error',
        req.ip,
        JSON.stringify({
          tables,
          format,
          timestamp: new Date().toISOString(),
          status: 'failed',
          error: error instanceof Error ? error.message : '未知错误'
        })
      ]
    );

    console.error('导出失败:', error)
    res.status(500).json({
      code: 500,
      message: '导出失败'
    })
  }
}

export {
  backupDatabase,
  restoreDatabase,
  getBackupFiles,
  getDatabaseInfo,
  getTables,
  exportData
} 