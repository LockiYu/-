<template>
  <div class="app-container">
    <!-- 学生进度列表 -->
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>学生进度</span>
          <div class="filter-container">
            <el-input
              v-model="queryParams.studentName"
              placeholder="学生姓名"
              style="width: 200px"
              class="filter-item"
              clearable
              @keyup.enter="handleQuery"
            />
            <el-select
              v-model="queryParams.stage"
              placeholder="进度阶段"
              style="width: 130px"
              class="filter-item"
              clearable
            >
              <el-option label="任务书" value="task" />
              <el-option label="文献综述" value="literature" />
              <el-option label="开题报告" value="proposal" />
              <el-option label="原文翻译" value="translation" />
              <el-option label="中期检查" value="midterm" />
              <el-option label="论文定稿" value="thesis" />
              <el-option label="论文评审" value="review" />
              <el-option label="论文答辩" value="defense" />
            </el-select>
            <el-select
              v-model="queryParams.status"
              placeholder="完成状态"
              style="width: 130px"
              class="filter-item"
              clearable
            >
              <el-option label="未开始" value="not_started" />
              <el-option label="进行中" value="in_progress" />
              <el-option label="待审核" value="pending" />
              <el-option label="已完成" value="completed" />
              <el-option label="已逾期" value="overdue" />
            </el-select>
            <el-button type="primary" @click="handleQuery">查询</el-button>
            <el-button @click="resetQuery">重置</el-button>
          </div>
        </div>
      </template>

      <el-table
        v-loading="loading"
        :data="progressList"
        border
        style="width: 100%"
      >
        <el-table-column type="expand">
          <template #default="{ row }">
            <el-timeline>
              <el-timeline-item
                v-for="(stage, index) in row.stages"
                :key="index"
                :type="getTimelineType(stage.status)"
                :timestamp="stage.deadline"
              >
                <el-card class="timeline-card">
                  <template #header>
                    <div class="timeline-header">
                      <span>{{ getStageText(stage.type) }}</span>
                      <el-tag :type="getStatusType(stage.status)">
                        {{ getStatusText(stage.status) }}
                      </el-tag>
                    </div>
                  </template>
                  <div class="timeline-content">
                    <!-- 文件信息 -->
                    <div v-if="stage.file_url" class="file-section">
                      <span class="file-info">
                        提交时间：{{ stage.submit_time }}
                      </span>
                    </div>

                    <!-- 评审信息 - 所有阶段都展示 -->
                    <div class="review-section">
                      <div class="review-item">
                        <h4>{{ getStageText(stage.type) }}评阅</h4>
                        <div v-if="stage.score !== null" class="score">
                          评分：{{ stage.score }}
                        </div>
                        <div v-if="stage.teacher_comment" class="comments">
                          评语：{{ stage.teacher_comment }}
                        </div>
                      </div>
                    </div>

                    <!-- 时间信息 -->
                    <div class="time-info">
                      <div v-if="stage.review_time" class="review-time">
                        审核时间：{{ stage.review_time }}
                      </div>
                      <div class="deadline">
                        截止时间：{{ stage.deadline }}
                      </div>
                    </div>
                  </div>
                </el-card>
              </el-timeline-item>
            </el-timeline>
          </template>
        </el-table-column>
        <el-table-column prop="studentName" label="学生姓名" width="120" />
        <el-table-column prop="studentId" label="学号" width="120" />
        <el-table-column prop="topicTitle" label="论文题目" min-width="200" />
        <el-table-column prop="currentStage" label="当前阶段" width="120">
          <template #default="{ row }">
            <template v-if="row.currentStage === 'completed'">
              <el-tag type="success">已完全通过</el-tag>
            </template>
            <template v-else>
              {{ getStageText(row.currentStage) }}
            </template>
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

    <!-- 审核对话框 -->
    <el-dialog
      v-model="reviewDialogVisible"
      :title="getReviewDialogTitle(currentStage?.type)"
      width="500px"
    >
      <el-form
        ref="reviewFormRef"
        :model="reviewForm"
        :rules="reviewRules"
        label-width="100px"
      >
        <template v-if="currentStage?.type === 'review'">
          <el-form-item label="评分" prop="score">
            <el-input-number
              v-model="reviewForm.score"
              :min="0"
              :max="100"
              :precision="1"
            />
          </el-form-item>
        </template>

        <el-form-item label="审核结果" prop="result">
          <el-radio-group v-model="reviewForm.result">
            <el-radio label="pass">通过</el-radio>
            <el-radio label="reject">不通过</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item label="审核意见" prop="comments">
          <el-input
            v-model="reviewForm.comments"
            type="textarea"
            :rows="4"
            placeholder="请输入审核意见"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="reviewDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleReviewSubmit">确认</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 详情对话框 -->
    <el-dialog
      v-model="detailsDialogVisible"
      title="进度详情"
      width="800px"
    >
      <el-descriptions :column="2" border>
        <el-descriptions-item label="学生姓名">
          {{ currentProgress?.studentName }}
        </el-descriptions-item>
        <el-descriptions-item label="学号">
          {{ currentProgress?.studentId }}
        </el-descriptions-item>
        <el-descriptions-item label="论文题目" :span="2">
          {{ currentProgress?.topicTitle }}
        </el-descriptions-item>
      </el-descriptions>

      <el-timeline class="progress-timeline">
        <el-timeline-item
          v-for="(stage, index) in currentProgress?.stages"
          :key="index"
          :type="getTimelineType(stage.status)"
          :timestamp="stage.deadline"
        >
          <el-card>
            <template #header>
              <div class="timeline-header">
                <span>{{ getStageText(stage.type) }}</span>
                <el-tag :type="getStatusType(stage.status)">
                  {{ getStatusText(stage.status) }}
                </el-tag>
              </div>
            </template>
            <div class="timeline-content">
              <div v-if="stage.submitTime" class="submit-info">
                提交时间：{{ stage.submitTime }}
              </div>
              <div v-if="stage.file" class="file-info">
                <el-button 
                  link 
                  type="primary"
                  @click="handleDownload(stage.type, row.studentId)"
                >
                  下载文件
                </el-button>
              </div>
              <div v-if="stage.comments" class="review-info">
                <div class="review-title">审核意见：</div>
                <div class="review-content">{{ stage.comments }}</div>
              </div>
            </div>
          </el-card>
        </el-timeline-item>
      </el-timeline>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import type { FormInstance, FormRules } from 'element-plus'
