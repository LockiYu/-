<template>
  <div class="proposal-review">
    <!-- 搜索和筛选区域 -->
    <a-card :bordered="false" class="filter-card">
      <a-row :gutter="16">
        <a-col :span="6">
          <a-input
            v-model:value="searchKeyword" 
            placeholder="搜索学号/姓名"
            allow-clear
            @search="handleSearch"
          />
        </a-col>
        <a-col :span="6">
          <a-select
            v-model:value="filterStatus"
            style="width: 100%"
            placeholder="选择状态"
            @change="handleSearch"
            allow-clear
          >
            <a-select-option value="">全部状态</a-select-option>
            <a-select-option value="not_started">未开始</a-select-option>
            <a-select-option value="in_progress">进行中</a-select-option>
            <a-select-option value="reviewing">评审中</a-select-option>
            <a-select-option value="revision_needed">需修改</a-select-option>
            <a-select-option value="completed">已完成</a-select-option>
          </a-select>
        </a-col>
      </a-row>
    </a-card>

    <!-- 开题报告列表 -->
    <a-card :bordered="false" class="table-card">
      <a-table
        :columns="columns"
        :data-source="proposalList"
        :loading="loading"
        :pagination="false"
        @change="handleTableChange"
        row-key="id"
      >
        <!-- 状态列 -->
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'">
            <a-tag :color="getStatusColor(record.status)">
              {{ getStatusText(record.status) }}
            </a-tag>
          </template>

          <!-- 操作列 -->
          <template v-else-if="column.key === 'action'">
            <a-space>
              <a-button
                type="primary"
                size="small"
                @click="handleReview(record)"
                :disabled="record.status === 'completed'"
              >
                评阅
              </a-button>
              <a-button
                type="link"
                size="small"
                @click="previewFile(record.file_url)"
                v-if="record.file_url"
              >
                查看文件
              </a-button>
              <a-button
                type="link"
                size="small"
                @click="viewDetail(record)"
              >
                查看详情
              </a-button>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- 评阅弹窗 -->
    <a-modal
      v-model:open="dialogVisible"
      title="开题报告评阅"
      @ok="submitReview"
      @cancel="dialogVisible = false"
      :confirmLoading="submitting"
      width="800px"
      centered
      :maskClosable="false"
      :destroyOnClose="true"
    >
      <a-form
        ref="reviewFormRef"
        :model="reviewForm"
        :rules="formRules"
        layout="vertical"
      >
        <!-- 评审结果 -->
        <a-form-item label="评审结果" required>
          <a-select
            v-model:value="reviewForm.status"
            @change="handleStatusChange"
          >
            <a-select-option value="revision_needed">需要修改</a-select-option>
            <a-select-option value="completed">通过</a-select-option>
          </a-select>
        </a-form-item>

        <!-- 评分项 -->
        <template v-if="reviewForm.status === 'completed'">
          <a-row :gutter="16">
            <a-col :span="12">
              <a-form-item label="研究背景评分" required>
                <a-input-number
                  v-model:value="reviewForm.researchBackgroundScore"
                  :min="0"
                  :max="100"
                  style="width: 100%"
                />
              </a-form-item>
            </a-col>
            <a-col :span="12">
              <a-form-item label="技术路线评分" required>
                <a-input-number
                  v-model:value="reviewForm.technicalRouteScore"
                  :min="0"
                  :max="100"
                  style="width: 100%"
                />
              </a-form-item>
            </a-col>
          </a-row>

          <a-row :gutter="16">
            <a-col :span="12">
              <a-form-item label="可行性分析评分" required>
                <a-input-number
                  v-model:value="reviewForm.feasibilityScore"
                  :min="0"
                  :max="100"
                  style="width: 100%"
                />
              </a-form-item>
            </a-col>
            <a-col :span="12">
              <a-form-item label="创新点评分" required>
                <a-input-number
                  v-model:value="reviewForm.innovationScore"
                  :min="0"
                  :max="100"
                  style="width: 100%"
                />
              </a-form-item>
            </a-col>
          </a-row>

          <a-form-item label="总分">
            <a-input-number
              v-model:value="reviewForm.totalScore"
              :min="0"
              :max="100"
              disabled
              style="width: 100%"
            />
          </a-form-item>
        </template>

        <!-- 评语项 -->
        <a-form-item label="研究背景评语" required>
          <a-textarea
            v-model:value="reviewForm.researchBackgroundComment"
            :rows="3"
          />
        </a-form-item>

        <a-form-item label="技术路线评语" required>
          <a-textarea
            v-model:value="reviewForm.technicalRouteComment"
            :rows="3"
          />
        </a-form-item>

        <a-form-item label="可行性分析评语" required>
          <a-textarea
            v-model:value="reviewForm.feasibilityComment"
            :rows="3"
          />
        </a-form-item>

        <a-form-item label="创新点评语" required>
          <a-textarea
            v-model:value="reviewForm.innovationComment"
            :rows="3"
          />
        </a-form-item>

        <a-form-item label="总体评语" required>
          <a-textarea
            v-model:value="reviewForm.generalComment"
            :rows="3"
          />
        </a-form-item>

        <a-form-item label="改进建议" required>
          <a-textarea
            v-model:value="reviewForm.improvementSuggestions"
            :rows="3"
          />
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- 详情弹窗 -->
    <a-modal
      v-model:open="detailVisible"
      title="开题报告详情"
      width="800px"
      centered
      @cancel="detailVisible = false"
    >
      <a-descriptions bordered :column="2">
        <a-descriptions-item label="学生姓名">
          {{ currentDetail?.student_name }}
        </a-descriptions-item>
        <a-descriptions-item label="学号">
          {{ currentDetail?.student_id }}
        </a-descriptions-item>
        <a-descriptions-item label="提交时间">
          {{ formatDateTime(currentDetail?.submit_time) }}
        </a-descriptions-item>
        <a-descriptions-item label="评审时间">
          {{ formatDateTime(currentDetail?.review_time) }}
        </a-descriptions-item>
        <a-descriptions-item label="状态">
          <a-tag :color="getStatusColor(currentDetail?.status)">
            {{ getStatusText(currentDetail?.status) }}
          </a-tag>
        </a-descriptions-item>
        <a-descriptions-item label="总分">
          {{ currentDetail?.total_score }}
        </a-descriptions-item>
      </a-descriptions>

      <a-divider>评分详情</a-divider>

      <a-descriptions bordered :column="1">
        <a-descriptions-item label="研究背景">
          分数：{{ currentDetail?.research_background_score }}
          <br>
          评语：{{ currentDetail?.research_background_comment }}
        </a-descriptions-item>
        <!-- 其他评分项保持相同结构 -->
      </a-descriptions>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch, computed } from 'vue'
