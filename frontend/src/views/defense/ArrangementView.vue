<template>
  <div class="defense-arrangement" style="position: relative;">
    <a-card :bordered="false">
      <!-- 搜索工具栏 - 只保留搜索，移除添加按钮 -->
      <div class="table-toolbar">
        <a-select
          v-model:value="searchParams.status"
          style="width: 150px"
          placeholder="答辩状态"
          @change="handleSearch"
        >
          <a-select-option value="">全部状态</a-select-option>
          <a-select-option value="pending">待安排</a-select-option>
          <a-select-option value="in_progress">已安排</a-select-option>
          <a-select-option value="completed">已完成</a-select-option>
          <a-select-option value="cancelled">已取消</a-select-option>
        </a-select>
        
        <!-- 只在非只读模式下显示添加按钮 -->
        <a-button v-if="!isReadOnly" type="primary" @click="showArrangeModal">
          <PlusOutlined /> 安排答辩
        </a-button>
      </div>

      <!-- 表格部分 -->
      <a-table
        :columns="getColumns()"
        :data-source="arrangements"
        :loading="loading"
        :pagination="pagination"
        @change="handleTableChange"
      >
        <!-- 使用新的插槽语法 -->
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'student'">
            {{ record.student_name }}
            <br />
            <small class="text-gray-500">{{ record.student_id }}</small>
          </template>

          <template v-else-if="column.key === 'defense_time'">
            {{ formatDateTime(record.defense_time) }}
          </template>

          <template v-else-if="column.key === 'status'">
            <a-tag :color="getStatusColor(record.status)">
              {{ getStatusText(record.status) }}
            </a-tag>
          </template>

          <template v-else-if="column.key === 'action'">
            <a-space>
              <a @click="handleEdit(record)">编辑</a>
              <a-divider type="vertical" />
              <a-popconfirm
                title="确定要删除此安排吗？"
                @confirm="handleDelete(record.id)"
              >
                <a class="text-red-500">删除</a>
              </a-popconfirm>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- 只在非只读模式下显示模态框 -->
    <a-modal v-if="!isReadOnly"
      :open="modalVisible"
      :title="modalTitle"
      :style="{ zIndex: 1000 }"
      @ok="handleModalOk"
      @cancel="handleModalCancel"
      :maskClosable="false"
      :keyboard="false"
      destroyOnClose
    >
      <a-form :model="formData" :rules="rules" ref="formRef">
        <a-form-item label="学生" name="student_id">
          <a-select
            v-model:value="formData.student_id"
            placeholder="选择学生"
            show-search
            :filter-option="filterOption"
            :options="students.map(student => ({
              value: student.student_id,
              label: `${student.name} (${student.student_id}) - ${student.major}`
            }))"
          />
        </a-form-item>

        <a-form-item label="答辩委员会" name="committee_id">
          <a-select
            v-model:value="formData.committee_id"
            placeholder="选择答辩委员会"
          >
            <a-select-option 
              v-for="committee in committees" 
              :key="committee.id"
              :value="committee.id"
            >
              {{ committee.name }}
            </a-select-option>
          </a-select>
        </a-form-item>

        <a-form-item label="答辩时间" name="defense_time">
          <a-date-picker
            v-model:value="formData.defense_time"
            :show-time="true"
            format="YYYY-MM-DD HH:mm"
            placeholder="选择答辩时间"
          />
        </a-form-item>

        <a-form-item label="答辩地点" name="location">
          <a-input v-model:value="formData.location" placeholder="输入答辩地点" />
        </a-form-item>

        <a-form-item label="答辩时长" name="duration">
          <a-input-number
            v-model:value="formData.duration"
            :min="15"
            :max="120"
            addon-after="分钟"
          />
        </a-form-item>

        <a-form-item label="备注" name="notes">
          <a-textarea v-model:value="formData.notes" :rows="3" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { message } from 'ant-design-vue'
import { PlusOutlined } from '@ant-design/icons-vue'
import { 
  getDefenseArrangements,
  createDefenseArrangement,
  updateDefenseArrangement,
  deleteDefenseArrangement,
  getAvailableStudents,
  getDefenseCommittees
} from '@/api/defense'
import { formatDateTime } from '@/utils/format'
import dayjs from 'dayjs'
import { useRoute } from 'vue-router'

// 状态和数据
const loading = ref(false)
const arrangements = ref([])
const students = ref([])
const committees = ref([])
const modalVisible = ref(false)
const modalTitle = ref('')
const formRef = ref()
const searchParams = ref({
  status: '',
  pageNum: 1,
  pageSize: 10
})

// 表单数据
const formData = ref({
  id: null,
  student_id: '',
  committee_id: '',
  defense_time: null,
  location: '',
  duration: 30,
  notes: ''
})

// 分页配置
const pagination = ref({
  current: 1,
  pageSize: 10,
  total: 0
})

// 表格列定义
const columns = [
  {
    title: '学生',
    dataIndex: 'student',
    key: 'student'
  },
  {
    title: '答辩时间',
    dataIndex: 'defense_time',
    key: 'defense_time'
  },
  {
    title: '状态',
    dataIndex: 'status',
    key: 'status'
  },
  {
    title: '操作',
    key: 'action'
  }
]

// 表单验证规则
const rules = {
  student_id: [{ required: true, message: '请选择学生' }],
  committee_id: [{ required: true, message: '请选择答辩委员会' }],
  defense_time: [{ required: true, message: '请选择答辩时间' }],
  location: [{ required: true, message: '请输入答辩地点' }]
}

