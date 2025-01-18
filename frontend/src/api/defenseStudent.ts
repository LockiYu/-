import request from '@/utils/request'

// 获取学生答辩信息
export function getStudentDefenseInfo() {
    return request({
        url: '/defense-student/info',
        method: 'get'
    })
}

// 获取答辩评分详情
export function getDefenseScores() {
    return request({
        url: '/defense-student/scores',
        method: 'get'
    })
} 