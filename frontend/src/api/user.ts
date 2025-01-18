/*
 * @Author: test abc@163.com
 * @Date: 2024-12-09 11:38:06
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-10 19:21:28
 * @FilePath: \Graduation Design Management System\frontend\src\api\user.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import request from '@/utils/request'

// 登录
export const login = (data: any) => {
    return request({
        url: '/auth/login',
        method: 'post',
        data
    })
}

// 获取用户信息
export const getUserInfo = () => {
    const userInfo = JSON.parse(localStorage.getItem('user') || '{}')

    // 添加错误检查
    if (!userInfo.userId) {
        return Promise.reject(new Error('No user ID available'))
    }

    return request({
        url: `/users/${userInfo.userId}`,
        method: 'get'
    })
}

// 登出
export const logout = () => {
    return request({
        url: '/auth/logout',
        method: 'post'
    })
}

// 修改密码
export const changePassword = (data: any) => {
    return request({
        url: '/auth/password',
        method: 'put',
        data
    })
}

// 获取用户详细信息
export const getUserDetail = () => {
    const userInfo = JSON.parse(localStorage.getItem('user') || '{}')
    return request({
        url: `/users/${userInfo.userId}`,
        method: 'get'
    })
}

// 更新用户信息
export const updateUserInfo = (data: {
    realName: string
    email: string
    phone: string
}) => {
    const userInfo = JSON.parse(localStorage.getItem('user') || '{}')
    return request({
        url: `/users/${userInfo.userId}`,
        method: 'put',
        data
    })
}

// 获取用户列表
export const getUserList = (params: {
    pageNum: number
    pageSize: number
    username?: string
    role?: string
}) => {
    return request({
        url: '/users',
        method: 'get',
        params
    })
}

// 创建用户
export const createUser = (data: {
    username: string
    password: string
    role: string
    email: string
}) => {
    return request({
        url: '/users',
        method: 'post',
        data
    })
}

// 更新用户
export const updateUser = (userId: string, data: {
    role?: string
    email?: string
}) => {
    return request({
        url: `/users/${userId}`,
        method: 'put',
        data
    })
}

// 删除用户
export const deleteUser = (userId: string) => {
    return request({
        url: `/users/${userId}`,
        method: 'delete'
    })
}

// 获取指定用户信息
export const getUserById = (userId: string) => {
    return request({
        url: `/users/${userId}`,
        method: 'get'
    })
}

// 更新指定用户信息
export const updateUserById = (userId: string, data: any) => {
    return request({
        url: `/users/${userId}`,
        method: 'put',
        data
    })
} 