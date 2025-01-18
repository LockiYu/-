import request from '@/utils/request'

// 获取教师负责的学生论文提交列表
export const getTeacherThesisConfirmations = (teacherId: string) => {
    return request({
        url: `/passConfirmation/teacher/${teacherId}`,
        method: 'get'
    })
}

// 更新论文确认状态
export const updateThesisConfirmation = (id: number, data: {
    advisor_review_status: 'approved' | 'rejected',
    advisor_comments: string
}) => {
    return request({
        url: `/passConfirmation/update/${id}`,
        method: 'post',
        data
    })
}