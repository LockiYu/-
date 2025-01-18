/*
 * @Author: test abc@163.com
 * @Date: 2024-12-14 00:10:11
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-19 00:23:15
 * @FilePath: \Graduation Design Management System\frontend\src\utils\format.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
export const formatDate = (date: string | Date) => {
    if (!date) return '';
    const d = new Date(date);
    return d.toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
    });
};

// 添加 formatDateTime 函数，与 formatDate 保持一致的格式
export const formatDateTime = (date: string | Date) => {
    if (!date) return '';
    const d = new Date(date);
    return d.toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
    });
};