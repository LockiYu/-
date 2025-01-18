import express from 'express';
import { auth } from '../middleware/auth';
import { 
  getThesisList,
  getAvailableReviewers,
  assignReviewer,
  getAssignmentInfo
} from '../controllers/thesisReviewAssignment';

const router = express.Router();

router.get('/list', auth(['admin']), getThesisList);
router.get('/available-reviewers', auth(['admin']), getAvailableReviewers);
router.post('/assign', auth(['admin']), assignReviewer);
router.get('/info/:thesisId', auth(['admin']), getAssignmentInfo);

export default router; 