import { Request, Response } from 'express'
import pool from '../utils/db'
import bcrypt from 'bcryptjs'
import { AuthRequest } from '../middleware/auth'

// 获取用户列表
export const getUsers = async (req: Request, res: Response) => {
  try {
    // 1. 获取并验证所有查询参数
    const pageNum = Math.max(1, Number(req.query.pageNum) || 1);
    const pageSize = Math.max(1, Number(req.query.pageSize) || 10);
    const { username, role, department } = req.query;
    const offset = (pageNum - 1) * pageSize;

    console.log('查询参数:', { pageNum, pageSize, username, role, department, offset });

    // 2. 构建查询条件
    let conditions = ['1=1'];
    const params: any[] = [];

    if (username) {
      conditions.push('username LIKE ?');
      params.push(`%${username}%`);
    }

    if (role) {
      conditions.push('role = ?');
      params.push(role);
    }

    if (department) {
      conditions.push('department LIKE ?');
      params.push(`%${department}%`);
    }

    // 3. 先执行计数查询
    const [countResult] = await pool.query(
      `SELECT COUNT(*) as total FROM users WHERE ${conditions.join(' AND ')}`,
      params
    );
    const total = (countResult as any)[0].total;

    console.log('总数查询结果:', { total });

    // 4. 执行分页查询
    const [rows] = await pool.query(
      `SELECT 
        user_id, 
        username, 
        role,
        email,
        status, 
        created_at,
        staff_id,
        student_id,
        name,
        department
      FROM users 
      WHERE ${conditions.join(' AND ')}
      ORDER BY created_at DESC 
      LIMIT ? OFFSET ?`,
      [...params, pageSize, offset]
    );

    console.log('查询结果数量:', (rows as any[]).length);

    // 5. 返回结果
    res.json({
      code: 200,
      message: '获取成功',
      data: rows,
      total,
      pageNum,
      pageSize
    });

  } catch (error: any) {
    console.error('获取用户列表失败:', {
      message: error.message,
      code: error.code,
      errno: error.errno,
      sqlMessage: error.sqlMessage,
      sqlState: error.sqlState,
      sql: error.sql,
      stack: error.stack
    });

    res.status(500).json({
      code: 500,
      message: '获取用户列表失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// 创建用户
export const createUser = async (req: Request, res: Response) => {
  try {
    const {
      username,
      password,
      role,
      email,
      name,
      gender,
      department,
      major,
      title,
      phone,
      introduction
    } = req.body;

    // 获取当前用户角色
    const currentUserRole = (req as any).user?.role;

    // 角色权限检查
    if (currentUserRole === 'admin') {
      // 管理员只能创建教师、学生和访客账号
      if (!['teacher', 'student', 'guest'].includes(role)) {
        return res.status(403).json({
          code: 403,
          message: '管理员只能创建教师、学生和访客账号'
        });
      }
    }

    // 验证必填字段
    if (!username || !password || !role || !email || !name || !phone) {
      return res.status(400).json({
        code: 400,
        message: '用户名、密码、角色、邮箱、姓名和手机号为必填项'
      });
    }

    // 检查用户名是否已存在
    const [existing] = await pool.execute(
      'SELECT username FROM users WHERE username = ?',
      [username]
    );

    if ((existing as any[]).length > 0) {
      return res.status(400).json({
        code: 400,
        message: '用户名已存在'
      });
    }

    // 生成用户ID
    const userId = `U${Date.now()}${Math.floor(Math.random() * 1000)}`;

    // 加密密码
    const hashedPassword = await bcrypt.hash(password, 10);

    // 根据角色决定存储的字段
    const isStudent = role === 'student';

    // 创建用户
    await pool.execute(`
      INSERT INTO users (
        user_id,
        username,
        password,
        role,
        email,
        name,
        gender,
        department,
        ${isStudent ? 'major' : 'title'},
        phone,
        introduction,
        created_at,
        updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    `, [
      userId,
      username,
      hashedPassword,
      role,
      email,
      name,
      gender,
      department,
      isStudent ? major : title,
      phone,
      introduction
    ]);

    // 记录系统日志
    const action = 'user.create';
    const details = JSON.stringify({
      createdBy: (req as any).user?.userId,
      newUser: {
        userId,
        username,
        role,
        department
      }
    });

    await pool.execute(
      `INSERT INTO system_logs (user_id, action, ip_address, details) 
       VALUES (?, ?, ?, ?)`,
      [(req as any).user?.userId, action, req.ip, details]
    );

    res.status(201).json({
      code: 200,
      message: '用户创建成功'
    });
  } catch (error: any) {
    console.error('创建用户失败:', {
      error,
      message: error.message,
      code: error.code,
      errno: error.errno,
      sqlMessage: error.sqlMessage,
      sqlState: error.sqlState,
      sql: error.sql
    });

    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({
        code: 400,
        message: '用户名已存在'
      });
    }

    res.status(500).json({
      code: 500,
      message: '创建用户失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// 更新用户状态
export const updateUserStatus = async (req: Request, res: Response) => {
  try {
    const { user_id, status } = req.body

    await pool.execute(
      'UPDATE users SET status = ? WHERE user_id = ?',
      [status, user_id]
    )

    res.json({ message: '用户状态更新成功' })
  } catch (error) {
    res.status(500).json({ message: '服务器错误' })
  }
}

// 重置密码
export const resetPassword = async (req: Request, res: Response) => {
  try {
    const { user_id, new_password } = req.body

    const hashedPassword = await bcrypt.hash(new_password, 10)

    await pool.execute(
      'UPDATE users SET password = ? WHERE user_id = ?',
      [hashedPassword, user_id]
    )

    res.json({ message: '密码重置成功' })
  } catch (error) {
    res.status(500).json({ message: '服务器错误' })
  }
}

// 获取用户个人信息
export const getUserProfile = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;

    const [rows] = await pool.execute(`
            SELECT 
                user_id,
                username,
                role,
                COALESCE(name, username) as name,
                COALESCE(gender, 'male') as gender,
                department,
                CASE 
                    WHEN role = 'student' THEN COALESCE(major, '')
                    WHEN role IN ('teacher', 'admin', 'superadmin') THEN COALESCE(title, '')
                    ELSE ''
                END as position,
                COALESCE(email, '') as email,
                COALESCE(phone, '') as phone,
                COALESCE(introduction, '') as introduction,
                COALESCE(login_count, 0) as login_count,
                staff_id,
                student_id
            FROM users
            WHERE user_id = ?
        `, [userId]);

    if (!rows[0]) {
      return res.status(404).json({
        code: 404,
        message: '用户不存在'
      });
    }

    const userData = {
      ...rows[0],
      department: rows[0].department || '',
    };

    console.log('User data:', userData);

    res.json({
      code: 200,
      data: userData
    });
  } catch (error) {
    console.error('获取用户信息失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取用户信息失败'
    });
  }
};

// 更新用户个人信息
export const updateUserProfile = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    const {
      name,
      gender,
      department,
      major,
      title,
      email,
      phone,
      introduction
    } = req.body;

    // 验证必填字段
    if (!name || !email || !phone) {
      return res.status(400).json({
        code: 400,
        message: '姓名、邮箱和手机号为必填项'
      });
    }

    // 根据角色决定更新哪些字段
    const isStudent = req.user?.role === 'student';

    await pool.execute(`
            UPDATE users 
            SET 
                name = ?,
                gender = ?,
                department = ?,
                ${isStudent ? 'major' : 'title'} = ?,
                email = ?,
                phone = ?,
                introduction = ?,
                updated_at = CURRENT_TIMESTAMP
            WHERE user_id = ?
        `, [
      name,
      gender,
      department,
      isStudent ? major : title,
      email,
      phone,
      introduction,
      userId
    ]);

    // 修改日志记录部分，移除 description 字段
    const action = 'user.profile.update';
    const details = JSON.stringify({
      message: `用户 ${req.user?.username} 更新了个人信息`,  // 将原来的 description 移到 details 中
      changes: {
        name: name !== req.user?.name ? `姓名: ${req.user?.name} -> ${name}` : null,
        gender: gender !== req.user?.gender ? `性别: ${req.user?.gender} -> ${gender}` : null,
        department: department !== req.user?.department ? `部门: ${req.user?.department} -> ${department}` : null,
        major: isStudent && major !== req.user?.major ? `专业: ${req.user?.major} -> ${major}` : null,
        title: !isStudent && title !== req.user?.title ? `职称: ${req.user?.title} -> ${title}` : null,
        email: email !== req.user?.email ? `邮箱: ${req.user?.email} -> ${email}` : null,
        phone: phone !== req.user?.phone ? `电话: ${req.user?.phone} -> ${phone}` : null
      }
    });

    // 获取客户端 IP 地址
    const ipAddress = req.ip || req.socket.remoteAddress || 'unknown';

    // 修改 SQL 语句以匹配表结构
    await pool.execute(`
      INSERT INTO system_logs (user_id, action, ip_address, details, created_at)
      VALUES (?, ?, ?, ?, NOW())
    `, [userId, action, ipAddress, details]);

    res.json({
      code: 200,
      message: '更新成功'
    });
  } catch (error) {
    console.error('更新用户信息失败:', error);
    res.status(500).json({
      code: 500,
      message: '更新用户信息失败'
    });
  }
};

// 添加修改密码方法
export const changePassword = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    const { oldPassword, newPassword } = req.body;

    // 获取用户当前密码
    const [rows] = await pool.execute(
      'SELECT password, username FROM users WHERE user_id = ?',
      [userId]
    );

    if (!rows[0]) {
      return res.status(404).json({
        code: 404,
        message: '用户不存在'
      });
    }

    // 验证旧密码
    const isValidPassword = await bcrypt.compare(oldPassword, rows[0].password);
    if (!isValidPassword) {
      return res.status(400).json({
        code: 400,
        message: '原密码错误'
      });
    }

    // 加密新密码
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // 更新密码
    await pool.execute(
      'UPDATE users SET password = ?, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?',
      [hashedPassword, userId]
    );

    // 记录系统日志
    const action = 'user.password.change';
    const details = JSON.stringify({
      message: `用户 ${rows[0].username} 修改了密码`,
      timestamp: new Date().toISOString()
    });

    // 获取客户端 IP 地址
    const ipAddress = req.ip || req.socket.remoteAddress || 'unknown';

    // 插入日志记录
    await pool.execute(`
      INSERT INTO system_logs (user_id, action, ip_address, details, created_at)
      VALUES (?, ?, ?, ?, NOW())
    `, [userId, action, ipAddress, details]);

    res.json({
      code: 200,
      message: '密码修改成功'
    });
  } catch (error) {
    console.error('修改密码失败:', error);
    res.status(500).json({
      code: 500,
      message: '修改密码失败'
    });
  }
};

