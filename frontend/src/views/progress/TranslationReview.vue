<template>
  <div class="translation-review-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>外文翻译评阅</span>
        </div>
      </template>

      <!-- 翻译列表 -->
      <el-table :data="translationList" style="width: 100%" v-loading="loading">
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
        <el-table-column label="操作" width="200">
          <template #default="scope">
            <el-button 
              type="primary" 
              link 
              @click="downloadFile(scope.row)"
            >
              下载文件
            </el-button>
            <el-button 
              type="primary" 
              link 
              @click="handleReview(scope.row)"
              v-if="scope.row.status === 'pending' || scope.row.status === 'revision_needed' || scope.row.status === 'reviewing'"
            >
              评阅
            </el-button>
            <el-button 
              type="primary" 
              link 
              @click="viewReview(scope.row)"
              v-else
            >
              查看评阅
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 评阅对话框 -->
      <el-dialog 
        v-model="dialogVisible" 
        title="外文翻译评阅" 
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
          <el-form-item 
            label="评审结果" 
            prop="status"
          >
            <el-select 
              v-model="reviewForm.status"
              @change="handleStatusChange"
            >
              <el-option label="需要修改" value="revision_needed" />
              <el-option label="通过" value="completed" />
            </el-select>
          </el-form-item>

          <!-- 评分项，仅在选择"通过"时显示和必填 -->
          <template v-if="reviewForm.status === 'completed'">
            <el-form-item label="语言准确性" prop="language_accuracy_score">
              <el-input-number 
                v-model="reviewForm.language_accuracy_score"
                :min="0"
                :max="100"
                :precision="2"
              />
            </el-form-item>
            
            <el-form-item label="内容完整性" prop="content_integrity_score">
              <el-input-number 
                v-model="reviewForm.content_integrity_score"
                :min="0"
                :max="100"
                :precision="2"
              />
            </el-form-item>
            
            <el-form-item label="格式规范" prop="format_score">
              <el-input-number 
                v-model="reviewForm.format_score"
                :min="0"
                :max="100"
                :precision="2"
              />
            </el-form-item>
          </template>

          <el-form-item label="总分" prop="total_score">
            <el-input-number 
              v-model="reviewForm.total_score"
              :min="0"
              :max="100"
              :precision="2"
              :disabled="true"
            />
          </el-form-item>
          
          <el-form-item label="语言准确性评语" prop="language_accuracy_comment">
            <el-input 
              v-model="reviewForm.language_accuracy_comment"
              type="textarea"
              :rows="3"
              placeholder="请输入语言准确性评语"
            />
          </el-form-item>
          
          <el-form-item label="内容完整性评语" prop="content_integrity_comment">
            <el-input 
              v-model="reviewForm.content_integrity_comment"
              type="textarea"
              :rows="3"
              placeholder="请输入内容完整性评语"
            />
          </el-form-item>
          
          <el-form-item label="格式规范评语" prop="format_comment">
            <el-input 
              v-model="reviewForm.format_comment"
              type="textarea"
              :rows="3"
              placeholder="请输入格式规范评语"
            />
          </el-form-item>
          
          <el-form-item label="总体评语" prop="general_comment">
            <el-input 
              v-model="reviewForm.general_comment"
              type="textarea"
              :rows="3"
              placeholder="请输入总体评语"
            />
          </el-form-item>
          
          <el-form-item label="改进建议" prop="improvement_suggestions">
            <el-input 
              v-model="reviewForm.improvement_suggestions"
              type="textarea"
              :rows="3"
              placeholder="请输入改进建议"
            />
          </el-form-item>
        </el-form>
        <template #footer>
          <span class="dialog-footer">
            <el-button @click="dialogVisible = false">取消</el-button>
            <el-button type="primary" @click="submitReview">
              提交评阅
            </el-button>
          </span>
        </template>
      </el-dialog>

      <!-- 查看评阅对话框 -->
      <el-dialog 
        v-model="viewDialogVisible" 
        title="评阅详情" 
        width="60%"
      >
        <el-descriptions :column="1" border>
          <el-descriptions-item label="学生姓名">
            {{ currentTranslation?.student_name }}
          </el-descriptions-item>
          <el-descriptions-item label="提交时间">
            {{ formatDateTime(currentTranslation?.submit_time) }}
          </el-descriptions-item>
          <el-descriptions-item label="语言准确性分数">
            {{ currentTranslation?.language_accuracy_score || '-' }}
          </el-descriptions-item>
          <el-descriptions-item label="内容完整性分数">
            {{ currentTranslation?.content_integrity_score || '-' }}
          </el-descriptions-item>
          <el-descriptions-item label="格式规范分数">
            {{ currentTranslation?.format_score || '-' }}
          </el-descriptions-item>
          <el-descriptions-item label="总分">
            {{ currentTranslation?.total_score || '-' }}
          </el-descriptions-item>
          <el-descriptions-item label="语言准确性评语">
            {{ currentTranslation?.language_accuracy_comment || '-' }}
          </el-descriptions-item>
          <el-descriptions-item label="内容完整性评语">
            {{ currentTranslation?.content_integrity_comment || '-' }}
          </el-descriptions-item>
          <el-descriptions-item label="格式规范评语">
            {{ currentTranslation?.format_comment || '-' }}
          </el-descriptions-item>
          <el-descriptions-item label="总体评语">
            {{ currentTranslation?.general_comment || '-' }}
          </el-descriptions-item>
          <el-descriptions-item label="改进建议">
            {{ currentTranslation?.improvement_suggestions || '-' }}
          </el-descriptions-item>
          <el-descriptions-item label="评阅状态">
            <el-tag :type="getStatusType(currentTranslation?.status)">
              {{ getStatusText(currentTranslation?.status) }}
            </el-tag>
          </el-descriptions-item>
        </el-descriptions>
      </el-dialog>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { getTeacherTranslations, reviewTranslation } from '@/api/translation'
