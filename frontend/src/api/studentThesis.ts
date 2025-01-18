import { request } from '@/utils/request'

// 获取论文提交历史
export const getStudentThesisHistory = () => {
    return request({
        url: '/student-thesis/history',
        method: 'get'
    })
}

// 获取论文评阅详情
export const getThesisReviewDetails = (studentId: string) => {
    return request({
        url: `/student-thesis/reviews/${studentId}`,
        method: 'get'
    })
} 