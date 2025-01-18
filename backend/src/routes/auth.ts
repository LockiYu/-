import * as express from 'express';
import { login, logout, register } from '../controllers/auth';

const router = express.Router();

router.post('/login', login);
router.post('/register', register);
router.post('/logout', logout);  // 添加退出登录路由

export default router;