<template>
  <div class="review-assignment">
    <!-- 页面头部 -->
    <div class="page-header">
      <h2>论文评阅分配</h2>
      <div class="search-section">
        <el-input
          v-model="searchQuery"
          placeholder="搜索论文标题/学生姓名"
          class="search-input"
          clearable
          @input="handleSearch"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
      </div>
    </div>

    <!-- 论文列表 -->
    <el-card class="table-card">
      <el-table 
        :data="filteredThesisList" 
        border 
        stripe
        style="width: 100%"
        v-loading="loading"
      >
        <el-table-column prop="student_id" label="学号" width="120" align="center" />
        <el-table-column prop="student_name" label="学生姓名" width="120" align="center" />
        <el-table-column prop="title" label="论文标题" min-width="200" show-overflow-tooltip />
        <el-table-column 
          label="指导教师" 
          width="120" 
          align="center"
        >
          <template #default="scope">
            <div class="advisor-info">
              <span class="advisor-name">{{ scope.row.teacher_name }}</span>
              <el-tag 
                size="small" 
                :type="getTeacherTitleType(scope.row.teacher_title)"
                class="ml-2"
              >
                {{ scope.row.teacher_title || '无职称' }}
              </el-tag>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="submit_time" label="提交时间" width="180" align="center">
          <template #default="scope">
            {{ formatDate(scope.row.submit_time) }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="120" align="center">
          <template #default="scope">
            <el-tag :type="getThesisStatusType(scope.row.status)">
              {{ getStatusText(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="评阅分配" width="120" align="center">
          <template #default="scope">
            <el-tag 
              :type="getAssignmentStatus(scope.row).type"
              size="small"
            >
              {{ getAssignmentStatus(scope.row).text }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right" align="center">
          <template #default="scope">
            <el-tooltip
              :content="getOperationTooltip(scope.row.status)"
              placement="top"
            >
              <div class="operation-buttons">
                <el-button 
                  type="primary" 
                  size="small"
                  @click="handleAssign(scope.row)"
                  :disabled="!canAssign(scope.row.status)"
                >
                  分配评阅
                </el-button>
                <el-button 
                  type="info" 
                  size="small"
                  @click="handleViewAssignment(scope.row)"
                  v-if="scope.row.review_assigned_count > 0"
                >
                  查看分配
                </el-button>
              </div>
            </el-tooltip>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 30, 50]"
          layout="total, sizes, prev, pager, next, jumper"
          :total="totalTheses"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 分配评阅人对话框 -->
    <el-dialog 
      v-model="dialogVisible" 
      title="分配论文评阅" 
      width="650px"
      destroy-on-close
    >
      <el-alert
        title="提示"
        type="warning"
        description="评阅人分配提交后将无法修改，请仔细确认！"
        show-icon
        :closable="false"
        style="margin-bottom: 20px;"
      />

      <el-descriptions :column="1" border>
        <el-descriptions-item label="论文标题">
          {{ currentThesis?.title }}
        </el-descriptions-item>
        <el-descriptions-item label="学生姓名">
          {{ currentThesis?.student_name }}
        </el-descriptions-item>
        <el-descriptions-item label="指导教师">
          {{ currentThesis?.teacher_name }} ({{ currentThesis?.teacher_title }})
        </el-descriptions-item>
      </el-descriptions>

      <div class="divider">评阅人分配</div>

      <el-form :model="assignForm" :rules="rules" ref="assignFormRef" label-width="120px">
        <!-- 导师评阅（自动填充且不可编辑） -->
        <el-form-item 
          label="导师评阅"
          prop="advisor_reviewer"
          :rules="[{ required: true, message: '导师评阅人不能为空' }]"
        >
          <el-input
            :value="currentThesis?.teacher_name"
            disabled
            class="reviewer-input"
          >
            <template #append>
              <span class="teacher-title">{{ currentThesis?.teacher_title }}</span>
            </template>
          </el-input>
          <input type="hidden" v-model="assignForm.advisor_reviewer" />
        </el-form-item>

        <!-- 同行评阅人选择 -->
        <template v-for="(_, index) in 3" :key="index">
          <el-form-item
            :label="`同行评阅${index + 1}`"
            :prop="`peer_reviewers.${index}`"
            :rules="[
              { required: true, message: '请选择评阅人', trigger: 'change' },
              { validator: validateReviewer, trigger: 'change' }
            ]"
          >
            <el-select 
              v-model="assignForm.peer_reviewers[index]"
              placeholder="请选择评阅人"
              class="reviewer-input"
              filterable
            >
              <div v-if="loading" class="no-data">
                加载中...
              </div>
              <div v-else-if="!availableReviewers.length" class="no-data">
                暂无可选评阅人
              </div>
              
              <el-option
                v-for="teacher in availableReviewers"
                :key="teacher.user_id"
                :label="`${teacher.name} (${teacher.title || '无职称'})`"
                :value="teacher.user_id"
                :disabled="isReviewerSelected(teacher.user_id, index) || teacher.user_id === currentThesis?.teacher_id"
              >
                <div class="reviewer-option">
                  <span>{{ teacher.name }} ({{ teacher.title || '无职称' }})</span>
                  <small class="research-area">研究方向: {{ teacher.research_area || '未设置' }}</small>
                </div>
              </el-option>
            </el-select>
          </el-form-item>
        </template>
      </el-form>

      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitAssignment" :loading="submitting">
            确认分配
          </el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 查看分配信息的对话框 -->
    <el-dialog
      v-model="viewDialogVisible"
      title="查看评阅分配"
      width="650px"
      destroy-on-close
    >
      <div v-loading="loading">
        <!-- 论文基本信息 -->
        <el-descriptions :column="1" border>
          <el-descriptions-item label="论文标题">
            {{ currentThesis?.title }}
          </el-descriptions-item>
          <el-descriptions-item label="学生姓名">
            {{ currentThesis?.student_name }}
          </el-descriptions-item>
        </el-descriptions>

        <!-- 评阅分配信息 -->
        <div class="section-title">评阅分配信息</div>
        
        <!-- 导师评阅 -->
        <template v-if="assignmentInfo.length > 0">
          <el-descriptions v-if="advisorReviewer" :column="1" border class="mt-4">
            <el-descriptions-item label="导师评阅">
              <div class="reviewer-info-box">
                <div class="reviewer-main">
                  <span class="reviewer-name">{{ advisorReviewer.reviewer_name }}</span>
                  <el-tag 
                    size="small" 
                    :type="getTeacherTitleType(advisorReviewer.reviewer_title)"
                    class="ml-2"
                  >
                    {{ advisorReviewer.reviewer_title || '无职称' }}
                  </el-tag>
                </div>
                <div class="reviewer-detail">
                  <div class="research-area" v-if="advisorReviewer.research_area">
                    研究方向: {{ advisorReviewer.research_area }}
                  </div>
                  <div class="review-status">
                    <el-tag 
                      :type="getReviewStatusType(advisorReviewer.status)" 
                      size="small"
                      effect="light"
                    >
                      {{ getReviewStatusText(advisorReviewer.status) }}
                    </el-tag>
                    <span class="assign-time">
                      分配时间: {{ formatDate(advisorReviewer.assigned_at) }}
                    </span>
                  </div>
                </div>
              </div>
            </el-descriptions-item>
          </el-descriptions>

          <!-- 同行评阅 -->
          <template v-if="peerReviewers.length">
            <el-descriptions 
              v-for="(reviewer, index) in peerReviewers" 
              :key="reviewer.reviewer_id"
              :column="1" 
              border 
              class="mt-4"
            >
              <el-descriptions-item :label="`同行评阅 ${index + 1}`">
                <div class="reviewer-info-box">
                  <div class="reviewer-main">
                    <span class="reviewer-name">{{ reviewer.reviewer_name }}</span>
                    <el-tag 
                      size="small" 
                      :type="getTeacherTitleType(reviewer.reviewer_title)"
                      class="ml-2"
                    >
                      {{ reviewer.reviewer_title || '无职称' }}
                    </el-tag>
                  </div>
                  <div class="reviewer-detail">
                    <div class="research-area" v-if="reviewer.research_area">
                      研究方向: {{ reviewer.research_area }}
                    </div>
                    <div class="review-status">
                      <el-tag 
                        :type="getReviewStatusType(reviewer.status)" 
                        size="small"
                        effect="light"
                      >
                        {{ getReviewStatusText(reviewer.status) }}
                      </el-tag>
                      <span class="assign-time">
                        分配时间: {{ formatDate(reviewer.assigned_at) }}
                      </span>
                    </div>
                  </div>
                </div>
              </el-descriptions-item>
            </el-descriptions>
          </template>
        </template>

        <!-- 无数据显示 -->
        <el-empty 
          v-if="!assignmentInfo.length"
          description="暂无评阅分配信息"
        />
      </div>

      <template #footer>
        <span class="dialog-footer">
          <el-button @click="viewDialogVisible = false">关闭</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ElMessage, type FormInstance, ElMessageBox } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import request from '@/utils/request'
import { useUserStore } from '@/stores/user'
import dayjs from 'dayjs'

const userStore = useUserStore()
const thesisList = ref([])
const dialogVisible = ref(false)
const currentThesis = ref<any>(null)
const availableReviewers = ref([])
const assignForm = ref({
  advisor_reviewer: '',
  peer_reviewers: ['', '', '']
})

const loading = ref(false)
const submitting = ref(false)
const searchQuery = ref('')
const currentPage = ref(1)
const pageSize = ref(10)
const totalTheses = ref(0)
const assignFormRef = ref<FormInstance>()

const rules = {
  peer_reviewers: [
    { required: true, message: '请选择评阅人', trigger: 'change' }
  ]
}

// 格式化日期
const formatDate = (date: string) => {
  return dayjs(date).format('YYYY-MM-DD HH:mm')
}

// 过滤论文列表
const filteredThesisList = computed(() => {
  if (!searchQuery.value) return thesisList.value
  const query = searchQuery.value.toLowerCase()
  return thesisList.value.filter(thesis => 
    thesis.title.toLowerCase().includes(query) ||
    thesis.student_name.toLowerCase().includes(query)
  )
})

// 验证评阅人选择
const validateReviewer = (rule: any, value: string, callback: any) => {
  if (!value) {
    callback(new Error('请选择评阅人'))
  } else if (assignForm.value.peer_reviewers.filter(v => v === value).length > 1) {
    callback(new Error('同一评阅人不能重复选择'))
  } else if (value === currentThesis.value?.teacher_id) {
    callback(new Error('不能选择论文指导教师作为同行评阅人'))
  } else {
    callback()
  }
}

// 检查评阅人是否已被选择
const isReviewerSelected = (reviewerId: string, currentIndex: number) => {
  return assignForm.value.peer_reviewers.some(
    (id, index) => id === reviewerId && index !== currentIndex
  )
}

// 获取评阅分配状态
const getAssignmentStatus = (thesis: any) => {
  if (thesis.review_assigned_count === 4) {
    return { type: 'success', text: '已分配完成' }
  } else if (thesis.review_assigned_count > 0) {
    return { type: 'warning', text: '部分分配' }
  }
  return { type: 'info', text: '未分配' }
}

// 提交分配
const submitAssignment = async () => {
  if (!assignFormRef.value) return
  
  await assignFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        // 添加确认对话框
        await ElMessageBox.confirm(
          '评阅人分配提交后将无法修改，是否确认提交？',
          '确认提交',
          {
            confirmButtonText: '确认',
            cancelButtonText: '取消',
            type: 'warning'
          }
        )
        
        submitting.value = true
        await request.post('/thesis-review-assignment/assign', {
          thesis_id: currentThesis.value.id,
          advisor_reviewer: assignForm.value.advisor_reviewer,
          peer_reviewer_ids: assignForm.value.peer_reviewers
        })
        ElMessage.success('分配成功')
        dialogVisible.value = false
        getThesisList()
      } catch (error) {
        if (error !== 'cancel') {
          console.error('分配失败:', error)
          ElMessage.error('分配评阅人失败')
        }
      } finally {
        submitting.value = false
      }
    }
  })
}

