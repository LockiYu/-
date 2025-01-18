<template>
  <div class="app-container">
    <a-card class="box-card">
      <template #title>论文评阅</template>

      <!-- 搜索栏 -->
      <div class="filter-container">
        <a-form layout="inline">
          <a-form-item label="学生姓名">
            <a-input
              v-model:value="queryParams.studentName"
              placeholder="请输入学生姓名"
              allow-clear
            />
          </a-form-item>
          <a-form-item label="论文标题">
            <a-input
              v-model:value="queryParams.thesisTitle"
              placeholder="请输入论文标题"
              allow-clear
            />
          </a-form-item>
          <a-form-item label="评阅状态">
            <a-select
              v-model:value="queryParams.status"
              placeholder="选择状态"
              style="width: 120px"
              allow-clear
            >
              <a-select-option value="pending">待评阅</a-select-option>
              <a-select-option value="completed">已评阅</a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item>
            <a-button type="primary" @click="handleQuery">查询</a-button>
            <a-button style="margin-left: 8px" @click="resetQuery">重置</a-button>
          </a-form-item>
        </a-form>
      </div>

      <!-- 论文列表 -->
      <a-table
        :loading="loading"
        :columns="columns"
        :data-source="thesisList"
        :pagination="false"
        bordered
      >
        <template #bodyCell="{ column, record }">
          <!-- 状态列 -->
          <template v-if="column.key === 'status'">
            <a-tag :color="getStatusColor(record.review_status)">
              {{ getStatusText(record.review_status) }}
            </a-tag>
          </template>
          
          <!-- 操作列 -->
          <template v-if="column.key === 'action'">
            <a-space>
              <a-button 
                type="link" 
                @click="downloadFile(record)"
                :disabled="!record.file_url"
              >
                下载论文
              </a-button>
              
              <!-- 评阅按钮 - 区分导师评阅和同行评阅 -->
              <template v-if="record.status === 'pending'">
                <a-tooltip placement="top">
                  <template #title>
                    <span v-if="record.review_type === 'peer' && record.advisor_review_status !== 'completed'" style="color: #ff4d4f">
                      导师评阅未完成，暂不能进行同行评阅
                    </span>
                    <span v-else style="color: #ff4d4f">
                      提示：评阅提交后将不可修改，请认真评阅
                    </span>
                  </template>
                  <a-button 
                    type="primary"
                    @click="handleReview(record)"
                    :disabled="record.review_type === 'peer' && record.advisor_review_status !== 'completed'"
                  >
                    {{ record.review_type === 'advisor' ? '导师评阅' : '同行评阅' }}
                  </a-button>
                </a-tooltip>
              </template>
              <template v-else>
                <a-button 
                  type="link" 
                  @click="handleViewReview(record)"
                >
                  查看评阅
                </a-button>
              </template>
            </a-space>
          </template>
        </template>
      </a-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <a-pagination
          v-model:current="queryParams.pageNum"
          v-model:pageSize="queryParams.pageSize"
          :total="total"
          :page-sizes="[10, 20, 50, 100]"
          show-size-changer
          show-quick-jumper
          @change="handleCurrentChange"
          @showSizeChange="handleSizeChange"
        />
      </div>
    </a-card>

    <!-- 将模态框容器移到外层 -->
    <div class="modal-container">
      <a-modal
        v-model:open="reviewVisible"
        :title="getDialogTitle"
        width="700px"
        @ok="handleSubmitReview"
        @cancel="reviewVisible = false"
        :confirmLoading="submitLoading"
        :maskClosable="false"
        :keyboard="false"
        :mask-style="{ zIndex: 1090 }"
        :wrap-style="{ zIndex: 1100 }"
        :style="{ zIndex: 1100 }"
        destroyOnClose
      >
        <!-- 添加提示信息 -->
        <template v-if="currentReview?.review_type === 'peer'">
          <a-alert
            message="同行评阅提示"
            :description="'1. 评阅提交后将不可修改\n2. 进度更新将在所有3位同行评阅老师完成评阅后自动生效'"
            type="info"
            show-icon
            style="margin-bottom: 16px"
          />
          <div style="margin-bottom: 16px">
            <a-tag color="blue">
              当前评阅进度: {{ completedPeerReviews }}/3
            </a-tag>
          </div>
        </template>
        <template v-else>
          <a-alert
            message="导师评阅提示"
            description="评阅提交后将不可修改，请认真评阅"
            type="warning"
            show-icon
            style="margin-bottom: 16px"
          />
        </template>

        <!-- 评阅表单 -->
        <a-form
          ref="reviewFormRef"
          :model="reviewForm"
          :rules="rules"
          :label-col="{ span: 6 }"
          :wrapper-col="{ span: 16 }"
        >
          <a-form-item label="创新性评分" name="scoreInnovation" required>
            <a-input-number
              v-model:value="reviewForm.scoreInnovation"
              :min="0"
              :max="100"
              style="width: 100%"
            />
            <div class="form-item-tip">请输入0-100的分数，提交后不可修改</div>
          </a-form-item>

          <a-form-item label="质量评分" name="scoreQuality" required>
            <a-input-number
              v-model:value="reviewForm.scoreQuality"
              :min="0"
              :max="100"
              style="width: 100%"
            />
            <div class="form-item-tip">请输入0-100的分数，提交后不可修改</div>
          </a-form-item>

          <a-form-item label="工作量评分" name="scoreWorkload" required>
            <a-input-number
              v-model:value="reviewForm.scoreWorkload"
              :min="0"
              :max="100"
              style="width: 100%"
            />
            <div class="form-item-tip">请输入0-100的分数，提交后不可修改</div>
          </a-form-item>

          <a-form-item label="写作水平评分" name="scoreWriting" required>
            <a-input-number
              v-model:value="reviewForm.scoreWriting"
              :min="0"
              :max="100"
              style="width: 100%"
            />
            <div class="form-item-tip">请输入0-100的分数，提交后不可修改</div>
          </a-form-item>

          <a-form-item label="评阅意见" name="reviewComments" required>
            <a-textarea
              v-model:value="reviewForm.reviewComments"
              :rows="4"
              placeholder="请输入评阅意见（必填）"
            />
            <div class="form-item-tip">请详细描述评阅意见，提交后不可修改</div>
          </a-form-item>
        </a-form>
      </a-modal>
    </div>

    <!-- 查看评阅对话框 -->
    <div class="modal-container">
      <a-modal
        v-model:open="viewReviewDialogVisible"
        title="评阅详情"
        width="600px"
        :footer="null"
        :maskClosable="false"
        :keyboard="false"
        :mask-style="{ zIndex: 1090 }"
        :wrap-style="{ zIndex: 1100 }"
        :style="{ zIndex: 1100 }"
        destroyOnClose
      >
        <a-descriptions bordered :column="1">
          <a-descriptions-item label="创新性评分">
            <div class="score-details">
              {{ currentReview?.score_innovation }} 分
            </div>
          </a-descriptions-item>
          <a-descriptions-item label="质量评分">
            <div class="score-details">
              {{ currentReview?.score_quality }} 分
            </div>
          </a-descriptions-item>
          <a-descriptions-item label="工作量评分">
            <div class="score-details">
              {{ currentReview?.score_workload }} 分
            </div>
          </a-descriptions-item>
          <a-descriptions-item label="写作水平评分">
            <div class="score-details">
              {{ currentReview?.score_writing }} 分
            </div>
          </a-descriptions-item>
          <a-descriptions-item label="总评分">
            <div class="total-score">
              {{ currentReview?.total_score }} 分
            </div>
          </a-descriptions-item>
          <a-descriptions-item label="评阅意见" v-if="currentReview?.review_comments">
            <div class="comment-section">
              <pre class="comment-text">{{ currentReview?.review_comments }}</pre>
            </div>
          </a-descriptions-item>
          <a-descriptions-item label="评阅时间">
            {{ formatDate(currentReview?.review_time) }}
          </a-descriptions-item>
        </a-descriptions>
      </a-modal>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { message } from 'ant-design-vue'
