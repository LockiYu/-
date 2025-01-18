<template>
  <div class="app-container">

    <!-- 原有的状态卡片 -->
    <el-card class="status-card" v-if="selectedTopic">
      <template #header>
        <div class="card-header">
          <span>我的选题状态</span>
          <div class="status-tags">
            <el-tag :type="getStatusType(selectedTopic.final_status)">
              {{ getStatusText(selectedTopic.final_status) }}
            </el-tag>
            <el-tag 
              class="ml-2" 
              :type="getDetailedStatusType(selectedTopic)"
            >
              {{ getDetailedStatus(selectedTopic) }}
            </el-tag>
            <el-button
              v-if="canCancelSelection"
              type="danger"
              size="small"
              class="ml-2"
              @click="handleCancelSelection"
            >
              取消选题
            </el-button>
          </div>
        </div>
      </template>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="论文题目">
          {{ selectedTopic.title }}
        </el-descriptions-item>
        <el-descriptions-item label="指导教师">
          {{ selectedTopic.teacherName }}
        </el-descriptions-item>
        <el-descriptions-item label="题目类型">
          {{ selectedTopic.type }}
        </el-descriptions-item>
        <el-descriptions-item label="题目来源">
          {{ selectedTopic.source }}
        </el-descriptions-item>
        <el-descriptions-item label="教师审核状态">
          <el-tag :type="getStatusType(selectedTopic.teacher_approval_status)">
            {{ getStatusText(selectedTopic.teacher_approval_status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="主任审核状态" v-if="selectedTopic.teacher_approval_status === 'approved'">
          <el-tag :type="getStatusType(selectedTopic.director_approval_status)">
            {{ getStatusText(selectedTopic.director_approval_status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="申请时间">
          {{ formatDate(selectedTopic.created_at) }}
        </el-descriptions-item>
        <el-descriptions-item label="最后更新时间">
          {{ formatDate(selectedTopic.updated_at) }}
        </el-descriptions-item>
        <el-descriptions-item label="主任审核时间" v-if="selectedTopic.director_approval_time">
          {{ formatDate(selectedTopic.director_approval_time) }}
        </el-descriptions-item>
        <el-descriptions-item label="题目描述" :span="2">
          {{ selectedTopic.description }}
        </el-descriptions-item>
        <el-descriptions-item label="专业要求" :span="2">
          {{ selectedTopic.major_requirements }}
        </el-descriptions-item>
        <el-descriptions-item label="学生要求" :span="2">
          {{ selectedTopic.student_requirements }}
        </el-descriptions-item>
      </el-descriptions>
    </el-card>

    <!-- 可选题目列表 -->
    <el-card>
      <template #header>
        <div class="card-header">
          <span>可选题目列表</span>
          <div>
            <el-tag type="info">共{{ total }}个题目</el-tag>
            <el-tag v-if="selectedTopic && selectedTopic.status === 'pending'" 
                    type="warning" 
                    class="ml-2">
              您已有选题，仅供查看
            </el-tag>
          </div>
        </div>
      </template>

      <!-- 搜索栏 -->
      <div class="filter-container">
        <el-form :inline="true">
          <el-form-item label="题目">
            <el-input
              v-model="queryParams.title"
              placeholder="请输入题目关键词"
              clearable
              @keyup.enter="handleQuery"
            />
          </el-form-item>
          <el-form-item label="教师">
            <el-input
              v-model="queryParams.teacherName"
              placeholder="请输入教师姓名"
              clearable
              @keyup.enter="handleQuery"
            />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleQuery">查询</el-button>
            <el-button @click="resetQuery">重置</el-button>
            <el-button 
              :type="sortByCount ? 'success' : 'default'" 
              @click="toggleSort"
            >
              {{ sortByCount ? '已按选题人数排序' : '按选题人数排序' }}
            </el-button>
          </el-form-item>
        </el-form>
      </div>

      <!-- 题目列表 -->
      <el-table v-loading="loading" :data="topicList" border style="width: 100%" @row-click="row => console.log('点击行:', row)">
        <el-table-column prop="title" label="论文题目" min-width="200" show-overflow-tooltip />
        <el-table-column prop="teacherName" label="指导教师" width="120">
          <template #default="{ row }">
            {{ row.teacherName }}
            <el-tag size="small" type="info">{{ row.teacherTitle }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="type" label="题目类型" width="120" />
        <el-table-column prop="source" label="题目来源" width="120" />
        <el-table-column label="要求" min-width="200">
          <template #default="{ row }">
            <el-popover
              placement="top-start"
              title="详细要求"
              :width="400"
              trigger="hover"
              :content="getRequirements(row)"
            >
              <template #reference>
                <el-button link type="primary">查看要求</el-button>
              </template>
            </el-popover>
          </template>
        </el-table-column>
        <el-table-column 
          prop="selectedCount" 
          label="已选人数" 
          width="100"
          align="center"
        >
          <template #default="{ row }">
            <el-popover
              placement="top"
              trigger="hover"
              :width="200"
              v-if="row.selectedCount > 0"
            >
              <template #reference>
                <span class="clickable-count">{{ row.selectedCount }}</span>
              </template>
              <div class="applicants-list">
                <h4>申请学生学号：</h4>
                <ul>
                  <li v-for="id in row.applicantIds" :key="id">{{ id }}</li>
                </ul>
              </div>
            </el-popover>
            <span v-else>{{ row.selectedCount }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button 
              v-if="canSelect(row)"
              type="primary" 
              link 
              @click="handleSelect(row)"
            >
              申请选题
            </el-button>
            <el-tag 
              v-else-if="isRejected(row)" 
              type="danger" 
              size="small"
            >
              已被拒绝
            </el-tag>
            <el-tag 
              v-else-if="isPending(row)" 
              type="warning" 
              size="small"
            >
              审核中
            </el-tag>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="queryParams.pageNum"
          v-model:page-size="queryParams.pageSize"
          :page-sizes="[10, 20, 30, 50]"
          :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 选题申请对话框 -->
    <el-dialog
      v-model="selectDialogVisible"
      title="选题申请"
      width="600px"
      append-to-body
    >
      <el-form
        ref="selectFormRef"
        :model="selectForm"
        :rules="selectFormRules"
        label-width="100px"
      >
        <el-form-item label="论文题目">
          <div>{{ currentTopic?.title }}</div>
        </el-form-item>
        <el-form-item label="指导教师">
          <div>{{ currentTopic?.teacherName }}</div>
        </el-form-item>
        <el-form-item label="专业要求">
          <div>{{ currentTopic?.major_requirements }}</div>
        </el-form-item>
        <el-form-item label="学生要求">
          <div>{{ currentTopic?.student_requirements }}</div>
        </el-form-item>
        <el-form-item label="申请理由" prop="reason">
          <el-input
            v-model="selectForm.reason"
            type="textarea"
            rows="4"
            placeholder="请简要说明选择该题目的理由"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="selectDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitSelection">提交申请</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 历史申请记录卡片 -->
    <el-card class="mb-4">
      <template #header>
        <div class="card-header">
          <span>历史申请记录</span>
          <el-tag type="info">共 {{ rejectedSelections.length }} 条记录</el-tag>
        </div>
      </template>
      
      <!-- 移除 v-if 条件，始终显示表格 -->
      <el-table 
        v-loading="loadingRejected"
        :data="rejectedSelections" 
        style="width: 100%"
      >
        <el-table-column prop="topic_title" label="论文题目" min-width="200" show-overflow-tooltip />
        <el-table-column prop="teacher_name" label="指导教师" width="120" />
        <el-table-column prop="student_reason" label="申请理由" min-width="200" show-overflow-tooltip />
        <el-table-column label="拒绝原因" min-width="200" show-overflow-tooltip>
          <template #default="{ row }">
            <div v-if="row.teacher_reject_reason">
              <strong>教师：</strong>{{ row.teacher_reject_reason }}
            </div>
            <div v-if="row.director_reject_reason">
              <strong>系主任：</strong>{{ row.director_reject_reason }}
            </div>
            <span v-if="!row.teacher_reject_reason && !row.director_reject_reason">
              暂无拒绝原因
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="申请时间" width="180">
          <template #default="{ row }">
            {{ formatDate(row.created_at) }}
          </template>
        </el-table-column>
      </el-table>
      
      <!-- 添加空数据提示 -->
      <el-empty 
        v-if="!loadingRejected && rejectedSelections.length === 0"
        description="暂无历史申请记录"
      />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox, ElLoading, FormInstance, FormRules } from 'element-plus'
import request from '@/utils/request'
import { formatDate } from '@/utils/format'

// 添加新的引用
const mySelectionRef = ref()
const currentSelection = ref(null)

// 添加排序相关的状态和方法
const sortByCount = ref(false)

// 查询参数增加排序字段
const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  title: '',
  teacherName: '',
  sortByCount: false
})

// 数据列表
const loading = ref(false)
const total = ref(0)
const topicList = ref([])
const selectedTopic = ref(null)

// 选题表单
const selectDialogVisible = ref(false)
const selectFormRef = ref<FormInstance>()
const currentTopic = ref<any>(null)
const selectForm = reactive({
  topicId: '',
  reason: ''
})

// 表单验证规则
const selectFormRules = reactive<FormRules>({
  reason: [
    { required: true, message: '请输入申请理由', trigger: 'blur' },
    { min: 10, message: '申请理由不能少于10个字符', trigger: 'blur' }
  ]
})

// 状态映射
const getStatusType = (status: string) => {
  const statusMap: Record<string, string> = {
    'pending': 'warning',
    'approved': 'success', 
    'rejected': 'danger'
  }
  return statusMap[status] || 'info'
}

const getStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    'pending': '审核中',
    'approved': '已通过',
    'rejected': '已拒绝'
  }
  return statusMap[status] || status
}

// 详细状态类型映射函数
const getDetailedStatusType = (selection: any) => {
  if (selection.teacher_approval_status === 'rejected') {
    return 'danger'
  }
  if (selection.teacher_approval_status === 'pending') {
    return 'warning'
  }
  if (selection.teacher_approval_status === 'approved' && 
      selection.director_approval_status === 'pending') {
    return 'warning'
  }
  if (selection.director_approval_status === 'rejected') {
    return 'danger'
  }
  if (selection.director_approval_status === 'approved') {
    return 'success'
  }
  return 'warning'
}

// 获取详细审核状态文本
const getDetailedStatus = (selection: any) => {
  if (selection.teacher_approval_status === 'rejected') {
    return '教师已拒绝'
  }
  if (selection.teacher_approval_status === 'pending') {
    return '等待教师审核'
  }
  if (selection.teacher_approval_status === 'approved' && 
      selection.director_approval_status === 'pending') {
    return '教师已通过,等待主任审核'
  }
  if (selection.director_approval_status === 'rejected') {
    return '主任已拒绝'
  }
  if (selection.director_approval_status === 'approved') {
    return '审核通过'
  }
  return '审核中'
}

// API请求方法
const getTopicList = async () => {
  try {
    loading.value = true
    const res = await request.get('/selections/available', {
      params: queryParams.value
    })
    if (res.code === 200) {
      topicList.value = res.data.list
      total.value = res.data.total
    }
  } catch (error) {
    console.error('获取题目列表失败:', error)
    ElMessage.error('获取题目列表失败')
  } finally {
    loading.value = false
  }
}

const getCurrentSelection = async () => {
  try {
    const res = await request.get('/selections/current')
    if (res.code === 200) {
      selectedTopic.value = res.data
    } else {
      throw new Error(res.message)
    }
  } catch (error: any) {
    console.error('获取当前选题失败:', error)
    ElMessage.error(error.message || '获取当前选题失败')
  }
}

// 处理函数
const handleQuery = () => {
  queryParams.value.pageNum = 1
  getTopicList()
}

const resetQuery = () => {
  queryParams.value = {
    pageNum: 1,
    pageSize: 10,
    title: '',
    teacherName: '',
    sortByCount: false
  }
  getTopicList()
}

const handleSelect = (row: any) => {
  currentTopic.value = row
  selectForm.topicId = row.topic_id
  selectForm.reason = ''
  selectDialogVisible.value = true
}

const submitSelection = async () => {
  if (!selectFormRef.value) return
  
  await selectFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        await request.post('/selections/submit', {
          topic_id: selectForm.topicId,
          reason: selectForm.reason
        })
        ElMessage.success('选题申请提交成功')
        selectDialogVisible.value = false
        // 刷新选题状态
        await getCurrentSelection()
        await getTopicList()
      } catch (error: any) {
        ElMessage.error(error.response?.data?.message || '选题申请提交失败')
      }
    }
  })
}

