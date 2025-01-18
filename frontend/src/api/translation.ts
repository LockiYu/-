import request from '@/utils/request'

// 获取教师负责的学生翻译列表
export const getTeacherTranslations = (teacherId: string) => {
    return request({
        url: `/translation/teacher/${teacherId}`,
        method: 'get'
    })
}

// 评阅翻译
export const reviewTranslation = (id: number, data: {
    language_accuracy_score: number,
    content_integrity_score: number,
    format_score: number,
    total_score: number,
    language_accuracy_comment: string,
    content_integrity_comment: string,
    format_comment: string,
    general_comment: string,
    improvement_suggestions: string,
    status: 'pending' | 'reviewing' | 'revision_needed' | 'completed'
}) => {
    return request({
        url: `/translation/review/${id}`,
        method: 'post',
        data
    })
}

// 获取翻译详情
export const getTranslationDetail = (id: number) => {
    return request({
        url: `/translation/detail/${id}`,
        method: 'get'
    })
}

// 现有的API保持不变
export const getTranslationReview = () => {
    return request({
        url: '/translation/review',
        method: 'get'
    })
}

export const createOrUpdateTranslationReview = (data: {
    file_url: string
    file_size: number
}) => {
    return request({
        url: '/translation/review',
        method: 'post',
        data: {
            file_url: data.file_url,
            file_size: data.file_size,
            status: 'pending'
        }
    })
} 