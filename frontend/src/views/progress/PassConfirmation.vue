<template>
  <div class="pass-confirmation-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>论文通过确认</span>
        </div>
      </template>

      <!-- 论文提交列表 -->
      <el-table :data="thesisList" style="width: 100%" v-loading="loading">
        <el-table-column prop="student_name" label="学生姓名" width="120" />
        <el-table-column prop="student_id" label="学号" width="120" />
        <el-table-column prop="thesis_title" label="论文题目" min-width="200" />
        <el-table-column prop="version" label="版本" width="80" />
        <el-table-column prop="submit_time" label="提交时间" width="180">
          <template #default="scope">
            {{ formatDateTime(scope.row.submit_time) }}
          </template>
        </el-table-column>
        <el-table-column prop="advisor_review_status" label="确认状态" width="120">
          <template #default="scope">
            <el-tag :type="getStatusType(scope.row.advisor_review_status)">
              {{ getStatusText(scope.row.advisor_review_status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="250" fixed="right">
          <template #default="scope">
            <!-- 下载按钮 -->
            <el-button 
              type="primary" 
              link 
              @click="downloadFile(scope.row)"
              :disabled="!scope.row.file_url"
            >
              <el-icon><Download /></el-icon>
              下载论文
            </el-button>

            <!-- 确认/查看按钮 -->
            <el-button 
              type="success" 
              link 
              @click="handleConfirm(scope.row)"
              v-if="scope.row.advisor_review_status === 'pending'"
            >
              <el-icon><CircleCheck /></el-icon>
              确认
            </el-button>
            <el-button 
              type="info" 
              link 
              @click="viewDetails(scope.row)"
              v-else
            >
              <el-icon><View /></el-icon>
              查看
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 确认对话框 -->
      <el-dialog 
        v-model="dialogVisible" 
        title="论文确认" 
        width="50%"
        :close-on-click-modal="false"
      >
        <el-form 
          ref="confirmFormRef"
          :model="confirmForm"
          :rules="formRules"
          label-width="100px"
        >
          <el-form-item label="确认结果" prop="advisor_review_status">
            <el-radio-group v-model="confirmForm.advisor_review_status">
              <el-radio label="approved">通过</el-radio>
              <el-radio label="rejected">不通过</el-radio>
            </el-radio-group>
          </el-form-item>

          <el-form-item label="确认意见" prop="advisor_comments">
            <el-input
              v-model="confirmForm.advisor_comments"
              type="textarea"
              :rows="4"
              placeholder="请输入确认意见"
            />
          </el-form-item>
        </el-form>

        <template #footer>
          <div class="dialog-footer">
            <el-button @click="dialogVisible = false">取消</el-button>
            <el-button type="primary" @click="submitConfirm">确定</el-button>
          </div>
        </template>
      </el-dialog>

      <!-- 详情对话框 -->
      <el-dialog
        v-model="detailsVisible"
        title="确认详情"
        width="50%"
      >
        <el-descriptions :column="1" border>
          <el-descriptions-item label="学生姓名">
            {{ currentThesis?.student_name }}
          </el-descriptions-item>
          <el-descriptions-item label="学号">
            {{ currentThesis?.student_id }}
          </el-descriptions-item>
          <el-descriptions-item label="论文题目">
            {{ currentThesis?.thesis_title }}
          </el-descriptions-item>
          <el-descriptions-item label="确认结果">
            <el-tag :type="getStatusType(currentThesis?.advisor_review_status)">
              {{ getStatusText(currentThesis?.advisor_review_status) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="确认意见">
            {{ currentThesis?.advisor_comments || '无' }}
          </el-descriptions-item>
          <el-descriptions-item label="确认时间">
            {{ formatDateTime(currentThesis?.advisor_review_time) }}
          </el-descriptions-item>
        </el-descriptions>
      </el-dialog>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { getTeacherThesisConfirmations, updateThesisConfirmation } from '@/api/passConfirmation'
import { formatDateTime } from '@/utils/format'
import { CircleCheck, View, Download } from '@element-plus/icons-vue'

const userStore = useUserStore()
const loading = ref(false)
const thesisList = ref([])
const dialogVisible = ref(false)
const detailsVisible = ref(false)
const currentThesis = ref(null)
const confirmFormRef = ref()
const currentConfirmId = ref<number | null>(null)

// 表单数据
const confirmForm = ref({
  advisor_review_status: 'approved',
  advisor_comments: ''
})

// 表单验证规则
const formRules = {
  advisor_review_status: [{ required: true, message: '请选择确认结果', trigger: 'change' }],
  advisor_comments: [{ required: true, message: '请输入确认意见', trigger: 'blur' }]
}

// 获取论文列表
const getThesisList = async () => {
  try {
    loading.value = true
    const { data } = await getTeacherThesisConfirmations(userStore.userInfo.userId)
    thesisList.value = data
  } catch (error) {
    console.error('获取论文列表失败:', error)
    ElMessage.error('获取论文列表失败')
  } finally {
    loading.value = false
  }
}

// 下载文件
const downloadFile = (row: any) => {
  if (row.file_url) {
    window.open(`http://localhost:3001/${row.file_url}`, '_blank')
  }
}

// 处理确认
const handleConfirm = (row: any) => {
  currentConfirmId.value = row.id
  dialogVisible.value = true
  confirmForm.value = {
    advisor_review_status: 'approved',
    advisor_comments: ''
  }
}

// 查看详情
const viewDetails = (row: any) => {
  currentThesis.value = row
  detailsVisible.value = true
}

// 提交确认
const submitConfirm = async () => {
  if (!confirmFormRef.value || !currentConfirmId.value) return
  
  try {
    await confirmFormRef.value.validate()
    await updateThesisConfirmation(currentConfirmId.value, confirmForm.value)
    ElMessage.success('确认提交成功')
    dialogVisible.value = false
    getThesisList()
  } catch (error) {
    console.error('提交确认失败:', error)
    ElMessage.error('提交确认失败')
  }
}

// 获取确认状态文本
const getStatusText = (status: string) => {
  const statusMap = {
    'pending': '待确认',
    'reviewing': '确认中',
    'approved': '已通过',
    'rejected': '未通过'
  }
  return statusMap[status] || '未知状态'
}

// 获取确认状态类型
const getStatusType = (status: string) => {
  const typeMap = {
    'pending': 'warning',
    'reviewing': 'info',
    'approved': 'success',
    'rejected': 'danger'
  }
  return typeMap[status] || 'info'
}

onMounted(() => {
  getThesisList()
})
</script>

<style scoped>
.pass-confirmation-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}
</style>