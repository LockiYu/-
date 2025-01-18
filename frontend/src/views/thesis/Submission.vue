<template>
  <div class="app-container">
    <!-- 论文信息卡片 -->
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>论文信息</span>
          <el-tag :type="getStatusType(thesisInfo.status)">
            {{ getStatusText(thesisInfo.status) }}
          </el-tag>
        </div>
      </template>

      <el-form
        ref="formRef"
        :model="thesisForm"
        :rules="formRules"
        label-width="120px"
      >
        <el-form-item label="论文题目" prop="title">
          <el-input 
            v-model="thesisForm.title" 
            :disabled="!canEdit"
            placeholder="请输入论文题目"
          />
        </el-form-item>

        <el-form-item label="论文摘要" prop="abstract">
          <el-input
            v-model="thesisForm.abstract"
            type="textarea"
            :rows="4"
            :disabled="!canEdit"
            placeholder="请输入论文摘要"
          />
        </el-form-item>

        <el-form-item label="关键词" prop="keywords">
          <el-select
            v-model="thesisForm.keywords"
            multiple
            filterable
            allow-create
            :disabled="!canEdit"
            placeholder="请输入关键词（可自定义）"
          >
            <el-option
              v-for="item in commonKeywords"
              :key="item"
              :label="item"
              :value="item"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="论文类型" prop="type">
          <el-select
            v-model="thesisForm.type"
            :disabled="!canEdit"
            placeholder="请选择论文类型"
          >
            <el-option label="工程设计" value="engineering" />
            <el-option label="理论研究" value="theoretical" />
            <el-option label="应用研究" value="applied" />
            <el-option label="实验研究" value="experimental" />
          </el-select>
        </el-form-item>

        <el-form-item label="论文文件" prop="file">
          <el-upload
            v-if="canEdit"
            class="upload-demo"
            :action="uploadUrl"
            :headers="uploadHeaders"
            :before-upload="beforeUpload"
            :on-success="handleUploadSuccess"
            :on-error="handleUploadError"
            :disabled="uploading"
          >
            <template #trigger>
              <el-button type="primary" :loading="uploading">
                {{ uploading ? '上传中...' : '上传论文' }}
              </el-button>
            </template>
            <template #tip>
              <div class="el-upload__tip">
                只能上传 PDF 文件，且不超过 20MB
              </div>
            </template>
          </el-upload>
          <div v-if="thesisForm.file">
            <el-button link @click="handleDownload">
              查看已提交论文
            </el-button>
            <span class="file-info">
              提交时间：{{ thesisForm.submitTime }}
            </span>
          </div>
        </el-form-item>

        <el-form-item v-if="canEdit">
          <el-button 
            type="primary" 
            @click="handleSubmit"
            :loading="submitting"
          >
            提交论文
          </el-button>
          <el-button @click="handleSaveDraft">
            保存草稿
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 评阅意见卡片 -->
    <el-card 
      v-if="thesisInfo.reviews && thesisInfo.reviews.length > 0"
      class="box-card review-card"
    >
      <template #header>
        <div class="card-header">
          <span>评阅意见</span>
        </div>
      </template>

      <el-timeline>
        <el-timeline-item
          v-for="review in thesisInfo.reviews"
          :key="review.id"
          :timestamp="review.time"
          :type="review.result === 'pass' ? 'success' : 'warning'"
        >
          <h4>{{ review.reviewerRole === 'supervisor' ? '导师评阅' : '同行评阅' }}</h4>
          <el-descriptions :column="1" border>
            <el-descriptions-item label="评分">
              {{ review.score }}
            </el-descriptions-item>
            <el-descriptions-item label="评阅意见">
              {{ review.comments }}
            </el-descriptions-item>
            <el-descriptions-item label="评阅结果">
              <el-tag :type="getReviewResultType(review.result)">
                {{ getReviewResultText(review.result) }}
              </el-tag>
            </el-descriptions-item>
          </el-descriptions>
        </el-timeline-item>
      </el-timeline>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, FormInstance, FormRules } from 'element-plus'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()
const formRef = ref<FormInstance>()
const uploading = ref(false)
const submitting = ref(false)

// 常用关键词
const commonKeywords = [
  '人工智能',
  '机器学习',
  '深度学习',
  '数据分析',
  '云计算',
  '区块链',
  '物联网',
  '信息安全'
]

// 论文信息
const thesisInfo = ref({
  status: 'draft',
  reviews: []
})

// 表单数据
const thesisForm = reactive({
  title: '',
  abstract: '',
  keywords: [],
  type: '',
  file: null,
  submitTime: ''
})

