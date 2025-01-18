<template>
  <div class="midterm-review-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>中期检查评阅</span>
        </div>
      </template>

      <!-- 中期报告列表 -->
      <el-table :data="midtermList" style="width: 100%" v-loading="loading">
        <el-table-column prop="student_name" label="学生姓名" width="120" />
        <el-table-column prop="student_id" label="学号" width="120" />
        <el-table-column prop="submit_time" label="提交时间" width="180">
          <template #default="scope">
            {{ formatDateTime(scope.row.submit_time) }}
          </template>
        </el-table-column>
        <el-table-column prop="version" label="版本" width="80" />
        <el-table-column prop="status" label="状态" width="120">
          <template #default="scope">
            <el-tag :type="getStatusType(scope.row.status)">
              {{ getStatusText(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="total_score" label="分数" width="100">
          <template #default="scope">
            {{ scope.row.total_score || scope.row.score || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="scope">
            <!-- 下载按钮 -->
            <el-button 
              type="primary" 
              link 
              @click="downloadFile(scope.row)"
              :disabled="!scope.row.file_url"
            >
              <el-icon><Download /></el-icon>
              下载文件
            </el-button>

            <!-- 评阅/查看按钮 -->
            <template v-if="scope.row.status === 'pending' || scope.row.status === 'reviewing'">
              <el-button 
                type="success" 
                link 
                @click="handleReview(scope.row)"
              >
                <el-icon><Edit /></el-icon>
                评阅
              </el-button>
            </template>
            <template v-else-if="scope.row.status === 'completed'">
              <el-button 
                type="info" 
                link 
                @click="viewReview(scope.row)"
              >
                <el-icon><View /></el-icon>
                查看评阅
              </el-button>
            </template>
            <template v-else-if="scope.row.status === 'revision_needed'">
              <el-button 
                type="warning" 
                link 
                @click="handleReview(scope.row)"
              >
                <el-icon><Edit /></el-icon>
                重新评阅
              </el-button>
            </template>
          </template>
        </el-table-column>
      </el-table>

      <!-- 评阅对话框 -->
      <el-dialog 
        v-model="dialogVisible" 
        title="中期检查评阅" 
        width="70%"
        :close-on-click-modal="false"
      >
        <el-form 
          ref="reviewFormRef"
          :model="reviewForm"
          :rules="formRules"
          label-width="120px"
        >
          <!-- 评审结果 -->
          <el-form-item label="评审结果" prop="status">
            <el-select v-model="reviewForm.status" @change="handleStatusChange">
              <el-option label="需要修改" value="revision_needed" />
              <el-option label="已完成" value="completed" />
            </el-select>
          </el-form-item>

          <!-- 评分项，仅在选择"通过"时显示和必填 -->
          <template v-if="reviewForm.status === 'completed'">
            <el-form-item label="研究进度" prop="research_progress_score">
              <el-input-number 
                v-model="reviewForm.research_progress_score"
                :min="0"
                :max="100"
                :precision="2"
              />
            </el-form-item>
            
            <el-form-item label="技术掌握" prop="technical_ability_score">
              <el-input-number 
                v-model="reviewForm.technical_ability_score"
                :min="0"
                :max="100"
                :precision="2"
              />
            </el-form-item>
            
            <el-form-item label="工作态度" prop="work_attitude_score">
              <el-input-number 
                v-model="reviewForm.work_attitude_score"
                :min="0"
                :max="100"
                :precision="2"
              />
            </el-form-item>
            
            <el-form-item label="总分">
              <el-input v-model="reviewForm.total_score" disabled />
            </el-form-item>
            
            <el-form-item label="研究进度评语" prop="progress_comment">
              <el-input 
                v-model="reviewForm.progress_comment"
                type="textarea"
                :rows="3"
                placeholder="请输入研究进度评语"
              />
            </el-form-item>
            
            <el-form-item label="技术掌握评语" prop="technical_comment">
              <el-input 
                v-model="reviewForm.technical_comment"
                type="textarea"
                :rows="3"
                placeholder="请输入技术掌握评语"
              />
            </el-form-item>
            
            <el-form-item label="工作态度评语" prop="attitude_comment">
              <el-input 
                v-model="reviewForm.attitude_comment"
                type="textarea"
                :rows="3"
                placeholder="请输入工作态度评语"
              />
            </el-form-item>
          </template>

          <!-- 修改建议，仅在选择"需要修改"时显示和必填 -->
          <el-form-item 
            v-if="reviewForm.status === 'revision_needed'"
            label="修改建议" 
            prop="improvement_suggestions"
          >
            <el-input 
              v-model="reviewForm.improvement_suggestions"
              type="textarea"
              :rows="5"
              placeholder="请输入具体的修改建议"
            />
          </el-form-item>
        </el-form>

        <template #footer>
          <span class="dialog-footer">
            <el-button @click="dialogVisible = false">取消</el-button>
            <el-button type="primary" @click="submitReview">提交评阅</el-button>
          </span>
        </template>
      </el-dialog>

      <!-- 查看评阅详情对话框 -->
      <el-dialog 
        v-model="viewDialogVisible" 
        title="评阅详情" 
        width="70%"
      >
        <template v-if="currentMidterm">
          <el-descriptions :column="2" border>
            <el-descriptions-item label="学生姓名">
              {{ currentMidterm.student_name }}
            </el-descriptions-item>
            <el-descriptions-item label="学号">
              {{ currentMidterm.student_id }}
            </el-descriptions-item>
            <el-descriptions-item label="提交时间">
              {{ formatDateTime(currentMidterm.submit_time) }}
            </el-descriptions-item>
            <el-descriptions-item label="评阅时间">
              {{ formatDateTime(currentMidterm.review_time) }}
            </el-descriptions-item>
            <el-descriptions-item label="评阅状态">
              <el-tag :type="getStatusType(currentMidterm.status)">
                {{ getStatusText(currentMidterm.status) }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="总分">
              {{ currentMidterm.total_score }}
            </el-descriptions-item>
          </el-descriptions>

          <template v-if="currentMidterm.status === 'completed'">
            <el-divider>评分详情</el-divider>
            <el-descriptions :column="1" border>
              <el-descriptions-item label="研究进度分数">
                {{ currentMidterm.research_progress_score }}
              </el-descriptions-item>
              <el-descriptions-item label="研究进度评语">
                {{ currentMidterm.progress_comment }}
              </el-descriptions-item>
              <el-descriptions-item label="技术掌握分数">
                {{ currentMidterm.technical_ability_score }}
              </el-descriptions-item>
              <el-descriptions-item label="技术掌握评语">
                {{ currentMidterm.technical_comment }}
              </el-descriptions-item>
              <el-descriptions-item label="工作态度分数">
                {{ currentMidterm.work_attitude_score }}
              </el-descriptions-item>
              <el-descriptions-item label="工作态度评语">
                {{ currentMidterm.attitude_comment }}
              </el-descriptions-item>
            </el-descriptions>
          </template>

          <template v-if="currentMidterm.status === 'revision_needed'">
            <el-divider>修改建议</el-divider>
            <div class="improvement-suggestions">
              {{ currentMidterm.improvement_suggestions }}
            </div>
          </template>
        </template>
      </el-dialog>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { getTeacherMidterms, reviewMidterm } from '@/api/midterm'
import { formatDateTime } from '@/utils/format'
import { Download, Edit, View } from '@element-plus/icons-vue'

const userStore = useUserStore()
const loading = ref(false)
const midtermList = ref([])
const dialogVisible = ref(false)
const viewDialogVisible = ref(false)
const currentMidterm = ref(null)
const reviewFormRef = ref()
const currentReviewId = ref<number | null>(null)

// 表单数据
const reviewForm = ref({
  research_progress_score: 0,
  technical_ability_score: 0,
  work_attitude_score: 0,
  total_score: 0,
  progress_comment: '',
  technical_comment: '',
  attitude_comment: '',
  improvement_suggestions: '',
  status: 'completed'
})

// 表单验证规则
const formRules = computed(() => ({
  status: [{ required: true, message: '请选择评审结果', trigger: 'change' }],
  ...(reviewForm.value.status === 'completed' ? {
    research_progress_score: [{ required: true, message: '请填写研究进度分数', trigger: 'blur' }],
    technical_ability_score: [{ required: true, message: '请填写技术掌握分数', trigger: 'blur' }],
    work_attitude_score: [{ required: true, message: '请填写工作态度分数', trigger: 'blur' }],
    progress_comment: [{ required: true, message: '请填写研究进度评语', trigger: 'blur' }],
    technical_comment: [{ required: true, message: '请填写技术掌握评语', trigger: 'blur' }],
    attitude_comment: [{ required: true, message: '请填写工作态度评语', trigger: 'blur' }]
  } : {
    improvement_suggestions: [{ required: true, message: '请填写修改建议', trigger: 'blur' }]
  })
}))

// 获取中期报告列表
const getMidtermList = async () => {
  try {
    loading.value = true
    const { data } = await getTeacherMidterms(userStore.userInfo.userId)
    midtermList.value = data.map(item => {
      if (!item.status) {
        item.status = 'pending'
      }
      return item
    })
  } catch (error) {
    console.error('获取中期报告列表失败:', error)
    ElMessage.error('获取中期报告列表失败')
  } finally {
    loading.value = false
  }
}

// 打开评阅对话框
const handleReview = (row: any) => {
  currentReviewId.value = row.id
  dialogVisible.value = true
  reviewForm.value = {
    research_progress_score: 0,
    technical_ability_score: 0,
    work_attitude_score: 0,
    total_score: 0,
    progress_comment: '',
    technical_comment: '',
    attitude_comment: '',
    improvement_suggestions: '',
    status: 'completed'
  }
}

// 查看评阅详情
const viewReview = (row) => {
  currentMidterm.value = row
  viewDialogVisible.value = true
}

// 提交评阅
const submitReview = async () => {
  if (!reviewFormRef.value || !currentReviewId.value) return
  
  try {
    const valid = await reviewFormRef.value.validate()
    if (!valid) {
      ElMessage.error('请填写完整的评阅信息')
      return
    }

    await reviewMidterm(currentReviewId.value, reviewForm.value)
    ElMessage.success('评阅提交成功')
    dialogVisible.value = false
    getMidtermList()
  } catch (error) {
    console.error('提交评阅失败:', error)
    ElMessage.error('提交评阅失败，请重试')
  }
}

// 下载文件
const downloadFile = (row: any) => {
  if (!row.file_url) {
    ElMessage.warning('文件链接不存在')
    return
  }
  
  const fileUrl = row.file_url
  const fullUrl = fileUrl.startsWith('http') 
    ? fileUrl 
    : `${import.meta.env.VITE_API_BASE_URL}/${fileUrl}`
    
  window.open(fullUrl, '_blank')
}

// 获取状态文本
const getStatusText = (status: string) => {
  const statusMap = {
    'pending': '待评阅',
    'reviewing': '评阅中',
    'revision_needed': '需修改',
    'completed': '已完成'
  }
  return statusMap[status] || '未知状态'
}

// 获取状态类型
const getStatusType = (status: string) => {
  const statusMap = {
    'pending': 'warning',
    'reviewing': 'warning',
    'revision_needed': 'danger',
    'completed': 'success'
  }
  return statusMap[status] || 'info'
}

// 计算总分
watch(
  [
    () => reviewForm.value.research_progress_score,
    () => reviewForm.value.technical_ability_score,
    () => reviewForm.value.work_attitude_score
  ],
  ([researchScore, technicalScore, attitudeScore]) => {
    reviewForm.value.total_score = Number(((researchScore + technicalScore + attitudeScore) / 3).toFixed(2))
  }
)

// 状态变更处理
const handleStatusChange = (value: string) => {
  if (value === 'revision_needed') {
    reviewForm.value = {
      ...reviewForm.value,
      research_progress_score: 0,
      technical_ability_score: 0,
      work_attitude_score: 0,
      total_score: 0
    }
  }
}

onMounted(() => {
  getMidtermList()
})
</script>

<style scoped>
.midterm-review-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.improvement-suggestions {
  padding: 15px;
  background-color: #f5f7fa;
  border-radius: 4px;
  white-space: pre-wrap;
}

:deep(.el-form-item) {
  margin-bottom: 22px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}
</style>