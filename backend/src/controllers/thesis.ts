import { Request, Response } from 'express'
import pool from '../utils/db'
import { Parser } from 'json2csv'
import multer from 'multer'
import { parse } from 'csv-parse'
import xlsx from 'xlsx'
import { createReadStream } from 'fs'
import { promisify } from 'util'
import { unlink } from 'fs/promises'

// 配置文件上传
const upload = multer({
    dest: 'uploads/',
    fileFilter: (req, file, cb) => {
        if (file.mimetype === 'text/csv' ||
            file.mimetype === 'application/vnd.ms-excel' ||
            file.mimetype === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
            cb(null, true)
        } else {
            cb(new Error('不支持的文件类型'))
        }
    }
}).single('file')

// 处理CSV文件
const parseCSV = async (filePath: string) => {
    return new Promise((resolve, reject) => {
        const results: any[] = [];

        createReadStream(filePath)
            .pipe(
                parse({
                    columns: true, // 使用第一行作为列名
                    skip_empty_lines: true,
                    trim: true,
                    bom: true
                })
            )
            .on('data', (data) => results.push(data))
            .on('error', (error) => reject(error))
            .on('end', () => resolve(results));
    });
}

// 处理Excel文件
const parseExcel = (filePath: string) => {
    const workbook = xlsx.readFile(filePath)
    const sheetName = workbook.SheetNames[0]
    const worksheet = workbook.Sheets[sheetName]
    return xlsx.utils.sheet_to_json(worksheet)
}

