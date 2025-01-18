<template>
  <div class="app-container">
    <!-- 操作按钮 -->
    <div class="operation-container">
      <el-button type="primary" @click="handleAdd">新增题目</el-button>
      <el-button type="success" @click="handleImport">批量导入</el-button>
      <el-button type="warning" @click="handleExport">导出题目</el-button>
    </div>

    <!-- 搜索栏 -->
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>论文题目管理</span>
          <div class="filter-container">
            <el-input
              v-model="queryParams.title"
              placeholder="题目关键词"
              style="width: 200px"
              class="filter-item"
              clearable
              @keyup.enter="handleQuery"
            />
            <el-select
              v-model="queryParams.type"
              placeholder="论文类型"
              style="width: 130px"
              class="filter-item"
              clearable
            >
              <el-option 
                v-for="item in topicTypes"
                :key="item.type"
                :label="item.type"
                :value="item.type"
              />
            </el-select>
            <el-select
              v-model="queryParams.status"
              placeholder="题目状态"
              style="width: 130px"
              class="filter-item"
              clearable
            >
              <el-option label="草稿" value="draft" />
              <el-option label="待审核" value="pending" />
              <el-option label="已通过" value="approved" />
              <el-option label="已拒绝" value="rejected" />
              <el-option label="已选择" value="selected" />
            </el-select>
            <el-button type="primary" @click="handleQuery">查询</el-button>
            <el-button @click="resetQuery">重置</el-button>
          </div>
        </div>
      </template>

      <!-- 题目列表 -->
      <el-table
        v-loading="loading"
        :data="topicList"
        border
        style="width: 100%"
      >
        <el-table-column type="expand">
          <template #default="{ row }">
            <el-form label-position="left" inline class="topic-detail">
              <el-form-item label="研究内容">
                {{ row.description }}
              </el-form-item>
              <el-form-item label="专业要求">
                {{ row.majorRequirements }}
              </el-form-item>
              <el-form-item label="学生要求">
                {{ row.studentRequirements }}
              </el-form-item>
              <el-form-item label="来源">
                {{ row.source }}
              </el-form-item>
              <el-form-item label="创建时间">
                {{ row.createdAt }}
              </el-form-item>
            </el-form>
          </template>
        </el-table-column>
        <el-table-column prop="title" label="题目" min-width="200" />
        <el-table-column prop="type" label="类型" width="120">
          <template #default="{ row }">
            {{ getTopicType(row.type) }}
          </template>
        </el-table-column>
        <el-table-column prop="teacherName" label="指导教师" width="120" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button
              v-if="row.status === 'draft' && row.teacherId === userStore.userInfo?.userId"
              type="primary"
              size="small"
              @click="handleApply(row)"
            >
              申请
            </el-button>
            <el-button
              v-if="row.status === 'draft' && row.teacherId === userStore.userInfo?.userId"
              type="warning"
              size="small"
              @click="handleEdit(row)"
            >
              编辑
            </el-button>
            <el-button
              v-if="row.status === 'draft' && row.teacherId === userStore.userInfo?.userId"
              type="danger"
              size="small"
              @click="handleDelete(row)"
            >
              删除
            </el-button>
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

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogType === 'add' ? '新增题目' : '编辑题目'"
      width="600px"
    >
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="100px"
      >
        <el-form-item label="题目" prop="title">
          <el-input v-model="form.title" placeholder="请输入论文题目" />
        </el-form-item>
        <el-form-item label="类型" prop="type">
          <el-select v-model="form.type" placeholder="请选择论文类型" style="width: 100%">
            <el-option
              v-for="item in topicTypes"
              :key="item.type"
              :label="item.type"
              :value="item.type"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="来源" prop="source">
          <el-input v-model="form.source" placeholder="请输入题目来源" />
        </el-form-item>
        <el-form-item label="研究内容" prop="description">
          <el-input
            v-model="form.description"
            type="textarea"
            :rows="4"
            placeholder="请输入研究内容"
          />
        </el-form-item>
        <el-form-item label="专业要求" prop="majorRequirements">
          <el-input
            v-model="form.majorRequirements"
            type="textarea"
            :rows="4"
            placeholder="请输入专业要求"
          />
        </el-form-item>
        <el-form-item label="学生要求" prop="studentRequirements">
          <el-input
            v-model="form.studentRequirements"
            type="textarea"
            :rows="4"
            placeholder="请输入学生要求"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSubmit">确定</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 查看学生对话框 -->
    <el-dialog
      v-model="studentsDialogVisible"
      title="选题学生"
      width="600px"
    >
      <el-table
        :data="selectedStudents"
        border
        style="width: 100%"
      >
        <el-table-column prop="name" label="姓名" width="120" />
        <el-table-column prop="studentId" label="学号" width="120" />
        <el-table-column prop="className" label="班级" />
        <el-table-column prop="selectTime" label="选题时间" width="160" />
      </el-table>
    </el-dialog>

    <!-- 导入对话框 -->
    <el-dialog
      v-model="importDialogVisible"
      title="批量导入题目"
      width="500px"
    >
      <el-upload
        class="upload-demo"
        :action="uploadUrl"
        :headers="uploadHeaders"
        :on-success="handleImportSuccess"
        :on-error="handleImportError"
        :before-upload="handleBeforeUpload"
        accept=".csv,.xlsx,.xls"
        :show-file-list="true"
        :limit="1"
        name="file"
      >
        <el-button type="primary">选择文件</el-button>
        <template #tip>
          <div class="el-upload__tip">
            支持 .csv、.xlsx、.xls 格式文件，
            <el-link 
              type="primary" 
              :href="templateUrl"
              target="_blank"
            >
              下载模板
            </el-link>
          </div>
        </template>
      </el-upload>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { UploadFilled } from '@element-plus/icons-vue'
