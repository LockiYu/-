import { Request, Response } from 'express'
import pool from '../utils/db'

// 创建题目
export const createTopic = async (req: Request, res: Response) => {
  try {
    const {
      title,
      type,
      source,
      teacher_id,
      description,
      major_requirements,
      student_requirements
    } = req.body

    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      // 创建题目
      const [result] = await connection.execute(
        `INSERT INTO topics 
        (title, type, source, teacher_id, description, major_requirements, student_requirements) 
        VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [title, type, source, teacher_id, description, major_requirements, student_requirements]
      );

      // 记录系统日志
      await connection.execute(
        'INSERT INTO system_logs (user_id, action, ip_address, details) VALUES (?, ?, ?, ?)',
        [
          teacher_id,
          'topic.create',
          req.ip,
          JSON.stringify({
            topic_id: result.insertId,
            title,
            type
          })
        ]
      );

      await connection.commit();
      res.status(201).json({ message: '题目创建成功', data: result });
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('创建题目失败:', error);
    res.status(500).json({ message: '服务器错误' });
  }
}

// 获取题目列表
export const getTopics = async (req: Request, res: Response) => {
  try {
    // 确保分页参数为数字类型
    const page = parseInt(req.query.page as string) || 1;
    const pageSize = parseInt(req.query.pageSize as string) || 25;
    const { type, source, status } = req.query;

    let sql = `
      SELECT 
        t.topic_id,
        t.title,
        t.type,
        t.source,
        u.name as teacher_name,
        t.status
      FROM topics t
      LEFT JOIN users u ON t.teacher_id = u.user_id
      WHERE 1=1
    `;

    const params: any[] = [];

    // 添加筛选条件
    if (type) {
      sql += ` AND t.type = ?`;
      params.push(type);
    }
    if (source) {
      sql += ` AND t.source = ?`;
      params.push(source);
    }
    if (status) {
      sql += ` AND t.status = ?`;
      params.push(status);
    } else {
      sql += ` AND t.status IN ('approved', 'pending')`;
    }

    // 获取总数
    const [countResult] = await pool.execute(
      `SELECT COUNT(*) as total FROM (${sql}) as count_table`,
      params
    ) as any;

    // 添加排序和分页
    sql += ` ORDER BY t.created_at DESC LIMIT ? OFFSET ?`;
    // 确保分页参数为数字类型
    params.push(Number(pageSize), Number((page - 1) * pageSize));

    // 执行主查询
    const [rows] = await pool.execute(sql, params);

    res.json({
      code: 200,
      data: {
        list: rows,
        pagination: {
          total: countResult[0].total,
          page,
          pageSize
        }
      },
      message: '获取题目列表成功'
    });

  } catch (error) {
    console.error('获取题目列表失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取题目列表失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// 审核题目
export const reviewTopic = async (req: Request, res: Response) => {
  try {
    const { topic_id, status } = req.body
    await pool.execute(
      'UPDATE topics SET status = ? WHERE topic_id = ?',
      [status, topic_id]
    )
    res.json({ message: '审核完成' })
  } catch (error) {
    res.status(500).json({ message: '服务器错误' })
  }
}

// 获取我的题目
export const getMyTopics = async (req: Request, res: Response) => {
  try {
    const teacherId = req.user.userId; // 假设从认证中间件获取
    const [rows] = await pool.execute(`
      SELECT * FROM topics 
      WHERE teacher_id = ?
      ORDER BY created_at DESC
    `, [teacherId]);

    res.json({ data: rows });
  } catch (error) {
    res.status(500).json({ message: '服务器错误' });
  }
};

// 更新题目
export const updateTopic = async (req: Request, res: Response) => {
  try {
    const topicId = req.params.id;
    const updateData = req.body;

    await pool.execute(
      'UPDATE topics SET ? WHERE topic_id = ?',
      [updateData, topicId]
    );

    res.json({ message: '更新成功' });
  } catch (error) {
    res.status(500).json({ message: '服务器错误' });
  }
};

// 更新题目状态
export const updateTopicStatus = async (req: Request, res: Response) => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const { id } = req.params;
    const { status } = req.body;
    const userId = (req as any).user.userId;

    // 获取题目原状态
    const [oldTopic] = await connection.query(
      'SELECT status FROM topics WHERE topic_id = ?',
      [id]
    );

    // 更新状态
    await connection.execute(
      'UPDATE topics SET status = ? WHERE topic_id = ?',
      [status, id]
    );

    // 记录系统日志
    await connection.execute(
      'INSERT INTO system_logs (user_id, action, ip_address, details) VALUES (?, ?, ?, ?)',
      [
        userId,
        'topic.status.update',
        req.ip,
        JSON.stringify({
          topic_id: id,
          old_status: oldTopic[0]?.status,
          new_status: status,
          update_time: new Date()
        })
      ]
    );

    await connection.commit();
    res.json({
      code: 200,
      message: '状态更新成功'
    });

  } catch (error) {
    await connection.rollback();
    console.error('更新题目状态失败:', error);
    res.status(500).json({
      code: 500,
      message: '更新状态失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  } finally {
    connection.release();
  }
};

// 添加批量导入日志
export const importTopics = async (req: Request, res: Response) => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    // 处理导入逻辑...

    // 记录系统日志
    await connection.execute(
      'INSERT INTO system_logs (user_id, action, ip_address, details) VALUES (?, ?, ?, ?)',
      [
        (req as any).user.userId,
        'topic.import',
        req.ip,
        JSON.stringify({
          file_name: req.file?.originalname,
          total_imported: importedCount
        })
      ]
    );

    await connection.commit();
    res.json({ message: '导入成功' });
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
};

// 添加导出日志
export const exportTopics = async (req: Request, res: Response) => {
  const connection = await pool.getConnection();
  try {
    const userId = (req as any).user.userId;

    // 获取导出数据
    const [topics] = await connection.query(`
      SELECT t.*, u.name as teacher_name 
      FROM topics t
      LEFT JOIN users u ON t.teacher_id = u.user_id
      WHERE ...
    `);

    // 记录系统日志
    await connection.execute(
      'INSERT INTO system_logs (user_id, action, ip_address, details) VALUES (?, ?, ?, ?)',
      [
        userId,
        'topic.export',
        req.ip,
        JSON.stringify({
          total_count: topics.length,
          export_time: new Date(),
          filters: req.query
        })
      ]
    );

    // 返回导出数据
    res.json({
      code: 200,
      data: topics,
      message: '导出成功'
    });

  } catch (error) {
    console.error('导出题目失败:', error);
    throw error;
  } finally {
    connection.release();
  }
};

// 获取题目详情
export const getTopicDetails = async (req: Request, res: Response) => {
  const connection = await pool.getConnection();
  try {
    const { id } = req.params;
    console.log('获取题目详情，ID:', id);  // 添加日志

    // 检查参数
    if (!id) {
      return res.status(400).json({
        code: 400,
        message: '缺少必要参数'
      });
    }

    const [topic] = await connection.query(`
      SELECT 
        t.*,
        u.name as teacher_name,
        u.title as teacher_title,
        u.department as teacher_department
      FROM topics t
      LEFT JOIN users u ON t.teacher_id = u.user_id
      WHERE t.topic_id = ?
    `, [id]);

    console.log('查询结果:', topic);  // 添加日志

    if (!topic[0]) {
      return res.status(404).json({
        code: 404,
        message: '未找到相关题目'
      });
    }

    res.json({
      code: 200,
      data: topic[0],
      message: '获取成功'
    });

  } catch (error) {
    console.error('获取题目详情失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取详情失败'
    });
  } finally {
    connection.release();
  }
};