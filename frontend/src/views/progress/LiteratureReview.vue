<template>
  <div class="literature-review">
    <!-- 搜索和筛选区域 -->
    <a-card :bordered="false" class="filter-card">
      <a-row :gutter="16">
        <a-col :span="6">
          <a-input
            v-model:value="searchForm.keyword"
            placeholder="搜索学号/姓名"
            allow-clear
          />
        </a-col>
        <a-col :span="6">
          <a-select
            v-model:value="searchForm.status"
            placeholder="选择状态"
            style="width: 100%"
            allow-clear
          >
            <a-select-option value="in_progress">进行中</a-select-option>
            <a-select-option value="reviewing">待审核</a-select-option>
            <a-select-option value="completed">已完成</a-select-option>
            <a-select-option value="revision_needed">需修改</a-select-option>
          </a-select>
        </a-col>
        <a-col :span="6">
          <a-space>
            <a-button type="primary" @click="handleSearch">查询</a-button>
            <a-button @click="resetSearch">重置</a-button>
          </a-space>
        </a-col>
      </a-row>
    </a-card>

    <!-- 综述列表 -->
    <a-card :bordered="false" class="table-card">
      <a-table
        :columns="columns"
        :data-source="literatureList"
        :loading="loading"
        :pagination="pagination"
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

          <!-- 分数列 -->
          <template v-else-if="column.key === 'score'">
            <span>{{ record.score || '-' }}</span>
          </template>

          <!-- 操作列 -->
          <template v-else-if="column.key === 'action'">
            <a-space>
              <a-button 
                type="link" 
                size="small"
                @click="viewFile(record)"
                v-if="record.file_url"
              >
                查看文件
              </a-button>
              <a-button 
                type="primary" 
                size="small"
                @click="openReviewModal(record)"
                :disabled="record.status === 'completed'"
              >
                评阅
              </a-button>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- 评阅弹窗 -->
    <a-modal
      v-model:open="reviewModalVisible"
      title="文献综述评阅"
      @ok="handleReviewSubmit"
      @cancel="closeReviewModal"
      :confirmLoading="submitting"
      width="800px"
      centered
      :maskClosable="false"
      :destroyOnClose="true"
      :getContainer="false"
      class="literature-review-modal"
    >
      <a-form :model="reviewForm" layout="vertical">
        <a-form-item label="学生信息">
          <span>{{ currentRecord?.student_name }} ({{ currentRecord?.student_id }}) - 第{{ currentRecord?.version }}版</span>
        </a-form-item>
        
        <!-- 评分部分 -->
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="内容完整性评分" required>
              <a-input-number
                v-model:value="reviewForm.content_score"
                :min="0"
                :max="100"
                style="width: 100%"
              />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="分析深度评分" required>
              <a-input-number
                v-model:value="reviewForm.analysis_score"
                :min="0"
                :max="100"
                style="width: 100%"
              />
            </a-form-item>
          </a-col>
        </a-row>
        
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="结构逻辑评分" required>
              <a-input-number
                v-model:value="reviewForm.structure_score"
                :min="0"
                :max="100"
                style="width: 100%"
              />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="写作规范评分" required>
              <a-input-number
                v-model:value="reviewForm.writing_score"
                :min="0"
                :max="100"
                style="width: 100%"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-form-item label="总评分（修改每一项评分后才能显示总分）">
          <span class="total-score">{{ calculateTotalScore.toFixed(2) }}</span>
        </a-form-item>

        <!-- 评语部分 -->
        <a-form-item label="内容评价" required>
          <a-textarea
            v-model:value="reviewForm.content_comment"
            :rows="3"
            placeholder="请评价文献综述的内容完整性"
          />
        </a-form-item>
        
        <a-form-item label="改进建议" required>
          <a-textarea
            v-model:value="reviewForm.improvement_suggestions"
            :rows="3"
            placeholder="请提供改进建议"
          />
        </a-form-item>
        
        <a-form-item label="总体评语" required>
          <a-textarea
            v-model:value="reviewForm.general_comment"
            :rows="3"
            placeholder="请输入总体评语"
          />
        </a-form-item>

        <a-form-item label="评阅结果" required>
          <a-radio-group v-model:value="reviewForm.status">
            <a-radio value="completed">通过</a-radio>
            <a-radio value="revision_needed">需要修改</a-radio>
          </a-radio-group>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed, nextTick } from 'vue'
