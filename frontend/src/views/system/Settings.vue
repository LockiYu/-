<template>
  <div class="app-container">
    <!-- 系统维护 -->
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>系统维护</span>
        </div>
      </template>

      <div class="maintenance-container">
        <el-row :gutter="20">
          <el-col :span="8">
            <el-card shadow="hover" class="maintenance-card">
              <template #header>
                <div class="tool-header">
                  <span>数据备份与恢复</span>
                </div>
              </template>
              <el-descriptions :column="1" border>
                <el-descriptions-item label="上次备份时间">
                  {{ lastBackupTime || '暂无备份' }}
                </el-descriptions-item>
                <el-descriptions-item label="备份文件数">
                  {{ backupFiles.length || 0 }} 个
                </el-descriptions-item>
                <el-descriptions-item label="操作">
                  <div class="button-group">
                    <el-button 
                      type="primary" 
                      size="small"
                      @click="handleBackup"
                      :loading="backingUp"
                    >
                      立即备份
                    </el-button>
                    <el-button 
                      type="warning"
                      size="small"
                      @click="showBackupFiles"
                    >
                      恢复数据
                    </el-button>
                  </div>
                </el-descriptions-item>
              </el-descriptions>
            </el-card>
          </el-col>

          <el-col :span="8">
            <el-card shadow="hover" class="maintenance-card">
              <template #header>
                <div class="tool-header">
                  <span>数据库信息</span>
                </div>
              </template>
              <el-descriptions :column="1" border>
                <el-descriptions-item label="数据库名称">
                  {{ dbInfo.name }}
                </el-descriptions-item>
                <el-descriptions-item label="数据表数量">
                  {{ dbInfo.tableCount }} 个
                </el-descriptions-item>
                <el-descriptions-item label="数据库大小">
                  {{ dbInfo.size }}
                </el-descriptions-item>
                <el-descriptions-item label="数据库状态">
                  <el-tag 
                    :type="dbInfo.status === 'running' ? 'success' : 'danger'"
                    size="small"
                  >
                    {{ dbInfo.status === 'running' ? '运行中' : '异常' }}
                  </el-tag>
                </el-descriptions-item>
                <el-descriptions-item label="连接情况">
                  <el-tooltip
                    content="当前连接数表示正在连接到数据库的客户端数量，包括应用程序、管理工具等"
                    placement="top"
                  >
                    <div>
                      当前 {{ dbInfo.connections }} / 最大 {{ dbInfo.maxConnections }}
                      <el-progress
                        :percentage="Math.round((dbInfo.connections / dbInfo.maxConnections) * 100)"
                        :status="dbInfo.connections / dbInfo.maxConnections > 0.8 ? 'warning' : 'success'"
                        :stroke-width="10"
                        style="margin-top: 5px"
                      />
                    </div>
                  </el-tooltip>
                </el-descriptions-item>
                <el-descriptions-item label="MySQL版本">
                  {{ dbInfo.version }}
                </el-descriptions-item>
              </el-descriptions>
              <div class="refresh-button">
                <el-button 
                  type="primary"
                  size="small"
                  :loading="refreshing"
                  @click="refreshDbInfo"
                >
                  {{ refreshing ? '刷新中...' : '刷新信息' }}
                </el-button>
              </div>
            </el-card>
          </el-col>

          <el-col :span="8">
            <el-card shadow="hover" class="maintenance-card">
              <template #header>
                <div class="tool-header">
                  <span>数据导出</span>
                </div>
              </template>
              <el-form :model="exportForm" label-width="100px">
                <el-form-item label="选择表">
                  <el-select 
                    v-model="exportForm.tables" 
                    multiple 
                    placeholder="请选择要导出的表"
                    style="width: 100%"
                    :loading="loadingTables"
                  >
                    <el-option 
                      v-for="table in tables" 
                      :key="table.name" 
                      :label="table.name" 
                      :value="table.name"
                    >
                      <span style="float: left">{{ table.name }}</span>
                      <span style="float: right; color: #8492a6; font-size: 13px">
                        {{ table.comment || '无注释' }} ({{ formatRows(table.rows) }})
                      </span>
                    </el-option>
                  </el-select>
                </el-form-item>
                <el-form-item label="导出格式">
                  <el-radio-group v-model="exportForm.format">
                    <el-radio label="sql">SQL</el-radio>
                    <el-radio label="csv">CSV</el-radio>
                    <el-radio label="xlsx">XLSX</el-radio>
                  </el-radio-group>
                </el-form-item>
              </el-form>
              <div class="button-group">
                <el-button 
                  type="primary" 
                  :loading="exporting"
                  @click="handleExport"
                >
                  {{ exporting ? '导出中...' : '导出数据' }}
                </el-button>
              </div>
            </el-card>
          </el-col>
        </el-row>
      </div>
    </el-card>

    <!-- 修改备份文件列表对话框 -->
    <el-dialog
      v-model="backupDialogVisible"
      title="备份文件列表"
      width="600px"
    >
      <el-table
        :data="paginatedBackupFiles"
        border
        style="width: 100%"
        v-loading="loadingBackups"
      >
        <el-table-column prop="filename" label="文件名" />
        <el-table-column prop="createdAt" label="创建时间">
          <template #default="{ row }">
            {{ new Date(row.createdAt).toLocaleString() }}
          </template>
        </el-table-column>
        <el-table-column prop="size" label="文件大小">
          <template #default="{ row }">
            {{ formatFileSize(row.size) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150">
          <template #default="{ row }">
            <el-button
              type="warning"
              size="small"
              @click="handleRestore(row.filename)"
            >
              恢复
            </el-button>
            <el-button
              type="danger"
              size="small"
              @click="handleDeleteBackup(row.filename)"
            >
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <!-- 添加分页组件 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[5, 10, 20, 50]"
          :total="backupFiles.length"
          layout="total, sizes, prev, pager, next"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'
import { getBackupFiles, getDatabaseInfo, getTables, exportData } from '@/api/system'

const backingUp = ref(false)
const backupDialogVisible = ref(false)
const backupFiles = ref([])
const lastBackupTime = ref('')

const dbInfo = ref({
  name: '',              // 数据库名称
  tableCount: 0,         // 数据表数量
  status: 'running',     // 数据库状态
  size: '0 MB',         // 数据库大小
  connections: 0,        // 当前连接数
  maxConnections: 0,     // 最大连接数
  version: '',          // MySQL版本
})

// 添加刷新状态
const refreshing = ref(false)

// 添加分页相关的响应式变量
const currentPage = ref(1)
const pageSize = ref(10)
const loadingBackups = ref(false)

// 计算分页后的数据
const paginatedBackupFiles = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return backupFiles.value.slice(start, end)
})