const handleSizeChange = (val: number) => {
  queryParams.value.pageSize = val
  getTopicList()
}

const handleCurrentChange = (val: number) => {
  queryParams.value.pageNum = val
  getTopicList()
}

// 获取要求文本
const getRequirements = (row: any) => {
  let text = ''
  if (row.major_requirements) {
    text += `专业要求：${row.major_requirements}\n\n`
  }
  if (row.student_requirements) {
    text += `学生要求：${row.student_requirements}`
  }
  return text || '暂无具体要求'
}

// 解析选题详情字符串
const parseSelectionDetails = (details: string) => {
  if (!details) return []
  return details.split('; ').map(item => {
    const [studentId, status] = item.split(': ')
    return { studentId, status }
  })
}

// 切换排序方式
const toggleSort = () => {
  sortByCount.value = !sortByCount.value
  queryParams.value.sortByCount = sortByCount.value
  handleQuery()
}

// 添加选题状态判断方法
const canSelect = (row: any) => {
  if (!currentSelection.value) return true
  if (currentSelection.value.status === '已拒绝') return true
  return false
}

const isRejected = (row: any) => {
  return currentSelection.value?.topic_id === row.topic_id && 
         currentSelection.value?.status === '已拒绝'
}

const isPending = (row: any) => {
  return currentSelection.value?.topic_id === row.topic_id && 
         ['教师审核中', '主任审核中'].includes(currentSelection.value?.status)
}

