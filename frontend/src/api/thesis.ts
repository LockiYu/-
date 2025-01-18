import request from '@/utils/request'

// 获取题目列表
export function getTopicList(params: any) {
    return request({
        url: '/thesis/topics',
        method: 'get',
        params: {
            page: params.pageNum,
            pageSize: params.pageSize,
            title: params.title,
            type: params.type,
            status: params.status,
            teacherId: params.teacherId
        }
    })
}

// 获取论文类型
export function getTopicTypes() {
    return request({
        url: '/thesis/types',
        method: 'get'
    })
}

export function addTopic(data: any) {
    return request({
        url: '/thesis/topics',
        method: 'post',
        data: {
            title: data.title,
            type: data.type,
            source: data.source || '',
            description: data.description,
            major_requirements: data.majorRequirements,
            student_requirements: data.studentRequirements,
            teacher_id: data.teacherId
        }
    })
}

export function exportTopics(params: any) {
    return request({
        url: '/thesis/topics/export',
        method: 'get',
        params,
        responseType: 'blob'
    })
}

export function updateTopicStatus(id: number, status: string) {
    return request({
        url: `/thesis/topics/${id}/status`,
        method: 'put',
        data: { status }
    })
}

export const getTopicDetails = (id: string | number) => {
    return request({
        url: `/topics/${id}`,
        method: 'get'
    })
}

// 获取学生论文评阅信息
export function getStudentThesisReviews() {
    return request({
        url: '/thesis/reviews/student',
        method: 'get'
    })
}

// 更新题目
export function updateTopic(id: number, data: any) {
    return request({
        url: `/thesis/topics/${id}`,
        method: 'put',
        data: {
            title: data.title,
            type: data.type,
            source: data.source || '',
            description: data.description,
            major_requirements: data.majorRequirements,
            student_requirements: data.studentRequirements
        }
    })
}

// 删除题目
export function deleteTopic(id: number) {
    return request({
        url: `/thesis/topics/${id}`,
        method: 'delete'
    })
}