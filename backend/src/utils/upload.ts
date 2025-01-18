// backend/src/utils/upload.ts
import multer from 'multer';
import path from 'path';
import fs from 'fs';

// 配置上传目录
const uploadDir = path.join(__dirname, '../../uploads');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

// 配置存储
const storage = multer.diskStorage({
    destination: function (req: any, file: any, cb: any) {
        cb(null, uploadDir);
    },
    filename: function (req: any, file: any, cb: any) {
        // multer.single('file') 在 body 解析之前运行，所以需要从 req.body 之前获取
        const userId = req.user?.userId;

        // 从原始请求中获取 stage_type
        const stageType = req.body?.stage_type || 'literature';

        // 添加调试日志
        console.log('文件上传信息:', {
            userId,
            stageType,
            body: req.body,
            originalname: file.originalname
        });

        const ext = path.extname(file.originalname);
        const filename = `${userId}_${stageType}_${Date.now()}${ext}`;

        cb(null, filename);
    }
});

const fileFilter = (req: any, file: any, cb: any) => {
    // 允许的文件类型
    const allowedMimes = ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'];

    if (allowedMimes.includes(file.mimetype)) {
        cb(null, true);
    } else {
        cb(new Error('不支持的文件类型'), false);
    }
};

// 创建 multer 实例
export const upload = multer({
    storage: storage,
    fileFilter,
    limits: {
        fileSize: 10 * 1024 * 1024  // 10MB
    }
});