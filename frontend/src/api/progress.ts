/*
 * @Author: test abc@163.com
 * @Date: 2024-12-10 22:49:38
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-29 22:44:48
 * @FilePath: \Graduation Design Management System\frontend\src\api\progress.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import request from '@/utils/request'
import { useUserStore } from '@/stores/user'

export function getStageList() {
    return request({
        url: '/progress/stages',
        method: 'get'
    })
}

export function updateStage(id: number, data: {
    name: string
    type: string
    timeRange: Date[]
    weight: number
    description: string
    status: string
}) {
    const [startTime, endTime] = data.timeRange
    return request({
        url: `/progress/stages/${id}`,
        method: 'put',
        data: {
            ...data,
            startTime,
            endTime
        }
    })
}

// 获取进度列表
export function getProgressList(params: {
    pageNum: number;
    pageSize: number;
    keyword?: string;
    stage?: string;
    status?: string;
}) {
    return request({
        url: '/progress/list',
        method: 'get',
        params
    });
}

// 发送提醒
export function sendReminder(id: number) {
    return request({
        url: `/progress/remind/${id}`,
        method: 'post'
    });
}

// 导出进度
export function exportProgress(params: any) {
    return request({
        url: '/progress/export',
        method: 'get',
        params,
        responseType: 'blob'
    });
}

// 获取统计数据
export function getStatistics() {
    return request({
        url: '/progress/statistics',
        method: 'get'
    });
}

// 更新分数
export function updateStageScore(data: {
    student_id: string;
    stage_type: string;
    score: number;
}) {
    return request({
        url: '/progress/score',
        method: 'put',
        data
    });
}

// 获取班级列表
export function getClassList() {
    return request({
        url: '/progress/classes',
        method: 'get'
    })
}

// 获取教师列表
export function getTeacherList() {
    return request({
        url: '/progress/teachers',
        method: 'get'
    })
}

// 获取学生进度
export function getStudentProgress(studentId: string) {
    return request({
        url: `/progress/student/${studentId}`,
        method: 'get'
    });
}

// 获取进度信息
export function getProgress() {
    return request({
        url: '/progress',
        method: 'get'
    })
}

// 更新进度状态
export function updateProgress(data: {
    stage_type: string
    status: string
    score?: number
    comment?: string
}) {
    return request({
        url: '/progress/update',
        method: 'post',
        data
    })
}

// 提交文件
export function submitFile(data: FormData) {
    return request({
        url: '/progress/submit',
        method: 'post',
        data,
        headers: {
            'Content-Type': 'multipart/form-data'
        }
    })
}

// 获取单个学生的文献综述详情
export function getLiteratureReview() {
    return request({
        url: '/progress/literature-review',
        method: 'get',
        params: {
            studentId: useUserStore().userId
        }
    })
}

// 获取文献综述列表（教师用）
export function getLiteratureReviews(params: any) {
    return request({
        url: '/progress/literature-reviews',
        method: 'get',
        params
    })
}

// 更新文献综述评阅结果
export function updateLiteratureReview(data: {
    student_id: string
    content_score: number
    analysis_score: number
    structure_score: number
    writing_score: number
    content_comment: string
    improvement_suggestions: string
    general_comment: string
    status: string
    total_score?: number
}) {
    return request({
        url: '/progress/literature-review',
        method: 'post',
        data
    })
}

// 获取或创建开题报告记录
export const getOrCreateProposalReview = () => {
    return request({
        url: '/progress/proposal/review',
        method: 'get',
        params: {
            studentId: useUserStore().userId
        }
    })
}

// 更新开题报告评审结果
export const updateProposalReview = (data: {
    studentId: string
    status: string
    researchBackgroundScore?: number
    technicalRouteScore?: number
    feasibilityScore?: number
    innovationScore?: number
    totalScore?: number
    researchBackgroundComment: string
    technicalRouteComment: string
    feasibilityComment: string
    innovationComment: string
    generalComment: string
    improvementSuggestions: string
}) => {
    return request({
        url: '/progress/proposal/review',
        method: 'post',
        data
    })
}

// 获取中期检查记录
export function getMidtermReview() {
    return request({
        url: '/progress/midterm-review',
        method: 'get',
        params: {
            studentId: useUserStore().userId
        }
    })
}

// 创建或更新中期检查记录
export function createOrUpdateMidtermReview(data: {
    file_url: string
    file_size: number
    version?: number
}) {
    return request({
        url: '/progress/midterm-review',
        method: 'post',
        data
    })
}

// 获取外文翻译评审记录
export const getTranslationReview = () => {
    return request({
        url: '/api/progress/translation-review',
        method: 'get'
    })
}

// 更新外文翻译评审记录
export const updateTranslationReview = (data: any) => {
    return request({
        url: '/api/progress/translation-review',
        method: 'post',
        data
    })
}

// 获取答辩信息
export function getDefenseInfo() {
    return request({
        url: '/defense/info',  // 修改为与后端 app.ts 中的路由配置一致
        method: 'get'
    })
}
