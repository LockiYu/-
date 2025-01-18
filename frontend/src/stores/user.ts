/*
 * @Author: test abc@163.com
 * @Date: 2024-12-08 21:56:28
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2025-01-01 14:12:33
 * @FilePath: \Graduation Design Management System\frontend\src\stores\user.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import { defineStore } from 'pinia'
import { login } from '@/api/auth'
import { getUserInfo as fetchUserInfo } from '@/api/user'
import request from '@/utils/request'

interface UserInfo {
    userId?: string
    username?: string
    role?: string
    staffId?: string
    studentId?: string
    loginCount: number
    department?: string
}

export const useUserStore = defineStore('user', {
    state: () => ({
        token: localStorage.getItem('token') || '',
        userInfo: JSON.parse(localStorage.getItem('user') || '{}'),
        isLoading: false,
        lastFetchTime: 0
    }),

    getters: {
        username: (state) => state.userInfo?.username || '未知用户',
        role: (state) => state.userInfo?.role,
        userId: (state) => state.userInfo?.userId,
        isLoggedIn: (state) => !!state.token && !!state.userInfo?.userId
    },

    actions: {
        async loginAction(loginData: any) {
            try {
                const response = await login(loginData)

                if (response.code === 200) {
                    const { token, userInfo } = response.data
                    this.setToken(token)
                    this.setUserInfo(userInfo)

                    setTimeout(() => {
                        window.location.reload()
                    }, 100)

                    return response
                }
                throw new Error(response.message || '登录失败')
            } catch (error) {
                console.error('Login error:', error)
                this.clearUser()
                throw error
            }
        },

        async getUserInfo() {
            const now = Date.now();
            if (this.isLoading || (now - this.lastFetchTime < 3000)) {
                return this.userInfo;
            }

            try {
                this.isLoading = true;
                
                if (!this.userInfo.userId) {
                    throw new Error('No user ID available');
                }

                const response = await request.get(`/users/${this.userInfo.userId}`);
                if (response.code === 200) {
                    const newUserInfo = {
                        ...this.userInfo,
                        ...response.data,
                        department: response.data.department
                    };

                    if (!newUserInfo.userId || !newUserInfo.role) {
                        throw new Error('Invalid user info from server');
                    }

                    this.setUserInfo(newUserInfo);
                    this.lastFetchTime = now;
                    return this.userInfo;
                }
                return null;
            } catch (error) {
                console.error('获取用户信息失败:', error);
                throw error;
            } finally {
                this.isLoading = false;
            }
        },

        setToken(token: string) {
            this.token = token
            localStorage.setItem('token', token)
        },

        setUserInfo(info: UserInfo) {
            if (!info.userId || !info.role) {
                console.error('Invalid user info:', info);
                return;
            }
            this.userInfo = info;
            localStorage.setItem('user', JSON.stringify(info));
        },

        clearUser() {
            this.token = ''
            this.userInfo = {} as UserInfo
            localStorage.removeItem('token')
            localStorage.removeItem('user')
        }
    }
})