import { message, Modal } from 'ant-design-vue'
import { getLiteratureReviews, updateLiteratureReview } from '@/api/progress'

// 表格列定义
const columns = [
  {
    title: '学号',
    dataIndex: 'student_id',
    key: 'student_id',
    width: 120
  },
  {
    title: '姓名',
    dataIndex: 'student_name',
    key: 'student_name',
    width: 100
  },
  {
    title: '提交时间',
    dataIndex: 'submit_time',
    key: 'submit_time',
    width: 180
  },
  {
    title: '评阅时间',
    dataIndex: 'review_time',
    key: 'review_time',
    width: 180
  },
  {
    title: '版本',
    dataIndex: 'version',
    key: 'version',
    width: 80
  },
  {
    title: '状态',
    dataIndex: 'status',
    key: 'status',
    width: 100
  },
  {
    title: '总分',
    dataIndex: 'total_score',
    key: 'total_score',
    width: 80
  },
  {
    title: '操作',
    key: 'action',
    width: 150,
    fixed: 'right'
  }
]

// 状态数据
const loading = ref(false)
const literatureList = ref([])
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showTotal: (total: number) => `共 ${total} 条`
})

// 搜索表单
const searchForm = reactive({
  keyword: '',
  status: undefined
})

// 评阅相关
const reviewModalVisible = ref(false)
const submitting = ref(false)
const currentRecord = ref<any>(null)
const reviewForm = reactive({
  content_score: 0,
  analysis_score: 0,
  structure_score: 0,
  writing_score: 0,
  content_comment: '',
  improvement_suggestions: '',
  general_comment: '',
  status: 'completed'
})

// 添加总分计算
const calculateTotalScore = computed(() => {
  const { content_score, analysis_score, structure_score, writing_score } = reviewForm
  if (!content_score || !analysis_score || !structure_score || !writing_score) return 0
  return (content_score + analysis_score + structure_score + writing_score) / 4
})

// 获取文献综述列表
const fetchLiteratureList = async () => {
  loading.value = true
  try {
    const res = await getLiteratureReviews({
      pageNum: pagination.current,
      pageSize: pagination.pageSize,
      ...searchForm
    })
    if (res.code === 200) {
      literatureList.value = res.data.list
      pagination.total = res.data.total
    }
  } catch (error) {
    message.error('获取数据失败')
  } finally {
    loading.value = false
  }
}

// 处理表格变化
const handleTableChange = (pag: any) => {
  pagination.current = pag.current
  pagination.pageSize = pag.pageSize
  fetchLiteratureList()
}

// 处理搜索
const handleSearch = () => {
  pagination.current = 1
  fetchLiteratureList()
}

// 重置搜索
const resetSearch = () => {
  Object.assign(searchForm, {
    keyword: '',
    status: undefined
  })
  handleSearch()
}

// 查看文件
const viewFile = (record: any) => {
  if (record.file_url) {
    window.open(`http://localhost:3001/${record.file_url}`, '_blank')
  }
}

// 打开评阅弹窗
const openReviewModal = (record: any) => {
  console.log('Opening review modal:', record);
  nextTick(() => {
    currentRecord.value = record;
    Object.assign(reviewForm, {
      content_score: record.content_score || 0,
      analysis_score: record.analysis_score || 0,
      structure_score: record.structure_score || 0,
      writing_score: record.writing_score || 0,
      content_comment: record.content_comment || '',
      improvement_suggestions: record.improvement_suggestions || '',
      general_comment: record.general_comment || '',
      status: record.status || 'completed'
    });
    reviewModalVisible.value = true;
  });
}

// 关闭评阅弹窗
const closeReviewModal = () => {
  reviewModalVisible.value = false
  currentRecord.value = null
  Object.assign(reviewForm, {
    content_score: 0,
    analysis_score: 0,
    structure_score: 0,
    writing_score: 0,
    content_comment: '',
    improvement_suggestions: '',
    general_comment: '',
    status: 'completed'
  })
}

