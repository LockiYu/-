import { Request, Response } from 'express';
import pool from '../utils/db';
import { AuthRequest } from '../middleware/auth';
import { logUserAction } from '../utils/logger'
import path from 'path';
import fs from 'fs';
import { Router } from 'express';

// 首先创建一个初始化文件夹的函数
const initializeStageFolders = async (connection: any) => {
  try {
    // 获取所有阶段
    const [stages] = await connection.query(`
      SELECT type FROM progress_stages WHERE status = 'active'
    `);

    // 创建uploads根目录(如果不存在)
    const uploadsDir = path.join(__dirname, '../../uploads');
    if (!fs.existsSync(uploadsDir)) {
      fs.mkdirSync(uploadsDir);
    }

    // 为每个阶段创建对应文件夹
    (stages as any[]).forEach(stage => {
      const stageDir = path.join(uploadsDir, stage.type);
      if (!fs.existsSync(stageDir)) {
        fs.mkdirSync(stageDir);
      }
    });
  } catch (error) {
    console.error('初始化阶段文件夹失败:', error);
  }
};

export const getProgress = async (req: AuthRequest, res: Response) => {
  const connection = await pool.getConnection();
  try {
    const studentId = req.user?.userId;

    // 获取所有阶段定义
    const [stages] = await connection.query(`
      SELECT 
        id,
        name,
        type,
        sequence,
        required_files,
        requires_review,
        weight,
        description,
        status
      FROM progress_stages
      WHERE status = 'active'
      ORDER BY sequence ASC
    `);

    // 获取学生的进度记录
    const [records] = await connection.query(`
      SELECT 
        pr.*,
        sss.task_book_score,
        sss.literature_score,
        sss.proposal_score,
        sss.translation_score,
        sss.midterm_score,
        sss.thesis_submit_score,
        sss.advisor_review_score,
        sss.peer_review_score,
        sss.defense_score,
        sss.total_weighted_score
      FROM progress_records pr
      LEFT JOIN student_stage_scores sss ON pr.student_id = sss.student_id
      WHERE pr.student_id = ?
    `, [studentId]);

    // 构建完整的进度数据
    const progressData = {
      stages: (stages as any[]).map(stage => {
        const record = (records as any[]).find(r => r.stage_type === stage.type) || {};
        const scoreField = `${stage.type}_score`;

        return {
          ...stage,
          ...record,
          score: record[scoreField],
          status: record.status || 'not_started',
          canStart: stage.sequence === 1 ||
            (stages as any[]).find(s => s.sequence === stage.sequence - 1)?.type in
            (records as any[]).filter(r => r.status === 'completed').map(r => r.stage_type)
        };
      }),
      totalScore: (records as any[])[0]?.total_weighted_score || null
    };

    res.json({
      code: 200,
      data: progressData,
      message: '获取成功'
    });

  } catch (error) {
    console.error('获取进度失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取进度失败'
    });
  } finally {
    connection.release();
  }
};

export const updateProgress = async (req: AuthRequest, res: Response) => {
  const connection = await pool.getConnection();
  try {
    const studentId = req.user?.userId;
    const { stage_type, file_url, file_size, status } = req.body;

    // 开始事务
    await connection.beginTransaction();

    try {
      // 更新进度记录
      await connection.query(`
        INSERT INTO progress_records (
          student_id,
          stage_type,
          file_url,
          status,
          submit_time
        ) VALUES (?, ?, ?, ?, NOW())
        ON DUPLICATE KEY UPDATE
          file_url = VALUES(file_url),
          status = VALUES(status),
          submit_time = NOW()`,
        [studentId, stage_type, file_url, status]
      );

      // 如果是论文提交，还需要更新thesis_submissions表
      if (stage_type === 'thesis_submit') {
        // 获取当前版本号
        const [existingSubmission] = await connection.query(
          `SELECT version 
           FROM thesis_submissions 
           WHERE student_id = ?
           ORDER BY version DESC 
           LIMIT 1`,
          [studentId]
        );

        const version = existingSubmission.length > 0 ?
          existingSubmission[0].version + 1 : 1;

        // 插入新的论文提交记录
        await connection.query(`
          INSERT INTO thesis_submissions (
            student_id,
            version,
            title,
            file_url,
            file_size,
            status,
            submit_time
          ) VALUES (?, ?, ?, ?, ?, ?, NOW())`,
          [studentId, version, `论文提交 v${version}`, file_url, file_size, status]
        );
      }

      // 记录操作日志
      await logUserAction(
        studentId,
        'progress.update',
        `更新${stage_type}阶段状态为${status}`,
        req
      );

      // 提交事务
      await connection.commit();

      res.json({
        code: 200,
        message: '更新成功'
      });

    } catch (error) {
      // 回滚事务
      await connection.rollback();
      throw error;
    }

  } catch (error) {
    console.error('更新进度失败:', error);
    res.status(500).json({
      code: 500,
      message: '更新进度失败'
    });
  } finally {
    connection.release();
  }
};

export const submitFile = async (req: AuthRequest, res: Response) => {
  console.log('开始处理文件上传请求');
  const connection = await pool.getConnection();
  try {
    const { userId } = req.user;
    const file = req.file;
    const { type } = req.body;

    if (!file || !type) {
      return res.status(400).json({
        code: 400,
        message: '未找到上传的文件或类型'
      });
    }

    // 检查是否存在同学生同阶段的记录
    const [existingRecord] = await connection.query(
      'SELECT file_url FROM progress_records WHERE student_id = ? AND stage_type = ?',
      [userId, type]
    );

    let finalFilePath: string;
    if (existingRecord.length > 0 && existingRecord[0].file_url) {
      // 如果存在旧文件，直接用新文件覆盖
      finalFilePath = existingRecord[0].file_url;
      const absolutePath = path.join(process.cwd(), finalFilePath);

      // 确保目录存在
      const dir = path.dirname(absolutePath);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }

      // 移动新文件到旧文件位置（覆盖）
      fs.renameSync(file.path, absolutePath);
    } else {
      // 如果是首次提交，创建新的文件路径
      const uploadDir = path.join('uploads', type);
      if (!fs.existsSync(uploadDir)) {
        fs.mkdirSync(uploadDir, { recursive: true });
      }

      // 构建文件名：学号_阶段类型.扩展名
      const fileExt = path.extname(file.originalname);
      const fileName = `${userId}_${type}${fileExt}`;
      finalFilePath = path.join('uploads', type, fileName).replace(/\\/g, '/');

      // 移动文件到目标位置
      fs.renameSync(file.path, path.join(process.cwd(), finalFilePath));
    }

    // 更新数据库记录
    await connection.query(`
      INSERT INTO progress_records (
        student_id,
        stage_type,
        file_url,
        status,
        submit_time
      ) VALUES (?, ?, ?, 'in_progress', NOW())
      ON DUPLICATE KEY UPDATE
        file_url = VALUES(file_url),
        status = 'in_progress',
        submit_time = NOW()
    `, [userId, type, finalFilePath]);

    // 记录操作日志
    await logUserAction(
      userId,
      'progress.file.submit',
      `更新${type}阶段文件`,
      req
    );

    res.json({
      code: 200,
      message: '文件上传成功',
      data: {
        file_url: finalFilePath,
        file_size: file.size
      }
    });

  } catch (error) {
    console.error('文件上传失败:', error);
    res.status(500).json({
      code: 500,
      message: '文件上传失败',
      error: error.message
    });
  } finally {
    connection.release();
  }
};