import { ElMessage } from 'element-plus'
import { getProgressStatistics, getProgressList, downloadFile } from '@/api/teacherProgress'

// 查询参数
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  studentName: '',
  stage: '',
  status: ''
})

// 统计数据
const statistics = reactive({
  totalStudents: 0,
  pendingTasks: 0,
  normalProgress: 0,
  abnormalProgress: 0
})

// 进度列表数据
const progressList = ref([])
const total = ref(0)
const loading = ref(false)

// 对话框控制
const reviewDialogVisible = ref(false)
const detailsDialogVisible = ref(false)
const reviewFormRef = ref<FormInstance>()
const currentProgress = ref(null)

// 审核表单
const reviewForm = reactive({
  id: '',
  result: 'pass',
  comments: '',
  score: 0,
})

// 审核表单校验规则
const reviewRules = reactive<FormRules>({
  result: [
    { required: true, message: '请选择审核结果', trigger: 'change' }
  ],
  comments: [
    { required: true, message: '请输入审核意见', trigger: 'blur' }
  ],
  score: [
    { required: true, message: '请输入评分', trigger: 'blur' },
    { type: 'number', min: 0, max: 100, message: '评分范围为0-100', trigger: 'blur' }
  ]
})

// 状态映射函数
const getTimelineType = (status: string) => {
  const typeMap: Record<string, string> = {
    'not_started': 'info',
    'in_progress': 'warning',
    'pending': 'warning',
    'completed': 'success',
    'overdue': 'danger'
  }
  return typeMap[status]
}

const getStatusType = (status: string) => {
  const typeMap: Record<string, string> = {
    'not_started': 'info',
    'in_progress': 'warning',
    'pending': 'warning',
    'completed': 'success',
    'overdue': 'danger'
  }
  return typeMap[status]
}

