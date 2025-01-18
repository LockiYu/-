/*
 * @Author: test abc@163.com
 * @Date: 2024-12-15 14:55:43
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-15 23:11:05
 * @FilePath: \Graduation Design Management System\backend\src\controllers\selection.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import { Request, Response } from 'express'
import db from '../utils/db'

// 扩展 Request 类型
declare global {
  namespace Express {
    interface Request {
      user?: {
        userId: string
        username: string
        role: string
      }
    }
  }
}

// 状态转换函数
function translateStatus(status: string) {
  const statusMap = {
    'pending': '审核中',
    'approved': '已通过',
    'rejected': '已拒绝'
  }
  return statusMap[status] || status
}

// 获取学生选题状态
export async function getStudentSelectionStatus(req: Request, res: Response) {
  const connection = await db.getConnection()
  try {
    const studentId = req.user?.userId

    console.log('获取选题状态 - 学生ID:', studentId)

    if (!studentId) {
      console.error('未获取到学生ID')
      return res.status(400).json({
        code: 400,
        message: '未获取到学生ID',
        debug: { user: req.user }
      })
    }

    const [selections] = await connection.query(`
      SELECT 
        ts.selection_id,
        ts.topic_id,
        ts.created_at as apply_time,
        ts.final_status as status,
        t.title,
        t.description,
        t.type,
        t.source,
        u.name as teacherName,
        u.title as teacherTitle
      FROM topic_selections ts
      JOIN topics t ON ts.topic_id = t.topic_id
      JOIN users u ON t.teacher_id = u.user_id
      WHERE ts.student_id = ?
      ORDER BY ts.created_at DESC
    `, [studentId])

    console.log('查询结果:', selections)

    res.json({
      code: 200,
      data: selections.map(s => ({
        ...s,
        status: translateStatus(s.status)
      }))
    })
  } catch (error) {
    console.error('获取选题状态失败:', error)
    res.status(500).json({
      code: 500,
      message: '获取选题状态失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    })
  } finally {
    if (connection) {
      connection.release()
    }
  }
}

// 获取可选题目列表
export async function getAvailableTopics(req: Request, res: Response) {
  const connection = await db.getConnection()
  try {
    const { pageNum = 1, pageSize = 10, title = '', teacherName = '', sortByCount = false } = req.query
    const offset = (Number(pageNum) - 1) * Number(pageSize)

    console.log('查询参数:', { pageNum, pageSize, title, teacherName, sortByCount })

    // 基础查询
    const baseQuery = `
      FROM topics t
      LEFT JOIN users u ON t.teacher_id = u.user_id
      LEFT JOIN topic_selections ts ON t.topic_id = ts.topic_id AND ts.final_status != 'rejected'
      WHERE t.status = 'approved'
      AND t.topic_id NOT IN (
        SELECT topic_id 
        FROM topic_selections 
        WHERE final_status = 'approved'
      )
      ${title ? 'AND t.title LIKE ?' : ''}
      ${teacherName ? 'AND u.name LIKE ?' : ''}`

    // 查询参数
    const queryParams = [
      ...(title ? [`%${title}%`] : []),
      ...(teacherName ? [`%${teacherName}%`] : [])
    ]

    // 获取总数
    const [countResult] = await connection.query(`
      SELECT COUNT(DISTINCT t.topic_id) as total ${baseQuery}
    `, queryParams)

    // 获取题目列表，只统计未被拒绝的申请
    const [topics] = await connection.query(`
      SELECT 
        t.topic_id,
        t.title,
        t.description,
        t.type,
        t.source,
        t.major_requirements,
        t.student_requirements,
        t.created_at,
        u.name as teacherName,
        u.title as teacherTitle,
        COUNT(DISTINCT CASE WHEN ts.final_status != 'rejected' THEN ts.student_id END) as selectedCount,
        GROUP_CONCAT(DISTINCT CASE WHEN ts.final_status != 'rejected' THEN ts.student_id END) as applicantIds
      ${baseQuery}
      GROUP BY t.topic_id
      ORDER BY ${sortByCount === 'true' ? 'selectedCount DESC' : 't.created_at DESC'}
      LIMIT ? OFFSET ?
    `, [...queryParams, Number(pageSize), offset])

    console.log('查询结果数量:', topics.length)

    res.json({
      code: 200,
      data: {
        list: topics.map(topic => ({
          ...topic,
          applicantIds: topic.applicantIds ? topic.applicantIds.split(',').filter(Boolean) : []
        })),
        total: countResult[0].total
      }
    })
  } catch (error) {
    console.error('获取可选题目失败:', error)
    res.status(500).json({
      code: 500,
      message: '获取可选题目失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    })
  } finally {
    if (connection) {
      connection.release()
    }
  }
}

// 获取当前选题
export async function getCurrentSelection(req: Request, res: Response) {
  const connection = await db.getConnection()
  try {
    const studentId = req.user?.userId

    if (!studentId) {
      return res.status(400).json({
        code: 400,
        message: '未获取到学生ID'
      })
    }

    const [selection] = await connection.query(`
      SELECT 
        ts.selection_id,
        ts.topic_id,
        ts.student_id,
        ts.teacher_approval_status,
        ts.director_approval_status,
        ts.director_approval_time,
        ts.created_at,
        ts.updated_at,
        ts.final_status,
        t.title,
        t.description,
        t.type,
        t.source,
        t.major_requirements,
        t.student_requirements,
        teacher.name as teacherName,
        teacher.title as teacherTitle,
        director.name as directorName
      FROM topic_selections ts
      JOIN topics t ON ts.topic_id = t.topic_id
      JOIN users teacher ON t.teacher_id = teacher.user_id
      LEFT JOIN users director ON ts.director_id = director.user_id
      WHERE ts.student_id = ?
      ORDER BY ts.created_at DESC
      LIMIT 1
    `, [studentId])

    // 处理返回数据
    const formattedSelection = selection[0] ? {
      ...selection[0],
      // 保持原始状态值以供前端使用
      teacher_approval_status: selection[0].teacher_approval_status,
      director_approval_status: selection[0].director_approval_status,
      final_status: selection[0].final_status,
      // 添加格式化后的状态文本
      teacher_approval_status_text: translateStatus(selection[0].teacher_approval_status),
      director_approval_status_text: translateStatus(selection[0].director_approval_status),
      final_status_text: translateStatus(selection[0].final_status)
    } : null

    res.json({
      code: 200,
      data: formattedSelection
    })
  } catch (error) {
    console.error('获取当前选题失败:', error)
    res.status(500).json({
      code: 500,
      message: '获取当前选题失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    })
  } finally {
    if (connection) {
      connection.release()
    }
  }
}

// 提交选题申请
export const submitSelection = async (req: Request, res: Response) => {
  const connection = await db.getConnection()
  try {
    await connection.beginTransaction()

    const { topic_id, reason } = req.body
    const student_id = req.user?.userId

    // 检查是否有pending或approved状态的任何选题申请
    const [activeSelections] = await connection.query(
      `SELECT * FROM topic_selections 
       WHERE student_id = ? 
       AND (final_status = 'pending' OR final_status = 'approved')`,
      [student_id]
    )

    if (activeSelections.length > 0) {
      throw new Error('您已有正在审批中或已通过的选题申请')
    }

    // 获取该学生对该题目的所有历史申请
    const [existingSelections] = await connection.query(
      `SELECT * FROM topic_selections 
       WHERE student_id = ? AND topic_id = ?
       ORDER BY created_at DESC`,
      [student_id, topic_id]
    )

    // 如果最近一次申请是pending或approved状态，则不允许重复申请
    if (existingSelections.length > 0) {
      const lastSelection = existingSelections[0]
      if (lastSelection.final_status === 'pending' ||
        lastSelection.final_status === 'approved') {
        throw new Error('您已经申请过该题目且正在审批中或已通过')
      }
    }

    // 插入新的选题记录
    const [result] = await connection.query(
      `INSERT INTO topic_selections 
       (topic_id, student_id, student_reason) 
       VALUES (?, ?, ?)`,
      [topic_id, student_id, reason]
    )

    // 记录系统日志
    await connection.query(
      `INSERT INTO system_logs 
       (user_id, action, ip_address, details) 
       VALUES (?, ?, ?, ?)`,
      [
        student_id,
        'selection.submit',
        req.ip,
        JSON.stringify({
          topic_id,
          reason,
          selection_id: result.insertId,
          previous_selections: existingSelections.length,
          message: '提交选题申请'
        })
      ]
    )

    await connection.commit()
    res.json({
      code: 200,
      message: '选题申请提交成功'
    })
  } catch (error: any) {
    await connection.rollback()
    res.status(400).json({
      code: 400,
      message: error.message || '选题申请提交失败'
    })
  } finally {
    connection.release()
  }
}

// 教师审批选题
export const teacherApproveSelection = async (req: Request, res: Response) => {
  const connection = await db.getConnection()
  try {
    await connection.beginTransaction()

    const { selectionId } = req.params
    const { status, reason } = req.body
    const teacher_id = req.user?.userId

    // 更新选题状态
    await connection.query(
      `UPDATE topic_selections 
       SET teacher_approval_status = ?,
           teacher_reject_reason = ?
       WHERE selection_id = ?`,
      [status, status === 'rejected' ? reason : null, selectionId]
    )

    // 记录系统日志
    await connection.query(
      `INSERT INTO system_logs 
       (user_id, action, ip_address, details) 
       VALUES (?, ?, ?, ?)`,
      [
        teacher_id,
        'selection.teacher.review',
        req.ip,
        JSON.stringify({
          selection_id: selectionId,
          status,
          reason,
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
    res.status(400).json({
      code: 400,
      message: error.message || '审批失败'
    })
  } finally {
    connection.release()
  }
}

// 系主任审批选题
export const directorApproveSelection = async (req: Request, res: Response) => {
  const connection = await db.getConnection()
  try {
    await connection.beginTransaction()

    const { selectionId } = req.params
    const { status, reason } = req.body
    const director_id = req.user?.userId

    // 更新选题状态
    await connection.query(
      `UPDATE topic_selections 
       SET director_approval_status = ?,
           director_reject_reason = ?,
           director_id = ?,
           director_approval_time = NOW()
       WHERE selection_id = ?`,
      [status, status === 'rejected' ? reason : null, director_id, selectionId]
    )

    // 记录系统日志
    await connection.query(
      `INSERT INTO system_logs 
       (user_id, action, ip_address, details) 
       VALUES (?, ?, ?, ?)`,
      [
        director_id,
        'selection.director.review',
        req.ip,
        JSON.stringify({
          selection_id: selectionId,
          status,
          reason,
          message: `系主任${status === 'approved' ? '通过' : '拒绝'}选题申请`
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
    res.status(400).json({
      code: 400,
      message: error.message || '审批失败'
    })
  } finally {
    connection.release()
  }
}

// 取消选题
export const cancelSelection = async (req: Request, res: Response) => {
  const connection = await db.getConnection()
  try {
    await connection.beginTransaction()

    const { selectionId } = req.params
    const student_id = req.user?.userId

    // 验证选题记录
    const [selections] = await connection.query(
      `SELECT ts.*, t.title as topic_title 
       FROM topic_selections ts
       JOIN topics t ON ts.topic_id = t.topic_id
       WHERE ts.selection_id = ? AND ts.student_id = ?`,
      [selectionId, student_id]
    )

    if (!selections.length) {
      throw new Error('未找到相关选题记录')
    }

    const selection = selections[0]

    // 验证是否可以取消
    if (selection.teacher_approval_status !== 'pending' &&
      selection.teacher_approval_status !== 'rejected') {
      throw new Error('当前状态不允许取消选题')
    }

    // 删除选题记录
    await connection.query(
      'DELETE FROM topic_selections WHERE selection_id = ?',
      [selectionId]
    )

    // 记录系统日志
    await connection.query(
      'INSERT INTO system_logs (user_id, action, ip_address, details) VALUES (?, ?, ?, ?)',
      [
        student_id,
        'selection.cancel',
        req.ip,
        JSON.stringify({
          selection_id: selectionId,
          topic_title: selection.topic_title,
          message: '取消选题申请'
        })
      ]
    )

    await connection.commit()
    res.json({
      code: 200,
      message: '取消选题成功'
    })
  } catch (error: any) {
    await connection.rollback()
    res.status(400).json({
      code: 400,
      message: error.message || '取消选题失败'
    })
  } finally {
    connection.release()
  }
}

// 获取被拒绝的历史申请记录
export const getRejectedSelections = async (req: Request, res: Response) => {
  const connection = await db.getConnection()
  try {
    const student_id = req.user?.userId

    const [selections] = await connection.query(
      `SELECT 
        ts.selection_id,
        ts.topic_id,
        ts.student_id,
        ts.student_reason,
        ts.teacher_approval_status,
        ts.teacher_reject_reason,
        ts.director_approval_status,
        ts.director_reject_reason,
        ts.created_at,
        t.title as topic_title,
        teacher.name as teacher_name,
        director.name as director_name
       FROM topic_selections ts
       JOIN topics t ON ts.topic_id = t.topic_id
       JOIN users teacher ON t.teacher_id = teacher.user_id
       LEFT JOIN users director ON ts.director_id = director.user_id
       WHERE ts.student_id = ? 
       AND (ts.final_status = 'rejected' OR ts.final_status = 'approved')
       ORDER BY ts.created_at DESC`,
      [student_id]
    )

    // 处理每条记录的状态和原因
    const formattedSelections = selections.map(selection => ({
      ...selection,
      approval_status: getApprovalStatus(selection),
      reject_reason: getRejectReason(selection)
    }))

    console.log('查询参数:', { student_id })
    console.log('处理后的结果:', formattedSelections)

    res.json({
      code: 200,
      message: '获取历史申请记录成功',
      data: formattedSelections
    })
  } catch (error) {
    console.error('获取历史申请记录失败:', error)
    res.status(500).json({
      code: 500,
      message: '获取历史申请记录失败'
    })
  } finally {
    connection.release()
  }
}

// 添加辅助函数来处理审批状态
function getApprovalStatus(selection: any) {
  if (selection.teacher_approval_status === 'rejected') {
    return '教师已拒绝'
  }
  if (selection.teacher_approval_status === 'approved') {
    if (selection.director_approval_status === 'rejected') {
      return '系主任已拒绝'
    }
    if (selection.director_approval_status === 'approved') {
      return '已通过'
    }
    return '教师已通过，等待系主任审核'
  }
  return '审核中'
}

// 添加辅助函数来处理拒绝理由
function getRejectReason(selection: any) {
  let reasons = []

  if (selection.teacher_approval_status === 'rejected' && selection.teacher_reject_reason) {
    reasons.push(`教师(${selection.teacher_name})：${selection.teacher_reject_reason}`)
  }

  if (selection.teacher_approval_status === 'approved' &&
    selection.director_approval_status === 'rejected' &&
    selection.director_reject_reason) {
    reasons.push(`系主任(${selection.director_name})：${selection.director_reject_reason}`)
  }

  if (selection.teacher_approval_status === 'approved' &&
    selection.director_approval_status === 'approved') {
    return '申请通过'
  }

  return reasons.length > 0 ? reasons.join('\n') : '无'
}