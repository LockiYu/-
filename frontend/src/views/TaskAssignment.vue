<template>
  <div class="task-assignment">
    <a-card title="任务书管理">
      <!-- 搜索和过滤区域 -->
      <div class="search-bar">
        <a-input-search
          v-model:value="searchKeyword"
          placeholder="搜索学生姓名/学号"
          style="width: 200px"
          @search="handleSearch"
        />
        <a-select
          v-model:value="filterStatus"
          style="width: 150px; margin-left: 16px"
          placeholder="状态筛选"
          @change="handleSearch"
        >
          <a-select-option value="">全部状态</a-select-option>
          <a-select-option value="draft">草稿</a-select-option>
          <a-select-option value="published">已发布</a-select-option>
          <a-select-option value="completed">已完成</a-select-option>
        </a-select>
      </div>

      <!-- 任务书列表 -->
      <a-table
        :dataSource="taskList"
        :columns="columns"
        :loading="loading"
        rowKey="id"
        :pagination="pagination"
        @change="handleTableChange"
      >
        <!-- 学生信息列 -->
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'student'">
            <div>
              <div>{{ record.student_name }}</div>
              <div class="text-gray-500">{{ record.student_id }}</div>
            </div>
          </template>

          <!-- 状态列 -->
          <template v-if="column.key === 'status'">
            <a-tag :color="getStatusColor(record.status)">
              {{ getStatusText(record.status) }}
            </a-tag>
          </template>

          <!-- 操作列 -->
          <template v-if="column.key === 'action'">
            <a-space>
              
              <a-button 
                type="primary" 
                size="small"
                @click="handleAssign(record)"
                v-if="record.status === 'draft'"
              >
                下达任务书
              </a-button>
              <a-button 
                type="link" 
                size="small"
                @click="handleView(record)"
                v-if="record.status !== 'draft'"
              >
                查看
              </a-button>
              <a-button 
                type="link" 
                size="small"
                @click="handleEdit(record)"
                v-if="record.status === 'published'"
              >
                编辑
              </a-button>
              <a-button 
                type="primary" 
                size="small"
                @click="handleComplete(record)"
                v-if="record.status === 'published'"
              >
                完成任务
              </a-button>
            </a-space>
          </template>
        </template>
      </a-table>

      <!-- 任务书表单对话框 -->
      <a-modal
        v-model:open="modalVisible"
        :title="modalTitle"
        @ok="handleModalOk"
        @cancel="handleModalCancel"
        :confirmLoading="modalLoading"
      >
        <a-form
          ref="formRef"
          :model="formState"
          :rules="rules"
          :label-col="{ span: 4 }"
          :wrapper-col="{ span: 20 }"
        >
          <!-- 显示当前记录信息（只读） -->
          <a-form-item label="学生">
            <span>{{ formState.student_name }} ({{ formState.student_id }})</span>
          </a-form-item>

          <a-form-item label="选题">
            <span>{{ topicInfo }}</span>
          </a-form-item>

          <!-- 任务书标题 -->
          <a-form-item label="标题" name="title">
            <a-input v-model:value="formState.title" placeholder="请输入任务书标题" />
          </a-form-item>

          <!-- 任务书内容 -->
          <a-form-item label="内容" name="content">
            <a-textarea 
              v-model:value="formState.content" 
              :rows="4" 
              placeholder="请输入任务书内容"
            />
          </a-form-item>

          <!-- 任务要求 -->
          <a-form-item label="要求" name="requirements">
            <a-textarea 
              v-model:value="formState.requirements" 
              :rows="4" 
              placeholder="请输入任务要求"
            />
          </a-form-item>

          <!-- 截止时间 -->
          <a-form-item label="截止时间" name="deadline">
            <a-date-picker
              v-model:value="formState.deadline"
              :show-time="{ format: 'HH:mm:ss' }"
              format="YYYY-MM-DD HH:mm:ss"
              placeholder="请选择截止时间"
            />
          </a-form-item>
        </a-form>
      </a-modal>

      <!-- 查看任务书对话框 -->
      <a-modal
        v-model:open="viewModalVisible"
        title="查看任务书"
        @cancel="viewModalVisible = false"
        :footer="null"
      >
        <div class="task-detail">
          <div class="detail-item">
            <div class="label">课题名称</div>
            <div class="content">{{ viewData.title }}</div>
          </div>
          <div class="detail-item">
            <div class="label">课题内容</div>
            <div class="content">{{ viewData.content }}</div>
          </div>
          <div class="detail-item">
            <div class="label">要求与目标</div>
            <div class="content">{{ viewData.requirements }}</div>
          </div>
          <div class="detail-item">
            <div class="label">截止时间</div>
            <div class="content">{{ formatDate(viewData.deadline) }}</div>
          </div>
          <div class="detail-item">
            <div class="label">状态</div>
            <div class="content">
              <a-tag :color="getStatusColor(viewData.status)">
                {{ getStatusText(viewData.status) }}
              </a-tag>
            </div>
          </div>
        </div>
      </a-modal>

      <!-- 添加评分对话框 -->
      <a-modal
        v-model:open="scoreModalVisible"
        title="完成任务并评分"
        @ok="handleScoreSubmit"
        @cancel="scoreModalVisible = false"
      >
        <a-form :model="scoreForm" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
          <a-form-item label="任务书评分" required>
            <a-input-number
              v-model:value="scoreForm.score"
              :min="0"
              :max="100"
              :precision="2"
            />
          </a-form-item>
          <a-form-item label="教师评语">
            <a-textarea
              v-model:value="scoreForm.teacherComment"
              :rows="4"
            />
          </a-form-item>
        </a-form>
      </a-modal>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { message } from 'ant-design-vue'