import { ElMessage, FormInstance } from 'element-plus'
import { getTeacherProposals, reviewProposal, getProposalDetail, updateProposalReview } from '@/api/proposalReview'
import { formatDateTime } from '@/utils/date'
import { useUserStore } from '@/stores/user'
import { getFileUrl } from '@/utils/file'
import { Document } from '@element-plus/icons-vue'
import type { ProposalReview } from '@/api/proposalReview'
import { message } from 'ant-design-vue'

const userStore = useUserStore()
const loading = ref(false)
const proposalList = ref<ProposalReview[]>([])
const dialogVisible = ref(false)
const detailVisible = ref(false)
const currentDetail = ref<ProposalReview | null>(null)
const reviewFormRef = ref<FormInstance>()

// 定义 emit
const emit = defineEmits(['success'])

// 定义评审表单的类型
interface ReviewForm {
  researchBackgroundScore: number
  technicalRouteScore: number
  feasibilityScore: number
  innovationScore: number
  totalScore: number
  researchBackgroundComment: string
  technicalRouteComment: string
  feasibilityComment: string
  innovationComment: string
  generalComment: string
  improvementSuggestions: string
  status: 'not_started' | 'in_progress' | 'reviewing' | 'revision_needed' | 'completed'
}

// 初始化评审表单
const reviewForm = ref<ReviewForm>({
  researchBackgroundScore: 0,
  technicalRouteScore: 0,
  feasibilityScore: 0,
  innovationScore: 0,
  totalScore: 0,
  researchBackgroundComment: '',
  technicalRouteComment: '',
  feasibilityComment: '',
  innovationComment: '',
  generalComment: '',
  improvementSuggestions: '',
  status: 'reviewing'
})

// 当前评审的记录ID
const currentReviewId = ref<number | null>(null)

const getStatusColor = (status: string) => {
  const colorMap = {
    'not_started': 'default',
    'in_progress': 'processing',
    'reviewing': 'warning',
    'revision_needed': 'error',
    'completed': 'success'
  }
  return colorMap[status] || 'default'
}

const getStatusText = (status: string) => {
  const statusMap = {
    'not_started': '未开始',
    'in_progress': '进行中',
    'reviewing': '评审中',
    'revision_needed': '需修改',
    'completed': '已完成'
  }
  return statusMap[status] || status
}