import type { FormInstance, FormRules } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { getTopicList, getTopicTypes, addTopic, exportTopics, updateTopicStatus, getTopicsList, updateTopic, deleteTopic } from '@/api/thesis'

const userStore = useUserStore()
const loading = ref(false)
const dialogVisible = ref(false)
const studentsDialogVisible = ref(false)
const importDialogVisible = ref(false)
const dialogType = ref<'add' | 'edit'>('add')
const formRef = ref<FormInstance>()
const topicList = ref([])
const selectedStudents = ref([])
const total = ref(0)

// 查询参数
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  title: '',
  type: '',
  status: '',
  teacherId: userStore.userInfo?.userId
})

// 表单数据
const form = reactive({
  id: '',
  title: '',
  type: '',
  source: '',
  description: '',
  majorRequirements: '',
  studentRequirements: '',
  teacherId: userStore.userInfo?.userId
})

// 表单校验规则
const rules = reactive<FormRules>({
  title: [
    { required: true, message: '请输入题目', trigger: 'blur' },
    { min: 5, max: 100, message: '长度在 5 到 100 个字符', trigger: 'blur' }
  ],
  type: [
    { required: true, message: '请选择论文类型', trigger: 'change' }
  ],
  description: [
    { required: true, message: '请输入研究内容', trigger: 'blur' }
  ],
  majorRequirements: [
    { required: true, message: '请输入专业要求', trigger: 'blur' }
  ],
  studentRequirements: [
    { required: true, message: '请输入学生要求', trigger: 'blur' }
  ]
})

// 上传相关
const uploadUrl = computed(() => {
  const baseUrl = import.meta.env.VITE_API_URL || ''
  return `${baseUrl}/api/thesis/topics/import`
})

const templateUrl = computed(() => {
  const baseUrl = import.meta.env.VITE_API_URL || ''
  return `${baseUrl}/api/thesis/topics/template`
})

const uploadHeaders = computed(() => ({
  'Authorization': `Bearer ${userStore.token}`
}))

// 论文类型列表
const topicTypes = ref<Array<{type: string}>>([])

// 获取论文类型
const fetchTopicTypes = async () => {
  try {
    const res = await getTopicTypes()
    if (res.code === 200) {
      topicTypes.value = res.data
    }
  } catch (error) {
    console.error('获取论文类型失败:', error)
  }
}

// 类型映射函数
const getTopicType = (type: string) => {
  return type // 直接返回类型值，因为是从数据库中获取的实际值
}

// 状态映射
const getStatusType = (status: string) => {
  const statusMap: Record<string, string> = {
    'draft': 'info',
    'pending': 'warning',
    'approved': 'success',
    'rejected': 'danger',
    'selected': 'primary'
  }
  return statusMap[status] || ''
}

const getStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    'draft': '草稿',
    'pending': '待审核',
    'approved': '已通过',
    'rejected': '已拒绝',
    'selected': '已选择'
  }
  return statusMap[status] || status
}

// 处理函数
const handleQuery = async () => {
  try {
    loading.value = true;
    const response = await getTopicList({
      pageNum: queryParams.pageNum,
      pageSize: queryParams.pageSize,
      title: queryParams.title || undefined,
      type: queryParams.type || undefined,
      status: queryParams.status || undefined,
      teacherId: queryParams.teacherId
    });

    if (response.code === 200) {
      topicList.value = response.data.list.map((item: any) => ({
        topic_id: item.topic_id,
        title: item.title,
        type: item.type,
        source: item.source,
        teacherId: item.teacher_id,
        teacherName: item.teacher_name,
        description: item.description,
        majorRequirements: item.major_requirements,
        studentRequirements: item.student_requirements,
        status: item.status,
        createdAt: formatDateTime(item.created_at),
        updatedAt: formatDateTime(item.updated_at)
      }));
      total.value = response.data.total;
    }
  } catch (error: any) {
    console.error('获取题目列表失败:', error);
    ElMessage.error(error.message || '获取题目列表失败');
  } finally {
    loading.value = false;
  }
};

const resetQuery = () => {
  queryParams.title = ''
  queryParams.type = ''
  queryParams.status = ''
  queryParams.pageNum = 1
  handleQuery()
}

