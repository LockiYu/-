import request from '@/utils/request'

// 获取系统消息列表
export const getSystemMessages = (params: {
  page: number
  pageSize: number
  type?: 'notice' | 'warning' | 'error'
  status?: 'active' | 'archived'
  priority?: 'low' | 'medium' | 'high'
  startDate?: string
  endDate?: string
}) => {
  return request.get('/dashboard/system-messages', { params })
}

// 获取系统日志列表
export const getSystemLogs = (params: {
  page: number
  pageSize: number
  userId?: string
  action?: string
  startDate?: string
  endDate?: string
}) => {
  return request.get('/dashboard/system-logs', { params })
}

// 获取备份文件列表
export const getBackupFiles = () => {
  return request.get('/system/backups')
}

// 添加获取数据库信息的 API
export const getDatabaseInfo = () => {
  return request({
    url: '/system/db/info',
    method: 'get'
  })
}

// 获取数据库表列表
export const getTables = () => {
  return request({
    url: '/system/tables',
    method: 'get'
  })
}

// 导出数据
export const exportData = (data: {
  tables: string[]
  format: 'sql' | 'csv' | 'excel'
}) => {
  return request({
    url: '/system/export',
    method: 'post',
    data,
    responseType: 'blob'
  })
}