const loadProposals = async () => {
  loading.value = true
  try {
    const { data } = await getTeacherProposals(userStore.userId)
    proposalList.value = data
  } catch (error) {
    console.error('加载开题报告列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleReview = (row: ProposalReview) => {
  currentReviewId.value = row.id
  // 如果有现有评审数据，则填充表单
  reviewForm.value = {
    researchBackgroundScore: row.research_background_score || 0,
    technicalRouteScore: row.technical_route_score || 0,
    feasibilityScore: row.feasibility_score || 0,
    innovationScore: row.innovation_score || 0,
    totalScore: row.total_score || 0,
    researchBackgroundComment: row.research_background_comment || '',
    technicalRouteComment: row.technical_route_comment || '',
    feasibilityComment: row.feasibility_comment || '',
    innovationComment: row.innovation_comment || '',
    generalComment: row.general_comment || '',
    improvementSuggestions: row.improvement_suggestions || '',
    status: row.status || 'reviewing'
  }
  dialogVisible.value = true
}

// 计算总分
const calculateTotalScore = computed(() => {
  if (reviewForm.value.status !== 'completed') return 0
  
  const {
    researchBackgroundScore = 0,
    technicalRouteScore = 0,
    feasibilityScore = 0,
    innovationScore = 0
  } = reviewForm.value

  return Number(((
    researchBackgroundScore +
    technicalRouteScore +
    feasibilityScore +
    innovationScore
  ) / 4).toFixed(2))
})

// 监听分数变化自动计算总分
watch(
  [
    () => reviewForm.value.researchBackgroundScore,
    () => reviewForm.value.technicalRouteScore,
    () => reviewForm.value.feasibilityScore,
    () => reviewForm.value.innovationScore
  ],
  () => {
    if (reviewForm.value.status === 'completed') {
      reviewForm.value.totalScore = calculateTotalScore.value
    }
  }
)

// 提交评审
const submitReview = async () => {
  if (!reviewFormRef.value) return
  
  try {
    await reviewFormRef.value.validate()
    
    // 准备提交数据
    const submitData = {
      researchBackgroundScore: reviewForm.value.researchBackgroundScore,
      technicalRouteScore: reviewForm.value.technicalRouteScore,
      feasibilityScore: reviewForm.value.feasibilityScore,
      innovationScore: reviewForm.value.innovationScore,
      totalScore: reviewForm.value.totalScore,
      researchBackgroundComment: reviewForm.value.researchBackgroundComment,
      technicalRouteComment: reviewForm.value.technicalRouteComment,
      feasibilityComment: reviewForm.value.feasibilityComment,
      innovationComment: reviewForm.value.innovationComment,
      generalComment: reviewForm.value.generalComment,
      improvementSuggestions: reviewForm.value.improvementSuggestions,
      status: reviewForm.value.status
    }

    await reviewProposal(currentReviewId.value, submitData)
    
    message.success(
      reviewForm.value.status === 'completed' 
        ? '评审已通过，进度已更新' 
        : '已要求学生修改'
    )
    
    dialogVisible.value = false
    emit('success')
    
    // 添加刷新数据的调用
    await loadProposals()
    
  } catch (error) {
    console.error('提交评审失败:', error)
    ElMessage.error('提交评审失败，请重试')
  }
}

const viewDetail = async (row: ProposalReview) => {
  try {
    const { data } = await getProposalDetail(row.id)
    currentDetail.value = data
    detailVisible.value = true
  } catch (error) {
    console.error('获取详情失败:', error)
  }
}

const previewFile = (fileUrl: string) => {
  if (!fileUrl) {
    ElMessage.warning('文件不存在')
    return
  }

  try {
    const previewUrl = getFileUrl(fileUrl)
    window.open(previewUrl, '_blank')
  } catch (error) {
    console.error('文件预览失败:', error)
    ElMessage.error('文件预览失败')
  }
}

// 处理评审结果变化
const handleStatusChange = (value: string) => {
  if (value === 'revision_needed') {
    // 清空所有分数
    reviewForm.value.researchBackgroundScore = 0
    reviewForm.value.technicalRouteScore = 0
    reviewForm.value.feasibilityScore = 0
    reviewForm.value.innovationScore = 0
    reviewForm.value.totalScore = 0
  }
}

// 动态表单验证规则
const formRules = computed(() => ({
  // 分数验证规则仅在选择"通过"时生效
  ...(reviewForm.value.status === 'completed' ? {
    researchBackgroundScore: [{ required: true, message: '请填写研究背景分数', trigger: 'blur' }],
    technicalRouteScore: [{ required: true, message: '请填写技术路线分数', trigger: 'blur' }],
    feasibilityScore: [{ required: true, message: '请填写可行性分析分数', trigger: 'blur' }],
    innovationScore: [{ required: true, message: '请填写创新点分数', trigger: 'blur' }]
  } : {})
}))

onMounted(() => {
  loadProposals()
})

// 表格列定义
const columns = [
  {
    title: '学生姓名',
    dataIndex: 'student_name',
    key: 'student_name',
    width: 120
  },
  {
    title: '学号',
    dataIndex: 'student_id',
    key: 'student_id',
    width: 120
  },
  {
    title: '提交时间',
    dataIndex: 'submit_time',
    key: 'submit_time',
    width: 180,
    customRender: ({ text }) => formatDateTime(text)
  },
  {
    title: '状态',
    dataIndex: 'status',
    key: 'status',
    width: 120
  },
  {
    title: '总分',
    dataIndex: 'total_score',
    key: 'total_score',
    width: 100
  },
  {
    title: '操作',
    key: 'action',
    width: 280,
    fixed: 'right'
  }
]
</script>

<style scoped>
.proposal-review {
  padding: 24px;
}

.filter-card {
  margin-bottom: 24px;
}

.table-card {
  margin-bottom: 24px;
}

:deep(.ant-form-item) {
  margin-bottom: 24px;
}
</style> 