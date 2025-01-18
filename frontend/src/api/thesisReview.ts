import request from '@/utils/request'

// 获取评阅列表
export function getReviewList(params: any) {
    return request({
        url: '/thesis-review/list',
        method: 'get',
        params: {
            pageNum: params.pageNum,
            pageSize: params.pageSize,
            studentName: params.studentName,
            thesisTitle: params.thesisTitle,
            status: params.status
        }
    })
}

// 提交评阅
export function submitReview(data: any) {
    return request({
        url: '/thesis-review/submit',
        method: 'post',
        data: data
    })
}

// 下载论文
export function downloadThesis(fileUrl: string) {
    return request({
        url: fileUrl,
        method: 'get',
        responseType: 'blob',
        headers: {
            'Content-Type': 'application/octet-stream'
        }
    })
}

// 添加获取同行评阅进度的 API
export function getPeerReviewProgress(studentId: string) {
    return request({
        url: '/thesis-review/progress',
        method: 'get',
        params: {
            studentId
        }
    })
}