<template>
  <div class="defense-scoring">
    <a-card :bordered="false">
      <!-- 状态筛选 -->
      <div class="table-toolbar">
        <a-select
          v-model:value="searchParams.status"
          style="width: 150px"
          placeholder="答辩状态"
          @change="handleSearch"
        >
          <a-select-option value="">全部状态</a-select-option>
          <a-select-option value="pending">待评分</a-select-option>
          <a-select-option value="scored">已评分</a-select-option>
          <a-select-option value="closed">已结束</a-select-option>
        </a-select>
      </div>

      <!-- 答辩列表 -->
      <a-table
        :columns="columns"
        :data-source="defenseList"
        :loading="loading"
        :pagination="pagination"
        @change="handleTableChange"
      >
        <template #bodyCell="{ column, record }">
          <!-- 学生信息列 -->
          <template v-if="column.key === 'student'">
            <span>{{ record.student_name }}</span>
            <br />
            <small class="text-gray-500">{{ record.student_id }}</small>
          </template>

          <!-- 答辩时间列 -->
          <template v-if="column.key === 'defense_time'">
            {{ formatDateTime(record.defense_time) }}
          </template>

          <!-- 评分状态列 -->
          <template v-if="column.key === 'score_status'">
            <a-tag :color="getStatusColor(record.score_status)">
              {{ getStatusText(record.score_status) }}
            </a-tag>
          </template>

          <!-- 操作列 -->
          <template v-if="column.key === 'action'">
            <a-space>
              <a-button
                type="primary"
                :disabled="!canScore(record)"
                @click="showScoreModal(record)"
              >
                评分
              </a-button>
              <a-button
                v-if="record.score_status === 'scored'"
                @click="viewScore(record)"
              >
                查看
              </a-button>
              <a-tooltip v-if="record.score_status === 'scored'">
                <template #title>评分已提交，无法修改</template>
                <InfoCircleOutlined />
              </a-tooltip>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- Modal 移到外层 -->
    <div class="modal-container">
      <a-modal
        :open="modalVisible"
        :title="modalTitle"
        @ok="handleSubmitScore"
        @cancel="handleModalCancel"
        :confirmLoading="submitLoading"
        width="700px"
        :maskClosable="false"
        :keyboard="false"
        destroyOnClose
      >
        <a-form
          ref="formRef"
          :model="formData"
          :rules="rules"
          :label-col="{ span: 6 }"
          :wrapper-col="{ span: 16 }"
        >
          <!-- 学生信息展示 -->
          <a-form-item label="学生信息">
            <span>{{ currentRecord?.student_name }} ({{ currentRecord?.student_id }})</span>
          </a-form-item>

          <!-- 评分项 -->
          <a-form-item label="答辩陈述" name="presentation_score" required>
            <a-input-number
              v-model:value="formData.presentation_score"
              :min="0"
              :max="100"
              style="width: 100%"
            />
            <div class="form-item-tip">请输入0-100的分数，提交后不可修改</div>
          </a-form-item>

          <a-form-item label="问答表现" name="qa_score" required>
            <a-input-number
              v-model:value="formData.qa_score"
              :min="0"
              :max="100"
              style="width: 100%"
            />
            <div class="form-item-tip">请输入0-100的分数，提交后不可修改</div>
          </a-form-item>

          <a-form-item label="创新性" name="innovation_score" required>
            <a-input-number
              v-model:value="formData.innovation_score"
              :min="0"
              :max="100"
              style="width: 100%"
            />
            <div class="form-item-tip">请输入0-100的分数，提交后不可修改</div>
          </a-form-item>

          <a-form-item label="完成度" name="completion_score" required>
            <a-input-number
              v-model:value="formData.completion_score"
              :min="0"
              :max="100"
              style="width: 100%"
            />
            <div class="form-item-tip">请输入0-100的分数，提交后不可修改</div>
          </a-form-item>

          <a-form-item label="评语" name="comments" required>
            <a-textarea
              v-model:value="formData.comments"
              :rows="4"
              placeholder="请输入评语（必填）"
            />
            <div class="form-item-tip">请详细描述评分依据，提交后不可修改</div>
          </a-form-item>

          <a-form-item label="修改要求" name="revision_requirements" required>
            <a-textarea
              v-model:value="formData.revision_requirements"
              :rows="4"
              placeholder="请输入具体修改要求（必填）"
            />
            <div class="form-item-tip">请详细说明需要修改的内容，提交后不可修改</div>
          </a-form-item>

          <a-form-item label="评定结果" name="result" required>
            <a-select v-model:value="formData.result">
              <a-select-option value="pass">通过</a-select-option>
              <a-select-option value="fail">不通过</a-select-option>
              <a-select-option value="revision_needed">需要修改</a-select-option>
            </a-select>
          </a-form-item>
        </a-form>
      </a-modal>
    </div>

    <!-- 查看评分详情对话框 -->
    <div class="modal-container">
      <a-modal
        v-model:open="detailVisible"
        title="评分详情"
        @cancel="detailVisible = false"
        :footer="null"
        width="700px"
        :maskClosable="false"
        :keyboard="false"
        destroyOnClose
      >
        <template v-if="scoreDetail">
          <a-descriptions bordered :column="1">
            <!-- 基本信息 -->
            <a-descriptions-item label="学生信息">
              {{ currentRecord?.student_name }} ({{ currentRecord?.student_id }})
            </a-descriptions-item>

            <!-- 评分情况 -->
            <template v-if="scoreDetail.isChairman">
              <!-- 主席可以看到所有评分 -->
              <a-descriptions-item label="评委评分情况">
                <div v-for="(score, index) in scoreDetail.scores" :key="index" class="committee-score">
                  <div class="teacher-name">{{ score.teacher_name }}</div>
                  <div class="score-details">
                    <div>答辩陈述：{{ score.presentation_score }} 分</div>
                    <div>问答表现：{{ score.qa_score }} 分</div>
                    <div>创新性：{{ score.innovation_score }} 分</div>
                    <div>完成度：{{ score.completion_score }} 分</div>
                    <div class="total-score">总分：{{ score.total_score }} 分</div>
                    <div>
                      <a-tag :color="getResultColor(score.result)">
                        {{ getResultText(score.result) }}
                      </a-tag>
                    </div>
                    <!-- 评委评语 -->
                    <div v-if="score.comments" class="comment-section">
                      <div class="comment-label">评语：</div>
                      <pre class="comment-text">{{ score.comments }}</pre>
                    </div>
                    <!-- 修改要求 -->
                    <div v-if="score.revision_requirements" class="comment-section">
                      <div class="comment-label">修改要求：</div>
                      <pre class="comment-text">{{ score.revision_requirements }}</pre>
                    </div>
                  </div>
                </div>
              </a-descriptions-item>
            </template>
            <template v-else>
              <!-- 普通评委只能看到自己的评分 -->
              <a-descriptions-item label="我的评分">
                <div class="score-details">
                  <div>答辩陈述：{{ scoreDetail.scores[0]?.presentation_score }} 分</div>
                  <div>问答表现：{{ scoreDetail.scores[0]?.qa_score }} 分</div>
                  <div>创新性：{{ scoreDetail.scores[0]?.innovation_score }} 分</div>
                  <div>完成度：{{ scoreDetail.scores[0]?.completion_score }} 分</div>
                  <div class="total-score">总分：{{ scoreDetail.scores[0]?.total_score }} 分</div>
                  <div>
                    <a-tag :color="getResultColor(scoreDetail.scores[0]?.result)">
                      {{ getResultText(scoreDetail.scores[0]?.result) }}
                    </a-tag>
                  </div>
                  <!-- 我的评语 -->
                  <div v-if="scoreDetail.scores[0]?.comments" class="comment-section">
                    <div class="comment-label">评语：</div>
                    <pre class="comment-text">{{ scoreDetail.scores[0]?.comments }}</pre>
                  </div>
                  <!-- 我的修改要求 -->
                  <div v-if="scoreDetail.scores[0]?.revision_requirements" class="comment-section">
                    <div class="comment-label">修改要求：</div>
                    <pre class="comment-text">{{ scoreDetail.scores[0]?.revision_requirements }}</pre>
                  </div>
                </div>
              </a-descriptions-item>
            </template>

            <!-- 最终评分（所有人都可以看到） -->
            <a-descriptions-item label="最终评分">
              <template v-if="scoreDetail.final && scoreDetail.final.status === 'completed'">
                <div class="final-score">
                  {{ scoreDetail.final.score }} 分
                  <a-tag :color="getFinalStatusColor(scoreDetail.final.status)" class="ml-2">
                    {{ getFinalStatusText(scoreDetail.final.status) }}
                  </a-tag>
                </div>
                <!-- 最终评语 -->
                <div v-if="scoreDetail.final.teacher_comment" class="comment-section">
                  <div class="comment-label">最终评语：</div>
                  <pre class="comment-text">{{ scoreDetail.final.teacher_comment }}</pre>
                </div>
              </template>
              <template v-else>
                <a-tag color="processing">评分进行中</a-tag>
              </template>
            </a-descriptions-item>
          </a-descriptions>
        </template>
        <template v-else>
          <a-empty description="暂无评分数据" />
        </template>
      </a-modal>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, nextTick } from 'vue'
