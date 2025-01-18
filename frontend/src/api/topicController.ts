import request from '@/utils/request'

// 获取公开课题列表
export const getPublicTopics = (params: {
    pageNum?: number
    pageSize?: number
    title?: string
    type?: string
    source?: string
}) => {
    return request({
        url: '/topicController/public',
        method: 'get',
        params
    })
}

// 获取课题详情
export const getTopicDetail = (topicId: number) => {
    return request({
        url: `/topics/${topicId}`,
        method: 'get'
    })
}

// 创建课题
export const createTopic = (data: any) => {
    return request({
        url: '/topics',
        method: 'post',
        data
    })
}

// 更新课题
export const updateTopic = (topicId: number, data: any) => {
    return request({
        url: `/topics/${topicId}`,
        method: 'put',
        data
    })
}

// 删除课题
export const deleteTopic = (topicId: number) => {
    return request({
        url: `/topics/${topicId}`,
        method: 'delete'
    })
}

// 提交课题审核
export const submitTopicForReview = (topicId: number) => {
    return request({
        url: `/topics/${topicId}/submit`,
        method: 'post'
    })
}

// 审核课题
export const reviewTopic = (topicId: number, data: {
    status: 'approved' | 'rejected'
    comment?: string
}) => {
    return request({
        url: `/topics/${topicId}/review`,
        method: 'post',
        data
    })
}