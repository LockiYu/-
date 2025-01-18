/*
 * @Author: test abc@163.com
 * @Date: 2024-12-08 21:15:50
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-30 13:20:42
 * @FilePath: \Graduation Design Management System\backend\src\app.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import express from 'express';
import cors from 'cors';
import * as dotenv from 'dotenv';
import authRoutes from './routes/auth';
import dashboardRoutes from './routes/dashboard';
import userRoutes from './routes/users';
import progressRoutes from './routes/progress';
import systemRoutes from './routes/system';
import topicsRouter from './routes/topics';
import dashboardRouter from './routes/dashboard';
import thesisRoutes from './routes/thesis';
import selectionRoutes from './routes/selection';
import taskRoutes from './routes/tasks';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import proposalReviewRoutes from './routes/proposalReview';
import translationRouter from './routes/translation'
import midtermRoutes from './routes/midterm';
import studentThesisRouter from './routes/studentThesis';
import passConfirmationRouter from './routes/passConfirmation'
import thesisReviewAssignmentRoutes from './routes/thesisReviewAssignment';
import thesisReviewRoutes from './routes/thesisReview';
import defenseRoutes from './routes/defense';
import defenseStudentRouter from './routes/defenseStudent'
import teacherProgressRouter from './routes/teacherProgress';
import topicControllerRouter from './routes/topicController'
import visitorRoutes from './routes/visitor';

dotenv.config();

const app = express();
const port = process.env.PORT || 3001;

// 配置文件上传
const uploadDir = path.join(__dirname, '../uploads');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

// 配置 multer
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, uploadDir);
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
    }
});

export const upload = multer({
    storage: storage,
    limits: {
        fileSize: 10 * 1024 * 1024  // 10MB
    },
    fileFilter: function (req, file, cb) {
        // 允许的文件类型
        const allowedTypes = ['.pdf', '.doc', '.docx'];
        const ext = path.extname(file.originalname).toLowerCase();
        if (allowedTypes.includes(ext)) {
            cb(null, true);
        } else {
            cb(new Error('不支持的文件类型'));
        }
    }
});

// 静态文件服务
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// 请求体解析
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));
app.use(cors({
    origin: ['http://localhost:3000', 'http://127.0.0.1:3000'],  // 修改为前端实际端口
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

// 详细的请求日志
app.use((req, res, next) => {
    console.log('=================================');
    console.log('收到请求:');
    console.log(`- 方法: ${req.method}`);
    console.log(`- 路径: ${req.path}`);
    console.log(`- 请求体: ${JSON.stringify(req.body)}`);
    console.log(`- Headers: ${JSON.stringify(req.headers)}`);
    console.log('=================================');
    next();
});

// API 路由
app.use('/api/auth', authRoutes);
app.use('/api/dashboard', dashboardRouter);
app.use('/api/users', userRoutes);
app.use('/api/progress', progressRoutes);
app.use('/api/system', systemRoutes);
app.use('/api/topics', topicsRouter);
app.use('/api/selections', selectionRoutes);
app.use('/api/thesis', thesisRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/proposal-reviews', proposalReviewRoutes);
app.use('/api/translation', translationRouter)
app.use('/api/midterm', midtermRoutes)
app.use('/api/student-thesis', studentThesisRouter)
app.use('/api/passConfirmation', passConfirmationRouter)
app.use('/api/thesis-review-assignment', thesisReviewAssignmentRoutes)
app.use('/api/thesis-review', thesisReviewRoutes)
app.use('/api/defense', defenseRoutes)
app.use('/api/defense-student', defenseStudentRouter)
app.use('/api/teacher/progress', teacherProgressRouter)
app.use('/api/topicController', topicControllerRouter)
app.use('/api/visitor', visitorRoutes);

// 404 处理
app.use((req, res) => {
    console.log('404 Not Found:', req.method, req.path);
    res.status(404).json({
        code: 404,
        message: '接口不存在'
    });
});

// 文件上传错误处理
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
    if (err instanceof multer.MulterError) {
        return res.status(400).json({
            code: 400,
            message: err.message
        });
    }
    next(err);
});

// 全局错误处理
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
    console.error('=================================');
    console.error('全局错误处理:');
    console.error('- 错误消息:', err.message);
    console.error('- 错误堆栈:', err.stack);
    console.error('- 请求信息:', {
        method: req.method,
        path: req.path,
        body: req.body,
        headers: req.headers
    });
    console.error('=================================');

    res.status(500).json({
        code: 500,
        message: '服务器内部错误',
        error: process.env.NODE_ENV === 'development' ? {
            message: err.message,
            stack: err.stack
        } : undefined
    });
});


// 启动服务器
const server = app.listen(port, () => {
    console.log('=================================');
    console.log(`服务器启动成功！`);
    console.log(`- 环境: ${process.env.NODE_ENV}`);
    console.log(`- 端口: ${port}`);
    console.log(`- 地址: http://localhost:${port}`);
    console.log(`- 数据库: ${process.env.DB_NAME}`);
    console.log('=================================');
});

// 优雅关闭
process.on('SIGTERM', () => {
    console.log('收到 SIGTERM 信号，准备关闭服务器');
    server.close(() => {
        console.log('服务器已关闭');
        process.exit(0);
    });
});

export default app;