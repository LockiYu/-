import express = require('express');  // 修改这一行
import { auth } from '../middleware/auth';
import * as proposalController from '../controllers/proposalReview';  // 修改导入方式

// 添加调试日志
console.log('导入的控制器:', proposalController);

const router = express.Router();

router.get('/teacher/:teacherId', auth(['teacher']), proposalController.getTeacherProposals);
router.post('/review/:id', auth(['teacher']), proposalController.reviewProposal);
router.get('/:id', auth(['teacher']), proposalController.getProposalDetail);

export default router;