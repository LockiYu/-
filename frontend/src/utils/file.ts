/*
 * @Author: test abc@163.com
 * @Date: 2024-12-18 20:24:32
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-18 20:24:43
 * @FilePath: \Graduation Design Management System\frontend\src\utils\file.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
// 获取文件URL
export const getFileUrl = (path: string) => {
    // 确保路径以 / 开头
    const normalizedPath = path.startsWith('/') ? path : `/${path}`
    return `${import.meta.env.VITE_API_BASE_URL}${normalizedPath}`
}

// 获取文件名
export const getFileName = (url: string) => {
    if (!url) return ''
    return url.split('/').pop() || ''
} 