// 处理页码改变
const handleCurrentChange = (val: number) => {
  currentPage.value = val
}

// 处理每页条数改变
const handleSizeChange = (val: number) => {
  pageSize.value = val
  // 当总页数小于当前页码时，重置为第一页
  const maxPage = Math.ceil(backupFiles.value.length / pageSize.value)
  if (currentPage.value > maxPage) {
    currentPage.value = 1
  }
}

// 获取备份文件列表
const updateBackupFiles = async () => {
  try {
    const response = await getBackupFiles()
    if (response.code === 200) {
      backupFiles.value = response.data
      // 更新最后备份时间
      if (response.data.length > 0) {
        const latestBackup = response.data[0] // 文件已按时间排序
        lastBackupTime.value = new Date(latestBackup.createdAt).toLocaleString()
      }
    }
  } catch (error: any) {
    console.error('获取备份文件列表失败:', error)
  }
}

// 显示备份文件列表对话框
const showBackupFiles = async () => {
  backupDialogVisible.value = true
  loadingBackups.value = true
  try {
    await updateBackupFiles()
  } finally {
    loadingBackups.value = false
  }
}

// 备份完成后更新列表
const handleBackup = async () => {
  backingUp.value = true
  try {
    const response = await request({
      url: '/system/backup',
      method: 'post'
    })
    
    if (response.code === 200) {
      ElMessage.success('数据库备份成功')
      await updateBackupFiles() // 更新备份文件列表
    } else {
      throw new Error(response.message)
    }
  } catch (error: any) {
    console.error('备份失败:', error)
    ElMessage.error(error.message || '备份失败')
  } finally {
    backingUp.value = false
  }
}

// 恢复数据
const handleRestore = async (filename: string) => {
  try {
    // 弹出输入框让用户输入新数据库名称
    const { value: newDbName } = await ElMessageBox.prompt(
      '请输入要创建的新数据库名称',
      '恢复数据',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        inputPattern: /^[a-zA-Z][a-zA-Z0-9_]*$/,
        inputErrorMessage: '数据库名称只能包含字母、数字和下划线，且必须以字母开头'
      }
    );

    if (newDbName) {
      await ElMessageBox.confirm(
        `将创建新数据库 "${newDbName}" 并恢复数据，是否继续？`,
        '确认',
        {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }
      );

      const response = await request({
        url: '/system/restore',
        method: 'post',
        data: { 
          filename,
          newDbName 
        }
      });

      if (response.code === 200) {
        ElMessage.success('数据恢复成功');
        // 显示恢复信息
        await ElMessageBox.alert(
          `数据已恢复到新数据库: ${response.data.newDbName}\n\n` +
          `如需恢复到原数据库，请使用以下命令：\n${response.data.restoreCommand}`,
          '恢复成功',
          {
            type: 'success',
            confirmButtonText: '确定'
          }
        );
        backupDialogVisible.value = false;
      }
    }
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '恢复失败');
    }
  }
};

