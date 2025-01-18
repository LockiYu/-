/*
 * @Author: test abc@163.com
 * @Date: 2024-12-17 18:24:18
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-18 23:53:42
 * @FilePath: \Graduation Design Management System\frontend\src\api\proposalReview.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import request from '@/utils/request'
import { message } from 'ant-design-vue'

// 定义接口类型
interface ProposalReview {
  id: number
  student_id: string
  version: number
  file_url: string | null
  status: 'not_started' | 'in_progress' | 'reviewing' | 'revision_needed' | 'completed'
  research_background_score: number
  technical_route_score: number
  feasibility_score: number
  innovation_score: number
  total_score: number
  research_background_comment: string
  technical_route_comment: string
  feasibility_comment: string
  innovation_comment: string
  general_comment: string
  improvement_suggestions: string
  submit_time: string
  review_time: string | null
  student_name: string
}

// 获取教师负责的学生开题报告列表
export function getTeacherProposals(teacherId: string) {
  return request<{ code: number, data: ProposalReview[] }>({
    url: `/proposal-reviews/teacher/${teacherId}`,
    method: 'get'
  }).catch(error => {
    message.error('获取开题报告列表失败')
    throw error
  })
}

// 评审开题报告请求参数接口
interface ReviewProposalParams {
  researchBackgroundScore: number
  technicalRouteScore: number
  feasibilityScore: number
  innovationScore: number
  totalScore: number
  researchBackgroundComment: string
  technicalRouteComment: string
  feasibilityComment: string
  innovationComment: string
  generalComment: string
  improvementSuggestions: string
  status: string
}

// 评审开题报告
export function reviewProposal(id: number, data: ReviewProposalParams) {
  return request<{ code: number, message: string }>({
    url: `/proposal-reviews/review/${id}`,
    method: 'post',
    data
  }).catch(error => {
    message.error('评审提交失败，请重试')
    throw error
  })
}

// 获取开题报告详情
export function getProposalDetail(id: number) {
  return request<{ code: number, data: ProposalReview }>({
    url: `/proposal-reviews/${id}`,
    method: 'get'
  }).catch(error => {
    message.error('获取开题报告详情失败')
    throw error
  })
} 