// 判断是否可以取消选题
const canCancelSelection = computed(() => {
  if (!selectedTopic.value) return false
  
  // 教师未审核或已拒绝时可以取消
  return selectedTopic.value.teacher_approval_status === 'pending' ||
         selectedTopic.value.final_status === 'rejected'
})

// 取消选题处理
const handleCancelSelection = async () => {
  try {
    const loading = ElLoading.service({
      lock: true,
      text: '正在取消选题...',
      background: 'rgba(0, 0, 0, 0.7)',
      timeout: 3000
    })

    try {
      await ElMessageBox.confirm(
        '确定要取消当前选题吗？取消后可重新选择其他题目。',
        '取消选题确认',
        {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }
      )

      const res = await request.delete(`/selections/${selectedTopic.value.selection_id}`)
      
      if (res.code === 200) {
        ElMessage.success('取消选题成功')
        // 直接调用需要的接口
        await getCurrentSelection()
        await getTopicList()
      } else {
        throw new Error(res.message || '取消选题失败')
      }
    } finally {
      loading.close()
    }
  } catch (error: any) {
    if (error === 'cancel' || error.type === 'cancel') {
      return
    }
    console.error('取消选题失败:', error)
    ElMessage.error(error.response?.data?.message || error.message || '取消选题失败')
  }
}

