<template>
  <div class="committee-view" style="position: relative;">
    <a-card :bordered="false">
      <!-- 工具栏 -->
      <div class="table-toolbar">
        <div></div>
        <a-button 
          v-if="!isReadOnly"
          type="primary" 
          @click="showModal"
        >
          <PlusOutlined />
          新建委员会
        </a-button>
      </div>

      <!-- 委员会列表 -->
      <a-table
        :columns="getColumns()"
        :data-source="committees"
        :loading="loading"
        :pagination="false"
      >
        <template #bodyCell="{ column, record }">
          <!-- 委员列表 -->
          <template v-if="column.key === 'members'">
            <div>秘书：{{ record.secretary_name }}</div>
            <div>委员：{{ record.member1_name }}</div>
            <div>委员：{{ record.member2_name }}</div>
            <div>委员：{{ record.member3_name }}</div>
          </template>

          <!-- 操作列 -->
          <template v-if="column.key === 'action'">
            <a-space>
              <a @click="showModal(record)">编辑</a>
              <a-divider type="vertical" />
              <a-popconfirm
                title="确定要删除此委员会吗？"
                @confirm="handleDelete(record.id)"
              >
                <a class="text-red-500">删除</a>
              </a-popconfirm>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- 编辑模态框 -->
    <a-modal
      v-if="!isReadOnly"
      :open="modalVisible"
      :title="modalTitle"
      :style="{ zIndex: 1000 }"
      @ok="handleModalOk"
      @cancel="handleModalCancel"
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
        <a-form-item label="委员会名称" name="name">
          <a-input v-model:value="formData.name" />
        </a-form-item>

        <a-form-item label="主席" name="chairman_id">
          <a-select
            v-model:value="formData.chairman_id"
            placeholder="选择主席"
            show-search
            :filter-option="filterOption"
          >
            <a-select-option
              v-for="teacher in teachers"
              :key="teacher.user_id"
              :value="teacher.user_id"
            >
              {{ teacher.name }} ({{ teacher.title }})
            </a-select-option>
          </a-select>
        </a-form-item>

        <a-form-item label="秘书" name="secretary_id">
          <a-select
            v-model:value="formData.secretary_id"
            placeholder="选择秘书"
            show-search
            :filter-option="filterOption"
          >
            <a-select-option
              v-for="teacher in teachers"
              :key="teacher.user_id"
              :value="teacher.user_id"
            >
              {{ teacher.name }} ({{ teacher.title }})
            </a-select-option>
          </a-select>
        </a-form-item>

        <a-form-item label="委员1" name="member1_id">
          <a-select
            v-model:value="formData.member1_id"
            placeholder="选择委员"
            show-search
            :filter-option="filterOption"
          >
            <a-select-option
              v-for="teacher in teachers"
              :key="teacher.user_id"
              :value="teacher.user_id"
            >
              {{ teacher.name }} ({{ teacher.title }})
            </a-select-option>
          </a-select>
        </a-form-item>

        <a-form-item label="委员2" name="member2_id">
          <a-select
            v-model:value="formData.member2_id"
            placeholder="选择委员"
            show-search
            :filter-option="filterOption"
          >
            <a-select-option
              v-for="teacher in teachers"
              :key="teacher.user_id"
              :value="teacher.user_id"
            >
              {{ teacher.name }} ({{ teacher.title }})
            </a-select-option>
          </a-select>
        </a-form-item>

        <a-form-item label="委员3" name="member3_id">
          <a-select
            v-model:value="formData.member3_id"
            placeholder="选择委员"
            show-search
            :filter-option="filterOption"
          >
            <a-select-option
              v-for="teacher in teachers"
              :key="teacher.user_id"
              :value="teacher.user_id"
            >
              {{ teacher.name }} ({{ teacher.title }})
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch, nextTick, computed } from 'vue'
import { message, Modal, Form, Input, Select, Space, Button, Divider, Popconfirm } from 'ant-design-vue'
import { PlusOutlined } from '@ant-design/icons-vue'
import { 
  getDefenseCommittees,
  createDefenseCommittee,
  updateDefenseCommittee,
  deleteDefenseCommittee,
  getAvailableTeachers
} from '@/api/defense'
import { useRoute } from 'vue-router'

// 响应式变量定义
const loading = ref(false)
const modalVisible = ref(false)
const modalTitle = ref('新建委员会')
const committees = ref([])
const teachers = ref([])

// 表单相关
const formRef = ref()
const formData = ref({
  id: null,
  name: '',
  chairman_id: '',
  secretary_id: '',
  member1_id: '',
  member2_id: '',
  member3_id: ''
})