import { getTaskList, assignTask, updateTask, completeTask } from '@/api/tasks'
import { formatDate } from '@/utils/date'
import dayjs from 'dayjs'
import 'dayjs/locale/zh-cn'
import { request } from '@/utils/request'
import { useUserStore } from '@/stores/user'

dayjs.locale('zh-cn')

const userStore = useUserStore()

// 表格列定义
const columns = [
  {
    title: '学生信息',
    key: 'student',
    dataIndex: 'student_name',
  },
  {
    title: '课题名称',
    key: 'title',
    dataIndex: 'title',
  },
  {
    title: '截止时间',
    key: 'deadline',
    dataIndex: 'deadline',
    customRender: ({ text }) => formatDate(text),
  },
  {
    title: '状态',
    key: 'status',
    dataIndex: 'status',
  },
  {
    title: '操作',
    key: 'action',
  },
]

// 数据状态
const loading = ref(false)
const taskList = ref([])
const searchKeyword = ref('')
const filterStatus = ref('')
const pagination = ref({
  current: 1,
  pageSize: 10,
  total: 0,
})
const currentRecord = ref({})

// 表单状态
const modalVisible = ref(false)
const modalTitle = ref('任务书详情')
const modalLoading = ref(false)
const formRef = ref()

// 初始化表单状态
const initFormState = {
  task_id: null,
  teacher_id: userStore.userId,
  student_id: '',
  student_name: '',
  topic_id: null,
  selection_id: null,
  title: '',
  content: '',
  requirements: '',
  deadline: null,
  status: 'draft'
};

const formState = ref({
  task_id: null,
  student_id: '',
  student_name: '',
  title: '',
  content: '',
  requirements: '',
  deadline: null,
  status: 'draft',
  topic_id: null,
  selection_id: null
});
const topicSelection = ref(null);

// 查看模态框状态
const viewModalVisible = ref(false)
const viewData = ref({})

// 表单验证规则
const rules = {
  title: [{ required: true, message: '请输入任务书标题' }],
  content: [{ required: true, message: '请输入任务书内容' }],
  deadline: [{ required: true, message: '请选择截止时间' }]
};

// 获取选题信息的函数
const fetchStudentTopicSelection = async (studentId) => {
  try {
    console.log('开始获取选题信息，学生ID:', studentId);
    const response = await request.get(`/tasks/student/${studentId}`);
    console.log('选题接口原始返回数据:', response);
    
    // 直接使用 response.data，因为它已经包含了我们需要的数据
    const topicData = response.data;
    console.log('选题数据:', topicData);
    
    if (topicData && topicData.selection_id && topicData.topic_id) {
      topicSelection.value = {
        selection_id: topicData.selection_id,
        topic_id: topicData.topic_id,
        topic_title: topicData.topic_title,
        topic_description: topicData.topic_description,
        final_status: topicData.final_status,
        teacher_approval_status: topicData.teacher_approval_status,
        director_approval_status: topicData.director_approval_status
      };
      
      console.log('赋值后的选题信息:', topicSelection.value);
      return true;
    }
    
    console.log('数据验证未通过，选题数据:', topicData);
    topicSelection.value = null;
    return false;
  } catch (error) {
    console.error('获取学生选题信息失败:', error);
    topicSelection.value = null;
    return false;
  }
};

// 获取任务书列表
const fetchTaskList = async () => {
  loading.value = true
  try {
    const res = await getTaskList({
      pageNum: pagination.value.current,
      pageSize: pagination.value.pageSize,
      keyword: searchKeyword.value,
      status: filterStatus.value,
    })
    taskList.value = res.data.list
    pagination.value.total = res.data.total
  } catch (error) {
    message.error('获取任务书列表失败')
  } finally {
    loading.value = false
  }
}

// 搜索处理
const handleSearch = () => {
  pagination.value.current = 1
  fetchTaskList()
}

// 表格变化处理
const handleTableChange = (pag) => {
  pagination.value.current = pag.current
  pagination.value.pageSize = pag.pageSize
  fetchTaskList()
}

