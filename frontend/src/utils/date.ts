/*
 * @Author: test abc@163.com
 * @Date: 2024-12-16 16:22:03
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-18 20:19:17
 * @FilePath: \Graduation Design Management System\frontend\src\utils\date.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import dayjs from 'dayjs'

// 格式化日期
export const formatDate = (date: string | Date, format: string = 'YYYY-MM-DD HH:mm:ss') => {
    if (!date) return ''
    return dayjs(date).format(format)
}

// 添加 formatDateTime 函数
export const formatDateTime = (date: string | Date) => {
    return formatDate(date, 'YYYY-MM-DD HH:mm:ss')
}

// 计算剩余天数
export const getRemainingDays = (deadline: string | Date) => {
    if (!deadline) return 0
    const now = dayjs()
    const deadlineDate = dayjs(deadline)
    return Math.ceil(deadlineDate.diff(now, 'day', true))
}

// 检查是否接近截止日期(7天内)
export const isDeadlineNear = (deadline: string | Date) => {
    const remainingDays = getRemainingDays(deadline)
    return remainingDays > 0 && remainingDays <= 7
}

// 检查是否已过期
export const isOverdue = (deadline: string | Date) => {
    return getRemainingDays(deadline) < 0
}

// 获取相对时间描述
export const getRelativeTime = (date: string | Date) => {
    return dayjs(date).fromNow()
} 