// 分页处理
const handleSizeChange = (val: number) => {
  pageSize.value = val
  getThesisList()
}

const handleCurrentChange = (val: number) => {
  currentPage.value = val
  getThesisList()
}

// 获取论文列表
const getThesisList = async () => {
  try {
    loading.value = true
    const res = await request.get('/thesis-review-assignment/list')
    console.log('获取到的论文列表数据:', res.data)
    if (res.code === 200) {
      thesisList.value = res.data.map(thesis => ({
        ...thesis,
        // 直接使用teacher_name和teacher_title
        advisor_display_name: thesis.teacher_name,
        advisor_display_title: thesis.teacher_title
      }))
    }
  } catch (error) {
    console.error('获取论文列表失败:', error)
    ElMessage.error('获取论文列表失败')
  } finally {
    loading.value = false
  }
}

// 定义类型
interface Reviewer {
  user_id: string
  name: string
  title: string
  department: string
  research_area: string | null
}

interface ApiResponse {
  code: number
  data: Reviewer[]
  message: string
}

// 修改获取评阅人列表的方法
const getAvailableReviewers = async () => {
  try {
    loading.value = true
    const response = await request.get('/thesis-review-assignment/available-reviewers')
    console.log('API响应数据:', response) // 添加日志

    // 检查响应数据结构
    if (response && response.data && Array.isArray(response.data)) {
      availableReviewers.value = response.data
    } else if (response && response.data && Array.isArray(response.data.data)) {
      availableReviewers.value = response.data.data
    } else {
      console.error('响应数据格式不正确:', response)
      throw new Error('数据格式不正确')
    }

    console.log('处理后的评阅人列表:', availableReviewers.value)
  } catch (error) {
    console.error('获取评阅教师列表失败:', error)
    ElMessage.error('获取评阅教师列表失败')
    availableReviewers.value = [] // 确保发生错误时设置为空数组
  } finally {
    loading.value = false
  }
}

