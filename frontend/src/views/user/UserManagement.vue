<template>
  <div class="app-container">
    <div class="filter-container">
      <el-form :inline="true" :model="queryParams">
        <el-form-item label="用户名">
          <el-input
            v-model="queryParams.username"
            placeholder="请输入用户名"
            clearable
          />
        </el-form-item>
        <el-form-item label="角色">
          <el-select
            v-model="queryParams.role"
            placeholder="选择角色"
            clearable
            @change="handleRoleChange"
          >
            <el-option label="系统管理员" value="superadmin" />
            <el-option label="管理员" value="admin" />
            <el-option label="教师" value="teacher" />
            <el-option label="学生" value="student" />
            <el-option label="访客" value="guest" />
          </el-select>
        </el-form-item>
        
        <!-- 显示当前选择的角色 -->
        <el-form-item v-if="queryParams.role">
          <el-tag
            closable
            @close="handleRoleReset"
          >
            当前角色: {{ roleMap[queryParams.role] }}
          </el-tag>
        </el-form-item>

        <el-form-item label="部门">
          <el-input
            v-model="queryParams.department"
            placeholder="请输入部门"
            clearable
            @clear="handleQuery"
          />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
          <el-button 
            v-if="canAddUser"
            type="success" 
            @click="handleAdd"
          >新增用户</el-button>
        </el-form-item>
      </el-form>
    </div>

    <el-card class="box-card">
      <el-table
        v-loading="loading"
        :data="userList"
        border
        style="width: 100%"
      >
        <el-table-column prop="username" label="用户名" />
        <el-table-column prop="name" label="姓名" />
        <el-table-column prop="role" label="角色">
          <template #default="{ row }">
            {{ formatRole(row.role) }}
          </template>
        </el-table-column>
        <el-table-column label="工号/学号">
          <template #default="{ row }">
            {{ row.staff_id || row.student_id || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="department" label="部门/院系" />
        <el-table-column prop="email" label="邮箱" />
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="row.status === 'active' ? 'success' : 'danger'">
              {{ row.status === 'active' ? '正常' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="创建时间" width="160">
          <template #default="{ row }">
            {{ row.created_at ? new Date(row.created_at).toLocaleString('zh-CN') : '-' }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button
              v-if="canEditUser(row)"
              link
              type="primary"
              @click="handleEdit(row)"
            >
              编辑
            </el-button>
            <el-button
              v-if="canDeleteUser(row.role)"
              link
              type="danger"
              @click="handleDelete(row)"
            >
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

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

    <!-- 用户编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="500px"
    >
      <user-profile-form
        ref="profileFormRef"
        :user-info="form"
        :is-admin="isSuperAdmin"
        :is-new="!form.id"
      />
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitForm">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { getUserList, createUser, updateUser, deleteUser, getUserById, updateUserById } from '@/api/user'
import UserProfileForm from '@/components/UserProfileForm.vue'

const userStore = useUserStore()

// 查询参数
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  username: '',
  role: '',
  department: ''
})

// 用户列表数据
const userList = ref([])
const total = ref(0)
const loading = ref(false)

// 表单数据
const dialogVisible = ref(false)
const profileFormRef = ref()
const form = reactive({
  id: undefined,
  username: '',
  password: '',
  role: '',
  email: '',
  name: '',
  gender: 'male',
  department: '',
  major: '',
  title: '',
  phone: '',
  introduction: ''
})

// 计算属性
const dialogTitle = computed(() => {
  return form.id ? '编辑用户' : '新增用户'
})

// 角色映射
const roleMap = {
  superadmin: '系统管理员',
  admin: '管理员',
  teacher: '教师',
  student: '学生',
  guest: '访客'
}

// 判断当前用户是否为超级管理员
const isSuperAdmin = computed(() => {
  return userStore.userInfo?.role === 'superadmin'
})

// 判断是否可以编辑该用户
const canEditUser = (targetUser: any) => {
  const currentUserInfo = userStore.userInfo
  
  // 如果当前用户不存在或没有角色信息，不允许编辑
  if (!currentUserInfo?.role) {
    return false
  }

  // 超级管理员可以编辑所有用户（除了其他超级管理员）
  if (currentUserInfo.role === 'superadmin') {
    // 不能编辑其他超级管理员，但可以编辑自己
    if (targetUser.role === 'superadmin') {
      return currentUserInfo.userId === targetUser.user_id
    }
    return true
  }

  // 管理员可以编辑除了超级管理员和管理员之外的用户
  if (currentUserInfo.role === 'admin') {
    return !['superadmin', 'admin'].includes(targetUser.role)
  }

  // 其他角色不能编辑用户
  return false
}

// 判断是否可以删除用户
const canDeleteUser = (userRole: string) => {
  const currentUserInfo = userStore.userInfo
  
  // 超级管理员可以删除除superadmin外的所有用户
  if (currentUserInfo.role === 'superadmin') {
    return !['superadmin'].includes(userRole)
  }
  
  // 管理员可以删除普通用户
  if (currentUserInfo.role === 'admin') {
    return !['superadmin', 'admin'].includes(userRole)
  }
  
  return false
}

// 判断是否可以新增用户
const canAddUser = computed(() => {
  const currentUserRole = userStore.userInfo?.role
  return ['superadmin', 'admin'].includes(currentUserRole || '')
})

// 处理函数
const handleQuery = async () => {
  loading.value = true
  try {
    console.log('发起查询请求，参数:', {
      pageNum: queryParams.pageNum,
      pageSize: queryParams.pageSize,
      username: queryParams.username,
      role: queryParams.role,
      department: queryParams.department
    })

    const response = await getUserList({
      pageNum: queryParams.pageNum,
      pageSize: queryParams.pageSize,
      username: queryParams.username || undefined,
      role: queryParams.role || undefined,
      department: queryParams.department || undefined
    })
    
    console.log('查询响应:', response)
    
    if (response.code === 200) {
      userList.value = response.data
      total.value = response.total
    } else {
      console.error('查询返回非200状态:', response)
      userList.value = []
      total.value = 0
    }
  } catch (error: any) {
    console.error('查询错误:', {
      error,
      response: error.response?.data,
      status: error.response?.status,
      headers: error.response?.headers,
      config: error.config
    })
    ElMessage.error(error.response?.data?.message || '查询失败')
    userList.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

const handleReset = () => {
  queryParams.username = ''
  queryParams.role = ''
  queryParams.department = ''
  handleQuery()
}

const handleAdd = () => {
  // 重置表单数据
  form.id = undefined
  form.username = ''
  form.role = ''
  form.email = ''
  form.password = ''
  
  // 根据当前用户角色设置可选的用户角色
  if (profileFormRef.value) {
    try {
      const currentUserRole = userStore.userInfo?.role
      const availableRoles = currentUserRole === 'admin'
        ? ['teacher', 'student', 'guest']  // 管理员只能创建教师、学生和访客账号
        : ['superadmin', 'admin', 'teacher', 'student', 'guest']  // 超级管理员可以创建所有类型的账号

      if (typeof profileFormRef.value.setAvailableRoles === 'function') {
        profileFormRef.value.setAvailableRoles(availableRoles)
      } else {
        console.warn('setAvailableRoles method not found in UserProfileForm component')
      }
    } catch (error) {
      console.error('Error setting available roles:', error)
    }
  }
  
  dialogVisible.value = true
}

const handleEdit = async (row: any) => {
  try {
    console.log('Editing user:', row)
    // 获取完整的用户信息
    const response = await getUserById(row.user_id)
    if (response.code === 200) {
      console.log('Got user details:', response.data)
      // 更新表单数据
      Object.assign(form, {
        id: response.data.user_id,
        username: response.data.username,
        role: response.data.role,
        email: response.data.email,
        name: response.data.name || '',
        gender: response.data.gender || 'male',
        department: response.data.department || '',
        major: response.data.role === 'student' ? response.data.position || '' : '',
        title: response.data.role !== 'student' ? response.data.position || '' : '',
        phone: response.data.phone || '',
        introduction: response.data.introduction || ''
      })
      dialogVisible.value = true
    }
  } catch (error) {
    console.error('获取用户信息失败:', error)
    ElMessage.error('获取用户信息失败')
  }
}

const handleDelete = async (row: any) => {
  try {
    if (!canDeleteUser(row.role)) {
      ElMessage.error('权限不足，无法删除该用户')
      return
    }

    await ElMessageBox.confirm(
      `确定要删除用户 "${row.username}" 吗？此操作不可恢复！`,
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    const response = await deleteUser(row.user_id)
    
    if (response.code === 200) {
      ElMessage.success('删除成功')
      handleQuery()
    } else {
      ElMessage.error(response.message || '删除失败')
    }
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('Delete error:', error)
      ElMessage.error(
        error.response?.status === 403 
          ? '权限不足，无法删除该用户' 
          : (error.response?.data?.message || '删除失败')
      )
    }
  }
}

const submitForm = async () => {
  if (!profileFormRef.value) return
  
  try {
    const valid = await profileFormRef.value.validate()
    if (valid) {
      const formData = profileFormRef.value.getFormData()
      
      console.log('Form data before submission:', {
        id: form.id,
        formData
      })

      const response = form.id 
        ? await updateUserById(form.id, {
            role: formData.role,
            email: formData.email,
            name: formData.name,
            gender: formData.gender,
            department: formData.department,
            major: formData.role === 'student' ? formData.major : undefined,
            title: formData.role !== 'student' ? formData.title : undefined,
            phone: formData.phone,
            introduction: formData.introduction
          })
        : await createUser({
            username: formData.username,
            password: formData.password,
            ...formData
          })
      
      console.log('API response:', response)
      
      if (response.code === 200) {
        ElMessage.success(form.id ? '更新成功' : '添加成功')
        dialogVisible.value = false
        handleQuery()
      } else {
        ElMessage.error(response.message || '保存失败')
      }
    }
  } catch (error: any) {
    console.error('Save error:', {
      error,
      response: error.response?.data,
      config: error.config
    })
    ElMessage.error(error.response?.data?.message || '保存失败')
  }
}

const handleSizeChange = (val: number) => {
  queryParams.pageSize = val
  handleQuery()
}

const handleCurrentChange = (val: number) => {
  queryParams.pageNum = val
  handleQuery()
}

// 初始化
onMounted(() => {
  handleQuery()
})

// 添加 watch 来监视数据变化
watch(userList, (newVal) => {
  console.log('userList changed:', newVal)
}, { deep: true })

watch(queryParams, (newVal) => {
  console.log('queryParams changed:', newVal)
}, { deep: true })

const handleRoleChange = (value: string) => {
  queryParams.role = value
}

const handleRoleReset = () => {
  queryParams.role = ''
}

// 在 script setup 中添加 formatRole 函数
const formatRole = (role: string) => {
  return roleMap[role] || role
}
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
  gap: 10px;
}

.selected-role {
  margin-top: 10px;
  font-weight: bold;
  color: #333;
}
</style> 