import { getReviewList, submitReview as submitReviewApi, getPeerReviewProgress } from '@/api/thesisReview'
import { formatDate } from '@/utils/format'

// 查询参数
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  studentName: '',
  thesisTitle: '',
  status: undefined
})

// 表格数据
const loading = ref(false)
const total = ref(0)
const thesisList = ref([])

// 表格列定义
const columns = [
  {
    title: '学生姓名',
    dataIndex: 'student_name',
    width: 120
  },
  {
    title: '论文标题',
    dataIndex: 'thesis_title',
    ellipsis: true
  },
  {
    title: '评阅类型',
    dataIndex: 'review_type',
    width: 100,
    customRender: ({ text }: { text: string }) => {
      return text === 'advisor' ? '导师评阅' : '同行评阅'
    }
  },
  {
    title: '分配时间',
    dataIndex: 'assigned_at',
    width: 160,
    customRender: ({ text }: { text: string }) => formatDate(text)
  },
  {
    title: '状态',
    dataIndex: 'review_status',
    key: 'status',
    width: 100
  },
  {
    title: '操作',
    key: 'action',
    width: 180,
    fixed: 'right'
  }
]

// 评阅表单
const reviewVisible = ref(false)
const submitLoading = ref(false)
const reviewFormRef = ref()
const reviewForm = reactive({
  assignmentId: 0,
  scoreInnovation: 0,
  scoreQuality: 0,
  scoreWorkload: 0,
  scoreWriting: 0,
  reviewComments: ''
})

