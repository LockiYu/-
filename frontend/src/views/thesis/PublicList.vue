<template>
  <div class="app-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>课题列表</span>
        </div>
      </template>

      <!-- 搜索栏 -->
      <div class="filter-container">
        <el-form :inline="true" :model="queryParams">
          <el-form-item label="课题名称">
            <el-input
              v-model="queryParams.title"
              placeholder="请输入课题名称"
              clearable
              @clear="handleQuery"
            />
          </el-form-item>
          <el-form-item label="类型">
            <el-select
              v-model="queryParams.type"
              placeholder="选择类型"
              clearable
              @change="handleTypeChange"
            >
              <el-option label="工程设计" value="工程设计" />
              <el-option label="理论研究" value="理论研究" />
              <el-option label="应用研究" value="应用研究" />
              <el-option label="工程实践" value="工程实践" />
            </el-select>
          </el-form-item>
          
          <!-- 显示当前选择的类型 -->
          <el-form-item v-if="queryParams.type">
            <el-tag
              closable
              @close="handleTypeReset"
            >
              当前类型: {{ queryParams.type }}
            </el-tag>
          </el-form-item>

          <el-form-item label="来源">
            <el-select
              v-model="queryParams.source"
              placeholder="选择来源"
              clearable
              @change="handleQuery"
            >
              <el-option label="教师科研" value="教师科研" />
              <el-option label="企业合作" value="企业合作" />
              <el-option label="横向项目" value="横向项目" />
              <el-option label="纵向项目" value="纵向项目" />
            </el-select>
          </el-form-item>

          <el-form-item>
            <el-button type="primary" @click="handleQuery">查询</el-button>
            <el-button @click="handleReset">重置</el-button>
          </el-form-item>
        </el-form>
      </div>

      <!-- 课题列表 -->
      <el-table
        v-loading="loading"
        :data="topicsList"
        border
        style="width: 100%"
      >
        <el-table-column prop="title" label="课题名称" min-width="200">
          <template #default="{ row }">
            <el-button 
              link 
              type="primary" 
              @click="handleViewDetails(row)"
            >
              {{ row.title }}
            </el-button>
          </template>
        </el-table-column>
        <el-table-column prop="type" label="类型" width="120">
          <template #default="{ row }">
            {{ getTopicType(row.type) }}
          </template>
        </el-table-column>
        <el-table-column prop="source" label="来源" width="150" />
        <el-table-column prop="teacher_name" label="指导教师" width="120" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="发布时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.created_at) }}
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="queryParams.pageNum"
          v-model:page-size="queryParams.pageSize"
          :total="total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 课题详情对话框 -->
    <el-dialog
      v-model="detailsDialogVisible"
      title="课题详情"
      width="700px"
    >
      <el-descriptions :column="2" border>
        <el-descriptions-item label="课题名称" :span="2">
          {{ currentTopic?.title }}
        </el-descriptions-item>
        <el-descriptions-item label="课题类型">
          {{ getTopicType(currentTopic?.type) }}
        </el-descriptions-item>
        <el-descriptions-item label="课题来源">
          {{ currentTopic?.source }}
        </el-descriptions-item>
        <el-descriptions-item label="指导教师">
          {{ currentTopic?.teacher_name }}
        </el-descriptions-item>
        <el-descriptions-item label="发布时间">
          {{ formatDateTime(currentTopic?.created_at) }}
        </el-descriptions-item>
        <el-descriptions-item label="课题描述" :span="2">
          {{ currentTopic?.description }}
        </el-descriptions-item>
        <el-descriptions-item label="专业要求" :span="2">
          {{ currentTopic?.major_requirements }}
        </el-descriptions-item>
        <el-descriptions-item label="学生要求" :span="2">
          {{ currentTopic?.student_requirements }}
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'
import { getPublicTopics } from '@/api/topicController'

// 查询参数
const queryParams = reactive({
  title: '',
  type: '',
  source: '',
  pageNum: 1,
  pageSize: 10
})

// 数据
const loading = ref(false)
const topicsList = ref([])
const total = ref(0)
const detailsDialogVisible = ref(false)
const currentTopic = ref(null)

// 类型映射
const getTopicType = (type: string) => {
  const typeMap: Record<string, string> = {
    'engineering': '工程设计',
    'theoretical': '理论研究',
    'applied': '应用研究',
    'experimental': '实验研究'
  }
  return typeMap[type] || type
}

// 状态映射
const getStatusType = (status: string) => {
  const statusMap: Record<string, string> = {
    'draft': 'info',
    'pending': 'warning',
    'approved': 'success',
    'rejected': 'danger',
    'selected': 'success'
  }
  return statusMap[status] || 'info'
}

const getStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    'draft': '草稿',
    'pending': '待审核',
    'approved': '已通过',
    'rejected': '已拒绝',
    'selected': '已选择'
  }
  return statusMap[status] || status
}

// 格式化日期时间
const formatDateTime = (datetime: string) => {
  if (!datetime) return '-'
  return new Date(datetime).toLocaleString('zh-CN')
}

// 处理函数
const handleQuery = async () => {
  loading.value = true
  try {
    const response = await getPublicTopics({
      title: queryParams.title || undefined,
      type: queryParams.type || undefined,
      source: queryParams.source || undefined
    })
    if (response.code === 200) {
      topicsList.value = response.data
    } else {
      ElMessage.error(response.message || '查询失败')
    }
  } catch (error: any) {
    ElMessage.error(error.message || '查询失败')
  } finally {
    loading.value = false
  }
}

const handleReset = () => {
  queryParams.title = ''
  queryParams.type = ''
  queryParams.source = ''
  handleQuery()
}

const handleTypeChange = (value: string) => {
  queryParams.type = value
  handleQuery()
}

const handleTypeReset = () => {
  queryParams.type = ''
  handleQuery()
}

const handleViewDetails = (row: any) => {
  currentTopic.value = row
  detailsDialogVisible.value = true
}

// 初始化
onMounted(() => {
  handleQuery()
})
</script>

<style scoped>
.app-container {
  padding: 20px;
}

.filter-container {
  padding-bottom: 20px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}

.selected-type {
  margin-top: 10px;
  font-weight: bold;
  color: #333;
}
</style> 