import request from '@/utils/request'

// 获取教师指导的学生进度统计
export const getProgressStatistics = () => {
  return request({
    url: '/teacher/progress/statistics',
    method: 'get'
  })
}

// 获取教师指导的学生进度列表
export const getProgressList = (params: {
  pageNum?: number;
  pageSize?: number;
  studentName?: string;
  stage?: string;
  status?: string;
}) => {
  return request({
    url: '/teacher/progress/list',
    method: 'get',
    params
  })
}

// 下载文件
export const downloadFile = async (params: { studentId: string; stageType: string }) => {
    try {
        const response = await request({
            url: '/teacher/progress/download',
            method: 'get',
            params,
            responseType: 'blob',
            headers: {
                'Accept': 'application/octet-stream'
            }
        });
        return response;
    } catch (error) {
        console.error('下载请求失败:', error);
        throw error;
    }
};