// 获取指定用户信息
export const getUserById = async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;

    const [rows] = await pool.execute(`
      SELECT 
        user_id,
        username,
        role,
        COALESCE(name, username) as name,
        COALESCE(gender, 'male') as gender,
        COALESCE(department, '') as department,
        CASE 
          WHEN role = 'student' THEN COALESCE(major, '')
          WHEN role IN ('teacher', 'admin', 'superadmin') THEN COALESCE(title, '')
          ELSE ''
        END as position,
        COALESCE(email, '') as email,
        COALESCE(phone, '') as phone,
        COALESCE(introduction, '') as introduction,
        staff_id,
        student_id
      FROM users
      WHERE user_id = ?
    `, [userId]);

    if (!rows[0]) {
      return res.status(404).json({
        code: 404,
        message: '用户不存在'
      });
    }

    const userData = {
      ...rows[0],
      department: rows[0].department || '',
      major: rows[0].role === 'student' ? rows[0].position : '',
      title: rows[0].role !== 'student' ? rows[0].position : '',
      introduction: rows[0].introduction || ''
    };

    res.json({
      code: 200,
      data: userData
    });
  } catch (error) {
    console.error('获取用户信息失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取用户信息失败'
    });
  }
};

// 超管更新用户信息
export const updateUserById = async (req: AuthRequest, res: Response) => {
  try {
    const { userId } = req.params;
    const {
      name,
      gender,
      department,
      major,
      title,
      email,
      phone,
      introduction,
      role
    } = req.body;

    // 获取用户原始信息用于比对变更
    const [oldUserData] = await pool.execute(
      'SELECT * FROM users WHERE user_id = ?',
      [userId]
    );
    const oldUser = (oldUserData as any[])[0];

    // 获取当前用户角色
    const currentUserRole = (req as any).user?.role;

    // 获取目标用户当前信息
    const [userRows] = await pool.execute(
      'SELECT role FROM users WHERE user_id = ?',
      [userId]
    );

    if (!userRows[0]) {
      return res.status(404).json({
        code: 404,
        message: '用户不存在'
      });
    }

    const targetUserRole = userRows[0].role;

    // 权限检查
    if (currentUserRole === 'admin') {
      // 管理员不能修改超级管理员和其他管理员的信息
      if (['superadmin', 'admin'].includes(targetUserRole)) {
        return res.status(403).json({
          code: 403,
          message: '权限不足'
        });
      }
      // 管理员不能将用户角色设置为超级管理员或管理员
      if (['superadmin', 'admin'].includes(role)) {
        return res.status(403).json({
          code: 403,
          message: '无权设置该角色'
        });
      }
    }

    // 验证必填字段
    if (!name || !email || !phone) {
      return res.status(400).json({
        code: 400,
        message: '姓名、邮箱和手机号为必填项'
      });
    }

    // 根据角色决定更新哪些字段
    const isStudent = role === 'student';

    await pool.execute(`
      UPDATE users 
      SET 
        name = ?,
        gender = ?,
        department = ?,
        ${isStudent ? 'major' : 'title'} = ?,
        email = ?,
        phone = ?,
        introduction = ?,
        role = ?,
        updated_at = CURRENT_TIMESTAMP
      WHERE user_id = ?
    `, [
      name,
      gender,
      department,
      isStudent ? major : title,
      email,
      phone,
      introduction,
      role,
      userId
    ]);

    // 记录系统日志
    const changes = {
      name: name !== oldUser.name ? `${oldUser.name} -> ${name}` : null,
      role: role !== oldUser.role ? `${oldUser.role} -> ${role}` : null,
      gender: gender !== oldUser.gender ? `${oldUser.gender} -> ${gender}` : null,
      department: department !== oldUser.department ? `${oldUser.department} -> ${department}` : null,
      email: email !== oldUser.email ? `${oldUser.email} -> ${email}` : null,
      phone: phone !== oldUser.phone ? `${oldUser.phone} -> ${phone}` : null
    };

    // 根据角色添加特定字段的变更记录
    if (isStudent) {
      changes.major = major !== oldUser.major ? `${oldUser.major} -> ${major}` : null;
    } else {
      changes.title = title !== oldUser.title ? `${oldUser.title} -> ${title}` : null;
    }

    // 过滤掉未变更的字段
    const actualChanges = Object.fromEntries(
      Object.entries(changes).filter(([_, value]) => value !== null)
    );

    const logDetails = JSON.stringify({
      action: 'user.update',
      targetUser: userId,
      operator: req.user?.username,
      changes: actualChanges
    });

    await pool.execute(
      `INSERT INTO system_logs (user_id, action, ip_address, details)
       VALUES (?, ?, ?, ?)`,
      [req.user?.userId, 'user.update', req.ip, logDetails]
    );

    res.json({
      code: 200,
      message: '更新成功'
    });
  } catch (error) {
    console.error('更新用户信息失败:', error);
    res.status(500).json({
      code: 500,
      message: '更新用户信息失败'
    });
  }
};