// 表单验证规则
const rules = {
  name: [{ required: true, message: '请输入委员会名称' }],
  chairman_id: [{ required: true, message: '请选择主席' }],
  secretary_id: [{ required: true, message: '请选择秘书' }],
  member1_id: [{ required: true, message: '请选择委员1' }],
  member2_id: [{ required: true, message: '请选择委员2' }],
  member3_id: [{ required: true, message: '请选择委员3' }]
}

// 表格列定义
const columns = [
  {
    title: '委员会名称',
    dataIndex: 'name',
    key: 'name'
  },
  {
    title: '主席',
    dataIndex: 'chairman_name',
    key: 'chairman_name'
  },
  {
    title: '其他成员',
    key: 'members'
  },
  {
    title: '操作',
    key: 'action',
    width: 150
  }
]

// 添加只读模式判断
const route = useRoute()
const isReadOnly = computed(() => route.meta.readOnly === true)

// 修改列配置方法
const getColumns = () => {
  const baseColumns = [
    {
      title: '委员会名称',
      dataIndex: 'name',
      key: 'name'
    },
    {
      title: '主席',
      dataIndex: 'chairman_name',
      key: 'chairman_name'
    },
    {
      title: '其他成员',
      key: 'members'
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

// 获取委员会列表
const fetchData = async () => {
  loading.value = true
  try {
    const res = await getDefenseCommittees()
    committees.value = res.data
  } catch (error) {
    message.error('获取委员会列表失败')
  } finally {
    loading.value = false
  }
}

// 加载教师列表
const loadTeachers = async () => {
  console.log('Loading teachers...')
  try {
    const res = await getAvailableTeachers()
    console.log('Teachers loaded:', res.data)
    teachers.value = res.data
  } catch (error) {
    console.error('Failed to load teachers:', error)
    message.error('获取教师列表失败')
  }
}

// 监视模态框状态
watch(modalVisible, (newVal) => {
  console.log('Modal visibility changed:', newVal)
})

// 修改 showModal 方法
const showModal = (record?: any) => {
  console.log('showModal called')
  
  // 使用 nextTick 确保状态更新
  nextTick(() => {
    modalVisible.value = true
    console.log('Modal visibility after nextTick:', modalVisible.value)
  })
  
  modalTitle.value = record ? '编辑委员会' : '新建委员会'
  
  formData.value = record ? { 
    id: record.id,
    name: record.name,
    chairman_id: record.chairman_id,
    secretary_id: record.secretary_id,
    member1_id: record.member1_id,
    member2_id: record.member2_id,
    member3_id: record.member3_id
  } : {
    id: null,
    name: '',
    chairman_id: '',
    secretary_id: '',
    member1_id: '',
    member2_id: '',
    member3_id: ''
  }
}

// 处理模态框确认
const handleModalOk = async () => {
  console.log('Modal OK clicked')
  try {
    await formRef.value.validate()
    
    // 检查成员是否重复
    const members = new Set([
      formData.value.chairman_id,
      formData.value.secretary_id,
      formData.value.member1_id,
      formData.value.member2_id,
      formData.value.member3_id
    ])
    
    if (members.size !== 5) {
      message.error('委员会成员不能重复')
      return
    }

    if (formData.value.id) {
      await updateDefenseCommittee(formData.value.id, formData.value)
      message.success('更新成功')
    } else {
      await createDefenseCommittee(formData.value)
      message.success('创建成功')
    }
    
    modalVisible.value = false
    formRef.value?.resetFields()
    fetchData()
  } catch (error) {
    console.error('Submit failed:', error)
    message.error('操作失败')
  }
}

// 处理模态框取消
const handleModalCancel = () => {
  modalVisible.value = false
  formRef.value?.resetFields()
}

// 处理删除
const handleDelete = async (id: number) => {
  try {
    await deleteDefenseCommittee(id)
    message.success('删除成功')
    fetchData()
  } catch (error) {
    console.error('删除失败:', error)
    message.error('删除失败')
  }
}

// 搜索过滤
const filterOption = (input: string, option: any) => {
  return option.children.toLowerCase().indexOf(input.toLowerCase()) >= 0
}

// 初始化加载
onMounted(async () => {
  console.log('Component mounted')
  try {
    await Promise.all([
      fetchData(),
      loadTeachers()
    ])
    console.log('Initial data loaded')
  } catch (error) {
    console.error('Failed to load initial data:', error)
  }
})
</script>

<style scoped>
.table-toolbar {
  display: flex;
  justify-content: flex-end;
  margin-bottom: 16px;
}

.text-red-500 {
  color: #ff4d4f;
}

.committee-view {
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
</style>