// 下达任务书
const handleAssign = async (record) => {
  console.log('开始下达任务书:', record);
  modalTitle.value = '下达任务书';
  
  // 重置选题信息
  topicSelection.value = null;
  
  // 先获取选题信息
  const hasTopicSelection = await fetchStudentTopicSelection(record.student_id);
  
  // 然后更新表单状态
  formState.value = {
    ...formState.value,
    task_id: record.task_id,
    student_id: record.student_id,
    student_name: record.student_name,
    title: record.title || '',
    content: record.content || '',
    requirements: record.requirements || '',
    deadline: record.deadline ? dayjs(record.deadline) : null,
    status: record.status || 'draft',
    topic_id: record.topic_id || topicSelection.value?.topic_id || null,
    selection_id: record.selection_id || topicSelection.value?.selection_id || null
  };
  
  console.log('下达任务书表单数据:', formState.value);
  modalVisible.value = true;
};

// 处理编辑
const handleEdit = async (record) => {
  console.log('开始编辑记录:', record);
  modalTitle.value = '编辑任务书';
  
  // 重置选题信息
  topicSelection.value = null;
  
  // 先获取选题信息
  const hasTopicSelection = await fetchStudentTopicSelection(record.student_id);
  
  // 然后更新表单状态
  formState.value = {
    task_id: record.task_id, // 确保这里使用数据库中的 task_id
    title: record.title || '',
    content: record.content || '',
    requirements: record.requirements || '',
    deadline: record.deadline ? dayjs(record.deadline) : null,
    status: record.status || 'draft',
    student_id: record.student_id || '',
    student_name: record.student_name || '',
    topic_id: record.topic_id || topicSelection.value?.topic_id || null,
    selection_id: record.selection_id || topicSelection.value?.selection_id || null
  };
  
  console.log('编辑表单数据:', formState.value);
  modalVisible.value = true;
};

// 查看任务书
const handleView = (record) => {
  viewData.value = record
  viewModalVisible.value = true
}

// 提交表单
const handleModalOk = async () => {
  try {
    await formRef.value.validate()
    modalLoading.value = true

    const submitData = {
      task_id: formState.value.task_id,
      title: formState.value.title,
      content: formState.value.content,
      requirements: formState.value.requirements,
      deadline: formState.value.deadline ? dayjs(formState.value.deadline).format('YYYY-MM-DD HH:mm:ss') : null,
      status: 'published'
    }

    await updateTask(submitData)
    message.success('任务书更新成功')
    modalVisible.value = false
    fetchTaskList() // 刷新列表
  } catch (error) {
    console.error('更新任务书失败:', error)
    message.error('更新失败：' + (error.response?.data?.message || '未知错误'))
  } finally {
    modalLoading.value = false
  }
}

// 模态框取消
const handleModalCancel = () => {
  formRef.value?.resetFields()
  modalVisible.value = false
}

// 状态颜色
const getStatusColor = (status) => {
  const colors = {
    draft: 'orange',
    published: 'blue',
    completed: 'success',
  }
  return colors[status] || 'default'
}

// 状态文本
const getStatusText = (status) => {
  const texts = {
    draft: '草稿',
    published: '已发布',
    completed: '已完成',
  }
  return texts[status] || '未知状态'
}

// 计算选题信息
const topicInfo = computed(() => {
  const info = topicSelection.value;
  console.log('计算选题信息，当前数据:', info);
  
  if (info && info.topic_title) {
    let status = '';
    if (info.final_status === 'approved') {
      status = '(已通过)';
    } else if (info.final_status === 'pending') {
      status = '(审批中)';
    } else {
      status = '(未通过)';
    }
    
    return ` ${info.topic_title} ${status}`;
  }
  return '未选题或选题未通过最终审批';
});

// 新增的状态
const scoreModalVisible = ref(false)
const scoreForm = ref({
  score: null,
  teacherComment: '',
  currentTaskId: null,
  studentId: ''
})

// 处理完成任务
const handleComplete = (record) => {
  scoreForm.value = {
    score: null,
    teacherComment: '',
    currentTaskId: record.task_id,
    studentId: record.student_id
  }
  scoreModalVisible.value = true
}

// 提交评分和完成任务
const handleScoreSubmit = async () => {
  try {
    if (!scoreForm.value.score) {
      message.error('请输入评分');
      return;
    }

    const { currentTaskId, studentId, score, teacherComment } = scoreForm.value;

    await completeTask(currentTaskId, {
      score,
      teacherComment,
      studentId
    });

    message.success('任务已完成并评分');
    scoreModalVisible.value = false;
    fetchTaskList(); // 刷新列表
  } catch (error) {
    console.error('完成任务失败:', error);
    message.error('操作失败：' + (error.response?.data?.message || '未知错误'));
  }
};

onMounted(() => {
  fetchTaskList()
})
</script>

<style scoped>
.task-assignment {
  padding: 24px;
}

.search-bar {
  margin-bottom: 16px;
}

.task-detail .detail-item {
  margin-bottom: 16px;
}

.task-detail .label {
  font-weight: bold;
  margin-bottom: 8px;
}

.task-detail .content {
  color: #666;
}
</style> 