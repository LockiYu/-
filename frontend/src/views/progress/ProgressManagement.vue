<template>
  <div class="app-container">
    <!-- 进度阶段设置 -->
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>进度阶段设置</span>
          <div class="header-actions">
            <span class="total-weight" :class="{ 'weight-warning': currentTotalWeight !== 100 }">
              未取消阶段权重总和: {{ currentTotalWeight }}%
            </span>
          </div>
        </div>
      </template>

      <el-table
        v-loading="stageLoading"
        :data="stageList"
        border
        style="width: 100%"
      >
        <el-table-column prop="name" label="阶段名称" width="150" />
        <el-table-column prop="type" label="阶段类型" min-width="65" show-overflow-tooltip>
          <template #default="{ row }">
            {{ getStageText(row.type) }}
          </template>
        </el-table-column>
        <el-table-column prop="startTime" label="开始时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.start_time) }}
          </template>
        </el-table-column>
        <el-table-column prop="endTime" label="截止时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.end_time) }}
          </template>
        </el-table-column>
        <el-table-column prop="weight" label="评分权重" width="100">
          <template #default="{ row }">
            {{ row.weight }}%
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStageStatusType(row.status)">
              {{ getStageStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120" v-if="canManageStages">
          <template #default="{ row }">
            <el-button
              link
              type="primary"
              @click="handleEditStage(row)"
            >
              编辑
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 进度监控 -->
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>进度监控</span>
          <div class="filter-container">
            <el-input
              v-model="queryParams.keyword"
              placeholder="学生姓名/学号"
              style="width: 200px"
              class="filter-item"
              clearable
              @keyup.enter="handleQuery"
            />
            <el-select
              v-model="queryParams.className"
              placeholder="选择班级"
              style="width: 130px"
              class="filter-item"
              clearable
            >
              <el-option
                v-for="className in classOptions"
                :key="className"
                :label="className"
                :value="className"
              />
            </el-select>
            <el-select
              v-model="queryParams.supervisorId"
              placeholder="指导教师"
              style="width: 130px"
              class="filter-item"
              clearable
            >
              <el-option
                v-for="teacher in teacherOptions"
                :key="teacher.id"
                :label="teacher.name"
                :value="teacher.id"
              />
            </el-select>
            <el-select
              v-model="queryParams.stage"
              placeholder="当前阶段"
              style="width: 130px"
              class="filter-item"
              clearable
            >
              <el-option
                v-for="stage in stageList"
                :key="stage.type"
                :label="stage.name"
                :value="stage.type"
              />
            </el-select>
            <el-select
              v-model="queryParams.status"
              placeholder="完成状态"
              style="width: 130px"
              class="filter-item"
              clearable
            >
              <el-option label="未开始" value="pending" />
              <el-option label="已提交" value="submitted" />
              <el-option label="审核中" value="reviewing" />
              <el-option label="需要修改" value="revision_needed" />
              <el-option label="已通过" value="approved" />
              <el-option label="已拒绝" value="rejected" />
              <el-option label="已逾期" value="overdue" />
            </el-select>
            <el-button type="primary" @click="handleQuery">查询</el-button>
            <el-button @click="resetQuery">重置</el-button>
            <el-button type="warning" @click="handleExport">导出进度</el-button>
          </div>
        </div>
      </template>

      <!-- 进度统计 -->
      <div class="statistics-container">
        <el-row :gutter="20">
          <el-col :span="6">
            <div class="statistics-item">
              <div class="statistics-title">总人数</div>
              <div class="statistics-value">{{ statistics.totalStudents }}</div>
            </div>
          </el-col>
          <el-col :span="6">
            <div class="statistics-item warning">
              <div class="statistics-title">进行中</div>
              <div class="statistics-value">{{ statistics.inProgress }}</div>
            </div>
          </el-col>
          <el-col :span="6">
            <div class="statistics-item success">
              <div class="statistics-title">已完成</div>
              <div class="statistics-value">{{ statistics.completed }}</div>
            </div>
          </el-col>
          <el-col :span="6">
            <div class="statistics-item danger">
              <div class="statistics-title">已逾期</div>
              <div class="statistics-value">{{ statistics.overdue }}</div>
            </div>
          </el-col>
        </el-row>
      </div>

      <!-- 进度列表 -->
      <el-table
        v-loading="loading"
        :data="progressList"
        border
        style="width: 100%"
      >
        <el-table-column 
          prop="student_name" 
          label="学生姓名" 
          min-width="100"
          show-overflow-tooltip
        />
        <el-table-column 
          prop="student_id" 
          label="学号" 
          min-width="120"
          show-overflow-tooltip
        />
        <el-table-column 
          prop="class_name" 
          label="班级" 
          min-width="120"
          show-overflow-tooltip
        />
        <el-table-column 
          label="指导教师" 
          min-width="150"
          show-overflow-tooltip
        >
          <template #default="{ row }">
            {{ row.supervisor_name }}
            <el-tag size="small" v-if="row.supervisor_title">
              {{ row.supervisor_title }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column 
          prop="stage_name" 
          label="当前阶段" 
          min-width="140"
          show-overflow-tooltip
        />
        <el-table-column 
          label="状态" 
          min-width="100"
          align="center"
        >
          <template #default="{ row }">
            <el-tag :type="getProgressStatusType(row.record_status)">
              {{ getProgressStatusText(row.record_status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column 
          label="操作" 
          min-width="100"
          fixed="right"
          align="center"
        >
          <template #default="{ row }">
            <el-button
              link
              type="primary"
              @click="handleViewDetails(row)"
            >
              查看详情
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 添加分页器 -->
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

    <!-- 提交对话框 -->
    <el-dialog
      v-model="submitDialogVisible"
      :title="getSubmitDialogTitle"
      width="600px"
      :close-on-click-modal="false"
    >
      <el-form
        ref="submitFormRef"
        :model="submitForm"
        :rules="submitRules"
        label-width="100px"
      >
        <el-form-item label="文件" prop="file">
          <el-upload
            class="upload-demo"
            :action="uploadUrl"
            :headers="uploadHeaders"
            :on-success="handleUploadSuccess"
            :on-error="handleUploadError"
            :before-upload="beforeUpload"
          >
            <el-button type="primary">选择文件</el-button>
            <template #tip>
              <div class="el-upload__tip">
                请上传PDF文件，且不超过20MB
              </div>
            </template>
          </el-upload>
        </el-form-item>
        <el-form-item label="备注" prop="comment">
          <el-input
            v-model="submitForm.comment"
            type="textarea"
            :rows="4"
            placeholder="请输入备注说明"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="submitDialogVisible = false">取 消</el-button>
          <el-button type="primary" @click="submitProgress">确 定</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 审核对话框 -->
    <el-dialog
      v-model="reviewDialogVisible"
      title="进度审核"
      width="500px"
      :close-on-click-modal="false"
    >
      <el-form
        ref="reviewFormRef"
        :model="reviewForm"
        :rules="reviewRules"
        label-width="100px"
      >
        <el-form-item label="审核结果" prop="status">
          <el-radio-group v-model="reviewForm.status">
            <el-radio label="completed">通过</el-radio>
            <el-radio label="rejected">驳回</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="审核意见" prop="comment">
          <el-input
            v-model="reviewForm.comment"
            type="textarea"
            :rows="4"
            placeholder="请输入审核意见"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="reviewDialogVisible = false">取 消</el-button>
          <el-button type="primary" @click="submitReview">确 定</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 阶段编辑对话框 -->
    <el-dialog
      title="编辑阶段"
      v-model="stageDialogVisible"
      width="500px"
    >
      <el-form
        ref="stageFormRef"
        :model="stageForm"
        :rules="stageRules"
        label-width="100px"
      >
        <el-form-item label="阶段名称" prop="name">
          <el-input v-model="stageForm.name" />
        </el-form-item>
        <el-form-item label="阶段类型" prop="type">
          <el-select v-model="stageForm.type" placeholder="请选择阶段类型">
            <el-option
              v-for="item in stageTypes"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="时间范围" prop="timeRange">
          <el-date-picker
            v-model="stageForm.timeRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
          />
        </el-form-item>
        <el-form-item label="评分权重" prop="weight">
          <el-input-number
            v-model="stageForm.weight"
            :min="0"
            :max="100"
            :step="5"
          />
          <span class="weight-unit">%</span>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select 
            v-model="stageForm.status" 
            placeholder="请选择状态"
            @change="handleStatusChange"
          >
            <el-option
              v-for="option in statusOptions"
              :key="option.value"
              :label="option.label"
              :value="option.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="阶段说明" prop="description">
          <el-input
            v-model="stageForm.description"
            type="textarea"
            :rows="3"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="stageDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleStageSubmit">确定</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 进度详情对话框 -->
    <el-dialog
      v-model="detailsDialogVisible"
      title="进度详情"
      width="800px"
    >
      <el-descriptions :column="2" border>
        <!-- 基本信息 -->
        <el-descriptions-item label="学生姓名">
          {{ currentProgress?.student_name }}
        </el-descriptions-item>
        <el-descriptions-item label="学号">
          {{ currentProgress?.student_id }}
        </el-descriptions-item>
        <el-descriptions-item label="班级">
          {{ currentProgress?.class_name }}
        </el-descriptions-item>
        <el-descriptions-item label="指导教师">
          {{ currentProgress?.supervisor_name }}
          <el-tag size="small" v-if="currentProgress?.supervisor_title">
            {{ currentProgress?.supervisor_title }}
          </el-tag>
        </el-descriptions-item>
        
        <!-- 当前阶段信息 -->
        <el-descriptions-item label="当前阶段">
          {{ currentProgress?.stage_name }}
        </el-descriptions-item>
        <el-descriptions-item label="阶段状态">
          <el-tag :type="getProgressStatusType(currentProgress?.record_status)">
            {{ getProgressStatusText(currentProgress?.record_status) }}
          </el-tag>
        </el-descriptions-item>
        
        <!-- 时间信息 -->
        <el-descriptions-item label="提交时间" :span="2">
          {{ formatDateTime(currentProgress?.submit_time) || '暂未提交' }}
        </el-descriptions-item>
        <el-descriptions-item label="审核时间" :span="2">
          {{ formatDateTime(currentProgress?.review_time) || '暂未审核' }}
        </el-descriptions-item>
        
        <!-- 评分和评语 -->
        <el-descriptions-item label="得分" v-if="currentProgress?.score">
          {{ currentProgress?.score }}分
        </el-descriptions-item>
        
        <!-- 文件信息 -->
        <el-descriptions-item label="提交文件" :span="2">
          <el-link 
            v-if="currentProgress?.file_url" 
            type="primary" 
            :href="currentProgress?.file_url" 
            target="_blank"
          >
            查看文件
          </el-link>
          <span v-else>暂无文件</span>
        </el-descriptions-item>
        
        <!-- 备注信息 -->
        <el-descriptions-item label="学生备注" :span="2">
          {{ currentProgress?.comment || '暂无备注' }}
        </el-descriptions-item>
        <el-descriptions-item label="审核评语" :span="2">
          {{ currentProgress?.review_comment || '暂无评语' }}
        </el-descriptions-item>
      </el-descriptions>

      <!-- 阶段进度时间线 -->
      <div class="progress-timeline-container">
        <h4 class="timeline-title">阶段进度</h4>
        <el-timeline>
          <el-timeline-item
            v-for="stage in stageList"
            :key="stage.id"
            :type="getProgressStatusType(stage.status)"
            :timestamp="formatDateTime(stage.start_time)"
            :hollow="stage.status === 'pending'"
          >
            <div class="timeline-content">
              <h4>{{ stage.name }}</h4>
              <div class="timeline-info">
                <p>
                  <span class="info-label">权重：</span>
                  <span class="info-value">{{ stage.weight }}%</span>
                </p>
                <p>
                  <span class="info-label">截止时间：</span>
                  <span class="info-value">{{ formatDateTime(stage.end_time) }}</span>
                </p>
                <p>
                  
                  
                </p>
                <p>
                  <span class="info-label">说明：</span>
                  <span class="info-value">{{ stage.description }}</span>
                </p>
                <p>
                  <span class="info-label">状态：</span>
                  <span class="info-value">
                    <el-tag :type="getStageStatusType(stage.status)">
                      {{ getStageStatusText(stage.status) }}
                    </el-tag>
                  </span>
                </p>
              </div>
            </div>
          </el-timeline-item>
        </el-timeline>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { Check, Warning } from '@element-plus/icons-vue'
import { 
  getStageList, 
  updateStage, 
  getProgressList, 
  exportProgress,
  getStatistics,
  updateStageScore,
  getClassList,
  getTeacherList
} from '@/api/progress'
import * as XLSX from 'xlsx'

const userStore = useUserStore()

// 定义响应式数据
const stageDialogVisible = ref(false)
const detailsDialogVisible = ref(false)
const dialogType = ref('')
const stageList = ref([])
const statistics = ref({
  totalStudents: 0,
  inProgress: 0,
  completed: 0,
  overdue: 0
})

// 表单相关
const submitDialogVisible = ref(false)
const reviewDialogVisible = ref(false)
const submitFormRef = ref(null)
const reviewFormRef = ref(null)
const stageFormRef = ref(null)

const submitForm = ref({
  id: '',
  stage: '',
  file: '',
  comment: ''
})

// 添加类型定义
interface StageForm {
  id?: number
  name: string
  type: string
  timeRange: Date[]
  weight: number
  description: string
  status: string
}

// 修改 ref 的类型声明
const stageForm = ref<StageForm>({
  name: '',
  type: '',
  timeRange: [],
  weight: 0,
  description: '',
  status: 'not_started'
})

const reviewForm = ref({
  id: '',
  status: '',
  comment: ''
})

// 查询参数
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  keyword: '',
  stage: '',
  status: '',
  className: '',
  supervisorId: ''
})

const loading = ref(false)
const total = ref(0)
const progressList = ref([])
const currentProgress = ref(null)

// 获取阶段类型
const getStageType = (type) => {
  const typeMap = {
    task_book: '任务书阶段',
    literature: '文献综述阶段',
    proposal: '开题报告阶段',
    translation: '外文翻译阶段',
    midterm: '中期检查阶段',
    thesis_draft: '论文初稿阶段',
    thesis_review: '论文评审阶段',
    defense_prep: '答辩准备阶段',
    defense: '论文答辩阶段'
  }
  return typeMap[type] || type
}

// 状态和阶段映射
const getStatusText = (status: string) => {
  const statusMap = {
    'not_started': '未开始',
    'in_progress': '进行中',
    'completed': '已完成',
    'cancelled': '已取消'
  }
  return statusMap[status] || status
}

const getStatusType = (status: string) => {
  const statusMap = {
    'not_started': 'info',
    'in_progress': 'warning',
    'completed': 'success',
    'cancelled': 'danger'
  }
  return statusMap[status] || 'info'
}

const getStageText = (stage: string) => {
  const stageMap: Record<string, string> = {
    task_book: '任务书阶段',
    literature: '文献综述阶段',
    proposal: '开题报告阶段',
    translation: '外文翻译阶段',
    midterm: '中期检查阶段',
    thesis_draft: '论文初稿阶段',
    thesis_review: '论文评审阶段',
    defense_prep: '答辩准备阶段',
    defense: '论文答辩阶段'
  }
  return stageMap[stage] || stage
}

// 计算属性
const getSubmitDialogTitle = computed(() => {
  return `提交${getStageText(submitForm.value.stage)}`
})

// 权限控制
const userRole = computed(() => userStore.userInfo?.role)

const canManageStages = computed(() => {
  return userStore.userInfo?.role === 'superadmin'
})

// 处理函数
const handleQuery = async () => {
  try {
    loading.value = true
    // 重置到第一页
    queryParams.pageNum = 1
    await initProgressData()
  } catch (error) {
    console.error('查询失败:', error)
    ElMessage.error(error.message || '查询失败')
  } finally {
    loading.value = false
  }
}

const resetQuery = () => {
  queryParams.pageNum = 1
  queryParams.pageSize = 10
  queryParams.keyword = ''
  queryParams.stage = ''
  queryParams.status = ''
  queryParams.className = ''
  queryParams.supervisorId = ''
  handleQuery()
}

const handleSubmit = (row: any) => {
  submitForm.value.id = row.id
  submitForm.value.stage = row.stage
  submitForm.value.file = ''
  submitForm.value.comment = ''
  submitDialogVisible.value = true
}

const handleReview = (row: any) => {
  reviewForm.value.id = row.id
  reviewForm.value.status = 'completed'
  reviewForm.value.comment = ''
  reviewDialogVisible.value = true
}

const handleDetail = (row: any) => {
  // TODO: 实现详情查看逻辑
}

const submitProgress = async () => {
  if (!submitFormRef.value) return
  
  await submitFormRef.value.validate(async (valid: boolean) => {
    if (valid) {
      try {
        const formData = new FormData()
        formData.append('file', submitForm.value.file)
        formData.append('comment', submitForm.value.comment)
        formData.append('stage', submitForm.value.stage)
        
        await submitFile(formData)
        ElMessage.success('提交成功')
        submitDialogVisible.value = false
        handleQuery()
      } catch (error: any) {
        ElMessage.error(error.response?.data?.message || '提交失败')
      }
    }
  })
}

const submitReview = async () => {
  if (!reviewFormRef.value) return
  
  await reviewFormRef.value.validate(async (valid: boolean) => {
    if (valid) {
      try {
        await updateProgress({
          progress_id: reviewForm.value.id,
          status: reviewForm.value.status,
          comment: reviewForm.value.comment
        })
        ElMessage.success('审核完成')
        reviewDialogVisible.value = false
        handleQuery()
      } catch (error: any) {
        ElMessage.error(error.response?.data?.message || '审核失败')
      }
    }
  })
}

const handleSizeChange = (val: number) => {
  queryParams.pageSize = val
  queryParams.pageNum = 1
  initProgressData()
}

const handleCurrentChange = (val: number) => {
  queryParams.pageNum = val
  initProgressData()
}

// 文件上传相关
const uploadUrl = '/api/upload'
const uploadHeaders = computed(() => ({
  Authorization: userStore.token ? `Bearer ${userStore.token}` : ''
}))

const handleUploadError = () => {
  ElMessage.error('文件上传失败')
}

const beforeUpload = (file: File) => {
  const isPDF = file.type === 'application/pdf'
  const isLt20M = file.size / 1024 / 1024 < 20

  if (!isPDF) {
    ElMessage.error('只能上传PDF文件!')
  }
  if (!isLt20M) {
    ElMessage.error('文件大小不能超过20MB!')
  }
  return isPDF && isLt20M
}

const handleUploadSuccess = (response: any) => {
  if (response.code === 200) {
    submitForm.value.file = response.data.url
    ElMessage.success('文件上传成功')
  } else {
    ElMessage.error(response.message || '文件上传失败')
  }
}

// 分离阶段管理和进度监控的加载状态
const stageLoading = ref(false)
const progressLoading = ref(false)

// 初始化阶段数据
const initStageData = async () => {
  try {
    stageLoading.value = true
    console.log('开始获取阶段列表...')
    const res = await getStageList()
    console.log('获取到的数据:', res)
    
    if (!res.data) {
      console.error('返回数据格式错误:', res)
      ElMessage.error('数据格式错误')
      return
    }
    
    stageList.value = res.data.sort((a, b) => a.id - b.id)
    console.log('处理后的列表:', stageList.value)
    
    // 计算未取消阶段的总权重
    const totalWeight = stageList.value
      .filter(stage => stage.status !== 'cancelled')
      .reduce((sum, stage) => sum + stage.weight, 0)

    // 如果总权重不等于100%显示警告
    if (totalWeight !== 100) {
      ElMessage.warning({
        message: `当前未取消阶段的权重总和为${totalWeight}%，请调整各阶段权重使总和为100%`,
        duration: 5000,
        showClose: true
      })
    }
  } catch (error: any) {
    console.error('获取阶段列表失败:', error)
    ElMessage.error('获取阶段列表失败')
  } finally {
    stageLoading.value = false
  }
}

// 初始化进度监控数据
const initProgressData = async () => {
  try {
    loading.value = true
    const response = await getProgressList({
      pageNum: queryParams.pageNum,
      pageSize: queryParams.pageSize,
      keyword: queryParams.keyword,
      stage: queryParams.stage,
      status: queryParams.status,
      className: queryParams.className,    // 添加班级查询参数
      supervisorId: queryParams.supervisorId  // 添加教师查询参数
    })
    
    if (response.code === 200) {
      progressList.value = response.data.list
      total.value = response.data.total
    } else {
      ElMessage.error(response.message || '查询失败')
    }
  } catch (error: any) {
    console.error('查询失败:', error)
    ElMessage.error(error.message || '查询失败')
  } finally {
    loading.value = false
  }
}

// 添加获取统计数据的方法
const fetchStatistics = async () => {
  try {
    console.log('开始获取统计数据');  // 添加日志
    const res = await getStatistics();
    console.log('获取统计数据响应:', res);  // 添加日志
    if (res.code === 200 && res.data) {
      statistics.value = res.data;
      console.log('更新统计数据:', statistics.value);  // 添加日志
    } else {
      console.error('获取统计数据失败:', res);
      ElMessage.warning('获取统计数据失败');
    }
  } catch (error) {
    console.error('获取统计数据失败:', error);
    ElMessage.error('获取统计数据失败');
  }
};

// 在组件挂载时分别初始化数据
onMounted(async () => {
  await Promise.all([
    initStageData(),
    initProgressData(),
    fetchStatistics(),
    fetchOptions()  // 添加获取选项数据的调用
  ])
})

// 修改阶段类型选项
const stageTypes = [
  { label: '任务书阶段', value: 'task_book' },
  { label: '文献综述阶段', value: 'literature' },
  { label: '开题报告阶段', value: 'proposal' },
  { label: '外文翻译阶段', value: 'translation' },
  { label: '中期检查阶段', value: 'midterm' },
  { label: '论文初稿阶段', value: 'thesis_draft' },
  { label: '论文评审阶段', value: 'thesis_review' },
  { label: '答辩准备阶段', value: 'defense_prep' },
  { label: '论文答辩阶段', value: 'defense' }
]

// 添加进度详情相关数据
interface ProgressDetail {
  taskBook: { status: string; submitTime?: string; comment?: string };
  literature: { status: string; submitTime?: string; comment?: string };
  proposal: { status: string; submitTime?: string; comment?: string };
  translation: { status: string; submitTime?: string; comment?: string };
  midterm: { status: string; submitTime?: string; comment?: string };
  review: { status: string; submitTime?: string; comment?: string };
  supervisorReview: { status: string; submitTime?: string; comment?: string };
  peerReview: { status: string; submitTime?: string; comment?: string };
  defense: { status: string; submitTime?: string; comment?: string };
}

const getProgressStatusText = (status: string) => {
  const statusMap = {
    'pending': '未开始',
    'submitted': '已提交',
    'reviewing': '审核中',
    'revision_needed': '需要修改',
    'approved': '已通过',
    'rejected': '已拒绝',
    'overdue': '已逾期',
    'cancelled': '已取消'  // 添加取消状态
  }
  return statusMap[status] || status
}

const getProgressStatusType = (status: string) => {
  const statusMap = {
    'pending': 'info',
    'submitted': 'info',
    'reviewing': 'primary',
    'revision_needed': 'danger',
    'approved': 'success',
    'rejected': 'danger',
    'overdue': 'danger',
    'cancelled': 'info'  // 添加取消状态
  }
  return statusMap[status] || 'info'
}

// 添加缺失的函数
const handleViewDetails = (row: any) => {
  detailsDialogVisible.value = true
  currentProgress.value = row
}

const handleEditStage = (row: any) => {
  dialogType.value = 'edit'
  // 转换日期格式
  stageForm.value = {
    ...row,
    timeRange: [new Date(row.start_time), new Date(row.end_time)],
    id: row.id,
    status: row.status || STAGE_STATUS.NOT_STARTED
  }
  stageDialogVisible.value = true
}

const handleStageSubmit = async () => {
  if (!stageFormRef.value) return
  
  await stageFormRef.value.validate(async (valid: boolean) => {
    if (valid) {
      try {
        // 只验证权重范围，不验证总和
        if (stageForm.value.status !== 'cancelled' && 
            (stageForm.value.weight < 0 || stageForm.value.weight > 100)) {
          ElMessage.warning('权重必须在0-100之间')
          return
        }

        await updateStage(stageForm.value.id, stageForm.value)
        ElMessage.success('修改成功')
        stageDialogVisible.value = false
        await initStageData()  // 刷新数据时会检查总权重
      } catch (error: any) {
        if (error.response?.data?.message) {
          if (error.response.data.message.includes('SQLSTATE')) {
            const message = error.response.data.message.split('MESSAGE_TEXT: ')[1]
            ElMessage.error(message)
          } else {
            ElMessage.error(error.response.data.message)
          }
        } else {
          ElMessage.error(error.message || '操作失败')
        }
      }
    }
  })
}

// 添加表单验证规则
const submitRules = {
  file: [{ required: true, message: '请上传文件', trigger: 'change' }],
  comment: [{ required: true, message: '请输入备注说明', trigger: 'blur' }]
}

const reviewRules = {
  status: [{ required: true, message: '请选择审核结果', trigger: 'change' }],
  comment: [{ required: true, message: '请输入审核意见', trigger: 'blur' }]
}

const stageRules = {
  name: [{ required: true, message: '请输入阶段名称', trigger: 'blur' }],
  type: [{ required: true, message: '请选择阶段类型', trigger: 'change' }],
  timeRange: [{ required: true, message: '请选择时间范围', trigger: 'change' }],
  weight: [
    { required: true, message: '请输入评分权重', trigger: 'change' },
    { type: 'number', min: 0, max: 100, message: '权重必须在0-100之间', trigger: 'change' }
  ],
  status: [{ required: true, message: '请选择状态', trigger: 'change' }],
  description: [{ required: false }]
}

// 添加导出功能
const handleExport = async () => {
  try {
    loading.value = true
    // 获取所有数据(不分页)
    const response = await getProgressList({
      pageNum: 1,
      pageSize: 999999, // 大数字以获取所有数据
      keyword: queryParams.keyword,
      stage: queryParams.stage,
      status: queryParams.status
    })
    
    if (response.code === 200 && response.data.list) {
      // 转换数据格式
      const exportData = response.data.list.map(item => ({
        '学生姓名': item.student_name,
        '学号': item.student_id,
        '班级': item.class_name,
        '指导教师': item.supervisor_name,
        '教师职称': item.supervisor_title || '',
        '当前阶段': item.stage_name,
        '阶段权重': `${item.stage_weight}%`,
        '完成状态': getProgressStatusText(item.record_status),
        '提交时间': item.submit_time ? formatDateTime(item.submit_time) : '',
        '得分': item.score || '',
        '学生备注': item.comment || '',
        '审核评语': item.review_comment || ''
      }))

      // 创建工作簿
      const wb = XLSX.utils.book_new()
      // 创建工作表
      const ws = XLSX.utils.json_to_sheet(exportData)
      // 设置列宽
      const colWidth = [
        { wch: 10 }, // 学生姓名
        { wch: 12 }, // 学号
        { wch: 15 }, // 班级
        { wch: 10 }, // 指导教师
        { wch: 10 }, // 教师职称
        { wch: 15 }, // 当前阶段
        { wch: 10 }, // 阶段权重
        { wch: 10 }, // 完成状态
        { wch: 20 }, // 提交时间
        { wch: 8 },  // 得分
        { wch: 20 }, // 学生备注
        { wch: 20 }  // 审核评语
      ]
      ws['!cols'] = colWidth

      // 将工作表添加到工作簿
      XLSX.utils.book_append_sheet(wb, ws, '进度监控')

      // 生成文件名
      const timestamp = formatDateTime(new Date()).replace(/[: ]/g, '')
      const fileName = `进度监控表_${timestamp}.xlsx`

      // 导出文件
      XLSX.writeFile(wb, fileName)
      ElMessage.success('导出成功')
    } else {
      ElMessage.error(response.message || '导出失败')
    }
  } catch (error: any) {
    console.error('导出失败:', error)
    ElMessage.error(error.message || '导出失败')
  } finally {
    loading.value = false
  }
}

// 添加计算属性
const totalWeight = computed(() => {
  return stageList.value.reduce((sum, stage) => sum + stage.weight, 0)
})

const isWeightValid = computed(() => {
  return totalWeight.value === 100
})

const convertNameToType = (name) => {
  const nameToTypeMap = {
    '任务书阶段': 'task_book',
    '文献综述阶段': 'literature',
    '开题报告阶段': 'proposal',
    '外文翻译阶段': 'translation',
    '中期检查阶段': 'midterm',
    '论文初稿阶段': 'thesis_draft',
    '论文评审阶段': 'thesis_review',
    '答辩准备阶段': 'defense_prep',
    '论文答辩阶段': 'defense'
  }
  return nameToTypeMap[name] || name
}

// 定义状态量
const STAGE_STATUS = {
  NOT_STARTED: 'not_started',
  IN_PROGRESS: 'in_progress',
  COMPLETED: 'completed',
  CANCELLED: 'cancelled'
} as const

// 状态选项
const statusOptions = [
  { label: '未开始', value: STAGE_STATUS.NOT_STARTED },
  { label: '进行中', value: STAGE_STATUS.IN_PROGRESS },
  { label: '已完成', value: STAGE_STATUS.COMPLETED },
  { label: '已取消', value: STAGE_STATUS.CANCELLED }
]

// 修改状态变更检查函数
const checkStatusChange = (newStatus: string, currentStage: any, stageList: any[]) => {
  // 找到当前进行中的阶段
  const inProgressStage = stageList.find(stage => 
    stage.status === 'in_progress' && stage.id !== currentStage.id
  )
  
  if (newStatus === 'in_progress') {
    if (inProgressStage) {
      return {
        valid: false,
        message: '已有正在进行的阶段，不能同时开始新阶段'
      }
    }

    // 检查之前的阶段是否都已完成或取消
    const previousStages = stageList.filter(stage => 
      stage.sequence < currentStage.sequence && 
      stage.id !== currentStage.id
    )
    
    const hasUnfinishedPrevious = previousStages.some(stage => 
      !['completed', 'cancelled'].includes(stage.status)
    )

    if (hasUnfinishedPrevious) {
      return {
        valid: false,
        message: '在当前阶段之前存在未完成或未取消的阶段'
      }
    }
  }

  // 如果有进行中的阶段
  if (inProgressStage) {
    // 检查当前阶段是否在进行中阶段之前
    if (currentStage.sequence < inProgressStage.sequence) {
      if (!['completed', 'cancelled'].includes(newStatus)) {
        return {
          valid: false,
          message: '进行中阶段之前的阶段只能是已完成或已取消状态'
        }
      }
    } 
    // 检查当前阶段是否在进行中阶段之后
    else if (currentStage.sequence > inProgressStage.sequence) {
      if (newStatus === 'completed') {
        return {
          valid: false,
          message: '不能将进行中阶段之后的阶段标记为已完成'
        }
      }
    }
  }

  return { valid: true }
}

// 修改状态变更处理函数
const handleStatusChange = (value: string) => {
  const result = checkStatusChange(value, stageForm.value, stageList.value)
  if (!result.valid) {
    ElMessage.warning(result.message)
    // 重置状态为原值
    stageForm.value.status = stageForm.value.originalStatus
    return
  }
  stageForm.value.status = value
}

// 添加一个显示当前总权重的计算属性
const currentTotalWeight = computed(() => {
  return stageList.value
    .filter(stage => stage.status !== 'cancelled')
    .reduce((sum, stage) => sum + stage.weight, 0)
})

// 添加日期格式化函数
const formatDateTime = (dateStr: string) => {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  }).replace(/\//g, '-')
}

// 添加阶段处理函数
const handleAddStage = () => {
  dialogType.value = 'add'
  stageForm.value = {
    id: 0,
    name: '',
    type: '',
    timeRange: [],
    weight: 0,
    description: '',
    status: STAGE_STATUS.NOT_STARTED
  }
  stageDialogVisible.value = true
}

// 阶段状态映射函数
const getStageStatusText = (status: string) => {
  const statusMap = {
    'not_started': '未开始',
    'in_progress': '进行中',
    'completed': '已完成',
    'cancelled': '已取消'
  }
  return statusMap[status] || status
}

const getStageStatusType = (status: string) => {
  const statusMap = {
    'not_started': 'info',
    'in_progress': 'warning',
    'completed': 'success',
    'cancelled': 'danger'
  }
  return statusMap[status] || 'info'
}

// 添加响应式变量
const stageScores = ref<Record<string, number>>({})
const canEditScore = computed(() => ['teacher', 'admin', 'superadmin'].includes(userRole.value))

// 添加处理分数变化的方法
const handleScoreChange = async (stageType: string, score: number) => {
  try {
    await updateStageScore({
      student_id: currentProgress.value.student_id,
      stage_type: stageType,
      score: score
    })
    
    ElMessage.success('分数更新成功')
    
    // 更新本地数据
    if (currentProgress.value?.scores) {
      const scoreField = `${stageType}_score` as keyof typeof currentProgress.value.scores
      currentProgress.value.scores[scoreField] = score
    }
  } catch (error) {
    console.error('更新分数失败:', error)
    ElMessage.error('更新分数失败')
    // 恢复原值
    if (currentProgress.value?.scores) {
      const scoreField = `${stageType}_score` as keyof typeof currentProgress.value.scores
      stageScores.value[stageType] = currentProgress.value.scores[scoreField] || 0
    }
  }
}

// 添加获取分数的方法
const getStageScore = (stageType: string): number | null => {
  if (!currentProgress.value?.scores) return null
  const scoreField = `${stageType}_score` as keyof typeof currentProgress.value.scores
  return currentProgress.value.scores[scoreField] || null
}

// 添加获取分数标签类型的方法
const getScoreTagType = (score: number | null): string => {
  if (score === null) return 'info'
  if (score >= 90) return 'success'
  if (score >= 75) return 'warning'
  return 'danger'
}

// 添加监听器
watch(() => currentProgress.value, (newVal) => {
  if (newVal?.scores) {
    Object.entries(newVal.scores).forEach(([key, value]) => {
      const stageType = key.replace('_score', '')
      stageScores.value[stageType] = value
    })
  }
}, { immediate: true })

// 监听查询参数变化
watch(queryParams, () => {
  console.log('queryParams changed:', queryParams)
}, { deep: true })

// 添加班级和教师选项
const classOptions = ref<string[]>([])
const teacherOptions = ref<any[]>([])

// 添加获取选项数据的方法
const fetchOptions = async () => {
  try {
    // 获取班级列表
    const classRes = await getClassList()
    if (classRes.code === 200) {
      classOptions.value = classRes.data
    }

    // 获取教师列表
    const teacherRes = await getTeacherList()
    if (teacherRes.code === 200) {
      teacherOptions.value = teacherRes.data
    }
  } catch (error) {
    console.error('获取选项数据失败:', error)
    ElMessage.error('获取选项数据失败')
  }
}
</script>

<style scoped>
.app-container {
  padding: 20px;
}

.filter-container {
  padding-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
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

.upload-demo {
  margin-bottom: 10px;
}

.statistics-container {
  margin-bottom: 20px;
}

.statistics-item {
  padding: 20px;
  border-radius: 4px;
  background-color: #f5f7fa;
  text-align: center;
}

.statistics-item.warning {
  background-color: #fdf6ec;
}

.statistics-item.success {
  background-color: #f0f9eb;
}

.statistics-item.danger {
  background-color: #fef0f0;
}

.statistics-title {
  font-size: 14px;
  color: #606266;
  margin-bottom: 10px;
}

.statistics-value {
  font-size: 24px;
  font-weight: bold;
  color: #303133;
}

.weight-unit {
  margin-left: 8px;
  color: #909399;
}

.total-weight {
  font-size: 14px;
  color: #606266;
}

.weight-warning {
  color: #e6a23c;
  font-weight: bold;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 20px;
}

.progress-timeline-container {
  margin-top: 20px;
  padding: 20px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

.timeline-title {
  margin-bottom: 16px;
  color: #303133;
  font-weight: 500;
}

:deep(.el-descriptions__label) {
  width: 120px;
  font-weight: bold;
}

:deep(.el-timeline-item__content h4) {
  margin: 0;
  font-size: 14px;
  color: #303133;
}

:deep(.el-timeline-item__content p) {
  margin: 5px 0;
  font-size: 13px;
  color: #606266;
}

.timeline-content {
  padding: 8px;
  border-radius: 4px;
  background-color: #fff;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
}

.timeline-info {
  margin-top: 8px;
}

.info-label {
  color: #606266;
  font-weight: 500;
  margin-right: 8px;
  display: inline-block;
  min-width: 70px;
}

.info-value {
  color: #303133;
}

.score-info {
  margin-left: 15px;
}

.timeline-info .el-tag {
  margin-left: 5px;
}

.score-tag {
  margin-left: 16px;
  padding: 2px 8px;
  background-color: #f0f9eb;
  color: #67c23a;
  border-radius: 4px;
  font-weight: 500;
}

:deep(.el-timeline-item__content) {
  min-width: 300px;
}

:deep(.el-timeline-item__timestamp) {
  font-size: 13px;
  color: #909399;
}

:deep(.el-timeline-item__node) {
  background-color: var(--el-color-primary);
}

:deep(.el-timeline-item__node--hollow) {
  background-color: #fff;
  border-color: var(--el-color-primary);
}

.pagination-container {
  margin-top: 15px;
  display: flex;
  justify-content: flex-end;
  padding: 10px 0;
}
</style> 