import { formatDateTime } from '@/utils/format'

const userStore = useUserStore()
const loading = ref(false)
const translationList = ref([])
const dialogVisible = ref(false)
const viewDialogVisible = ref(false)
const currentTranslation = ref(null)

// 定义表单引用和当前评阅ID
const reviewFormRef = ref()
const currentReviewId = ref<number | null>(null)

// 表单数据
const reviewForm = ref({
  language_accuracy_score: 0,
  content_integrity_score: 0,
  format_score: 0,
  total_score: 0,
  language_accuracy_comment: '',
  content_integrity_comment: '',
  format_comment: '',
  general_comment: '',
  improvement_suggestions: '',
  status: 'completed'
})

// 表单验证规则
const formRules = computed(() => ({
  status: [{ required: true, message: '请选择评审结果', trigger: 'change' }],
  ...(reviewForm.value.status === 'completed' ? {
    language_accuracy_score: [{ required: true, message: '请填写语言准确性分数', trigger: 'blur' }],
    content_integrity_score: [{ required: true, message: '请填写内容完整性分数', trigger: 'blur' }],
    format_score: [{ required: true, message: '请填写格式规范分数', trigger: 'blur' }],
    language_accuracy_comment: [{ required: true, message: '请填写语言准确性评语', trigger: 'blur' }],
    content_integrity_comment: [{ required: true, message: '请填写内容完整性评语', trigger: 'blur' }],
    format_comment: [{ required: true, message: '请填写格式规范评语', trigger: 'blur' }]
  } : {
    improvement_suggestions: [{ required: true, message: '请填写修改建议', trigger: 'blur' }]
  })
}))

// 获取翻译列表
const getTranslationList = async () => {
  try {
    loading.value = true
    const { data } = await getTeacherTranslations(userStore.userInfo.userId)
    translationList.value = data
  } catch (error) {
    console.error('获取翻译列表失败:', error)
    ElMessage.error('获取翻译列表失败')
  } finally {
    loading.value = false
  }
}

// 打开评阅对话框
const handleReview = (row: any) => {
  console.log('Opening review dialog for:', row)
  currentReviewId.value = row.id // 确保从行数据中获取正确的ID
  dialogVisible.value = true
  // 重置表单
  reviewForm.value = {
    language_accuracy_score: 0,
    content_integrity_score: 0,
    format_score: 0,
    total_score: 0,
    language_accuracy_comment: '',
    content_integrity_comment: '',
    format_comment: '',
    general_comment: '',
    improvement_suggestions: '',
    status: 'completed'
  }
}

// 查看评阅详情
const viewReview = (row) => {
  currentTranslation.value = row
  viewDialogVisible.value = true
}

// 提交评阅
const submitReview = async () => {
  if (!reviewFormRef.value || !currentReviewId.value) {
    console.log('Form ref or review ID missing:', { 
      formRef: reviewFormRef.value, 
      reviewId: currentReviewId.value 
    })
    return
  }
  
  try {
    const valid = await reviewFormRef.value.validate()
    if (!valid) {
      ElMessage.error('请填写完整的评阅信息')
      return
    }

    console.log('Submitting review:', {
      id: currentReviewId.value,
      data: reviewForm.value
    })

    await reviewTranslation(currentReviewId.value, reviewForm.value)
    ElMessage.success('评阅提交成功')
    dialogVisible.value = false
    // 刷新页面
    window.location.reload()
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
  
  // 从数据库记录中获取文件URL
  const fileUrl = row.file_url
  
  // 如果是相对路径，需要拼接完整的URL
  const fullUrl = fileUrl.startsWith('http') 
    ? fileUrl 
    : `${import.meta.env.VITE_API_BASE_URL}/${fileUrl}`
    
  // 打开新窗口下载文件
  window.open(fullUrl, '_blank')
  
  // 可以添加下载记录
  console.log('下载外文翻译文件:', {
    student_id: row.student_id,
    student_name: row.student_name,
    file_url: fileUrl,
    version: row.version
  })
}

// 获取状态类型
const getStatusType = (status) => {
  const statusMap = {
    pending: 'warning',
    completed: 'success',
    revision_needed: 'danger',
    reviewing: 'info'
  }
  return statusMap[status] || 'info'
}

// 获取状态文本
const getStatusText = (status) => {
  const statusMap = {
    pending: '待评阅',
    completed: '已通过',
    reviewing: '评审中',
    revision_needed: '需修改'
  }
  return statusMap[status] || '未知'
}

// 添加计算总分的监听器
watch(
  [
    () => reviewForm.value.language_accuracy_score,
    () => reviewForm.value.content_integrity_score,
    () => reviewForm.value.format_score
  ],
  ([languageScore, contentScore, formatScore]) => {
    reviewForm.value.total_score = Number(((languageScore + contentScore + formatScore) / 3).toFixed(2))
  }
)

// 在 script setup 部分添加这个方法
const handleStatusChange = (value: string) => {
  if (value === 'revision_needed') {
    // 如果需要修改，重置所有分数
    reviewForm.value = {
      ...reviewForm.value,
      language_accuracy_score: 0,
      content_integrity_score: 0,
      format_score: 0,
      total_score: 0
    }
  }
}

onMounted(() => {
  getTranslationList()
})
</script>

<style scoped>
.translation-review-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

:deep(.el-form-item) {
  margin-bottom: 22px;
}
</style> 