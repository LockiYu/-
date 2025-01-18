import request from '@/utils/request';

// 获取公开统计数据
export function getPublicStats() {
    return request({
        url: '/visitor/stats',
        method: 'get'
    });
}

// 获取公开教师信息
export function getPublicTeachers() {
    return request({
        url: '/visitor/teachers',
        method: 'get'
    });
}

// 获取公开题目列表
export function getPublicTopics() {
    return request({
        url: '/visitor/topics',
        method: 'get'
    });
}

// 获取公开公告
export function getPublicAnnouncements() {
    return request({
        url: '/visitor/announcements',
        method: 'get'
    });
}

// 获取公开答辩安排
export function getPublicDefenseArrangements() {
    return request({
        url: '/visitor/defense-arrangements',
        method: 'get'
    });
}