// 提交评阅
const handleReviewSubmit = async () => {
  // 验证必填字段
  if (!reviewForm.content_score || !reviewForm.analysis_score || 
      !reviewForm.structure_score || !reviewForm.writing_score ||
      !reviewForm.content_comment || !reviewForm.improvement_suggestions || 
      !reviewForm.general_comment) {
    message.error('请填写所有必填项');
    return;
  }

  // 如果是通过状态，先确认
  if (reviewForm.status === 'completed') {
    try {
      await Modal.confirm({
        title: '确认通过',
        content: '通过后将不能再修改评阅结果，且分数将计入学生成绩，是否确认？',
        okText: '确认',
        cancelText: '取消'
      });
    } catch (e) {
      return; // 用户取消操作
    }
  }

  submitting.value = true;
  try {
    const totalScore = calculateTotalScore.value;
    const reviewData = {
      student_id: currentRecord.value.student_id,
      content_score: reviewForm.content_score,
      analysis_score: reviewForm.analysis_score,
      structure_score: reviewForm.structure_score,
      writing_score: reviewForm.writing_score,
      content_comment: reviewForm.content_comment,
      improvement_suggestions: reviewForm.improvement_suggestions,
      general_comment: reviewForm.general_comment,
      status: reviewForm.status,
      total_score: totalScore
    };

    const res = await updateLiteratureReview(reviewData);

    if (res.code === 200) {
      message.success(reviewForm.status === 'completed' ? 
        '评阅完成，分数已同步更新' : '评阅意见已保存');
      closeReviewModal();
      fetchLiteratureList();
    } else {
      throw new Error(res.message || '评阅失败');
    }
  } catch (error) {
    message.error('评阅失败：' + (error.message || '未知错误'));
  } finally {
    submitting.value = false;
  }
};

// 获取状态颜色
const getStatusColor = (status: string) => {
  const colors: Record<string, string> = {
    'not_started': 'default',
    'in_progress': 'processing',
    'reviewing': 'warning',
    'completed': 'success',
    'revision_needed': 'error'
  }
  return colors[status] || 'default'
}

// 获取状态文本
const getStatusText = (status: string) => {
  const texts: Record<string, string> = {
    'not_started': '未开始',
    'in_progress': '进行中',
    'reviewing': '审核中',
    'completed': '已完成',
    'revision_needed': '需要修改'
  }
  return texts[status] || '未知状态'
}

const testModal = () => {
  currentRecord.value = {
    student_id: 'TEST001',
    student_name: '测试学生',
    version: 1,
    content_score: 0,
    analysis_score: 0,
    structure_score: 0,
    writing_score: 0,
    content_comment: '',
    improvement_suggestions: '',
    general_comment: '',
    status: 'reviewing'
  };

  reviewModalVisible.value = true;
  console.log('Test modal visibility:', reviewModalVisible.value);
};

onMounted(() => {
  fetchLiteratureList()
})
</script>

<style scoped>
.literature-review {
  padding: 24px;
}

.filter-card {
  margin-bottom: 24px;
}

.table-card {
  margin-bottom: 24px;
}

:deep(.ant-form-item) {
  margin-bottom: 16px;
}

.total-score {
  font-size: 24px;
  font-weight: bold;
  color: #1890ff;
}

:deep(.literature-review-modal) {
  .ant-modal,
  .ant-modal-wrap {
    position: fixed;
    z-index: 2000;
  }
}

:deep(.ant-modal-wrap),
:deep(.ant-modal-mask),
:deep(.ant-modal) {
  position: fixed;
}

:deep(.ant-modal) {
  padding-bottom: 24px;
}

:deep(.ant-modal-content) {
  padding: 24px;
  border-radius: 8px;
}

:deep(.ant-modal-header) {
  margin-bottom: 16px;
}

:deep(.ant-modal-body) {
  max-height: calc(100vh - 280px);
  overflow-y: auto;
}
</style> 