import { message, Modal } from 'ant-design-vue'
import { formatDateTime } from '@/utils/format'
import {
  getDefenseScoreList,
  submitDefenseScore,
  getDefenseScoreDetail
} from '@/api/defense'
import type { FormInstance } from 'ant-design-vue'
import { InfoCircleOutlined } from '@ant-design/icons-vue'

// 状态定义
const loading = ref(false)
const submitLoading = ref(false)
const modalVisible = ref(false)
const detailVisible = ref(false)
const defenseList = ref([])
const currentRecord = ref(null)
const scoreDetail = ref(null)
const modalTitle = ref('答辩评分')

// 搜索参数
const searchParams = ref({
  pageNum: 1,
  pageSize: 10,
  status: ''
})

// 分页配置
const pagination = ref({
  current: 1,
  pageSize: 10,
  total: 0,
  showTotal: (total: number) => `共 ${total} 条`
})

// 表单数据
const formRef = ref<FormInstance>()
const formData = ref({
  arrangement_id: null as number | null,
  presentation_score: null as number | null,
  qa_score: null as number | null,
  innovation_score: null as number | null,
  completion_score: null as number | null,
  comments: '',
  revision_requirements: '',
  result: 'pass' as 'pass' | 'fail' | 'revision_needed'
})

// 表单验证规则
const rules = {
  presentation_score: [
    { required: true, message: '请输入答辩陈述分数' },
    { type: 'number', min: 0, max: 100, message: '分数必须在0-100之间' }
  ],
  qa_score: [
    { required: true, message: '请输入问答表现分数' },
    { type: 'number', min: 0, max: 100, message: '分数必须在0-100之间' }
  ],
  innovation_score: [
    { required: true, message: '请输入创新性分数' },
    { type: 'number', min: 0, max: 100, message: '分数必须在0-100之间' }
  ],
  completion_score: [
    { required: true, message: '请输入完成度分数' },
    { type: 'number', min: 0, max: 100, message: '分数必须在0-100之间' }
  ],
  comments: [
    { required: true, message: '请输入评语' }
  ],
  revision_requirements: [
    { required: true, message: '请输入修改要求' }
  ],
  result: [
    { required: true, message: '请选择评定结果' }
  ]
}

