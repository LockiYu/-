import request from '@/utils/request'

// 获取答辩安排列表
export function getDefenseArrangements(params: {
    pageNum: number
    pageSize: number
    keyword?: string
    status?: string
}) {
    return request({
        url: '/defense/arrangements',
        method: 'get',
        params
    })
}

// 创建答辩安排
export function createDefenseArrangement(data: {
    student_id: string
    committee_id: number
    defense_time: string
    location: string
    duration: number
    notes?: string
}) {
    return request({
        url: '/defense/arrangements',
        method: 'post',
        data
    })
}

// 更新答辩安排
export function updateDefenseArrangement(id: number, data: any) {
    return request({
        url: `/defense/arrangements/${id}`,
        method: 'put',
        data
    })
}

// 删除答辩安排
export function deleteDefenseArrangement(id: number) {
    return request({
        url: `/defense/arrangements/${id}`,
        method: 'delete'
    })
}

// 获取可安排答辩的学生列表
export function getAvailableStudents() {
    return request({
        url: '/defense/available-students',
        method: 'get'
    })
}

// 获取答辩委员会列表
export function getDefenseCommittees() {
    return request({
        url: '/defense/committees',
        method: 'get'
    })
}

// 创建答辩委员会
export function createDefenseCommittee(data: {
    name: string
    chairman_id: string
    secretary_id: string
    member1_id: string
    member2_id: string
    member3_id: string
}) {
    return request({
        url: '/defense/committees',
        method: 'post',
        data
    })
}

// 更新答辩委员会
export function updateDefenseCommittee(id: number, data: {
    name: string
    chairman_id: string
    secretary_id: string
    member1_id: string
    member2_id: string
    member3_id: string
}) {
    return request({
        url: `/defense/committees/${id}`,
        method: 'put',
        data
    })
}

// 删除答辩委员会
export function deleteDefenseCommittee(id: number) {
    return request({
        url: `/defense/committees/${id}`,
        method: 'delete'
    })
}

// 获取可选的教师列表
export function getAvailableTeachers() {
    return request({
        url: '/defense/available-teachers',
        method: 'get'
    })
}

// 获取答辩评分列表
export function getDefenseScoreList(params: {
    pageNum: number
    pageSize: number
    status?: string
}) {
    return request({
        url: '/defense/scores',
        method: 'get',
        params
    })
}

// 提交答辩评分
export function submitDefenseScore(data: {
    arrangement_id: number
    presentation_score: number
    qa_score: number
    innovation_score: number
    completion_score: number
    comments?: string
    revision_requirements?: string
}) {
    return request({
        url: '/defense/scores',
        method: 'post',
        data
    })
}

// 获取答辩评分详情
export function getDefenseScoreDetail(arrangementId: number) {
    return request({
        url: `/defense/scores/${arrangementId}`,
        method: 'get'
    })
}