export const getProgressDetails = async (req: AuthRequest, res: Response) => {
  const connection = await pool.getConnection();
  try {
    const { id } = req.params;

    // 修改 SQL 查询，添加指导教师信息
    const [details] = await connection.query(`
      SELECT 
        pr.*,
        s.name as student_name,
        s.class_name,
        s.email as student_email,
        s.phone as student_phone,
        ps.name as stage_name,
        ps.type as stage_type,
        ps.weight as stage_weight,
        ps.description as stage_description,
        u.name as teacher_name,
        u.title as teacher_title,
        u.email as teacher_email,
        u.phone as teacher_phone,
        sss.task_book_score,
        sss.literature_score,
        sss.proposal_score,
        sss.translation_score,
        sss.midterm_score,
        sss.thesis_submit_score,
        sss.advisor_review_score,
        sss.peer_review_score,
        sss.defense_score,
        sss.total_weighted_score,
        -- 添加指导教师信息
        supervisor.name as supervisor_name,
        supervisor.title as supervisor_title,
        supervisor.email as supervisor_email,
        supervisor.phone as supervisor_phone
      FROM progress_records pr
      LEFT JOIN students s ON pr.student_id = s.student_id
      LEFT JOIN progress_stages ps ON pr.stage_type = ps.type
      LEFT JOIN topic_selections ts ON pr.student_id = ts.student_id AND ts.final_status = 'approved'
      LEFT JOIN topics t ON ts.topic_id = t.topic_id
      LEFT JOIN users u ON t.teacher_id = u.user_id
      LEFT JOIN student_stage_scores sss ON pr.student_id = sss.student_id
      -- 添加指导教师关联
      LEFT JOIN users supervisor ON t.teacher_id = supervisor.user_id
      WHERE pr.id = ?
    `, [id]);

    if (!details[0]) {
      return res.status(404).json({
        code: 404,
        message: '进度记录不存在'
      });
    }

    await logUserAction(
      req.user.userId,
      'progress.details.view',
      `查看进度详情：ID ${id}`,
      req
    );

    res.json({
      code: 200,
      data: details[0]
    });

  } catch (error) {
    console.error('获取进度详情失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取进度详情失败'
    });
  } finally {
    connection.release();
  }
};