// 获取数据
const fetchData = async () => {
  loading.value = true
  try {
    const res = await getDefenseArrangements(searchParams.value)
    arrangements.value = res.data.list
    pagination.value = {
      ...pagination.value,
      total: res.data.total
    }
  } catch (error) {
    message.error('获取答辩安排失败')
  } finally {
    loading.value = false
  }
}

// 加载基础数据
const loadBaseData = async () => {
  try {
    console.log('====================');
    console.log('开始加载基础数据...');
    
    const [studentsRes, committeesRes] = await Promise.all([
      getAvailableStudents(),
      getDefenseCommittees()
    ]);
    
    console.log('学生数据响应:', studentsRes);
    console.log('委员会数据响应:', committeesRes);
    
    if (studentsRes.data) {
      students.value = studentsRes.data;
      console.log('可用学生列表:', students.value);
      console.log('学生数量:', students.value.length);
    } else {
      console.warn('学生数据为空');
    }
    
    if (committeesRes.data) {
      committees.value = committeesRes.data;
      console.log('委员会列表:', committees.value);
    } else {
      console.warn('委员会数据为空');
    }
    
    console.log('基础数据加载完成');
    console.log('====================');
  } catch (error) {
    console.error('====================');
    console.error('加载基础数据失败');
    console.error('错误详情:', error);
    console.error('====================');
    message.error('加载基础数据失败');
  }
};

onMounted(() => {
  fetchData()
  loadBaseData()
})

// 处理搜索
const handleSearch = () => {
  searchParams.value.pageNum = 1
  fetchData()
}

// 处理表格变化
const handleTableChange = (pag: any) => {
  searchParams.value.pageNum = pag.current
  searchParams.value.pageSize = pag.pageSize
  fetchData()
}

// 显示安排模态框
const showArrangeModal = () => {
  modalTitle.value = '安排答辩'
  formData.value = {
    id: null,
    student_id: '',
    committee_id: '',
    defense_time: null,
    location: '',
    duration: 30,
    notes: ''
  }
  modalVisible.value = true
}

// 处理编辑
const handleEdit = (record: any) => {
  modalTitle.value = '编辑答辩安排'
  formData.value = {
    ...record,
    defense_time: record.defense_time ? dayjs(record.defense_time) : null
  }
  modalVisible.value = true
}

// 处理删除
const handleDelete = async (id: number) => {
  try {
    await deleteDefenseArrangement(id)
    message.success('删除成功')
    fetchData()
  } catch (error) {
    message.error('删除失败')
  }
}

// 处理模态框确认
const handleModalOk = async () => {
  try {
    await formRef.value.validate()
    const submitData = {
      ...formData.value,
      defense_time: formData.value.defense_time.format('YYYY-MM-DD HH:mm:ss'),
      status: 'in_progress'
    }
    
    if (formData.value.id) {
      await updateDefenseArrangement(formData.value.id, submitData)
      message.success('更新成功')
    } else {
      await createDefenseArrangement(submitData)
      message.success('创建成功')
    }
    
    modalVisible.value = false
    formRef.value?.resetFields()
    fetchData()
  } catch (error) {
    console.error('提交失败:', error)
    message.error('操作失败')
  }
}

// 处理模态框取消
const handleModalCancel = () => {
  modalVisible.value = false
  formRef.value?.resetFields()
}

// Select 搜索过滤
const filterOption = (input: string, option: any) => {
  const searchText = option.label.toLowerCase();
  return searchText.indexOf(input.toLowerCase()) >= 0;
}

// 获取状态文本
const getStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    pending: '待安排',
    in_progress: '已安排',
    completed: '已完成',
    cancelled: '已取消'
  }
  return statusMap[status] || status
}

// 获取状态颜色
const getStatusColor = (status: string) => {
  const colorMap: Record<string, string> = {
    pending: 'orange',
    in_progress: 'blue',
    completed: 'green',
    cancelled: 'red'
  }
  return colorMap[status] || 'default'
}

// 添加只读模式判断
const route = useRoute()
const isReadOnly = computed(() => route.meta.readOnly === true)

// 修改列配置方法
const getColumns = () => {
  const baseColumns = [
    {
      title: '学生',
      key: 'student',
      dataIndex: 'student_name'
    },
    {
      title: '答辩时间',
      key: 'defense_time',
      dataIndex: 'defense_time'
    },
    {
      title: '答辩地点',
      dataIndex: 'location'
    },
    {
      title: '答辩委员会',
      dataIndex: 'committee_name'
    },
    {
      title: '状态',
      key: 'status',
      dataIndex: 'status'
    }
  ]
  
  // 只在非只读模式下添加操作列
  if (!isReadOnly.value) {
    baseColumns.push({
      title: '操作',
      key: 'action',
      width: 150,
      fixed: 'right'
    })
  }
  
  return baseColumns
}
</script>

<style scoped>
.defense-arrangement {
  position: relative;
  z-index: 1;
}

/* 确保模态框层级高于其他元素 */
:deep(.ant-modal-wrap) {
  z-index: 1000;
}

:deep(.ant-modal-mask) {
  z-index: 999;
}

.table-toolbar {
  display: flex;
  justify-content: space-between;
  margin-bottom: 16px;
}

.text-gray-500 {
  color: #666;
}
</style>