const getStatusText = (status: string) => {
  const textMap: Record<string, string> = {
    'not_started': '未开始',
    'in_progress': '进行中',
    'pending': '待审核',
    'completed': '已完成',
    'overdue': '已逾期'
  }
  return textMap[status]
}

const getStageText = (stage: string) => {
  if (!stage) return '未开始';
  if (stage === 'completed') return '已完全通过';
  
  const stageMap: Record<string, string> = {
    'task_book': '任务书',
    'literature': '文献综述',
    'proposal': '开题报告',
    'translation': '原文翻译',
    'midterm': '中期检查',
    'thesis_submit': '论文定稿',
    'advisor_review': '导师评审',
    'peer_review': '同行评审',
    'defense': '论文答辩'
  }
  return stageMap[stage] || stage;
}

const getReviewDialogTitle = (stageType: string) => {
  return `${getStageText(stageType)}审核`
}

// 处理函数
const handleQuery = async () => {
  loading.value = true
  try {
    const response = await getProgressList(queryParams)
    if (response.code === 200) {
      progressList.value = response.data.list
      total.value = response.data.total
    }
  } catch (error: any) {
    ElMessage.error(error.message || '查询失败')
  } finally {
    loading.value = false
  }
}

const resetQuery = () => {
  queryParams.studentName = ''
  queryParams.stage = ''
  queryParams.status = ''
  handleQuery()
}

const handleReview = (row: any) => {
  currentProgress.value = row
  reviewForm.id = row.id
  reviewForm.result = 'pass'
  reviewForm.comments = ''
  reviewDialogVisible.value = true
}

const handleViewDetails = (row: any) => {
  currentProgress.value = row
  detailsDialogVisible.value = true
}

const handleDownload = async (row) => {
  if (!row.file_url) {
    ElMessage.warning('文件不存在')
    return
  }

  try {
    const fileUrl = getFileUrl(row.file_url)
    window.open(fileUrl, '_blank')
  } catch (error) {
    console.error('文件下载失败:', error)
    ElMessage.error('文件下载失败')
  }
}

const handleReviewSubmit = async () => {
  if (!reviewFormRef.value) return

  await reviewFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        // TODO: 调用审核API
        ElMessage.success('审核完成')
        reviewDialogVisible.value = false
        handleQuery()
        getStatistics()
      } catch (error: any) {
        ElMessage.error(error.message || '审核失败')
      }
    }
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

const getStatistics = async () => {
  try {
    const response = await getProgressStatistics()
    if (response.code === 200) {
      Object.assign(statistics, response.data)
    }
  } catch (error: any) {
    ElMessage.error(error.message || '获取统计数据失败')
  }
}

// 初始化
onMounted(() => {
  getStatistics()
  handleQuery()
})
</script>

<style scoped>
.app-container {
  padding: 20px;
}

.statistics-row {
  margin-bottom: 20px;
}

.statistics-card {
  .statistics-value {
    font-size: 24px;
    font-weight: bold;
    text-align: center;
    
    &.warning {
      color: #E6A23C;
    }
    
    &.success {
      color: #67C23A;
    }
    
    &.danger {
      color: #F56C6C;
    }
  }
}

.box-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.filter-container {
  display: flex;
  gap: 10px;
}

.timeline-card {
  margin-bottom: 10px;
}

.timeline-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.timeline-content {
  padding: 10px 0;
}

.comments {
  margin-top: 10px;
  color: #666;
  font-size: 14px;
}

.progress-timeline {
  margin-top: 20px;
  padding: 20px;
}

.submit-info,
.file-info {
  margin-bottom: 10px;
}

.review-info {
  .review-title {
    font-weight: bold;
    margin-bottom: 5px;
  }
  
  .review-content {
    color: #666;
  }
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

.review-section {
  margin: 15px 0;
  border-left: 3px solid #409EFF;
  padding-left: 15px;
}

.review-item {
  margin-bottom: 15px;
  
  h4 {
    margin: 0 0 10px 0;
    color: #409EFF;
  }
}

.score {
  font-weight: bold;
  color: #303133;
  margin-bottom: 5px;
}

.file-section {
  display: flex;
  align-items: center;
  gap: 15px;
  
  .file-info {
    color: #909399;
    font-size: 14px;
  }
}
</style> 