// 表单验证规则
const rules = {
  scoreInnovation: [{ required: true, message: '请输入创新性评分' }],
  scoreQuality: [{ required: true, message: '请输入质量评分' }],
  scoreWorkload: [{ required: true, message: '请输入工作量评分' }],
  scoreWriting: [{ required: true, message: '请输入写作水平评分' }],
  reviewComments: [
    { required: true, message: '请输入评阅意见' },
    { min: 10, message: '评阅意见不能少于10个字符' }
  ]
}

// 查看评阅详情
const viewReviewDialogVisible = ref(false)
const currentReview = ref<any>(null)
const completedPeerReviews = ref(0)

// 状态相关函数
const getStatusColor = (status: string) => {
  const colorMap: Record<string, string> = {
    pending: 'warning',
    completed: 'success'
  }
  return colorMap[status] || 'default'
}

const getStatusText = (status: string) => {
  const textMap: Record<string, string> = {
    pending: '待评阅',
    completed: '已评阅'
  }
  return textMap[status] || status
}

// 处理函数
const handleQuery = async () => {
  loading.value = true
  try {
    const res = await getReviewList(queryParams)
    thesisList.value = res.data.list.map((item: any) => ({
      ...item,
      status: item.review_status || item.status,
      review_type: item.review_type,
      advisor_review_status: item.advisor_review_status || 'pending'
    }))
    console.log('处理后的数据:', thesisList.value)
    total.value = res.data.total
  } catch (error: any) {
    message.error(error.message || '查询失败')
  } finally {
    loading.value = false
  }
}

const resetQuery = () => {
  queryParams.studentName = ''
  queryParams.thesisTitle = ''
  queryParams.status = undefined
  handleQuery()
}

// 获取评阅按钮的提示文本
const getReviewButtonTitle = (record: any) => {
  if (record.review_type === 'advisor') {
    return '点击进行导师评阅'
  }
  return record.advisor_review_status === 'completed' ? 
    '点击进行同行评阅' : 
    '导师评阅未完成，暂不能进行同行评阅'
}

// 修改评阅处理函数
const handleReview = (record: any) => {
  // 检查是否可以评阅
  if (record.review_type === 'peer' && record.advisor_review_status !== 'completed') {
    message.warning('导师评阅未完成，暂不能进行同行评阅')
    return
  }

  currentReview.value = record
  reviewForm.assignmentId = record.assignment_id
  reviewForm.scoreInnovation = 0
  reviewForm.scoreQuality = 0
  reviewForm.scoreWorkload = 0
  reviewForm.scoreWriting = 0
  reviewForm.reviewComments = ''

  // 如果是同行评阅，获取当前评阅进度
  if (record.review_type === 'peer') {
    getReviewProgress(record.student_id)
  }

  reviewVisible.value = true
}

const handleViewReview = (record: any) => {
  console.log('查看评阅详情:', record) // 添加调试日志
  currentReview.value = { ...record } // 使用解构赋值创建新对象
  viewReviewDialogVisible.value = true
}