// 修改打开对话框的方法
const handleAssign = async (thesis: any) => {
  if (!canAssign(thesis.status)) {
    ElMessage.warning('只有导师通过的论文才能分配评阅人')
    return
  }
  
  currentThesis.value = thesis
  // 设置导师评阅人ID
  assignForm.value.advisor_reviewer = thesis.teacher_id || ''
  dialogVisible.value = true
  
  await getAvailableReviewers()
}

// 状态判断
const canAssign = (status: string) => {
  return status === 'advisor_approved'
}

// 论文状态相关函数
const getThesisStatusType = (status: string) => {
  const statusMap = {
    submitted: 'info',
    advisor_reviewing: 'warning',
    advisor_rejected: 'danger',
    advisor_approved: 'success',
    review_assigned: 'primary',
    reviewing: 'warning',
    completed: 'success',
    revision_needed: 'danger'
  }
  return statusMap[status] || 'info'
}

// 获取职称标签类型
const getTeacherTitleType = (title: string) => {
  const titleTypes = {
    '教授': 'success',
    '副教授': 'warning',
    '讲师': 'info',
    '助教': ''  // 默认灰色
  }
  return titleTypes[title] || ''
}

// 修改评阅状态标签类型
const getReviewStatusType = (status: string) => {
  const statusTypes = {
    'pending': 'info',      // 待评阅 - 蓝灰色
    'in_progress': 'warning', // 评阅中 - 黄色
    'completed': 'success',   // 已完成 - 绿色
    'rejected': 'danger'      // 已拒绝 - 红色
  }
  return statusTypes[status] || ''
}