const handleAdd = () => {
  dialogType.value = 'add'
  Object.assign(form, {
    id: '',
    title: '',
    type: '',
    source: '',
    description: '',
    majorRequirements: '',
    studentRequirements: '',
    teacherId: userStore.userInfo?.userId
  })
  dialogVisible.value = true
}

const handleEdit = (row: any) => {
  dialogType.value = 'edit'
  Object.assign(form, {
    id: row.topic_id,
    title: row.title,
    type: row.type,
    source: row.source,
    description: row.description,
    majorRequirements: row.majorRequirements,
    studentRequirements: row.studentRequirements
  })
  dialogVisible.value = true
}

const handleDelete = async (row: any) => {
  try {
    await ElMessageBox.confirm(
      '确认要删除此题目吗？此操作不可恢复',
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    await deleteTopic(row.topic_id)
    ElMessage.success('删除成功')
    handleQuery()
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('删除失败:', error)
      ElMessage.error(error.response?.data?.message || '删除失败')
    }
  }
}

const handleSubmit = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        const topicData = {
          title: form.title,
          type: form.type,
          source: form.source || '',
          description: form.description,
          majorRequirements: form.majorRequirements,
          studentRequirements: form.studentRequirements,
          teacherId: userStore.userInfo?.userId
        }

        if (dialogType.value === 'add') {
          await addTopic(topicData)
          ElMessage.success('新增题目成功')
        } else {
          await updateTopic(form.id, topicData)
          ElMessage.success('更新题目成功')
        }
        
        dialogVisible.value = false
        handleQuery()
      } catch (error: any) {
        console.error('保存失败:', error)
        ElMessage.error(error.response?.data?.message || '保存失败')
      }
    }
  })
}

const handleViewStudents = async (row: any) => {
  try {
    // TODO: 调用获取选题学生API
    // const response = await getTopicStudents(row.id)
    // selectedStudents.value = response.data
    studentsDialogVisible.value = true
  } catch (error: any) {
    ElMessage.error(error.message || '获取学生信息失败')
  }
}

const handleImport = () => {
  importDialogVisible.value = true
}

const handleExport = async () => {
  try {
    const response = await exportTopics({
      title: queryParams.title || undefined,
      type: queryParams.type || undefined,
      status: queryParams.status || undefined,
      teacherId: queryParams.teacherId || undefined
    })
    
    // 从响应头中获取文件名
    const filename = 'topics.csv'
    
    // 创建 Blob 对象
    const blob = new Blob([response], { type: 'text/csv;charset=utf-8;' })
    
    // 创建下载链接
    const link = document.createElement('a')
    link.href = window.URL.createObjectURL(blob)
    link.setAttribute('download', filename)
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    
    ElMessage.success('导出成功')
  } catch (error: any) {
    console.error('导出失败:', error)
    ElMessage.error(error.message || '导出失败')
  }
}

const handleImportSuccess = (response: any) => {
  if (response.code === 200) {
    ElMessage.success(response.message)
    importDialogVisible.value = false
    handleQuery()
  } else {
    ElMessage.error(response.message || '导入失败')
  }
}

const handleImportError = (error: any) => {
  console.error('导入失败:', error)
  let errorMessage = '导入失败'
  if (error.response) {
    errorMessage = error.response.data?.message || errorMessage
  }
  ElMessage.error(errorMessage)
}

const handleSizeChange = (val: number) => {
  queryParams.pageSize = val;
  queryParams.pageNum = 1; // 切换每页数量时重置为第一页
  handleQuery();
}

const handleCurrentChange = (val: number) => {
  queryParams.pageNum = val;
  handleQuery();
}

const formatDateTime = (dateStr: string) => {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 添加申请处理函数
const handleApply = async (row: any) => {
  try {
    await ElMessageBox.confirm(
      '确认要提交此题目进行审核吗？(申请后不可撤销)',
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    if (!row.topic_id) {
      throw new Error('题目ID不存在');
    }
    
    await updateTopicStatus(row.topic_id, 'pending')
    ElMessage.success('提交审核成功')
    handleQuery() // 刷新列表
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('提交审核失败:', error)
      ElMessage.error(error.response?.data?.message || '提交审核失败')
    }
  }
}

// 添加上传前的处理函数
const handleBeforeUpload = (file: File) => {
  const isValidType = [
    'text/csv',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  ].includes(file.type)
  
  const isLt5M = file.size / 1024 / 1024 < 5

  if (!isValidType) {
    ElMessage.error('只能上传 .csv、.xlsx、.xls 格式文件!')
    return false
  }
  
  if (!isLt5M) {
    ElMessage.error('文件大小不能超过 5MB!')
    return false
  }

  return true
}

// 初始化
onMounted(() => {
  fetchTopicTypes() // 获取论文类型
  handleQuery()
})
</script>

<style scoped>
.app-container {
  padding: 20px;
}

.operation-container {
  margin-bottom: 20px;
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

.topic-detail {
  padding: 20px;
  
  .el-form-item {
    margin-bottom: 0;
    width: 100%;
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

.upload-demo {
  text-align: center;
}
</style> 