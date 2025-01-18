import request from '@/utils/request'

export interface LoginData {
    username: string
    password: string
}

export const login = (data: LoginData) => {
    return request({
        url: '/auth/login',
        method: 'post',
        data,
        validateStatus: function (status) {
            return status >= 200 && status < 500
        }
    })
}

export const logout = () => {
    return request({
        url: '/auth/logout',
        method: 'post'
    })
}

export interface RegisterData {
    username: string
    password: string
    role: string
}

export const register = (data: RegisterData) => {
    return request({
        url: '/auth/register',
        method: 'post',
        data
    })
} 