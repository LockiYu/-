/*
 * @Author: test abc@163.com
 * @Date: 2024-12-28 16:35:22
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-28 17:13:14
 * @FilePath: \Graduation Design Management System\frontend\src\api\midterm.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import request from '@/utils/request'

// 获取教师负责的学生中期报告列表
export const getTeacherMidterms = (teacherId: string) => {
    return request({
        url: `/midterm/teacher/${teacherId}`,
        method: 'get'
    })
}

// 评阅中期报告
export const reviewMidterm = (id: number, data: {
    research_progress_score: number,
    technical_ability_score: number,
    work_attitude_score: number,
    total_score: number,
    progress_comment: string,
    technical_comment: string,
    attitude_comment: string,
    improvement_suggestions: string,
    status: 'completed' | 'revision_needed'
}) => {
    return request({
        url: `/midterm/review/${id}`,
        method: 'post',
        data
    })
}

// 获取中期报告详情
export const getMidtermDetail = (id: number) => {
    return request({
        url: `/midterm/detail/${id}`,
        method: 'get'
    })
}