import express from 'express'
import { getPublicTopics } from '../controllers/topicController'

const router = express.Router()

router.get('/public', getPublicTopics)

export default router