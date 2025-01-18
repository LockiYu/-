import express from 'express';
import { createTopic, getTopics, reviewTopic, getMyTopics, updateTopic, updateTopicStatus, getTopicDetails } from '../controllers/topic';
import { authMiddleware, roleMiddleware } from '../middleware/auth';

const router = express.Router();

router.prefix = '/thesis/topics';

router.get('/', getTopics);
router.post('/', authMiddleware, roleMiddleware(['teacher']), createTopic);
router.put('/review', authMiddleware, roleMiddleware(['admin']), reviewTopic);
router.get('/my', authMiddleware, roleMiddleware(['teacher']), getMyTopics);
router.put('/:id', updateTopic);
router.put('/:id/status', authMiddleware, roleMiddleware(['admin']), updateTopicStatus);
router.get('/:id', authMiddleware, getTopicDetails);

export default router;