// 表格列定义
const columns = [
  {
    title: '学生',
    key: 'student',
    dataIndex: 'student_name',
    width: 200
  },
  {
    title: '答辩时间',
    key: 'defense_time',
    dataIndex: 'defense_time',
    width: 180
  },
  {
    title: '地点',
    dataIndex: 'location',
    width: 150
  },
  {
    title: '评分状态',
    key: 'score_status',
    dataIndex: 'score_status',
    width: 120
  },
  {
    title: '操作',
    key: 'action',
    width: 150,
    fixed: 'right'
  }
]

// 获取数据
const fetchData = async () => {
  loading.value = true
  try {
    const res = await getDefenseScoreList({
      pageNum: searchParams.value.pageNum,
      pageSize: searchParams.value.pageSize,
      status: searchParams.value.status
    })
    defenseList.value = res.data.list
    pagination.value.total = res.data.total
  } catch (error) {
    message.error('获取数据失败')
  } finally {
    loading.value = false
  }
}

// 状态相关方法
const getStatusColor = (status: string) => {
  const colors = {
    pending: 'blue',
    scored: 'green',
    closed: 'gray'
  }
  return colors[status] || 'blue'
}

const getStatusText = (status: string) => {
  const texts = {
    pending: '待评分',
    scored: '已评分',
    closed: '已结束'
  }
  return texts[status] || status
}

