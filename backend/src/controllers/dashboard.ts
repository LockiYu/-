/*
 * @Author: test abc@163.com
 * @Date: 2024-12-10 11:48:05
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-16 14:26:12
 * @FilePath: \Graduation Design Management System\backend\src\controllers\dashboard.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
/*
 * @Author: test abc@163.com
 * @Date: 2024-12-10 11:48:05
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-10 22:33:10
 * @FilePath: \Graduation Design Management System\backend\src\controllers\dashboard.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import { Request, Response } from 'express';
import pool from '../utils/db';

const getClientIP = (req: Request): string => {
  const forwarded = req.headers['x-forwarded-for'] as string;
  const ip = forwarded ? forwarded.split(',')[0] : req.socket.remoteAddress;
  return ip || 'unknown';
};

export const getSuperAdminStats = async (req: Request, res: Response) => {
  try {
    // 获取所有统计数据
    const [userStats] = await pool.query(`
      SELECT 
        COUNT(*) as totalUsers,
        (
          SELECT COUNT(DISTINCT user_id) 
          FROM users 
          WHERE last_login_time >= DATE_SUB(NOW(), INTERVAL 7 DAY)
        ) as activeUsers
      FROM users
    `)

    const [messageStats] = await pool.query(`
      SELECT COUNT(*) as systemMessages
      FROM system_messages
      WHERE status = 'active'
    `)

    const [logStats] = await pool.query(`
      SELECT COUNT(*) as systemLogs
      FROM system_logs
    `)

    // 正确提取数据
    const stats = {
      totalUsers: userStats[0].totalUsers || 0,
      activeUsers: userStats[0].activeUsers || 0,
      systemMessages: messageStats[0].systemMessages || 0,
      systemLogs: logStats[0].systemLogs || 0
    }

    console.log('返回的统计数据：', stats)

    res.json({
      code: 200,
      data: stats,
      message: '获取统计数据成功'
    })

  } catch (error: any) {
    console.error('获取超级管理员统计数据失败:', error)
    res.status(500).json({
      code: 500,
      message: '获取统计数据失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    })
  }
}

export const getSystemMessages = async (req: Request, res: Response) => {
  try {
    const {
      page = 1,
      pageSize = 10,
      type,
      status,
      priority,
      startDate,
      endDate
    } = req.query

    // 构建基础查询
    let query = `
      SELECT 
        m.*,
        u.username as creator_name
      FROM system_messages m
      LEFT JOIN users u ON m.created_by = u.user_id
      WHERE 1=1
    `
    const queryParams: any[] = []

    // 添加筛选条件
    if (type) {
      query += ` AND m.type = ?`
      queryParams.push(type)
    }
    if (status) {
      query += ` AND m.status = ?`
      queryParams.push(status)
    }
    if (priority) {
      query += ` AND m.priority = ?`
      queryParams.push(priority)
    }
    if (startDate) {
      query += ` AND m.created_at >= ?`
      queryParams.push(startDate)
    }
    if (endDate) {
      query += ` AND m.created_at <= ?`
      queryParams.push(endDate)
    }

    // 获取总数
    const [countResult] = await pool.query(
      `SELECT COUNT(*) as total FROM (${query}) as temp`,
      queryParams
    )
    const total = countResult[0].total

    // 添加分页
    query += ` ORDER BY m.created_at DESC LIMIT ? OFFSET ?`
    queryParams.push(Number(pageSize), (Number(page) - 1) * Number(pageSize))

    // 执行查询
    const [messages] = await pool.query(query, queryParams)

    res.json({
      code: 200,
      data: {
        list: messages,
        pagination: {
          total,
          page: Number(page),
          pageSize: Number(pageSize)
        }
      },
      message: '获取系统消息成功'
    })

  } catch (error: any) {
    console.error('获取系统消息失败:', error)
    res.status(500).json({
      code: 500,
      message: '获取系统消息失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    })
  }
}

export const getSystemLogs = async (req: Request, res: Response) => {
  try {
    const {
      page = 1,
      pageSize = 10,
      userId,
      action,
      startDate,
      endDate
    } = req.query

    // 构建基础查询
    let query = `
      SELECT 
        l.*,
        u.username as user_name
      FROM system_logs l
      LEFT JOIN users u ON l.user_id = u.user_id
      WHERE 1=1
    `
    const queryParams: any[] = []

    // 添加筛选条件
    if (userId) {
      query += ` AND l.user_id = ?`
      queryParams.push(userId)
    }
    if (action) {
      query += ` AND l.action LIKE ?`
      queryParams.push(`%${action}%`)
    }
    if (startDate) {
      query += ` AND l.created_at >= ?`
      queryParams.push(startDate)
    }
    if (endDate) {
      query += ` AND l.created_at <= ?`
      queryParams.push(endDate)
    }

    // 获取总数
    const [countResult] = await pool.query(
      `SELECT COUNT(*) as total FROM (${query}) as temp`,
      queryParams
    )
    const total = countResult[0].total

    // 添加分页和排序
    query += ` ORDER BY l.created_at DESC LIMIT ? OFFSET ?`
    queryParams.push(Number(pageSize), (Number(page) - 1) * Number(pageSize))

    // 执行查询
    const [logs] = await pool.query(query, queryParams)

    res.json({
      code: 200,
      data: {
        list: logs,
        pagination: {
          total,
          page: Number(page),
          pageSize: Number(pageSize)
        }
      },
      message: '获取系统日志成功'
    })

  } catch (error: any) {
    console.error('获取系统日志失败:', error)
    res.status(500).json({
      code: 500,
      message: '获取系统日志失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    })
  }
}

export const getAdminStats = async (req: Request, res: Response) => {
  try {
    const adminId = (req as any).user.userId;

    // 获取管理员所在学院
    const [adminInfo] = await pool.execute(
      'SELECT department FROM users WHERE user_id = ?',
      [adminId]
    ) as any[];

    if (!adminInfo || !adminInfo[0]) {
      return res.status(404).json({
        code: 404,
        message: '未找到管理员信息'
      });
    }

    const department = adminInfo[0].department;

    // 使用子查询统计不同状态的题目数量
    const [stats] = await pool.query(`
      SELECT 
        (SELECT COUNT(*) 
         FROM topics t
         JOIN users u ON t.teacher_id = u.user_id
         WHERE t.status = 'pending' 
         AND u.department = ?) as pendingTopics,
        
        (SELECT COUNT(*) 
         FROM topics t
         JOIN users u ON t.teacher_id = u.user_id
         WHERE t.status = 'approved' 
         AND u.department = ?) as approvedTopics,
        
        (SELECT COUNT(*) 
         FROM topics t
         JOIN users u ON t.teacher_id = u.user_id
         WHERE t.status = 'rejected' 
         AND u.department = ?) as rejectedTopics,
        
        (SELECT COUNT(DISTINCT l.log_id)
         FROM system_logs l
         JOIN users u ON l.user_id = u.user_id
         WHERE u.department = ?
         AND l.action LIKE 'topic%'
         AND l.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)) as recentLogs
    `, [department, department, department, department]);

    res.json({
      code: 200,
      data: {
        pendingTopics: stats[0].pendingTopics || 0,
        approvedTopics: stats[0].approvedTopics || 0,
        rejectedTopics: stats[0].rejectedTopics || 0,
        recentLogs: stats[0].recentLogs || 0,
        department
      },
      message: '获取统计数据成功'
    });

  } catch (error: any) {
    console.error('获取管理员统计数据失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取统计数据失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

export const getAdminTopics = async (req: Request, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const pageSize = parseInt(req.query.pageSize as string) || 10;
    const { type, source } = req.query;

    // 从认证信息中获取当前系主任的信息
    const adminId = (req as any).user.userId;

    // 基础查询 - 添加系主任所属学院的筛选
    let countSql = `
      SELECT COUNT(*) as total
      FROM topics t
      LEFT JOIN users u ON t.teacher_id = u.user_id
      LEFT JOIN users admin ON admin.user_id = ?
      WHERE t.status IN ('approved', 'pending')
      AND u.department = admin.department
    `;

    let dataSql = `
      SELECT
        t.topic_id,
        t.title,
        t.type,
        t.source,
        u.name as teacher_name,
        u.department,
        CASE
          WHEN t.status = 'approved' THEN 'approved'
          WHEN t.status = 'pending' THEN 'pending'
          WHEN t.status = 'rejected' THEN 'rejected'
          WHEN t.status = 'selected' THEN 'selected'
          ELSE t.status
        END as status
      FROM topics t
      LEFT JOIN users u ON t.teacher_id = u.user_id
      LEFT JOIN users admin ON admin.user_id = ?
      WHERE t.status IN ('approved', 'pending', 'rejected', 'selected')
      AND u.department = admin.department
    `;

    // 参数数组，首先添加系主任ID
    const params = [adminId];
    let whereConditions = [];

    // 添加其他筛选条件
    if (type) {
      whereConditions.push('t.type = ?');
      params.push(type);
    }
    if (source) {
      whereConditions.push('t.source = ?');
      params.push(source);
    }

    // 如果有额外的where条件，添加到SQL
    if (whereConditions.length > 0) {
      const whereClause = ' AND ' + whereConditions.join(' AND ');
      countSql += whereClause;
      dataSql += whereClause;
    }

    // 获取总数
    const [totalRows] = await pool.query(countSql, params);
    const total = totalRows[0].total;

    // 添加排序和分页
    dataSql += ` ORDER BY t.created_at DESC LIMIT ${pageSize} OFFSET ${(page - 1) * pageSize}`;

    // 执行数据查询
    const [rows] = await pool.query(dataSql, params);

    // 返回结果
    res.json({
      code: 200,
      data: {
        list: rows,
        pagination: {
          total,
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
      message: '服务器错误',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

export const getTeacherStats = async (req: Request, res: Response) => {
  try {
    const teacherId = (req as any).user.userId;

    // 获取指导学生数量（已通过的选题）
    const [supervisionStats] = await pool.query(`
      SELECT COUNT(DISTINCT ts.student_id) as supervising_students
      FROM topics t
      JOIN topic_selections ts ON t.topic_id = ts.topic_id
      WHERE t.teacher_id = ? 
      AND ts.final_status = 'approved'
    `, [teacherId]);

    // 获取待审核的选题申请数量
    const [pendingStats] = await pool.query(`
      SELECT COUNT(*) as pending_selections
      FROM topics t
      JOIN topic_selections ts ON t.topic_id = ts.topic_id
      WHERE t.teacher_id = ? 
      AND ts.teacher_approval_status = 'pending'
    `, [teacherId]);

    // 获取教师最大可指导学生数
    const [maxStudents] = await pool.query(`
      SELECT max_students
      FROM supervisors
      WHERE supervisor_id = ?
    `, [teacherId]);

    const data = {
      supervisingStudents: supervisionStats[0].supervising_students || 0,
      pendingSelections: pendingStats[0].pending_selections || 0,
      maxStudents: maxStudents[0]?.max_students || 8
    };

    res.json({
      code: 200,
      data,
      message: '获取统计数据成功'
    });

  } catch (error: any) {
    console.error('获取教师统计数据失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取统计数据失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// 获取教师指导的学生列表
export const getSupervisionList = async (req: Request, res: Response) => {
  try {
    const teacherId = (req as any).user.userId;
    console.log('正在查询教师ID:', teacherId, '的指导学生列表');

    const [supervisionList] = await pool.query(`
      SELECT 
        u.user_id as student_id,
        u.name,
        u.gender,
        u.department,
        u.major,
        u.phone,
        u.email,
        t.title as topic_title,
        ts.created_at,
        ts.final_status,
        ts.teacher_approval_status,
        ts.director_approval_status
      FROM topic_selections ts
      JOIN topics t ON ts.topic_id = t.topic_id
      JOIN users u ON ts.student_id = u.user_id
      WHERE t.teacher_id = ?
      AND (ts.teacher_approval_status = 'approved' OR ts.final_status = 'approved')
    `, [teacherId]);

    console.log('查询结果:', supervisionList);

    res.json({
      code: 200,
      data: supervisionList,
      message: '获取指导学生列表成功'
    });

  } catch (error) {
    console.error('获取指导学生列表失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取指导学生列表失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// 获取教师待审核的选题申请列表
export const getPendingSelections = async (req: Request, res: Response) => {
  try {
    const teacherId = (req as any).user.userId;
    console.log('正在查询教师ID:', teacherId, '的待审核选题列表');

    const [pendingList] = await pool.query(`
      SELECT 
        ts.selection_id,
        u.name as student_name,
        u.department as student_department,
        u.major as student_major,
        t.title as topic_title,
        t.type as topic_type,
        ts.created_at,
        ts.teacher_approval_status,
        ts.director_approval_status
      FROM topic_selections ts
      JOIN topics t ON ts.topic_id = t.topic_id
      JOIN users u ON ts.student_id = u.user_id
      WHERE t.teacher_id = ?
      AND ts.teacher_approval_status = 'pending'
      ORDER BY ts.created_at DESC
    `, [teacherId]);

    console.log('查询结果:', pendingList);

    res.json({
      code: 200,
      data: pendingList,
      message: '获取待审核选题列表成功'
    });

  } catch (error) {
    console.error('获取待审核选题列表失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取待审核选题列表失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// 更新选题申请状态
export const updateSelectionStatus = async (req: Request, res: Response) => {
  const connection = await pool.getConnection()
  try {
    await connection.beginTransaction()

    const { selectionId } = req.params
    const { status, rejectReason } = req.body
    const teacherId = (req as any).user.userId

    // 更新选题状态和拒绝理由
    await connection.query(
      `UPDATE topic_selections 
       SET teacher_approval_status = ?,
           teacher_reject_reason = ?
       WHERE selection_id = ?`,
      [status, status === 'rejected' ? rejectReason : null, selectionId]
    )

    // 获取选题详情用于日志记录
    const [selections] = await connection.query(
      `SELECT ts.*, s.name as student_name, t.title as topic_title
       FROM topic_selections ts
       JOIN users s ON ts.student_id = s.user_id
       JOIN topics t ON ts.topic_id = t.topic_id
       WHERE ts.selection_id = ?`,
      [selectionId]
    )

    const selection = selections[0]

    // 记录系统日志
    await connection.query(
      `INSERT INTO system_logs 
       (user_id, action, ip_address, details) 
       VALUES (?, ?, ?, ?)`,
      [
        teacherId,
        'selection.teacher.review',
        req.ip,
        JSON.stringify({
          selection_id: selectionId,
          status,
          reason: rejectReason,
          student_name: selection.student_name,
          topic_title: selection.topic_title,
          message: `教师${status === 'approved' ? '通过' : '拒绝'}选题申请`
        })
      ]
    )

    await connection.commit()
    res.json({
      code: 200,
      message: '审批成功'
    })
  } catch (error: any) {
    await connection.rollback()
    console.error('教师审批失败:', error)
    res.status(500).json({
      code: 500,
      message: '审批失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    })
  } finally {
    connection.release()
  }
}

// 修改获取待审核列表的控制器方法
export const getDirectorPendingSelections = async (req: Request, res: Response) => {
  try {
    const directorId = (req as any).user.userId;
    const page = parseInt(req.query.page as string) || 1;
    const pageSize = parseInt(req.query.pageSize as string) || 10;
    const status = req.query.status as string;  // 添加状态筛选参数

    // 1. 获取系主任所在学院
    const [directorInfo] = await pool.query(`
      SELECT department 
      FROM users 
      WHERE user_id = ? AND role = 'admin'
    `, [directorId]);

    if (!directorInfo[0]) {
      return res.status(404).json({
        code: 404,
        message: '未找到系主任信息'
      });
    }

    const department = directorInfo[0].department;

    // 2. 构建基础查询条件
    let whereClause = `WHERE student.department = ?`;
    const queryParams = [department];

    // 添加状态筛选条件
    if (status) {
      whereClause += ` AND ts.director_approval_status = ?`;
      queryParams.push(status);
    }

    // 3. 获取总数
    const [countResult] = await pool.query(`
      SELECT COUNT(*) as total
      FROM topic_selections ts
      JOIN users student ON ts.student_id = student.user_id
      JOIN topics t ON ts.topic_id = t.topic_id
      JOIN users teacher ON t.teacher_id = teacher.user_id
      ${whereClause}
    `, queryParams);

    // 4. 获取分页数据
    const [pendingList] = await pool.query(`
      SELECT 
        ts.selection_id,
        ts.topic_id,
        ts.student_id,
        ts.teacher_approval_status,
        ts.director_approval_status,
        ts.created_at,
        ts.updated_at,
        ts.final_status,
        student.name as student_name,
        student.department as student_department,
        student.major as student_major,
        student.phone as student_phone,
        student.email as student_email,
        t.title as topic_title,
        t.type as topic_type,
        t.source as topic_source,
        t.description as topic_description,
        teacher.name as teacher_name,
        teacher.title as teacher_title
      FROM topic_selections ts
      JOIN users student ON ts.student_id = student.user_id
      JOIN topics t ON ts.topic_id = t.topic_id
      JOIN users teacher ON t.teacher_id = teacher.user_id
      ${whereClause}
      ORDER BY ts.created_at DESC
      LIMIT ? OFFSET ?
    `, [...queryParams, pageSize, (page - 1) * pageSize]);

    // 打印调试信息
    console.log('系主任ID:', directorId);
    console.log('所在院系:', department);
    console.log('待审核总数:', countResult[0].total);
    console.log('当前页数据:', pendingList.length);

    res.json({
      code: 200,
      data: {
        list: pendingList,
        pagination: {
          total: countResult[0].total,
          page,
          pageSize
        }
      },
      message: '获取待审核列表成功'
    });

  } catch (error) {
    console.error('获取系主任待审核列表失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取待审核列表失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// 修改系主任审批函数
export const updateDirectorSelectionStatus = async (req: Request, res: Response) => {
  const connection = await pool.getConnection()
  try {
    await connection.beginTransaction()

    const { selectionId } = req.params
    const { status } = req.body
    const directorId = (req as any).user.userId

    // 首先获取当前选题申请的详细信息
    const [currentSelection] = await connection.query(
      `SELECT ts.*, t.title as topic_title, s.name as student_name
       FROM topic_selections ts
       JOIN topics t ON ts.topic_id = t.topic_id
       JOIN users s ON ts.student_id = s.user_id
       WHERE ts.selection_id = ?`,
      [selectionId]
    )

    if (!currentSelection[0]) {
      throw new Error('未找到相关选题申请')
    }

    const selection = currentSelection[0]

    // 如果是通过操作
    if (status === 'approved') {
      // 1. 更新当前申请状态
      await connection.query(
        `UPDATE topic_selections 
         SET director_approval_status = ?,
             director_id = ?,
             director_approval_time = NOW()
         WHERE selection_id = ?`,
        [status, directorId, selectionId]
      )

      // 2. 更新题目状态为已选择
      await connection.query(
        `UPDATE topics 
         SET status = 'selected'
         WHERE topic_id = ?`,
        [selection.topic_id]
      )

      // 3. 自动拒绝同一题目的其他所有申请（包括待审核和已通过教师审核的）
      const rejectReason = `该题目已被学生 ${selection.student_name} 选中并通过最终审核`
      await connection.query(
        `UPDATE topic_selections 
         SET director_approval_status = 'rejected',
             director_reject_reason = ?,
             director_id = ?,
             director_approval_time = NOW()
         WHERE topic_id = ? 
         AND selection_id != ?`,
        [rejectReason, directorId, selection.topic_id, selectionId]
      )

      // 4. 记录系统日志 - 批量操作
      await connection.query(
        `INSERT INTO system_logs (user_id, action, ip_address, details)
         VALUES (?, 'selection.director.approve.complete', ?, ?)`,
        [
          directorId,
          req.ip,
          JSON.stringify({
            topic_id: selection.topic_id,
            topic_title: selection.topic_title,
            approved_student: selection.student_name,
            selection_id: selectionId,
            action: 'topic_selected',
            message: `题目被选中并完成最终审批，其他申请已自动处理`
          })
        ]
      )
    } else {
      // 如果是拒绝操作，走原有的逻辑
      await connection.query(
        `UPDATE topic_selections 
         SET director_approval_status = ?,
             director_reject_reason = ?,
             director_id = ?,
             director_approval_time = NOW()
         WHERE selection_id = ?`,
        [status, req.body.rejectReason, directorId, selectionId]
      )
    }

    // 记录当前操作的系统日志
    await connection.query(
      `INSERT INTO system_logs (user_id, action, ip_address, details)
       VALUES (?, ?, ?, ?)`,
      [
        directorId,
        'selection.director.review',
        req.ip,
        JSON.stringify({
          selection_id: selectionId,
          topic_title: selection.topic_title,
          student_name: selection.student_name,
          status,
          message: `系主任${status === 'approved' ? '通过' : '拒绝'}选题申请`
        })
      ]
    )

    await connection.commit()
    res.json({
      code: 200,
      message: status === 'approved'
        ? '已通过选题申请，题目已标记为已选择状态'
        : '已拒绝选题申请'
    })

  } catch (error: any) {
    await connection.rollback()
    console.error('系主任审批失败:', error)
    res.status(500).json({
      code: 500,
      message: '审批失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    })
  } finally {
    connection.release()
  }
}

export const getDirectorPendingDetails = async (req: Request, res: Response) => {
  try {
    const { selectionId } = req.params;

    const [details] = await pool.query(`
      SELECT 
        ts.*,
        s.name as student_name,
        s.gender as student_gender,
        u1.department as student_department,
        u1.major as student_major,
        s.class_name as student_class,
        s.phone as student_phone,
        s.email as student_email,
        s.notes as student_notes,
        t.title as topic_title,
        t.type as topic_type,
        t.description as topic_description,
        u2.name as teacher_name,
        u2.title as teacher_title
      FROM topic_selections ts
      JOIN students s ON ts.student_id = s.student_id
      JOIN users u1 ON ts.student_id = u1.user_id
      JOIN topics t ON ts.topic_id = t.topic_id
      JOIN users u2 ON t.teacher_id = u2.user_id
      WHERE ts.selection_id = ?
    `, [selectionId]);

    if (!details[0]) {
      return res.status(404).json({
        code: 404,
        message: '未找到选题申请详情'
      });
    }

    res.json({
      code: 200,
      data: details[0],
      message: '获取选题申请详情成功'
    });

  } catch (error) {
    console.error('获取选题申请详情失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取选题申请详情失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

export const updateTopicStatus = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const adminId = (req as any).user.userId;

    // 验证管理员权限和院系
    const [adminInfo] = await pool.query(
      'SELECT department FROM users WHERE user_id = ?',
      [adminId]
    );

    // 验证选题是否存在且属于同一院系
    const [topic] = await pool.query(`
      SELECT t.*, u.department as teacher_department 
      FROM topics t
      JOIN users u ON t.teacher_id = u.user_id
      WHERE t.topic_id = ?
    `, [id]);

    if (!topic[0]) {
      return res.status(404).json({
        code: 404,
        message: '未找到相关选题'
      });
    }

    if (adminInfo[0].department !== topic[0].teacher_department) {
      return res.status(403).json({
        code: 403,
        message: '无权修改其他院系的选题'
      });
    }

    // 开启事务
    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      // 更新状态
      await connection.query(
        'UPDATE topics SET status = ? WHERE topic_id = ?',
        [status, id]
      );

      // 记录系统日志
      await connection.query(
        'INSERT INTO system_logs (user_id, action, ip_address, details) VALUES (?, ?, ?, ?)',
        [
          adminId,
          'topic.status.update',
          getClientIP(req),
          `管理员更新选题状态为${status}`
        ]
      );

      await connection.commit();

      res.json({
        code: 200,
        message: '更新选题状态成功'
      });

    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('更新选题状态失败:', error);
    res.status(500).json({
      code: 500,
      message: '更新选题状态失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// 添加新的控制器方法
export const getPendingCountForTopic = async (req: Request, res: Response) => {
  const connection = await pool.getConnection()
  try {
    const { topicId } = req.params

    const [result] = await connection.query(
      `SELECT COUNT(*) as count
       FROM topic_selections
       WHERE topic_id = ?
       AND selection_id != ?
       AND final_status = 'pending'`,
      [topicId, req.query.currentSelectionId]
    )

    res.json({
      code: 200,
      data: {
        count: result[0].count
      }
    })
  } catch (error) {
    console.error('获取待审核数量失败:', error)
    res.status(500).json({
      code: 500,
      message: '获取待审核数量失败'
    })
  } finally {
    connection.release()
  }
}

// 修改获取选题申请详情的控制器方法
export const getSelectionDetail = async (req: AuthRequest, res: Response) => {
  const connection = await pool.getConnection();
  try {
    const { selectionId } = req.params;

    const [selection] = await connection.query(`
      SELECT 
        ts.*,
        t.title as topic_title,
        t.description as topic_description,
        s.name as student_name,
        s.department as student_department,
        s.user_id as student_number,
        tea.name as teacher_name
      FROM topic_selections ts
      JOIN topics t ON ts.topic_id = t.topic_id
      JOIN users s ON ts.student_id = s.user_id
      JOIN users tea ON t.teacher_id = tea.user_id
      WHERE ts.selection_id = ?
    `, [selectionId]);

    if (!selection[0]) {
      return res.status(404).json({
        code: 404,
        message: '未找到选题申请'
      });
    }

    res.json({
      code: 200,
      data: selection[0],
      message: '获取成功'
    });

  } catch (error) {
    console.error('获取选题申请详情失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取选题申请详情失败'
    });
  } finally {
    connection.release();
  }
};

// 重命名并修改控制器方法
export const getAdminSelectionsList = async (req: Request, res: Response) => {
  const connection = await pool.getConnection()
  try {
    const { page = 1, pageSize = 10 } = req.query
    const offset = (Number(page) - 1) * Number(pageSize)

    // 简单的查询语句
    const query = `
      SELECT 
        ts.*,
        t.title as topic_title,
        t.type as topic_type,
        s.name as student_name,
        s.department as student_department,
        s.major as student_major,
        teacher.name as teacher_name
      FROM topic_selections ts
      LEFT JOIN topics t ON ts.topic_id = t.topic_id
      LEFT JOIN users s ON ts.student_id = s.user_id
      LEFT JOIN users teacher ON t.teacher_id = teacher.user_id
      ORDER BY ts.created_at DESC
      LIMIT ? OFFSET ?
    `

    // 获取总数
    const countQuery = `SELECT COUNT(*) as total FROM topic_selections`

    // 执行查询
    const [selections] = await connection.query(query, [Number(pageSize), offset])
    const [totalResult] = await connection.query(countQuery)

    // 打印调试信息
    console.log('查询参数:', { page, pageSize, offset })
    console.log('查询结果数量:', selections.length)
    console.log('查询结果:', JSON.stringify(selections, null, 2))

    res.json({
      code: 200,
      data: {
        list: selections,
        pagination: {
          total: totalResult[0].total,
          page: Number(page),
          pageSize: Number(pageSize)
        }
      },
      message: '获取选题申请列表成功'
    })

  } catch (error) {
    console.error('获取选题申请列表失败:', error)
    res.status(500).json({
      code: 500,
      message: '获取选题申请列表失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    })
  } finally {
    connection.release()
  }
}

// 获取教师待审核选题列表
export const getTeacherPendingSelections = async (req: AuthRequest, res: Response) => {
  try {
    const teacherId = req.user?.userId;

    const [selections] = await pool.execute(`
      SELECT 
        ts.selection_id,
        ts.topic_id,
        ts.student_id,
        ts.student_reason,
        ts.teacher_approval_status,
        ts.created_at,
        t.title as topic_title,
        u.name as student_name
      FROM topic_selections ts
      JOIN topics t ON ts.topic_id = t.topic_id
      JOIN users u ON ts.student_id = u.user_id
      WHERE t.teacher_id = ?
      AND ts.teacher_approval_status = 'pending'
      ORDER BY ts.created_at DESC
    `, [teacherId]);

    res.json({
      code: 200,
      data: selections,
      message: '获取成功'
    });
  } catch (error) {
    console.error('获取待审核选题失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取待审核选题失败'
    });
  }
};

// 教师通过选题申请
export const approveTeacherSelection = async (req: AuthRequest, res: Response) => {
  try {
    const { selectionId } = req.params;
    const teacherId = req.user?.userId;

    // 验证选题是否属于该教师
    const [topic] = await pool.execute(`
      SELECT t.teacher_id 
      FROM topic_selections ts
      JOIN topics t ON ts.topic_id = t.topic_id
      WHERE ts.selection_id = ?
    `, [selectionId]);

    if (!topic[0] || topic[0].teacher_id !== teacherId) {
      return res.status(403).json({
        code: 403,
        message: '无权操作此选题'
      });
    }

    // 更新审批状态
    await pool.execute(`
      UPDATE topic_selections 
      SET teacher_approval_status = 'approved',
          updated_at = CURRENT_TIMESTAMP
      WHERE selection_id = ?
    `, [selectionId]);

    // 记录系统日志
    await pool.execute(`
      INSERT INTO system_logs 
      (user_id, action, ip_address, details) 
      VALUES (?, ?, ?, ?)`,
      [
        teacherId,
        'topic.selection.approve',
        req.ip,
        JSON.stringify({
          selection_id: selectionId,
          action: '通过选题申请'
        })
      ]
    );

    res.json({
      code: 200,
      message: '已通过选题申请'
    });
  } catch (error) {
    console.error('审批失败:', error);
    res.status(500).json({
      code: 500,
      message: '审批失败'
    });
  }
};

// 教师拒绝选题申请
export const rejectTeacherSelection = async (req: AuthRequest, res: Response) => {
  try {
    const { selectionId } = req.params;
    const { reason } = req.body;
    const teacherId = req.user?.userId;

    // 验证选题是否属于该教师
    const [topic] = await pool.execute(`
      SELECT t.teacher_id 
      FROM topic_selections ts
      JOIN topics t ON ts.topic_id = t.topic_id
      WHERE ts.selection_id = ?
    `, [selectionId]);

    if (!topic[0] || topic[0].teacher_id !== teacherId) {
      return res.status(403).json({
        code: 403,
        message: '无权操作此选题'
      });
    }

    // 更新审批状态和拒绝原因
    await pool.execute(`
      UPDATE topic_selections 
      SET teacher_approval_status = 'rejected',
          teacher_reject_reason = ?,
          updated_at = CURRENT_TIMESTAMP
      WHERE selection_id = ?
    `, [reason, selectionId]);

    // 记录系统日志
    await pool.execute(`
      INSERT INTO system_logs 
      (user_id, action, ip_address, details) 
      VALUES (?, ?, ?, ?)`,
      [
        teacherId,
        'topic.selection.reject',
        req.ip,
        JSON.stringify({
          selection_id: selectionId,
          reason,
          action: '拒绝选题申请'
        })
      ]
    );

    res.json({
      code: 200,
      message: '已拒绝选题申请'
    });
  } catch (error) {
    console.error('拒绝失败:', error);
    res.status(500).json({
      code: 500,
      message: '拒绝失败'
    });
  }
};

// 获取选题申请详情
export const getSelectionDetails = async (req: AuthRequest, res: Response) => {
  try {
    const { selectionId } = req.params;

    // 修改 SQL 查询，只包含实际存在的列
    const [selection] = await pool.execute(`
      SELECT 
        ts.*,
        t.title as topic_title,
        t.description as topic_description,
        s.name as student_name,
        s.user_id as student_number,  /* 修改这里：使用 user_id 而不是 student_id */
        tea.name as teacher_name
      FROM topic_selections ts
      JOIN topics t ON ts.topic_id = t.topic_id
      JOIN users s ON ts.student_id = s.user_id
      JOIN users tea ON t.teacher_id = tea.user_id
      WHERE ts.selection_id = ?
    `, [selectionId]);

    if (!selection[0]) {
      return res.status(404).json({
        code: 404,
        message: '未找到选题申请'
      });
    }

    res.json({
      code: 200,
      data: selection[0],
      message: '获取成功'
    });

  } catch (error) {
    console.error('获取选题申请详情失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取选题申请详情失败'
    });
  }
};

// 获取教师已审批通过的选题列表
export const getTeacherApprovedSelections = async (req: AuthRequest, res: Response) => {
  const connection = await pool.getConnection();
  try {
    const teacherId = req.user?.userId;
    const page = Number(req.query.page) || 1;
    const pageSize = Number(req.query.pageSize) || 10;
    const offset = (page - 1) * pageSize;

    // 获取总数
    const [countResult] = await connection.query(
      `SELECT COUNT(*) as total
       FROM topic_selections ts
       JOIN topics t ON ts.topic_id = t.topic_id
       WHERE t.teacher_id = ?
       AND ts.teacher_approval_status = 'approved'`,
      [teacherId]
    );

    // 获取列表数据
    const [selections] = await connection.query(
      `SELECT 
        ts.selection_id,
        ts.topic_id,
        ts.student_id,
        ts.student_reason,
        ts.teacher_approval_status,
        ts.director_approval_status,
        ts.created_at,
        t.title as topic_title,
        u.name as student_name,
        u.department as student_department
       FROM topic_selections ts
       JOIN topics t ON ts.topic_id = t.topic_id
       JOIN users u ON ts.student_id = u.user_id
       WHERE t.teacher_id = ?
       AND ts.teacher_approval_status = 'approved'
       ORDER BY ts.created_at DESC
       LIMIT ?, ?`,
      [teacherId, offset, pageSize]
    );

    res.json({
      code: 200,
      data: {
        list: selections,
        pagination: {
          total: countResult[0].total,
          page: page,
          pageSize: pageSize
        }
      },
      message: '获取成功'
    });
  } catch (error) {
    console.error('获取已审批选题失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取已审批选题失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  } finally {
    connection.release();
  }
};