// 删除用户
export const deleteUser = async (req: AuthRequest, res: Response) => {
  try {
    const { userId } = req.params;
    
    // 获取要删除的用户信息
    const [userRows] = await pool.execute(
      'SELECT username, role FROM users WHERE user_id = ?',
      [userId]
    );

    if (!userRows[0]) {
      return res.status(404).json({
        code: 404,
        message: '用户不存在'
      });
    }

    const targetUser = (userRows as any[])[0];
    const currentUserRole = req.user?.role;

    // 修改权限检查逻辑
    if (targetUser.role === 'superadmin') {
      return res.status(403).json({
        code: 403,
        message: '不能删除超级管理员账号'
      });
    }

    // admin不能删除admin和superadmin
    if (currentUserRole === 'admin' && 
        ['admin', 'superadmin'].includes(targetUser.role)) {
      return res.status(403).json({
        code: 403,
        message: '权限不足，无法删除该用户'
      });
    }

    // 执行删除操作
    await pool.execute(
      'DELETE FROM users WHERE user_id = ?',
      [userId]
    );

    // 记录系统日志
    const logDetails = JSON.stringify({
      action: 'user.delete',
      targetUser: {
        userId,
        username: targetUser.username,
        role: targetUser.role
      },
      operator: req.user?.username,
      timestamp: new Date().toISOString()
    });

    await pool.execute(
      `INSERT INTO system_logs (user_id, action, ip_address, details)
       VALUES (?, ?, ?, ?)`,
      [req.user?.userId, 'user.delete', req.ip, logDetails]
    );

    res.json({
      code: 200,
      message: '删除成功'
    });
  } catch (error) {
    console.error('删除用户失败:', error);
    res.status(500).json({
      code: 500,
      message: '删除用户失败'
    });
  }
};