// 提交选题申请
const handleSubmitSelection = async (topic: any) => {
  try {
    const loading = ElLoading.service({
      lock: true,
      text: '正在提交申请...',
      background: 'rgba(0, 0, 0, 0.7)',
      timeout: 3000
    })

    try {
      // 确认对话框
      await ElMessageBox.confirm(
        '确定要申请该选题吗？',
        '申请确认',
        {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }
      )

      // 获取申请理由
      const { value: reason } = await ElMessageBox.prompt(
        '请输入申请理由',
        '申请理由',
        {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          inputType: 'textarea',
          inputPlaceholder: '请详细说明您选择该题目的原因...',
          inputValidator: (value) => {
            if (!value) {
              return '申请理由不能为空'
            }
            if (value.length < 10) {
              return '申请理由至少需要10个字'
            }
            return true
          }
        }
      )

      // 发送申请请求
      const res = await request.post('/selections', {
        topic_id: topic.topic_id,
        reason
      })

      if (res.code === 200) {
        ElMessage.success('选题申请提交成功')
        // 直接调用需要的接口
        await getCurrentSelection()
        await getTopicList()
      } else {
        throw new Error(res.message || '申请失败')
      }
    } finally {
      loading.close()
    }
  } catch (error: any) {
    if (error === 'cancel' || error.type === 'cancel') {
      return
    }
    console.error('选题申请失败:', error)
    ElMessage.error(error.response?.data?.message || error.message || '选题申请失败')
  }
}

// 添加加载状态
const loadingRejected = ref(false)
const rejectedSelections = ref<any[]>([])

// 修改获取被拒绝申请记录的方法
const getRejectedSelections = async () => {
  loadingRejected.value = true
  try {
    const res = await request.get('/selections/rejected')
    if (res.code === 200) {
      rejectedSelections.value = res.data
      console.log('历史申请记录:', res.data) // 添加调试日志
    } else {
      throw new Error(res.message)
    }
  } catch (error) {
    console.error('获取历史申请记录失败:', error)
    ElMessage.error('获取历史申请记录失败')
  } finally {
    loadingRejected.value = false
  }
}

// 组件挂载时分别加载数据
onMounted(async () => {
  try {
    await Promise.all([
      getTopicList(),
      getCurrentSelection(),
      getRejectedSelections() // 确保这个方法被调用
    ])
  } catch (error) {
    console.error('初始化数据失败:', error)
    ElMessage.error('初始化数据失败，请刷新页面重试')
  }
})
</script>

<style scoped>
.app-container {
  padding: 20px;
}

.status-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.filter-container {
  padding-bottom: 20px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.selection-details {
  max-height: 200px;
  overflow-y: auto;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 4px 0;
}

.student-id {
  margin-right: 8px;
}

.ml-2 {
  margin-left: 8px;
}

.status-tags {
  display: flex;
  gap: 8px;
  align-items: center;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
}

.mb-4 {
  margin-bottom: 16px;
}

.selection-info {
  line-height: 1.8;
}

.selection-info p {
  margin: 8px 0;
}

/* 添加表格内容样式 */
:deep(.el-table) {
  margin-top: 10px;
}

:deep(.el-table__empty-text) {
  line-height: 60px;
}

.clickable-count {
  color: #409EFF;
  cursor: pointer;
}

.applicants-list {
  padding: 8px;
}

.applicants-list h4 {
  margin: 0 0 8px 0;
  font-size: 14px;
  color: #606266;
}

.applicants-list ul {
  margin: 0;
  padding-left: 20px;
  list-style: disc;
}

.applicants-list li {
  line-height: 1.8;
  color: #666;
}
</style>