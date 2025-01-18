/*
 * @Author: test abc@163.com
 * @Date: 2024-12-08 23:11:48
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-18 20:17:58
 * @FilePath: \Graduation Design Management System\frontend\src\utils\request.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import axios from 'axios'
import { useUserStore } from '@/stores/user'
import router from '@/router'
import { ElMessage } from 'element-plus'

export const request = axios.create({
    baseURL: 'http://localhost:3001/api',
    timeout: 30000,
    withCredentials: true,
    headers: {
        'Content-Type': 'application/json'
    }
})

// 添加请求拦截器
request.interceptors.request.use(
    config => {
        const token = localStorage.getItem('token') // 直接从 localStorage 获取
        console.log('Current token:', token) // 添加调试日志

        if (token) {
            config.headers.Authorization = `Bearer ${token}`
        } else {
            console.log('No token found in localStorage') // 添加调试日志
        }
        return config
    },
    error => {
        return Promise.reject(error)
    }
)

// 添加响应拦截器
request.interceptors.response.use(
    response => {
        return response.data;
    },
    async error => {
        if (error.response) {
            switch (error.response.status) {
                case 401:
                    const userStore = useUserStore();
                    userStore.clearUser();
                    if (!error.config.url?.includes('/login')) {
                        router.push({
                            path: '/login',
                            query: { redirect: router.currentRoute.value.fullPath }
                        });
                        ElMessage.error('请先登录');
                    }
                    break;
                case 403:
                    if (!error.config.url?.includes('/users/')) {
                        ElMessage.error('权限不足');
                    }
                    break;
                default:
                    ElMessage.error(error.response.data?.message || '请求失败');
            }
        } else if (error.code === 'ERR_NETWORK') {
            ElMessage.error('网络连接失败');
        }
        return Promise.reject(error);
    }
)

// 默认导出
export default request