// 表单验证规则
const formRules = reactive<FormRules>({
  title: [
    { required: true, message: '请输入论文题目', trigger: 'blur' },
    { min: 10, message: '论文题目不能少于10个字符', trigger: 'blur' }
  ],
  abstract: [
    { required: true, message: '请输入论文摘要', trigger: 'blur' },
    { min: 200, message: '论文摘要不能少于200个字符', trigger: 'blur' }
  ],
  keywords: [
    { required: true, message: '请至少输入3个关键词', trigger: 'change' },
    { 
      validator: (rule, value, callback) => {
        if (value.length < 3) {
          callback(new Error('请至少输入3个关键词'))
        } else {
          callback()
        }
      },
      trigger: 'change'
    }
  ],
  type: [
    { required: true, message: '请选择论文类型', trigger: 'change' }
  ],
  file: [
    { required: true, message: '请上传论文文件', trigger: 'change' }
  ]
})

// 上传配置
const uploadUrl = '/api/upload'
const uploadHeaders = computed(() => ({
  Authorization: userStore.token ? `Bearer ${userStore.token}` : ''
}))

// 计算属性
const canEdit = computed(() => {
  return ['draft', 'rejected'].includes(thesisInfo.value.status)
})

// 状态映射
const getStatusType = (status: string) => {
  const statusMap: Record<string, string> = {
    'draft': 'info',
    'submitted': 'warning',
    'reviewing': 'warning',
    'rejected': 'danger',
    'approved': 'success'
  }
  return statusMap[status] || ''
}

const getStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    'draft': '草稿',
    'submitted': '已提交',
    'reviewing': '评阅中',
    'rejected': '需修改',
    'approved': '已通过'
  }
  return statusMap[status] || status
}

const getReviewResultType = (result: string) => {
  const resultMap: Record<string, string> = {
    'pass': 'success',
    'return': 'warning',
    'fail': 'danger'
  }
  return resultMap[result] || ''
}

const getReviewResultText = (result: string) => {
  const resultMap: Record<string, string> = {
    'pass': '通过',
    'return': '需修改',
    'fail': '不通过'
  }
  return resultMap[result] || result
}

// 处理函数
const beforeUpload = (file: File) => {
  const isPDF = file.type === 'application/pdf'
  const isLt20M = file.size / 1024 / 1024 < 20

  if (!isPDF) {
    ElMessage.error('只能上传 PDF 文件!')
  }
  if (!isLt20M) {
    ElMessage.error('文件大小不能超过 20MB!')
  }
  return isPDF && isLt20M
}

const handleUploadSuccess = (response: any) => {
  uploading.value = false
  if (response.code === 200) {
    thesisForm.file = response.data.url
    thesisForm.submitTime = new Date().toLocaleString()
    ElMessage.success('文件上传成功')
  } else {
    ElMessage.error(response.message || '文件上传失败')
  }
}

const handleUploadError = (error: any) => {
  uploading.value = false
  console.error('上传失败:', error)
  ElMessage.error('文件上传失败，请检查网络连接')
}

const handleDownload = async () => {
  if (!thesisForm.file) {
    ElMessage.warning('没有可下载的文件')
    return
  }

  try {
    // TODO: 调用下载API
    window.open(thesisForm.file)
  } catch (error: any) {
    console.error('下载失败:', error)
    ElMessage.error(error.message || '下载失败')
  }
}

const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      submitting.value = true
      try {
        // TODO: 调用提交论文API
        ElMessage.success('论文提交成功')
        await getThesisInfo()
      } catch (error: any) {
        ElMessage.error(error.message || '提交失败')
      } finally {
        submitting.value = false
      }
    }
  })
}

const handleSaveDraft = async () => {
  try {
    // TODO: 调用保存草稿API
    ElMessage.success('草稿保存成功')
  } catch (error: any) {
    ElMessage.error(error.message || '保存失败')
  }
}

const getThesisInfo = async () => {
  try {
    if (!userStore.token) {
      throw new Error('未登录或登录已过期')
    }
    // TODO: 调用获取论文信息API
    // const response = await getThesisInfo()
    // if (response.code === 200) {
    //   Object.assign(thesisInfo.value, response.data)
    //   Object.assign(thesisForm, response.data)
    // } else {
    //   throw new Error(response.message)
    // }
  } catch (error: any) {
    console.error('获取论文信息失败:', error)
    ElMessage.error(error.message || '获取论文信息失败')
  }
}

// 初始化
onMounted(async () => {
  try {
    await getThesisInfo()
  } catch (error: any) {
    console.error('初始化失败:', error)
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

.file-info {
  margin-left: 10px;
  color: #666;
  font-size: 14px;
}

.review-card {
  margin-top: 20px;
}

:deep(.el-timeline-item__node--large) {
  width: 16px;
  height: 16px;
}

:deep(.el-timeline-item__tail) {
  left: 7px;
}
</style> 