const handleSubmitReview = () => {
  if (!reviewFormRef.value) return
  
  submitLoading.value = true
  reviewFormRef.value
    .validate()
    .then(() => {
      return submitReviewApi(reviewForm)
    })
    .then(() => {
      if (currentReview.value?.review_type === 'peer') {
        message.success('评阅提交成功，进度将在所有同行评阅完成后更新')
      } else {
        message.success('评阅提交成功')
      }
      reviewVisible.value = false
      handleQuery()
    })
    .catch((err: any) => {
      console.error('评阅提交失败:', err)
      message.error(err.response?.data?.message || '评阅提交失败')
    })
    .finally(() => {
      submitLoading.value = false
    })
}

const handleSizeChange = (val: number) => {
  queryParams.pageSize = val
  handleQuery()
}

const handleCurrentChange = (val: number) => {
  queryParams.pageNum = val
  handleQuery()
}

// 下载文件
const downloadFile = (record: any) => {
  if (record.file_url) {
    window.open(`http://localhost:3001/${record.file_url}`, '_blank')
  }
}

// 获取评阅按钮的状态和样式
const getReviewButtonProps = (record: any) => {
  const isAdvisor = record.review_type === 'advisor'
  const isPeer = record.review_type === 'peer'
  const advisorCompleted = record.advisor_review_status === 'completed'
  
  return {
    disabled: isPeer && !advisorCompleted,
    type: 'primary',
    danger: isPeer && !advisorCompleted,
    title: isAdvisor ? '导师评阅' : (advisorCompleted ? '同行评阅' : '等待导师评阅')
  }
}

// 修改获取评阅进度的函数
const getReviewProgress = async (studentId: string) => {
  try {
    console.log('获取评阅进度，学生ID:', studentId);  // 添加日志
    const res = await getPeerReviewProgress(studentId)
    console.log('评阅进度结果:', res);  // 添加日志
    completedPeerReviews.value = res.data.completedCount
  } catch (error) {
    console.error('获取评阅进度失败:', error)
    message.error('获取评阅进度失败')
    completedPeerReviews.value = 0
  }
}

// 添加计算属性
const getDialogTitle = computed(() => {
  if (!currentReview.value) return '论文评阅';
  
  // 根据评阅类型返回不同标题
  switch (currentReview.value.review_type) {
    case 'advisor':
      return '导师评阅';
    case 'peer':
      return '同行评阅';
    default:
      return '论文评阅';
  }
});

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

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.total-score {
  font-size: 18px;
  font-weight: bold;
  color: #1890ff;
}

/* 可以添加一些样式来区分不同状态的按钮 */
.ant-btn-dangerous {
  background-color: #ff4d4f;
  border-color: #ff4d4f;
}
.ant-btn-dangerous:hover {
  background-color: #ff7875;
  border-color: #ff7875;
}

/* 删除 Element Plus 相关样式 */
:deep(.el-dialog__wrapper),
:deep(.v-modal),
:deep(.el-dialog),
:deep(.el-card__body) {
  display: none;
}

/* 保留 Ant Design Vue 相关样式 */
.modal-container {
  position: relative;
  z-index: 1100;
}

:deep(.ant-modal-mask),
:deep(.ant-modal-wrap),
:deep(.ant-modal) {
  z-index: 1100 !important;
}

.total-score {
  font-size: 18px;
  font-weight: bold;
  color: #1890ff;
}

/* 确保 Modal 在最上层 */
.modal-container {
  position: relative;
  z-index: 1100;
}

/* 覆盖 ant-design-vue 的默认样式 */
:deep(.ant-modal-wrap) {
  z-index: 1100;
}

:deep(.ant-modal-mask) {
  z-index: 1090;
}

:deep(.ant-modal) {
  z-index: 1100;
}

.score-details {
  display: grid;
  gap: 8px;
}

.total-score {
  font-size: 18px;
  font-weight: bold;
  color: #1890ff;
}

.comment-section {
  margin-top: 12px;
  border-top: 1px dashed #f0f0f0;
  padding-top: 8px;
}

.comment-text {
  white-space: pre-wrap;
  margin: 0;
  font-family: inherit;
  background-color: #fafafa;
  padding: 8px;
  border-radius: 4px;
  font-size: 14px;
  line-height: 1.5;
}

.form-item-tip {
  color: #ff4d4f;
  font-size: 12px;
  margin-top: 4px;
}
</style> 