// 判断是否可以评分
const canScore = (record: any) => {
  return record.score_status === 'pending' && record.status === 'in_progress'
}

// 显示评分对话框
const showScoreModal = (record: any) => {
  currentRecord.value = record
  formData.value = {
    arrangement_id: Number(record.id),
    presentation_score: null,
    qa_score: null,
    innovation_score: null,
    completion_score: null,
    comments: '',
    revision_requirements: '',
    result: 'pass'  // 默认通过
  }
  modalVisible.value = true
}

// 查看评分详情
const viewScore = async (record: any) => {
  try {
    currentRecord.value = record
    const res = await getDefenseScoreDetail(record.id)
    
    if (res.code === 200 && res.data) {
      // 获取当前用户的评分
      const myScore = res.data.scores[0] // 后端已经根据用户ID筛选过了
      
      if (myScore || res.data.isChairman) {
        scoreDetail.value = {
          scores: res.data.scores,
          final: res.data.final,
          isChairman: res.data.isChairman
        }
        detailVisible.value = true
      } else {
        message.error('未找到您的评分记录')
      }
    }
  } catch (error) {
    console.error('获取评分详情失败:', error)
    message.error('获取评分详情失败')
  }
}

// 提交评分
const handleSubmitScore = async () => {
  try {
    // 表单验证
    await formRef.value?.validate();
    
    // 检查所有必填字段
    if (!formData.value.arrangement_id ||
        !formData.value.presentation_score ||
        !formData.value.qa_score ||
        !formData.value.innovation_score ||
        !formData.value.completion_score ||
        !formData.value.comments ||
        !formData.value.revision_requirements ||
        !formData.value.result) {
      message.error('请填写所有必填字段');
      return;
    }

    // 二次确认
    Modal.confirm({
      title: '确认提交评分',
      content: '评分提交后将无法修改，是否确认提交？',
      okText: '确认',
      cancelText: '取消',
      async onOk() {
        try {
          submitLoading.value = true;
          console.log('提交的数据:', formData.value); // 调试用
          const response = await submitDefenseScore(formData.value);
          
          if (response.data.isCompleted) {
            message.success('评分提交成功！所有评委已完成评分，答辩评审已结束');
          } else {
            message.success('评分提交成功！等待其他评委完成评分');
          }
          
          modalVisible.value = false;
          handleSearch();
        } catch (error: any) {
          console.error('提交错误:', error);
          message.error(error.response?.data?.message || '提交失败');
        } finally {
          submitLoading.value = false;
        }
      }
    });
  } catch (error: any) {
    console.error('验证错误:', error);
    message.error('表单验证失败，请检查所有字段是否填写正确');
  }
};