// 获取进度列表
export const getProgressList = async (req: AuthRequest, res: Response) => {
  try {
    const { role, userId } = req.user;
    const pageNum = parseInt(req.query.pageNum as string) || 1;
    const pageSize = parseInt(req.query.pageSize as string) || 10;
    const { keyword, stage, status, className, supervisorId } = req.query;

    const offset = (pageNum - 1) * pageSize;

    let baseQuery = `
      SELECT 
        pr.id,
        pr.student_id,
        pr.stage_id,
        pr.status as record_status,
        pr.submit_time,
        pr.score,
        pr.file_url,
        pr.comment,
        s.name as student_name,
        s.class_name,
        ps.name as stage_name,
        ps.weight as stage_weight,
        sup.name as supervisor_name,
        sup.title as supervisor_title
      FROM progress_records pr
      LEFT JOIN students s ON pr.student_id = s.student_id
      LEFT JOIN progress_stages ps ON pr.stage_id = ps.id
      LEFT JOIN supervisors sup ON pr.reviewer_id = sup.supervisor_id
      WHERE 1=1
    `;

    const params: any[] = [];

    // 添加新的查询条件
    if (className) {
      baseQuery += ` AND s.class_name = ?`;
      params.push(className);
    }

    if (supervisorId) {
      baseQuery += ` AND sup.supervisor_id = ?`;
      params.push(supervisorId);
    }

    // 添加阶段筛选条件
    if (stage) {
      baseQuery += ` AND ps.type = ?`;
      params.push(stage);
    }

    // 添加状态筛选条件
    if (status) {
      baseQuery += ` AND pr.status = ?`;
      params.push(status);
    }

    // 原有的关键字查询条件
    if (keyword) {
      baseQuery += ` AND (s.name LIKE ? OR s.student_id LIKE ?)`;
      params.push(`%${keyword}%`, `%${keyword}%`);
    }

    // 根据角色添加权限过滤
    if (role === 'teacher') {
      baseQuery += ` AND sup.supervisor_id = ?`;
      params.push(userId);
    } else if (role === 'student') {
      baseQuery += ` AND pr.student_id = ?`;
      params.push(userId);
    }

    // 先获取总数
    const countQuery = `SELECT COUNT(*) as total FROM (${baseQuery}) as t`;
    const [countResult] = await pool.execute(countQuery, params);
    const total = (countResult as any[])[0].total;

    // 添加排序和分页
    baseQuery += ` ORDER BY pr.id DESC LIMIT ${pageSize} OFFSET ${offset}`;

    // 执行主查询
    const [rows] = await pool.execute(baseQuery, params);

    res.json({
      code: 200,
      data: {
        list: rows,
        total: total,
        pageNum,
        pageSize
      },
      message: '获取成功'
    });

  } catch (error: any) {
    console.error('获取进度列表失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取进度列表失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// 添加发送提醒功能
export const sendReminder = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    // 获取学生信息
    const [student] = await pool.execute(`
      SELECT s.email, s.name, ps.name as stage_name 
      FROM user_progress up
      JOIN students s ON up.student_id = s.student_id
      JOIN progress_stages ps ON up.current_stage_id = ps.id
      WHERE up.id = ?
    `, [id]);

    if (!student[0]) {
      return res.status(404).json({
        code: 404,
        message: '未找到相关进度记录'
      });
    }

    // TODO: 实现发送邮件的逻辑
    // 这里可以调用邮件服务发送提醒

    res.json({
      code: 200,
      message: '提醒发送成功'
    });
  } catch (error: any) {
    console.error('发送提醒失败:', error);
    res.status(500).json({
      code: 500,
      message: '发送提醒失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// 添加导出进度功能
export const exportProgress = async (req: AuthRequest, res: Response) => {
  try {
    const { role, userId } = req.user;
    const { stage, status } = req.query;

    let query = `
      SELECT 
        s.name as student_name,
        s.class_name,
        sup.name as supervisor_name,
        ps.name as stage_name,
        ps.weight as stage_weight,
        pr.status as record_status,
        pr.submit_time,
        pr.score
      FROM user_progress up
      LEFT JOIN students s ON up.student_id = s.student_id
      LEFT JOIN supervisors sup ON up.supervisor_id = sup.supervisor_id
      LEFT JOIN progress_stages ps ON up.current_stage_id = ps.id
      LEFT JOIN progress_records pr ON up.student_id = pr.student_id 
        AND up.current_stage_id = pr.stage_id
      WHERE 1=1
    `;

    const params: any[] = [];

    // 根据角色过滤
    if (role === 'teacher') {
      query += ' AND up.supervisor_id = ?';
      params.push(userId);
    }

    // 阶段筛选
    if (stage) {
      query += ` AND ps.type = ?`;
      params.push(stage);
    }

    // 状态筛选
    if (status) {
      query += ` AND up.status = ?`;
      params.push(status);
    }

    const [rows] = await pool.execute(query, params);

    // 设置响应头为Excel文件
    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', 'attachment; filename=progress-export.xlsx');

    // 返回数据
    res.json({
      code: 200,
      data: rows,
      message: '导出成功'
    });
  } catch (error: any) {
    console.error('导出进度失败:', error);
    res.status(500).json({
      code: 500,
      message: '导出进度失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// 添加获取统计数据的函数
export const getStatistics = async (req: AuthRequest, res: Response) => {
  try {
    console.log('开始获取统计数据...');  // 添加日志
    const { role, userId } = req.user;
    let whereClause = '1=1';
    const params: any[] = [];

    // 根据角色过滤数据
    if (role === 'student') {
      whereClause += ' AND pr.student_id = ?';
      params.push(userId);
    } else if (role === 'teacher') {
      whereClause += ' AND pr.reviewer_id = ?';
      params.push(userId);
    }

    console.log('执行统计查询，SQL:', whereClause);  // 添加日志
    console.log('参数:', params);  // 添加日志

    const query = `
      SELECT 
        COUNT(DISTINCT pr.student_id) as totalStudents,
        SUM(CASE WHEN pr.status IN ('submitted', 'reviewing') THEN 1 ELSE 0 END) as inProgress,
        SUM(CASE WHEN pr.status = 'approved' THEN 1 ELSE 0 END) as completed,
        SUM(CASE 
          WHEN pr.status NOT IN ('approved', 'rejected') 
          AND DATEDIFF(CURRENT_DATE, pr.submit_time) > 30 
          THEN 1 ELSE 0 END) as overdue
      FROM progress_records pr
      WHERE ${whereClause}
    `;

    const [rows] = await pool.execute(query, params);
    console.log('查询结果:', rows);  // 添加日志

    const statistics = {
      totalStudents: Number(rows[0]?.totalStudents || 0),
      inProgress: Number(rows[0]?.inProgress || 0),
      completed: Number(rows[0]?.completed || 0),
      overdue: Number(rows[0]?.overdue || 0)
    };

    console.log('返回统计数据:', statistics);  // 添加日志

    res.json({
      code: 200,
      data: statistics,
      message: '获取统计数据成功'
    });
  } catch (error: any) {
    console.error('获取统计数据失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取统计数据失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// 添加更新分数的控制器函数
export const updateStageScore = async (req: AuthRequest, res: Response) => {
  try {
    const { student_id, stage_type, score } = req.body;

    // 验证分数范围
    if (score < 0 || score > 100) {
      return res.status(400).json({
        code: 400,
        message: '分数必须在0-100之间'
      });
    }

    // 根据阶段类型确定要更新的字段
    const scoreFieldMap: Record<string, string> = {
      'task_book': 'task_book_score',
      'literature': 'literature_score',
      'proposal': 'proposal_score',
      'translation': 'translation_score',
      'midterm': 'midterm_score',
      'thesis_submit': 'thesis_submit_score',
      'advisor_review': 'advisor_review_score',
      'peer_review': 'peer_review_score',
      'defense': 'defense_score'
    };

    const scoreField = scoreFieldMap[stage_type];
    if (!scoreField) {
      return res.status(400).json({
        code: 400,
        message: '无效的阶段类型'
      });
    }

    // 更新分数
    await pool.execute(
      `INSERT INTO student_stage_scores (student_id, ${scoreField})
       VALUES (?, ?)
       ON DUPLICATE KEY UPDATE ${scoreField} = ?`,
      [student_id, score, score]
    );

    // 重计算加权分数
    await pool.execute(
      `UPDATE student_stage_scores sss
       JOIN (
         SELECT ps.type, ps.weight
         FROM progress_stages ps
         WHERE ps.status != 'cancelled'
       ) stages ON 1=1
       SET sss.total_weighted_score = (
         COALESCE(sss.task_book_score * CASE WHEN stages.type = 'task_book' THEN stages.weight ELSE 0 END, 0) +
         COALESCE(sss.literature_score * CASE WHEN stages.type = 'literature' THEN stages.weight ELSE 0 END, 0) +
         COALESCE(sss.proposal_score * CASE WHEN stages.type = 'proposal' THEN stages.weight ELSE 0 END, 0) +
         COALESCE(sss.translation_score * CASE WHEN stages.type = 'translation' THEN stages.weight ELSE 0 END, 0) +
         COALESCE(sss.midterm_score * CASE WHEN stages.type = 'midterm' THEN stages.weight ELSE 0 END, 0) +
         COALESCE(sss.thesis_submit_score * CASE WHEN stages.type = 'thesis_submit' THEN stages.weight ELSE 0 END, 0) +
         COALESCE(sss.advisor_review_score * CASE WHEN stages.type = 'advisor_review' THEN stages.weight ELSE 0 END, 0) +
         COALESCE(sss.peer_review_score * CASE WHEN stages.type = 'peer_review' THEN stages.weight ELSE 0 END, 0) +
         COALESCE(sss.defense_score * CASE WHEN stages.type = 'defense' THEN stages.weight ELSE 0 END, 0)
       ) / 100
       WHERE sss.student_id = ?`,
      [student_id]
    );

    // 添加日志记录
    await logUserAction(
      req.user.userId,
      'progress.score.update',
      `更新分数：学生${student_id}，阶段${stage_type}，分数${score}`,
      req
    );

    res.json({
      code: 200,
      message: '分数更新成功'
    });
  } catch (error: any) {
    console.error('更新分数失败:', error);
    res.status(500).json({
      code: 500,
      message: '更新分数失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// 添加获取班级列表的控制器
export const getClasses = async (req: Request, res: Response) => {
  try {
    const [rows] = await pool.execute(`
      SELECT DISTINCT class_name 
      FROM students 
      WHERE class_name IS NOT NULL 
      ORDER BY class_name
    `)

    res.json({
      code: 200,
      data: (rows as any[]).map(row => row.class_name),
      message: '获取成功'
    })
  } catch (error) {
    console.error('获取班级列表失败:', error)
    res.status(500).json({
      code: 500,
      message: '获取班级列表失败'
    })
  }
}

// 添加获取教师列表的控制器
export const getTeachers = async (req: Request, res: Response) => {
  try {
    const [rows] = await pool.execute(`
      SELECT supervisor_id as id, name, title 
      FROM supervisors 
      ORDER BY name
    `)

    res.json({
      code: 200,
      data: rows,
      message: '获取成功'
    })
  } catch (error) {
    console.error('获取教师列表失败:', error)
    res.status(500).json({
      code: 500,
      message: '获取教师列表失败'
    })
  }
}

export const getStudentProgress = async (req: AuthRequest, res: Response) => {
  const connection = await pool.getConnection();
  try {
    const studentId = req.user?.userId;

    // 获取所有阶段定义
    const [stages] = await connection.query(`
      SELECT 
        id,
        name,
        type,
        sequence,
        required_files,
        requires_review,
        weight,
        description,
        status
      FROM progress_stages
      WHERE status = 'active'
      ORDER BY sequence ASC
    `);

    // 获取学生的进度记录
    const [records] = await connection.query(`
      SELECT 
        pr.*,
        sss.task_book_score,
        sss.literature_score,
        sss.proposal_score,
        sss.translation_score,
        sss.midterm_score,
        sss.thesis_submit_score,
        sss.advisor_review_score,
        sss.peer_review_score,
        sss.defense_score,
        sss.total_weighted_score
      FROM progress_records pr
      LEFT JOIN student_stage_scores sss ON pr.student_id = sss.student_id
      WHERE pr.student_id = ?
    `, [studentId]);

    // 查并自动开启下一阶段
    for (let i = 0; i < (stages as any[]).length - 1; i++) {
      const currentStage = (stages as any[])[i];
      const nextStage = (stages as any[])[i + 1];

      // 检查当前阶段是否完成
      const currentRecord = (records as any[]).find(r => r.stage_type === currentStage.type);
      const nextRecord = (records as any[]).find(r => r.stage_type === nextStage.type);

      if (currentRecord?.status === 'completed' && (!nextRecord || nextRecord.status === 'not_started')) {
        // 自动开启下一阶段
        await connection.query(`
          INSERT INTO progress_records (
            student_id,
            stage_type,
            status,
            created_at
          ) VALUES (?, ?, 'in_progress', NOW())
          ON DUPLICATE KEY UPDATE
            status = 'in_progress',
            updated_at = NOW()
        `, [studentId, nextStage.type]);

        // 记录日志
        await logUserAction(
          studentId,
          'progress.stage.auto_start',
          `自动开启新阶段：${nextStage.type}`,
          req
        );
      }
    }

    // 重新获取更新后的记录
    const [updatedRecords] = await connection.query(`
      SELECT 
        pr.*,
        sss.task_book_score,
        sss.literature_score,
        sss.proposal_score,
        sss.translation_score,
        sss.midterm_score,
        sss.thesis_submit_score,
        sss.advisor_review_score,
        sss.peer_review_score,
        sss.defense_score,
        sss.total_weighted_score
      FROM progress_records pr
      LEFT JOIN student_stage_scores sss ON pr.student_id = sss.student_id
      WHERE pr.student_id = ?
    `, [studentId]);

    // 构建完整的进度数据
    const progressData = {
      stages: (stages as any[]).map(stage => {
        const record = (updatedRecords as any[]).find(r => r.stage_type === stage.type) || {};
        const scoreField = `${stage.type}_score`;

        return {
          ...stage,
          ...record,
          score: record[scoreField],
          status: record.status || 'not_started',
          canStart: stage.sequence === 1 ||
            (stages as any[]).find(s => s.sequence === stage.sequence - 1)?.type in
            (updatedRecords as any[]).filter(r => r.status === 'completed').map(r => r.stage_type)
        };
      }),
      totalScore: (updatedRecords as any[])[0]?.total_weighted_score || null
    };

    res.json({
      code: 200,
      data: progressData,
      message: '获取成功'
    });

  } catch (error) {
    console.error('获取进度失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取进度失败'
    });
  } finally {
    connection.release();
  }
};

// 开启下一阶段
export const startNextStage = async (req: AuthRequest, res: Response) => {
  const connection = await pool.getConnection();
  try {
    const { currentStage, nextStage } = req.body;
    const studentId = req.user?.userId;

    // 验证当前阶段和下一阶段
    const [stagesCheck] = await connection.query(`
      SELECT * FROM progress_stages 
      WHERE type IN (?, ?) 
      AND status = 'active'
      ORDER BY sequence ASC
    `, [currentStage, nextStage]);

    if ((stagesCheck as any[]).length !== 2) {
      return res.status(400).json({
        code: 400,
        message: '无效的阶段类型'
      });
    }

    // 验证当前阶段是否已完成
    const [currentRecord] = await connection.query(`
      SELECT * FROM progress_records 
      WHERE student_id = ? 
      AND stage_type = ?
      AND status = 'completed'
    `, [studentId, currentStage]);

    if (!(currentRecord as any[])[0]) {
      return res.status(400).json({
        code: 400,
        message: '当前阶段尚未完成'
      });
    }

    // 开启下一阶段
    await connection.query(`
      INSERT INTO progress_records (
        student_id,
        stage_type,
        status,
        created_at
      ) VALUES (?, ?, 'in_progress', NOW())
      ON DUPLICATE KEY UPDATE
        status = 'in_progress',
        updated_at = NOW()
    `, [studentId, nextStage]);

    await logUserAction(
      req.user.userId,
      'progress.stage.start',
      `开启新阶段：从 ${currentStage} 到 ${nextStage}`,
      req
    );

    res.json({
      code: 200,
      message: '下一阶段已开启',
      data: {
        stage_type: nextStage,
        status: 'in_progress'
      }
    });

  } catch (error) {
    console.error('开启下一阶段失败:', error);
    res.status(500).json({
      code: 500,
      message: '开启下一阶段失败'
    });
  } finally {
    connection.release();
  }
};

// 获取或创建文献综述记录
export const getOrCreateLiteratureReview = async (req: AuthRequest, res: Response) => {
  const connection = await pool.getConnection();
  try {
    const studentId = req.user?.userId;

    // 1. 获取当前进度记录，检查是否已到文献综述阶段
    const [currentProgress] = await connection.query(`
      SELECT pr.*, ps.sequence
      FROM progress_records pr
      JOIN progress_stages ps ON pr.stage_type = ps.type
      WHERE pr.student_id = ? AND pr.stage_type = 'literature'
      LIMIT 1
    `, [studentId]);

    if (!currentProgress[0]) {
      return res.status(400).json({
        code: 400,
        message: '尚未进入文献综述阶段'
      });
    }

    // 2. 获取指导教师信息
    const [teacherInfo] = await connection.query(`
      SELECT t.teacher_id
      FROM topic_selections ts
      JOIN topics t ON ts.topic_id = t.topic_id
      WHERE ts.student_id = ? AND ts.final_status = 'approved'
      LIMIT 1
    `, [studentId]);

    if (!teacherInfo[0]) {
      return res.status(400).json({
        code: 400,
        message: '未找到指导教师信息'
      });
    }

    // 3. 检查是否已有文献综述记录
    const [existingReview] = await connection.query(`
      SELECT *
      FROM literature_reviews
      WHERE student_id = ?
      ORDER BY version DESC
      LIMIT 1
    `, [studentId]);

    if (!existingReview[0]) {
      // 4. 创建新记录
      await connection.query(`
        INSERT INTO literature_reviews (
          student_id,
          teacher_id,
          status,
          version
        ) VALUES (?, ?, 'not_started', 1)
      `, [studentId, teacherInfo[0].teacher_id]);
    } else {
      // 5. 更新现有记录的状态（如果需要）
      // 从 progress_records 同步状态和文件信息
      await connection.query(`
        UPDATE literature_reviews
        SET 
          status = ?,
          file_url = ?,
          submit_time = ?,
          updated_at = NOW()
        WHERE id = ?
      `, [
        currentProgress[0].status,
        currentProgress[0].file_url,
        currentProgress[0].submit_time,
        existingReview[0].id
      ]);
    }

    // 6. 获取最新的记录
    const [updatedReview] = await connection.query(`
      SELECT 
        lr.*,
        u.name as teacher_name,
        u.title as teacher_title,
        ps.weight as literature_weight,
        sss.*,
        (
          COALESCE(sss.task_book_score * 
            (SELECT weight FROM progress_stages WHERE type = 'task_book'), 0) +
          COALESCE(sss.literature_score * 
            (SELECT weight FROM progress_stages WHERE type = 'literature'), 0) +
          COALESCE(sss.proposal_score * 
            (SELECT weight FROM progress_stages WHERE type = 'proposal'), 0) +
          COALESCE(sss.translation_score * 
            (SELECT weight FROM progress_stages WHERE type = 'translation'), 0) +
          COALESCE(sss.midterm_score * 
            (SELECT weight FROM progress_stages WHERE type = 'midterm'), 0) +
          COALESCE(sss.thesis_submit_score * 
            (SELECT weight FROM progress_stages WHERE type = 'thesis_submit'), 0) +
          COALESCE(sss.advisor_review_score * 
            (SELECT weight FROM progress_stages WHERE type = 'advisor_review'), 0) +
          COALESCE(sss.peer_review_score * 
            (SELECT weight FROM progress_stages WHERE type = 'peer_review'), 0) +
          COALESCE(sss.defense_score * 
            (SELECT weight FROM progress_stages WHERE type = 'defense'), 0)
        ) as calculated_weighted_score,
        (
          SELECT GROUP_CONCAT(
            CONCAT(type, ':', COALESCE(
              CASE 
                WHEN type = 'task_book' THEN sss.task_book_score
                WHEN type = 'literature' THEN sss.literature_score
                WHEN type = 'proposal' THEN sss.proposal_score
                WHEN type = 'translation' THEN sss.translation_score
                WHEN type = 'midterm' THEN sss.midterm_score
                WHEN type = 'thesis_submit' THEN sss.thesis_submit_score
                WHEN type = 'advisor_review' THEN sss.advisor_review_score
                WHEN type = 'peer_review' THEN sss.peer_review_score
                WHEN type = 'defense' THEN sss.defense_score
              END, 'N/A'
            ), '×', weight, '%')
            ORDER BY sequence
          ) 
          FROM progress_stages 
          WHERE status = 'active'
        ) as score_details
      FROM literature_reviews lr
      LEFT JOIN users u ON lr.teacher_id = u.user_id
      LEFT JOIN progress_stages ps ON ps.type = 'literature'
      LEFT JOIN student_stage_scores sss ON lr.student_id = sss.student_id
      WHERE lr.student_id = ?
      ORDER BY lr.version DESC
      LIMIT 1
    `, [studentId]);

    // 添加调试日志
    console.log('查询结果:', {
      studentId,
      scores: {
        task_book: updatedReview[0]?.task_book_score,
        literature: updatedReview[0]?.literature_score,
        proposal: updatedReview[0]?.proposal_score,
        translation: updatedReview[0]?.translation_score,
        midterm: updatedReview[0]?.midterm_score,
        thesis_submit: updatedReview[0]?.thesis_submit_score,
        advisor_review: updatedReview[0]?.advisor_review_score,
        peer_review: updatedReview[0]?.peer_review_score,
        defense: updatedReview[0]?.defense_score
      },
      weights: updatedReview[0]?.stage_weights,
      calculatedScore: updatedReview[0]?.calculated_weighted_score
    });

    res.json({
      code: 200,
      data: updatedReview[0]
    });

  } catch (error) {
    console.error('获取文献综述记录失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取文献综述记录失败'
    });
  } finally {
    connection.release();
  }
};

// 更新文献综述评阅结果
export const updateLiteratureReview = async (req: AuthRequest, res: Response) => {
  const connection = await pool.getConnection();
  try {
    const teacherId = req.user?.userId;
    const {
      student_id,
      content_score,
      analysis_score,
      structure_score,
      writing_score,
      content_comment,
      improvement_suggestions,
      general_comment,
      status,
      total_score
    } = req.body;

    console.log('收到评阅请求:', req.body); // 添加日志

    await connection.beginTransaction();

    // 1. 更新 literature_reviews 表
    await connection.execute(
      `INSERT INTO literature_reviews (
        student_id,
        teacher_id,
        content_score,
        analysis_score,
        structure_score,
        writing_score,
        content_comment,
        improvement_suggestions,
        general_comment,
        total_score,
        updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
      ON DUPLICATE KEY UPDATE
        content_score = VALUES(content_score),
        analysis_score = VALUES(analysis_score),
        structure_score = VALUES(structure_score),
        writing_score = VALUES(writing_score),
        content_comment = VALUES(content_comment),
        improvement_suggestions = VALUES(improvement_suggestions),
        general_comment = VALUES(general_comment),
        total_score = VALUES(total_score),
        updated_at = NOW()`,
      [
        student_id,
        teacherId,
        content_score,
        analysis_score,
        structure_score,
        writing_score,
        content_comment,
        improvement_suggestions,
        general_comment,
        total_score
      ]
    );

    // 2. 更新 progress_records 表
    await connection.execute(
      `UPDATE progress_records 
       SET status = ?,
           score = ?,
           teacher_comment = ?,
           review_time = NOW()
       WHERE student_id = ? AND stage_type = 'literature'`,
      [status, total_score, general_comment, student_id]
    );

    // 3. 如果状态为completed，更新student_stage_scores表
    if (status === 'completed') {
      await connection.execute(
        `UPDATE student_stage_scores 
         SET literature_score = ?,
             total_weighted_score = (
               SELECT SUM(
                 CASE 
                   WHEN ps.type = 'literature' THEN ? * ps.weight
                   WHEN ps.type = 'task_book' THEN COALESCE(task_book_score, 0) * ps.weight
                   WHEN ps.type = 'proposal' THEN COALESCE(proposal_score, 0) * ps.weight
                   WHEN ps.type = 'translation' THEN COALESCE(translation_score, 0) * ps.weight
                   WHEN ps.type = 'midterm' THEN COALESCE(midterm_score, 0) * ps.weight
                   WHEN ps.type = 'thesis_submit' THEN COALESCE(thesis_submit_score, 0) * ps.weight
                   WHEN ps.type = 'advisor_review' THEN COALESCE(advisor_review_score, 0) * ps.weight
                   WHEN ps.type = 'peer_review' THEN COALESCE(peer_review_score, 0) * ps.weight
                   WHEN ps.type = 'defense' THEN COALESCE(defense_score, 0) * ps.weight
                   ELSE 0
                 END
               ) / 100
               FROM progress_stages ps
               WHERE ps.status = 'active'
             )
         WHERE student_id = ?`,
        [total_score, total_score, student_id]
      );
    }

    await connection.commit();

    // 记录操作日志
    await logUserAction(
      teacherId,
      'literature.review.update',
      `更新文献综述评阅：学生 ${student_id}, 状态 ${status}, 总分 ${total_score}`,
      req
    );

    res.json({
      code: 200,
      message: status === 'revision_needed' ? '已要求修改' : '评阅成功',
      data: { total_score }
    });

  } catch (error) {
    await connection.rollback();
    console.error('评阅文献综述失败:', error);
    res.status(500).json({
      code: 500,
      message: '评阅失败',
      error: error.message
    });
  } finally {
    connection.release();
  }
};

// 获取文献综述列表
export const getLiteratureReviews = async (req: Request, res: Response) => {
  const connection = await pool.getConnection();

  try {
    const { pageNum = 1, pageSize = 10, keyword, status } = req.query;
    const teacher_id = req.user.userId;

    let query = `
      SELECT 
        lr.*,
        s.name as student_name,
        u.name as teacher_name,
        pr.status as progress_status,
        pr.file_url as progress_file_url,
        pr.submit_time as progress_submit_time,
        pr.review_time as progress_review_time,
        pr.score as progress_score,
        pr.teacher_comment as progress_comment
      FROM literature_reviews lr
      LEFT JOIN students s ON lr.student_id = s.student_id
      LEFT JOIN users u ON lr.teacher_id = u.user_id
      LEFT JOIN progress_records pr ON lr.student_id = pr.student_id 
        AND pr.stage_type = 'literature'
      WHERE lr.teacher_id = ?
    `;
    const params: any[] = [teacher_id];

    if (keyword) {
      query += ` AND (lr.student_id LIKE ? OR s.name LIKE ?)`;
      params.push(`%${keyword}%`, `%${keyword}%`);
    }

    if (status) {
      query += ` AND pr.status = ?`;  // 改为使用 progress_records 的状态
      params.push(status);
    }

    // 获取总数
    const [countResult] = await connection.query(
      `SELECT COUNT(*) as total FROM (${query}) as t`,
      params
    );
    const total = countResult[0].total;

    // 添加分页和排序（优先按提交时间排序）
    query += ` ORDER BY pr.submit_time DESC, lr.updated_at DESC LIMIT ? OFFSET ?`;
    params.push(Number(pageSize), (Number(pageNum) - 1) * Number(pageSize));

    // 获取列表数据
    const [rows] = await connection.query(query, params);

    // 处理返回数据，合并 progress_records 的信息
    const formattedRows = (rows as any[]).map(row => ({
      ...row,
      status: row.progress_status || row.status,
      file_url: row.progress_file_url || row.file_url,
      submit_time: row.progress_submit_time || row.submit_time,
      review_time: row.progress_review_time || row.review_time,
      score: row.progress_score || row.total_score,
      teacher_comment: row.progress_comment || row.general_comment
    }));

    res.json({
      code: 200,
      message: '获取成功',
      data: {
        list: formattedRows,
        total,
        pageNum: Number(pageNum),
        pageSize: Number(pageSize)
      }
    });
  } catch (error) {
    console.error('获取文献综述列表失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取失败',
      error: error.message
    });
  } finally {
    connection.release();
  }
};

// 添加路由
export const progressRoutes = (router: Router) => {
  router.get('/api/progress/literature-reviews', auth, getLiteratureReviews)
  router.post('/api/progress/literature-review', auth, updateLiteratureReview)
}

// 获取或创建开题报告记录
export const getOrCreateProposalReview = async (req: AuthRequest, res: Response) => {
  const connection = await pool.getConnection();
  try {
    const studentId = req.user?.userId;

    // 修改查询，添加阶段权重信息
    const [result] = await connection.query(`
      SELECT 
        pr.*,
        u.name as teacher_name,
        u.title as teacher_title,
        u.email as teacher_email,
        u.phone as teacher_phone,
        ps.weight as proposal_weight
      FROM proposal_reviews pr
      LEFT JOIN topic_selections ts ON pr.student_id = ts.student_id AND ts.final_status = 'approved'
      LEFT JOIN topics t ON ts.topic_id = t.topic_id
      LEFT JOIN users u ON t.teacher_id = u.user_id
      LEFT JOIN progress_stages ps ON ps.type = 'proposal'
      WHERE pr.student_id = ?
      ORDER BY pr.version DESC
      LIMIT 1
    `, [studentId]);

    // 如果没有记录，创建新记录
    if (!result[0]) {
      // 获取指导教师信息和阶段权重
      const [teacherAndStageInfo] = await connection.query(`
        SELECT 
          u.user_id as teacher_id,
          u.name as teacher_name,
          u.title as teacher_title,
          u.email as teacher_email,
          u.phone as teacher_phone,
          ps.weight as proposal_weight
        FROM topic_selections ts
        JOIN topics t ON ts.topic_id = t.topic_id
        JOIN users u ON t.teacher_id = u.user_id
        JOIN progress_stages ps ON ps.type = 'proposal'
        WHERE ts.student_id = ? AND ts.final_status = 'approved'
        LIMIT 1
      `, [studentId]);

      if (!teacherAndStageInfo[0]) {
        return res.status(400).json({
          code: 400,
          message: '未找到指导教师信息'
        });
      }

      // 创建新记录
      await connection.query(`
        INSERT INTO proposal_reviews 
        (student_id, teacher_id, version, status)
        VALUES (?, ?, 1, 'not_started')
      `, [studentId, teacherAndStageInfo[0].teacher_id]);

      // 返回新创建的记录和教师信息
      return res.json({
        code: 200,
        data: {
          student_id: studentId,
          teacher_id: teacherAndStageInfo[0].teacher_id,
          version: 1,
          status: 'not_started',
          teacher_name: teacherAndStageInfo[0].teacher_name,
          teacher_title: teacherAndStageInfo[0].teacher_title,
          teacher_email: teacherAndStageInfo[0].teacher_email,
          teacher_phone: teacherAndStageInfo[0].teacher_phone,
          proposal_weight: teacherAndStageInfo[0].proposal_weight
        }
      });
    }

    res.json({
      code: 200,
      data: result[0]
    });

  } catch (error) {
    console.error('获取开题报告记录失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取开题报告记录失败'
    });
  } finally {
    connection.release();
  }
};

// 获取学生最新任务书
export const getLatestTaskBook = async (req: AuthRequest, res: Response) => {
  const connection = await pool.getConnection();
  try {
    const { studentId } = req.params;

    // 修改查询，添加教师信息
    const [result] = await connection.query(`
      SELECT 
        tb.*,
        u.name as teacher_name,
        u.title as teacher_title,
        u.email as teacher_email,
        u.phone as teacher_phone,
        t.title as topic_title,
        t.description as topic_description
      FROM task_books tb
      LEFT JOIN topic_selections ts ON tb.student_id = ts.student_id AND ts.final_status = 'approved'
      LEFT JOIN topics t ON ts.topic_id = t.topic_id
      LEFT JOIN users u ON t.teacher_id = u.user_id
      WHERE tb.student_id = ?
      ORDER BY tb.version DESC
      LIMIT 1
    `, [studentId]);

    if (!result[0]) {
      // 如果没有任务书记录，创建新记录
      // 先获取指导教师和课题信息
      const [teacherAndTopicInfo] = await connection.query(`
        SELECT 
          u.user_id as teacher_id,
          u.name as teacher_name,
          u.title as teacher_title,
          u.email as teacher_email,
          u.phone as teacher_phone,
          t.title as topic_title,
          t.description as topic_description
        FROM topic_selections ts
        JOIN topics t ON ts.topic_id = t.topic_id
        JOIN users u ON t.teacher_id = u.user_id
        WHERE ts.student_id = ? AND ts.final_status = 'approved'
        LIMIT 1
      `, [studentId]);

      if (!teacherAndTopicInfo[0]) {
        return res.status(400).json({
          code: 400,
          message: '未找到指导教师或课题信息'
        });
      }

      // 创建新的任务书记录
      await connection.query(`
        INSERT INTO task_books 
        (student_id, teacher_id, version, status, topic_title)
        VALUES (?, ?, 1, 'not_started', ?)
      `, [studentId, teacherAndTopicInfo[0].teacher_id, teacherAndTopicInfo[0].topic_title]);

      // 返回新创建的记录和教师信息
      return res.json({
        code: 200,
        data: {
          student_id: studentId,
          teacher_id: teacherAndTopicInfo[0].teacher_id,
          version: 1,
          status: 'not_started',
          topic_title: teacherAndTopicInfo[0].topic_title,
          topic_description: teacherAndTopicInfo[0].topic_description,
          teacher_name: teacherAndTopicInfo[0].teacher_name,
          teacher_title: teacherAndTopicInfo[0].teacher_title,
          teacher_email: teacherAndTopicInfo[0].teacher_email,
          teacher_phone: teacherAndTopicInfo[0].teacher_phone
        }
      });
    }

    res.json({
      code: 200,
      data: result[0]
    });

  } catch (error) {
    console.error('获取任务书失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取任务书失败'
    });
  } finally {
    connection.release();
  }
};

// 获取或创建中期检查记录
export const getOrCreateMidtermReview = async (req: AuthRequest, res: Response) => {
  const connection = await pool.getConnection();
  try {
    const studentId = req.user?.userId;
    console.log('获取中期检查记录，学生ID:', studentId);

    const [reviews] = await connection.query(`
      SELECT 
        mr.*,
        u.name as teacher_name,
        u.title as teacher_title,
        t.title as topic_title,
        t.description as topic_description
      FROM midterm_reports mr
      JOIN topic_selections ts ON ts.student_id = mr.student_id
      JOIN topics t ON ts.topic_id = t.topic_id
      JOIN users u ON t.teacher_id = u.user_id
      WHERE mr.student_id = ? 
        AND ts.final_status = 'approved'
      ORDER BY mr.version DESC 
      LIMIT 1
    `, [studentId]);

    console.log('查询结果:', reviews);

    if (reviews.length === 0) {
      // 如果没有记录，创建新记录
      const [teacherInfo] = await connection.query(`
        SELECT 
          u.user_id as teacher_id,
          u.name as teacher_name,
          u.title as teacher_title,
          t.title as topic_title,
          t.description as topic_description
        FROM topic_selections ts
        JOIN topics t ON ts.topic_id = t.topic_id
        JOIN users u ON t.teacher_id = u.user_id
        WHERE ts.student_id = ? 
          AND ts.final_status = 'approved'
      `, [studentId]);

      if (teacherInfo.length > 0) {
        // 创建新的中期检查记录
        await connection.query(`
          INSERT INTO midterm_reports (
            student_id,
            teacher_id,
            version,
            status,
            created_at
          ) VALUES (?, ?, 1, 'not_started', NOW())
        `, [studentId, teacherInfo[0].teacher_id]);

        // 返回初始记录
        res.json({
          code: 200,
          data: {
            student_id: studentId,
            teacher_id: teacherInfo[0].teacher_id,
            teacher_name: teacherInfo[0].teacher_name,
            teacher_title: teacherInfo[0].teacher_title,
            topic_title: teacherInfo[0].topic_title,
            topic_description: teacherInfo[0].topic_description,
            version: 1,
            status: 'not_started',
            created_at: new Date()
          }
        });
      } else {
        res.status(404).json({
          code: 404,
          message: '未找到相关选题信息'
        });
      }
    } else {
      // 返回现有记录
      res.json({
        code: 200,
        data: reviews[0]
      });
    }

  } catch (error) {
    console.error('获取中期检查记录失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取中期检查记录失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  } finally {
    connection.release();
  }
};

// 更新提交中期报告的函数
export const createOrUpdateMidtermReview = async (req: AuthRequest, res: Response) => {
  const connection = await pool.getConnection();
  try {
    const { file_url, file_size } = req.body;
    const studentId = req.user?.userId;

    // 检查是否存在记录
    const [existingRecord] = await connection.query(`
      SELECT id, version
      FROM midterm_reports
      WHERE student_id = ?
      ORDER BY version DESC
      LIMIT 1
    `, [studentId]);

    if (existingRecord.length > 0) {
      // 如果存在记录，直接更新
      await connection.query(`
        UPDATE midterm_reports
        SET 
          file_url = ?,
          file_size = ?,
          status = 'reviewing',
          submit_time = NOW(),
          updated_at = NOW()
        WHERE id = ?
      `, [
        file_url,
        file_size,
        existingRecord[0].id
      ]);

      await logUserAction(
        req.user.userId,
        'midterm.update',
        `更新中期检查报告：版本 ${existingRecord[0].version}`,
        req
      );

      res.json({
        code: 200,
        message: '更新成功',
        data: {
          version: existingRecord[0].version
        }
      });
    } else {
      // 如果不存在记录，创建新记录
      await connection.query(`
        INSERT INTO midterm_reports (
          student_id,
          file_url,
          file_size,
          version,
          status,
          submit_time,
          created_at,
          updated_at
        ) VALUES (
          ?,
          ?,
          ?,
          1,
          'reviewing',
          NOW(),
          NOW()
        )
      `, [
        studentId,
        file_url,
        file_size
      ]);

      await logUserAction(
        req.user.userId,
        'midterm.submit',
        '提交中期检查报告：版本 1',
        req
      );

      res.json({
        code: 200,
        message: '提交成功',
        data: {
          version: 1
        }
      });
    }

  } catch (error) {
    console.error('提交中期检查记录失败:', error);
    res.status(500).json({
      code: 500,
      message: '提交失败'
    });
  } finally {
    connection.release();
  }
};

// 获取中期检查记录
export const getMidtermReview = async (req: AuthRequest, res: Response) => {
  const connection = await pool.getConnection();
  try {
    const studentId = req.user?.userId;

    // 修改查询语句，确保能获取到教师信息
    const [reviews] = await connection.query(`
      SELECT 
        mr.*,
        u.name as teacher_name,
        u.title as teacher_title,
        t.title as topic_title,
        t.description as topic_description
      FROM midterm_reports mr
      JOIN topic_selections ts ON ts.student_id = mr.student_id
      JOIN topics t ON ts.topic_id = t.topic_id
      JOIN users u ON t.teacher_id = u.user_id
      WHERE mr.student_id = ? 
        AND ts.final_status = 'approved'
      ORDER BY mr.version DESC 
      LIMIT 1
    `, [studentId]);

    if (reviews.length === 0) {
      // 如果没有记录，创建新记录
      const [teacherInfo] = await connection.query(`
        SELECT 
          u.user_id as teacher_id,
          u.name as teacher_name,
          u.title as teacher_title,
          u.email as teacher_email,
          u.phone as teacher_phone,
          t.title as topic_title,
          t.description as topic_description
        FROM topic_selections ts
        JOIN topics t ON ts.topic_id = t.topic_id
        JOIN users u ON t.teacher_id = u.user_id
        WHERE ts.student_id = ? 
          AND ts.final_status = 'approved'
      `, [studentId]);

      if (teacherInfo.length > 0) {
        // 创建新的中期检查记录
        await connection.query(`
          INSERT INTO midterm_reports (
            student_id,
            teacher_id,
            version,
            status,
            created_at
          ) VALUES (?, ?, 1, 'not_started', NOW())
        `, [studentId, teacherInfo[0].teacher_id]);

        // 返回初始记录
        res.json({
          code: 200,
          data: {
            student_id: studentId,
            teacher_id: teacherInfo[0].teacher_id,
            teacher_name: teacherInfo[0].teacher_name,
            teacher_title: teacherInfo[0].teacher_title,
            teacher_email: teacherInfo[0].teacher_email,
            teacher_phone: teacherInfo[0].teacher_phone,
            topic_title: teacherInfo[0].topic_title,
            topic_description: teacherInfo[0].topic_description,
            version: 1,
            status: 'not_started',
            created_at: new Date()
          }
        });
      } else {
        res.status(404).json({
          code: 404,
          message: '未找到相关选题信息'
        });
      }
    } else {
      // 返回现有记录
      res.json({
        code: 200,
        data: reviews[0]
      });
    }

  } catch (error) {
    console.error('获取中期检查记录失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取中期检查记录失败'
    });
  } finally {
    connection.release();
  }
};

// 处理论文提交
export const handleThesisSubmit = async (req: AuthRequest, res: Response) => {
  const connection = await pool.getConnection();
  try {
    const studentId = req.user?.userId;
    const file = req.file;

    if (!file) {
      return res.status(400).json({
        code: 400,
        message: '请选择要上传的文件'
      });
    }

    // 添加论文提交类型
    req.body.type = 'thesis_submit';

    // 调用现有的 submitFile 处理文件上传
    const uploadResult = await submitFile(req, res);

    // 如果文件上传成功，更新论文提交记录
    if (uploadResult && uploadResult.code === 200) {
      const { file_url, file_size } = uploadResult.data;

      // 获取当前论文提交记录
      const [existingSubmission] = await connection.query(
        `SELECT version FROM thesis_submissions 
         WHERE student_id = ? 
         ORDER BY version DESC 
         LIMIT 1`,
        [studentId]
      );

      // 计算新版本号
      const version = existingSubmission.length > 0 ? existingSubmission[0].version + 1 : 1;

      // 插入论文提交记录
      await connection.query(`
        INSERT INTO thesis_submissions (
          student_id,
          version,
          file_url,
          file_size,
          status,
          submit_time
        ) VALUES (?, ?, ?, ?, 'reviewing', NOW())`,
        [studentId, version, file_url, file_size]
      );

      // 更新进度记录状态
      await connection.query(`
        UPDATE progress_records 
        SET status = 'reviewing'
        WHERE student_id = ? AND stage_type = 'thesis_submit'`,
        [studentId]
      );

      // 记录日志
      await logUserAction(
        studentId,
        'thesis.submit',
        `提交论文 v${version}`,
        req
      );

      res.json({
        code: 200,
        message: '论文提交成功',
        data: {
          version,
          file_url
        }
      });
    }

  } catch (error) {
    console.error('论文提交失败:', error);
    res.status(500).json({
      code: 500,
      message: '论文提交失败'
    });
  } finally {
    connection.release();
  }
};

// 获取答辩信息
export const getDefenseInfo = async (req: AuthRequest, res: Response) => {
  const connection = await pool.getConnection();
  try {
    const studentId = req.user?.userId;

    // 获取答辩信息，包括委员会成员信息
    const [defenseInfo] = await connection.query(`
      SELECT 
        da.*,
        dc.name as committee_name,
        dc.chairman_id,
        u1.name as chairman_name,
        u1.title as chairman_title,
        dc.secretary_id,
        u2.name as secretary_name,
        u2.title as secretary_title,
        dc.member1_id,
        u3.name as member1_name,
        u3.title as member1_title,
        dc.member2_id,
        u4.name as member2_name,
        u4.title as member2_title,
        dc.member3_id,
        u5.name as member3_name,
        u5.title as member3_title,
        DATE_FORMAT(da.defense_time, '%Y-%m-%d %H:%i') as formatted_defense_time
      FROM defense_arrangements da
      LEFT JOIN defense_committee dc ON da.committee_id = dc.id
      LEFT JOIN users u1 ON dc.chairman_id = u1.user_id
      LEFT JOIN users u2 ON dc.secretary_id = u2.user_id
      LEFT JOIN users u3 ON dc.member1_id = u3.user_id
      LEFT JOIN users u4 ON dc.member2_id = u4.user_id
      LEFT JOIN users u5 ON dc.member3_id = u5.user_id
      WHERE da.student_id = ?
    `, [studentId]);

    // 格式化返回数据
    const formattedData = defenseInfo[0] ? {
      id: defenseInfo[0].id,
      defense_time: defenseInfo[0].formatted_defense_time,
      location: defenseInfo[0].location,
      duration: defenseInfo[0].duration,
      status: defenseInfo[0].status,
      notes: defenseInfo[0].notes,
      committee: {
        id: defenseInfo[0].committee_id,
        name: defenseInfo[0].committee_name,
        members: [
          { 
            role: '主席', 
            id: defenseInfo[0].chairman_id, 
            name: defenseInfo[0].chairman_name,
            title: defenseInfo[0].chairman_title 
          },
          { 
            role: '秘书', 
            id: defenseInfo[0].secretary_id, 
            name: defenseInfo[0].secretary_name,
            title: defenseInfo[0].secretary_title 
          },
          { 
            role: '委员', 
            id: defenseInfo[0].member1_id, 
            name: defenseInfo[0].member1_name,
            title: defenseInfo[0].member1_title 
          },
          { 
            role: '委员', 
            id: defenseInfo[0].member2_id, 
            name: defenseInfo[0].member2_name,
            title: defenseInfo[0].member2_title 
          },
          { 
            role: '委员', 
            id: defenseInfo[0].member3_id, 
            name: defenseInfo[0].member3_name,
            title: defenseInfo[0].member3_title 
          }
        ]
      }
    } : null;

    res.json({
      code: 200,
      data: formattedData,
      message: '获取成功'
    });

  } catch (error) {
    console.error('获取答辩信息失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取答辩信息失败'
    });
  } finally {
    connection.release();
  }
};