// 删除备份文件
const handleDeleteBackup = async (filename: string) => {
  try {
    await ElMessageBox.confirm(
      '确定要删除此备份文件吗？',
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const response = await request({
      url: `/system/backups/${filename}`,
      method: 'delete'
    })

    if (response.code === 200) {
      ElMessage.success('删除成功')
      showBackupFiles()
    }
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

// 格式化文件大小
const formatFileSize = (bytes: number) => {
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

// 修改刷新函数
const refreshDbInfo = async () => {
  if (refreshing.value) return  // 防止重复点击
  refreshing.value = true
  try {
    const response = await getDatabaseInfo()
    if (response.code === 200) {
      dbInfo.value = response.data
      ElMessage({
        message: '数据库信息刷新成功',
        type: 'success',
        duration: 2000
      })
    } else {
      throw new Error(response.message || '刷新失败')
    }
  } catch (error: any) {
    console.error('获取数据库信息失败:', error)
    ElMessage({
      message: error.message || '数据库信息刷新失败',
      type: 'error',
      duration: 3000
    })
  } finally {
    refreshing.value = false  // 无论成功失败都要关闭加载状态
  }
}

// 定时更新备份文件列表
let updateInterval: NodeJS.Timer

// 添加导出相关的响应式变量
const exportForm = ref({
  tables: [], // 选中的表
  format: 'sql' // 默认导出格式
})

interface TableInfo {
  name: string
  rows: number
  size: number
  comment: string
}

// 修改表列表的类型
const tables = ref<TableInfo[]>([])
const loadingTables = ref(false)

// 格式化行数
const formatRows = (rows: number) => {
  if (rows >= 10000) {
    return `${(rows / 10000).toFixed(1)}万行`
  }
  return `${rows}行`
}

// 获取数据库表列表
const loadTableList = async () => {
  loadingTables.value = true
  try {
    const response = await getTables()
    if (response.code === 200) {
      tables.value = response.data
    } else {
      throw new Error(response.message || '获取表列表失败')
    }
  } catch (error: any) {
    ElMessage.error(error.message || '获取表列表失败')
  } finally {
    loadingTables.value = false
  }
}

// 添加导出状态变量
const exporting = ref(false)

// 修改导出处理函数
const handleExport = async () => {
  if (!exportForm.value.tables.length) {
    ElMessage.warning('请至少选择一个表进行导出')
    return
  }
  
  try {
    await ElMessageBox.confirm(
      `确定要导出 ${exportForm.value.tables.length} 个表的数据吗？`,
      '确认导出',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    exporting.value = true
    const response = await exportData({
      tables: exportForm.value.tables,
      format: exportForm.value.format
    })
    
    // 创建下载链接
    const blob = new Blob([response], { 
      type: exportForm.value.format === 'sql' ? 'application/sql' :
            exportForm.value.format === 'csv' ? 'text/csv' : 
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    })
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `export_${Date.now()}.${exportForm.value.format}`
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    window.URL.revokeObjectURL(url)
    
    ElMessage.success('数据导出成功')
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '数据导出失败')
    }
  } finally {
    exporting.value = false
  }
}

// 在组件挂载时获取表列表
onMounted(() => {
  refreshDbInfo()
  updateBackupFiles()
  updateInterval = setInterval(updateBackupFiles, 60000)
  loadTableList()
})

onUnmounted(() => {
  if (updateInterval) {
    clearInterval(updateInterval)
  }
})
</script>

<style scoped>
.app-container {
  padding: 20px;
}

.box-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.maintenance-container {
  margin-top: 20px;
}

.maintenance-card {
  height: 100%;
  min-height: 300px; /* 设置最小高度 */
}

.tool-header {
  font-size: 14px;
  font-weight: bold;
}

.button-group {
  display: flex;
  gap: 10px;
  justify-content: center;
}

.refresh-button {
  margin-top: 10px;
  text-align: center;
}

/* 统一描述列表样式 */
:deep(.el-descriptions) {
  margin-bottom: 10px;
}

:deep(.el-descriptions__body) {
  background-color: #fff;
}

:deep(.el-descriptions__label) {
  width: 120px;
  font-weight: bold;
}

:deep(.el-progress) {
  margin: 5px 0;
}

/* 确保所有卡片内容垂直居中 */
:deep(.el-card__body) {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  height: calc(100% - 55px); /* 减去卡片头部的高度 */
  padding: 15px;
}

.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

/* 调整对话框内容的内边距 */
:deep(.el-dialog__body) {
  padding: 20px;
}

:deep(.el-select-dropdown__item) {
  padding: 0 20px;
  height: 34px;
  line-height: 34px;
}

/* 优化选项内容的布局 */
:deep(.el-select-dropdown__item span) {
  display: inline-block;
  max-width: 50%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style> 