// 事件处理方法
const handleSearch = () => {
  searchParams.value.pageNum = 1
  fetchData()
}

const handleTableChange = (pag: any) => {
  searchParams.value.pageNum = pag.current
  searchParams.value.pageSize = pag.pageSize
  fetchData()
}

const handleModalCancel = () => {
  formRef.value?.resetFields()
  modalVisible.value = false
}

// 初始化
onMounted(() => {
  fetchData()
})

// 添加结果状态相关方法
const getResultColor = (result: string) => {
  const colors = {
    pass: 'success',
    fail: 'error',
    revision_needed: 'warning'
  }
  return colors[result] || 'default'
}

const getResultText = (result: string) => {
  const texts = {
    pass: '通过',
    fail: '不通过',
    revision_needed: '需要修改'
  }
  return texts[result] || '未知'
}

// 添加新的数据属性
const allScores = ref<any[]>([])

// 添加计算最终评分的方法
const getFinalScore = (scores: any[]) => {
  const total = scores.reduce((sum, score) => sum + score.total_score, 0)
  return (total / scores.length).toFixed(2)
}

// 添加计算最终结果的方法
const getFinalResultColor = (scores: any[]) => {
  const allPassed = scores.every(score => score.result === 'pass')
  return allPassed ? 'success' : 'warning'
}

const getFinalResultText = (scores: any[]) => {
  const allPassed = scores.every(score => score.result === 'pass')
  return allPassed ? '通过' : '需要修改'
}

// 添加最终状态相关方法
const getFinalStatusColor = (status: string) => {
  const colors = {
    completed: 'success',
    revision_needed: 'warning',
    in_progress: 'processing',
    not_started: 'default'
  }
  return colors[status] || 'default'
}

const getFinalStatusText = (status: string) => {
  const texts = {
    completed: '通过',
    revision_needed: '需要修改',
    in_progress: '评分中',
    not_started: '未开始'
  }
  return texts[status] || '未知状态'
}
</script>

<style scoped>
.defense-scoring {
  padding: 24px;
  position: relative;
}

/* 添加新的样式来确保 Modal 在最上层 */
.modal-container {
  position: relative;
  z-index: 1100;  /* 确保比 ant-card-body 更高 */
}

/* 覆盖 ant-design-vue 的默认样式 */
:deep(.ant-card-body) {
  position: relative;
  z-index: 1;
}

:deep(.ant-modal-wrap) {
  z-index: 1100;
}

:deep(.ant-modal-mask) {
  z-index: 1090;
}

:deep(.ant-modal) {
  z-index: 1100;
}

.table-toolbar {
  margin-bottom: 16px;
  display: flex;
  justify-content: flex-start;
}

.text-gray-500 {
  color: #666;
}

.form-item-tip {
  color: #ff4d4f;
  font-size: 12px;
  margin-top: 4px;
}

/* 添加新的样式 */
.score-details {
  display: grid;
  gap: 8px;
}

.total-score {
  font-weight: bold;
  margin-top: 8px;
  color: #1890ff;
}

.comment-text {
  white-space: pre-wrap;
  margin: 0;
  font-family: inherit;
}

.committee-score {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 8px;
}

.teacher-name {
  font-weight: bold;
  min-width: 100px;
}

.final-score {
  font-size: 16px;
  font-weight: bold;
  color: #1890ff;
  display: flex;
  align-items: center;
  gap: 16px;
}

.ml-2 {
  margin-left: 8px;
}

/* 添加评语相关样式 */
.comment-section {
  margin-top: 12px;
  border-top: 1px dashed #f0f0f0;
  padding-top: 8px;
}

.comment-label {
  font-weight: bold;
  color: #666;
  margin-bottom: 4px;
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
</style>

<!-- 全局样式 -->
<style>
/* 移除之前的全局样式，改用 scoped 样式 */
</style> 