/*
 * @Author: test abc@163.com
 * @Date: 2024-12-16 16:38:29
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-30 15:11:00
 * @FilePath: \Graduation Design Management System\frontend\src\api\tasks.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import request from '@/utils/request'

// 获取任务书列表
export function getTaskList(params: {
    pageNum: number;
    pageSize: number;
    keyword?: string;
    status?: string;
}) {
    return request({
        url: '/tasks/list',
        method: 'get',
        params
    })
}

// 下达任务书
export function assignTask(data: {
    student_id: string;
    title: string;
    content: string;
    requirements: string;
    deadline: string;
    topic_id?: number;
    selection_id?: number;
}) {
    return request({
        url: '/tasks/assign',
        method: 'post',
        data
    })
}

// 更新任务书
export function updateTask(data: {
    task_id: number;
    student_id: string;
    title: string;
    content: string;
    requirements: string;
    deadline: string;
}) {
    return request({
        url: `/tasks/${data.task_id}`,
        method: 'put',
        data
    })
}

// 获取学生列表（用于选择下达任务书的学生）
export function getStudentList() {
    return request({
        url: '/tasks/students',
        method: 'get'
    })
}

// 获取学生最新任务书
export function getLatestStudentTask(studentId: string) {
    return request({
        url: `/tasks/student/${studentId}/latest`,
        method: 'get'
    })
}

// 完成任务并评分
export function completeTask(taskId: number, data: {
    score: number;
    teacherComment: string;
    studentId: string;
}) {
    return request({
        url: `/tasks/${taskId}/complete`,
        method: 'post',
        data
    });
} 