// 状态文本
const getStatusText = (status: string) => {
  const statusMap = {
    submitted: '已提交',
    advisor_reviewing: '导师审核中',
    advisor_rejected: '导师驳回',
    advisor_approved: '导师通过',
    review_assigned: '已分配评阅',
    reviewing: '评阅中',
    completed: '已完成',
    revision_needed: '需修改'
  }
  return statusMap[status] || status
}

const getOperationTooltip = (status: string) => {
  if (status === 'advisor_approved') {
    return '可以分配评阅人'
  } else if (status === 'submitted') {
    return '等待导师审核'
  } else if (status === 'advisor_reviewing') {
    return '导师正在审核中'
  } else if (status === 'advisor_rejected') {
    return '论文被导师驳回'
  } else if (status === 'review_assigned') {
    return '已分配评阅人'
  } else if (status === 'reviewing') {
    return '评阅进行中'
  } else if (status === 'completed') {
    return '评阅已完成'
  } else if (status === 'revision_needed') {
    return '需要修改论文'
  }
  return '当前状态不可分配评阅人'
}

// 查看分配信息
const viewDialogVisible = ref(false)
const assignmentInfo = ref<any[]>([])

// 获取评阅分配信息
const handleViewAssignment = async (thesis: any) => {
  loading.value = true
  viewDialogVisible.value = true
  currentThesis.value = thesis  // 先设置当前论文信息
  
  try {
    const response = await request.get(`/thesis-review-assignment/info/${thesis.id}`)
    console.log('获取到的评阅分配信息:', response)
    
    // 修改判断条件，直接检查 response 的 code
    if (response.code === 200 && response.data) {
      const responseData = response.data
      
      // 更新论文基本信息
      currentThesis.value = {
        ...thesis,  // 保留原有信息
        title: responseData.thesis_title,
        student_name: responseData.student_name
      }
      
      // 直接设置评阅分配信息
      assignmentInfo.value = responseData.assignments || []
      
      // 打印检查
      console.log('设置后的 assignmentInfo:', assignmentInfo.value)
      console.log('导师评阅信息:', advisorReviewer.value)
      console.log('同行评阅信息:', peerReviewers.value)
    }

  } catch (error) {
    console.error('获取评阅分配信息失败:', error)
    ElMessage.error('获取评阅分配信息失败')
    assignmentInfo.value = []
  } finally {
    loading.value = false
  }
}

