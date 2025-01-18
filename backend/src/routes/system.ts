import express from 'express';
import { backupDatabase, restoreDatabase, getBackupFiles, getDatabaseInfo, getTables, exportData } from '../controllers/system';
import { authMiddleware, roleMiddleware } from '../middleware/auth';

const router = express.Router();

// 添加 authMiddleware 中间件
router.post('/backup', 
    authMiddleware,  // 先验证 token
    roleMiddleware(['superadmin']),  // 再验证角色
    backupDatabase
);

router.get('/backups', 
    authMiddleware, 
    roleMiddleware(['superadmin']), 
    getBackupFiles
);

router.post('/restore', 
    authMiddleware, 
    roleMiddleware(['superadmin']), 
    restoreDatabase
);

// 添加获取数据库信息的路由
router.get('/db/info', 
  authMiddleware,
  roleMiddleware(['superadmin']),
  getDatabaseInfo
);

router.get('/tables', authMiddleware, roleMiddleware(['superadmin']), getTables)
router.post('/export', authMiddleware, roleMiddleware(['superadmin']), exportData)

export default router;