export const getTopicList = async (req: Request, res: Response) => {
    try {
        // 确保分页参数为数字
        const page = Number(req.query.page) || 1;
        const pageSize = Number(req.query.pageSize) || 10;
        const { title, type, status, teacherId } = req.query;

        let sql = `
            SELECT 
                t.topic_id,
                t.title,
                t.type,
                t.source,
                t.description,
                t.major_requirements,
                t.student_requirements,
                t.status,
                t.created_at,
                t.updated_at,
                u.name as teacher_name,
                u.user_id as teacher_id
            FROM topics t
            LEFT JOIN users u ON t.teacher_id = u.user_id
            WHERE 1=1
        `;

        const params: any[] = [];

        // 构建查询条件
        if (teacherId) {
            sql += ` AND t.teacher_id = ?`;
            params.push(teacherId);
        }

        if (!status) {
            sql += ` AND t.status IN ('approved', 'pending')`;
        } else {
            sql += ` AND t.status = ?`;
            params.push(status);
        }

        if (title) {
            sql += ` AND t.title LIKE ?`;
            params.push(`%${title}%`);
        }

        if (type) {
            sql += ` AND t.type = ?`;
            params.push(type);
        }

        // 获取总数
        const [countResult] = await pool.execute(
            `SELECT COUNT(*) as total FROM (${sql}) as count_table`,
            params
        ) as any[];

        // 添加排序和分页
        sql += ` ORDER BY t.created_at DESC`;

        // 直接在SQL中使用计算好的值，而不是参数
        const offset = (page - 1) * pageSize;
        sql += ` LIMIT ${pageSize} OFFSET ${offset}`;

        // 执行主查询，不需要添加额外的分页参数
        const [rows] = await pool.execute(sql, params);

        res.json({
            code: 200,
            data: {
                list: rows,
                total: countResult[0].total,
                page,
                pageSize
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

export const getTopicTypes = async (req: Request, res: Response) => {
    try {
        const [types] = await pool.query('SELECT DISTINCT type FROM topics')

        res.json({
            code: 200,
            data: types,
            message: '获取论文类型成功'
        })
    } catch (error) {
        console.error('获取论文类型失败:', error)
        res.status(500).json({
            code: 500,
            message: '获取论文类型失败'
        })
    }
}

export const addTopic = async (req: Request, res: Response) => {
    try {
        const {
            title,
            type,
            source,
            description,
            major_requirements,
            student_requirements,
            teacher_id
        } = req.body

        // 参数验证
        if (!title || !type || !description || !teacher_id) {
            return res.status(400).json({
                code: 400,
                message: '缺少必要参数'
            })
        }

        const [result] = await pool.query(
            `INSERT INTO topics (
        title,
        type,
        source,
        teacher_id,
        description,
        major_requirements,
        student_requirements,
        status
      ) VALUES (?, ?, ?, ?, ?, ?, ?, 'draft')`,
            [
                title,
                type,
                source,
                teacher_id,
                description,
                major_requirements,
                student_requirements
            ]
        )

        res.json({
            code: 200,
            data: result,
            message: '新增题目成功'
        })
    } catch (error) {
        console.error('新增题目失败:', error)
        res.status(500).json({
            code: 500,
            message: '新增题目失败'
        })
    }
}

export const exportTopics = async (req: Request, res: Response) => {
    try {
        const { title, type, status, teacherId } = req.query

        // 构建查询条件
        const conditions = []
        const params = []

        if (title) {
            conditions.push('t.title LIKE ?')
            params.push(`%${title}%`)
        }
        if (type) {
            conditions.push('t.type = ?')
            params.push(type)
        }
        if (status) {
            conditions.push('t.status = ?')
            params.push(status)
        }
        if (teacherId) {
            conditions.push('t.teacher_id = ?')
            params.push(teacherId)
        }

        const whereClause = conditions.length > 0
            ? `WHERE ${conditions.join(' AND ')}`
            : ''

        const [list] = await pool.query(
            `SELECT 
        t.*,
        u.name as teacher_name
       FROM topics t
       LEFT JOIN users u ON t.teacher_id = u.user_id
       ${whereClause}
       ORDER BY t.created_at DESC`,
            params
        )

        // 定义CSV字段
        const fields = [
            { label: '题目', value: 'title' },
            { label: '类型', value: 'type' },
            { label: '来源', value: 'source' },
            { label: '指导教师', value: 'teacher_name' },
            { label: '研究内容', value: 'description' },
            { label: '专业要求', value: 'major_requirements' },
            { label: '学生要求', value: 'student_requirements' },
            { label: '状态', value: 'status' },
            { label: '创建时间', value: 'created_at' }
        ]

        // 创建 Parser 实例
        const json2csvParser = new Parser({ fields })
        const csv = json2csvParser.parse(list)

        // 设置响应头
        res.setHeader('Content-Type', 'text/csv; charset=utf-8')
        res.setHeader('Content-Disposition', 'attachment; filename=topics.csv')

        // 添加 BOM 以支持中文
        res.send('\ufeff' + csv)

    } catch (error) {
        console.error('导出题目失败:', error)
        res.status(500).json({
            code: 500,
            message: '导出题目失败'
        })
    }
}

export const updateTopicStatus = async (req: Request, res: Response) => {
    try {
        const { id } = req.params
        const { status } = req.body

        const [result] = await pool.query(
            'UPDATE topics SET status = ? WHERE topic_id = ?',
            [status, id]
        )

        if (result.affectedRows === 0) {
            return res.status(404).json({
                code: 404,
                message: '题目不存在'
            })
        }

        res.json({
            code: 200,
            message: '更新状态成功'
        })
    } catch (error) {
        console.error('更新状态失败:', error)
        res.status(500).json({
            code: 500,
            message: '更新状态失败'
        })
    }
}

// 导入题目
export const importTopics = async (req: Request, res: Response) => {
    let filePath: string | undefined

    try {
        // 处理文件上传
        await new Promise((resolve, reject) => {
            upload(req, res, (err) => {
                if (err) {
                    reject(err)
                } else if (!req.file) {
                    reject(new Error('请选择文件'))
                } else {
                    resolve(null)
                }
            })
        })

        filePath = req.file?.path

        if (!filePath) {
            throw new Error('文件上传失败')
        }

        // 解析文件内容
        let records: any[]
        const fileType = req.file?.originalname.split('.').pop()?.toLowerCase()

        if (fileType === 'csv') {
            records = await parseCSV(filePath)
        } else if (['xlsx', 'xls'].includes(fileType || '')) {
            records = parseExcel(filePath)
        } else {
            throw new Error('不支持的文件类型')
        }

        // 验证和转换数据
        const validRecords = records.filter((record: any) => {
            // 检查必要字段
            const hasRequiredFields = record.题目 && record.类型 && record.指导教师ID

            // 检查字段长度
            const titleLength = record.题目.length >= 5 && record.题目.length <= 100

            return hasRequiredFields && titleLength
        })

        if (validRecords.length === 0) {
            throw new Error('文件中没有有效数据')
        }

        // 批量插入数据
        const values = validRecords.map((record: any) => [
            record.题目?.trim(),
            record.类型?.trim(),
            record.来源?.trim() || null,
            record.指导教师ID?.trim(),
            record.研究内容?.trim() || null,
            record.专业要求?.trim() || null,
            record.学生要求?.trim() || null,
            'draft'
        ])

        const [result] = await pool.query(
            `INSERT INTO topics (
        title, type, source, teacher_id, 
        description, major_requirements, 
        student_requirements, status
      ) VALUES ?`,
            [values]
        )

        // 清理临时文件
        await unlink(filePath).catch(console.error)

        res.json({
            code: 200,
            data: {
                total: validRecords.length,
                success: result.affectedRows
            },
            message: `成功导入 ${result.affectedRows} 条数据`
        })

    } catch (error: any) {
        // 清理临时文件
        if (filePath) {
            await unlink(filePath).catch(console.error)
        }

        console.error('导入失败:', error)
        res.status(500).json({
            code: 500,
            message: error.message || '导入失败'
        })
    }
}

// 下载模板
export const downloadTemplate = (req: Request, res: Response) => {
    try {
        const template = [
            {
                '题目': '示例：基于深度学习的图像识别系统设计与实现',
                '类型': '工程设计',
                '来源': '企业合作',
                '研究内容': '本课题旨在设计和实现一个基于深度学习的图像识别系统...',
                '专业要求': '计算机科学与技术、软件工程相关专业',
                '学生要求': '1. 熟悉Python编程 2. 了解深度学习基础知识',
                '指导教师ID': 'T2024006'
            }
        ]

        const ws = xlsx.utils.json_to_sheet(template)
        const wb = xlsx.utils.book_new()
        xlsx.utils.book_append_sheet(wb, ws, '模板')

        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        res.setHeader('Content-Disposition', 'attachment; filename=topics_template.xlsx')

        const buffer = xlsx.write(wb, { type: 'buffer', bookType: 'xlsx' })
        res.send(buffer)

    } catch (error) {
        console.error('生成模板失败:', error)
        res.status(500).json({
            code: 500,
            message: '生成模板失败'
        })
    }
}

export const getStudentThesisReviews = async (req: Request, res: Response) => {
    try {
        const studentId = req.user?.userId;
        console.log('当前学生ID:', studentId);

        if (!studentId) {
            return res.status(401).json({
                code: 401,
                message: '未授权访问'
            });
        }

        // 获取论文评阅分配信息和评阅详情
        const [reviews] = await pool.query(`
            SELECT 
                tra.id,
                tra.student_id,
                tra.reviewer_id,
                tra.review_type,
                tra.status,
                tra.assigned_at,
                tra.completed_at,
                u.name as reviewer_name,
                u.title as reviewer_title,
                trd.score_innovation,
                trd.score_quality,
                trd.score_workload,
                trd.score_writing,
                trd.total_score,
                trd.review_comments,
                trd.review_time
            FROM thesis_reviews_assignment tra
            LEFT JOIN users u ON tra.reviewer_id = u.user_id
            LEFT JOIN thesis_review_details trd ON tra.id = trd.assignment_id
            WHERE tra.student_id = ?
            ORDER BY tra.review_type DESC, tra.assigned_at ASC
        `, [studentId]);

        console.log('查询结果:', reviews);

        res.json({
            code: 200,
            data: reviews,
            message: '获取论文评阅信息成功'
        });
    } catch (error) {
        console.error('获取论文评阅信息失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取论文评阅信息失败'
        });
    }
};

export const getStudentThesisHistory = async (req: Request, res: Response) => {
    try {
        const studentId = req.user?.id;

        // 获取论文提交历史
        const [submissions] = await pool.query(`
            SELECT 
                ts.id,
                ts.version,
                ts.title,
                ts.keywords,
                ts.abstract,
                ts.file_url,
                ts.file_size,
                ts.status,
                ts.submit_time,
                ts.advisor_review_status,
                JSON_OBJECT(
                    'status', ar.status,
                    'score_innovation', ar.score_innovation,
                    'score_quality', ar.score_quality,
                    'score_workload', ar.score_workload,
                    'score_writing', ar.score_writing,
                    'total_score', ar.total_score,
                    'review_comments', ar.review_comments,
                    'review_time', ar.review_time
                ) as advisor_review,
                (
                    SELECT JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'status', pr.status,
                            'score_innovation', pr.score_innovation,
                            'score_quality', pr.score_quality,
                            'score_workload', pr.score_workload,
                            'score_writing', pr.score_writing,
                            'total_score', pr.total_score,
                            'review_comments', pr.review_comments,
                            'review_time', pr.review_time
                        )
                    )
                    FROM thesis_review_details pr
                    WHERE pr.submission_id = ts.id AND pr.reviewer_type = 'peer'
                ) as peer_reviews
            FROM thesis_submissions ts
            LEFT JOIN thesis_review_details ar ON ts.id = ar.submission_id AND ar.reviewer_type = 'advisor'
            WHERE ts.student_id = ?
            ORDER BY ts.submit_time DESC
        `, [studentId]);

        res.json({
            code: 200,
            data: submissions,
            message: '获取论文提交历史成功'
        });
    } catch (error) {
        console.error('获取论文提交历史失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取论文提交历史失败'
        });
    }
};

// 更新题目
export const updateTopic = async (req: Request, res: Response) => {
    try {
        const { id } = req.params
        const {
            title,
            type,
            source,
            description,
            major_requirements,
            student_requirements
        } = req.body

        // 检查题目是否存在且为草稿状态
        const [topic] = await pool.query(
            'SELECT status, teacher_id FROM topics WHERE topic_id = ?',
            [id]
        ) as any

        if (!topic[0]) {
            return res.status(404).json({
                code: 404,
                message: '题目不存在'
            })
        }

        if (topic[0].status !== 'draft') {
            return res.status(400).json({
                code: 400,
                message: '只能编辑草稿状态的题目'
            })
        }

        // 检查是否为题目创建者
        if (topic[0].teacher_id !== req.user?.userId) {
            return res.status(403).json({
                code: 403,
                message: '无权编辑此题目'
            })
        }

        // 更新题目
        const [result] = await pool.query(
            `UPDATE topics 
            SET title = ?, type = ?, source = ?, 
                description = ?, major_requirements = ?, 
                student_requirements = ?
            WHERE topic_id = ?`,
            [title, type, source, description, major_requirements,
                student_requirements, id]
        )

        res.json({
            code: 200,
            message: '更新题目成功'
        })
    } catch (error) {
        console.error('更新题目失败:', error)
        res.status(500).json({
            code: 500,
            message: '更新题目失败'
        })
    }
}

// 删除题目
export const deleteTopic = async (req: Request, res: Response) => {
    try {
        const { id } = req.params

        // 检查题目是否存在且为草稿状态
        const [topic] = await pool.query(
            'SELECT status, teacher_id FROM topics WHERE topic_id = ?',
            [id]
        ) as any

        if (!topic[0]) {
            return res.status(404).json({
                code: 404,
                message: '题目不存在'
            })
        }

        if (topic[0].status !== 'draft') {
            return res.status(400).json({
                code: 400,
                message: '只能删除草稿状态的题目'
            })
        }

        // 检查是否为题目创建者
        if (topic[0].teacher_id !== req.user?.userId) {
            return res.status(403).json({
                code: 403,
                message: '无权删除此题目'
            })
        }

        // 删除题目
        await pool.query('DELETE FROM topics WHERE topic_id = ?', [id])

        res.json({
            code: 200,
            message: '删除题目成功'
        })
    } catch (error) {
        console.error('删除题目失败:', error)
        res.status(500).json({
            code: 500,
            message: '删除题目失败'
        })
    }
}