// 修改计算属性的定义
const advisorReviewer = computed(() => {
  const reviewer = assignmentInfo.value?.find(r => r.review_type === 'advisor')
  console.log('计算属性 advisorReviewer:', reviewer)
  return reviewer
})

const peerReviewers = computed(() => {
  const reviewers = assignmentInfo.value?.filter(r => r.review_type === 'peer') || []
  console.log('计算属性 peerReviewers:', reviewers)
  return reviewers
})

// 评阅状态文本映射
const getReviewStatusText = (status: string) => {
  const texts = {
    'pending': '待评阅',
    'in_progress': '评阅中',
    'completed': '已完成',
    'rejected': '已拒绝'
  }
  return texts[status] || '未知状态'
}

onMounted(() => {
  getThesisList()
})
</script>

<style scoped>
.review-assignment {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.search-section {
  display: flex;
  gap: 16px;
}

.search-input {
  width: 300px;
}

.table-card {
  margin-bottom: 20px;
  border-radius: 8px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.divider {
  font-size: 16px;
  font-weight: bold;
  margin: 20px 0;
  padding-bottom: 10px;
  border-bottom: 1px solid var(--el-border-color-light);
}

.reviewer-input {
  width: 100%;
}

:deep(.el-descriptions) {
  margin-bottom: 20px;
  .el-descriptions__label {
    font-weight: bold;
    color: var(--el-text-color-primary);
  }
  .el-descriptions__content {
    color: var(--el-text-color-regular);
  }
}

:deep(.el-table) {
  border-radius: 8px;
  overflow: hidden;
  
  .el-table__header th {
    background-color: var(--el-fill-color-light);
    font-weight: bold;
  }
}

:deep(.el-dialog) {
  border-radius: 8px;
  
  .el-dialog__header {
    margin-bottom: 20px;
    border-bottom: 1px solid var(--el-border-color-light);
    padding-bottom: 20px;
  }
  
  .el-dialog__footer {
    border-top: 1px solid var(--el-border-color-light);
    padding-top: 20px;
  }
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.reviewer-option {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.research-area {
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

:deep(.el-select-dropdown__item) {
  padding: 8px 12px;
}

.no-data {
  padding: 8px 12px;
  color: var(--el-text-color-secondary);
  text-align: center;
}

.operation-buttons {
  display: flex;
  gap: 8px;
  justify-content: center;
}

.reviewer-info {
  margin-top: 4px;
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.reviewer-status {
  margin-top: 8px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.assign-time {
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

.ml-2 {
  margin-left: 8px;
}

.section-title {
  margin: 20px 0 12px;
  font-weight: bold;
  color: var(--el-text-color-primary);
  font-size: 16px;
}

.reviewer-info-box {
  padding: 8px 0;
}

.reviewer-main {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.reviewer-name {
  font-weight: 500;
  font-size: 14px;
}

.reviewer-detail {
  font-size: 13px;
}

.research-area {
  color: var(--el-text-color-secondary);
  margin-bottom: 8px;
}

.review-status {
  display: flex;
  align-items: center;
  gap: 12px;
}

.assign-time {
  color: var(--el-text-color-secondary);
}

.mt-4 {
  margin-top: 16px;
}

.ml-2 {
  margin-left: 8px;
}

:deep(.el-descriptions__cell) {
  padding: 16px !important;
}

:deep(.el-tag) {
  border-radius: 4px;
}

:deep(.el-tag--light) {
  border: 1px solid transparent;
}

.review-status {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-top: 8px;
}

.assign-time {
  color: var(--el-text-color-secondary);
  font-size: 13px;
}
</style> 