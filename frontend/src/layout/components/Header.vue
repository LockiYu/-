<template>
  <div class="navbar">
    <div class="logo-container">
      <img src="@/assets/logo_system.svg" alt="系统 Logo" class="logo" />
      <span class="title">毕业设计管理系统</span>
    </div>
    <div class="right-menu">
      <el-dropdown class="avatar-container" trigger="click">
        <div class="avatar-wrapper">
          <el-avatar :size="32" :icon="UserFilled" />
          <span class="user-name">
            {{ currentUsername }}
            <small v-if="currentRole">
              ({{ formatRole(currentRole) }})
            </small>
          </span>
          <el-icon><CaretBottom /></el-icon>
        </div>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item @click="handlePersonalInfo">
              <el-icon><User /></el-icon>
              <span>个人信息</span>
            </el-dropdown-item>
            
            <el-dropdown-item 
              v-if="isAdmin" 
              @click="handleUserManagement"
            >
              <el-icon><Setting /></el-icon>
              <span>用户管理</span>
            </el-dropdown-item>

            <el-dropdown-item @click="handleChangePassword">
              <el-icon><Lock /></el-icon>
              <span>修改密码</span>
            </el-dropdown-item>
            
            <el-dropdown-item divided @click="handleLogout">
              <el-icon><SwitchButton /></el-icon>
              <span>退出登录</span>
            </el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>

    <el-dialog
      v-model="passwordDialogVisible"
      title="修改密码"
      width="400px"
    >
      <el-form
        ref="passwordFormRef"
        :model="passwordForm"
        :rules="passwordRules"
        label-width="100px"
      >
        <el-form-item label="原密码" prop="oldPassword">
          <el-input
            v-model="passwordForm.oldPassword"
            type="password"
            show-password
            placeholder="请输入原密码"
          />
        </el-form-item>
        <el-form-item label="新密码" prop="newPassword">
          <el-input
            v-model="passwordForm.newPassword"
            type="password"
            show-password
            placeholder="请输入新密码"
          />
        </el-form-item>
        <el-form-item label="确认新密码" prop="confirmPassword">
          <el-input
            v-model="passwordForm.confirmPassword"
            type="password"
            show-password
            placeholder="请再次输入新密码"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="passwordDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handlePasswordSubmit">确认</el-button>
        </span>
      </template>
    </el-dialog>

    <el-dialog
      v-model="userManageDialogVisible"
      title="用户管理"
      width="800px"
    >
      <div class="user-manage-container">
        <div class="search-bar">
          <el-form :inline="true">
            <el-form-item label="用户名">
              <el-input
                v-model="userQueryParams.username"
                placeholder="请输入用户名"
                clearable
              />
            </el-form-item>
            <el-form-item label="角色">
              <el-select
                v-model="userQueryParams.role"
                placeholder="选择角色"
                clearable
              >
                <el-option label="教师" value="teacher" />
                <el-option label="学生" value="student" />
                <el-option label="管理员" value="admin" />
              </el-select>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleUserQuery">查询</el-button>
              <el-button @click="resetUserQuery">重置</el-button>
              <el-button type="success" @click="handleAddUser">新增用户</el-button>
            </el-form-item>
          </el-form>
        </div>

        <el-table
          v-loading="userTableLoading"
          :data="userList"
          border
          style="width: 100%"
        >
          <el-table-column prop="username" label="用户名" />
          <el-table-column prop="role" label="角色">
            <template #default="{ row }">
              {{ formatRole(row.role) }}
            </template>
          </el-table-column>
          <el-table-column prop="email" label="邮箱" />
          <el-table-column prop="createTime" label="创建时间" />
          <el-table-column label="操作" width="200">
            <template #default="{ row }">
              <el-button
                link
                type="primary"
                @click="handleEditUser(row)"
              >
                编辑
              </el-button>
              <el-button
                link
                type="danger"
                @click="handleDeleteUser(row)"
              >
                删除
              </el-button>
            </template>
          </el-table-column>
        </el-table>

        <div class="pagination">
          <el-pagination
            v-model:current-page="userQueryParams.pageNum"
            v-model:page-size="userQueryParams.pageSize"
            :total="total"
            :page-sizes="[10, 20, 50, 100]"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, watch, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessage, FormInstance, FormRules } from 'element-plus'
import { User, Lock, SwitchButton, CaretBottom, UserFilled, Setting } from '@element-plus/icons-vue'

const router = useRouter()
const userStore = useUserStore()

// 计算属性获取用户名和角色
const currentUsername = computed(() => {
  return userStore.userInfo?.username || '未知用户'
})

const currentRole = computed(() => {
  return userStore.userInfo?.role
})

// 格式化角色显示
const formatRole = (role: string) => {
  const roleMap: Record<string, string> = {
    'admin': '管理员',
    'superadmin': '超级管理员',
    'teacher': '教师',
    'student': '学生',
    'guest': '访客'
  }
  return roleMap[role] || role
}

// 判断是否为管理员
const isAdmin = computed(() => {
  const role = userStore.userInfo?.role
  return role === 'admin' || role === 'superadmin'
})

// 监听用户信息变化
watch(() => userStore.getUserInfo(), (newUserInfo) => {
  console.log('Header - Current user info:', newUserInfo)
}, { immediate: true })

onMounted(() => {
  console.log('Header mounted - User info:', userStore.getUserInfo())
})

// 修改密码相关
const passwordDialogVisible = ref(false)
const passwordFormRef = ref<FormInstance>()
const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const validateConfirmPassword = (rule: any, value: string, callback: any) => {
  if (value === '') {
    callback(new Error('请再次输入密码'))
  } else if (value !== passwordForm.newPassword) {
    callback(new Error('两次输入密码不一致'))
  } else {
    callback()
  }
}

const passwordRules = reactive<FormRules>({
  oldPassword: [
    { required: true, message: '请输入原密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能小于6位', trigger: 'blur' }
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能小于6位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, validator: validateConfirmPassword, trigger: 'blur' }
  ]
})

// 处理函数
const handlePersonalInfo = () => {
  console.log('Clicking personal info')
  router.push('/personal-info').catch(err => {
    console.error('Navigation failed:', err)
  })
}

const handleChangePassword = () => {
  router.push('/change-password')
}

const handlePasswordSubmit = async () => {
  if (!passwordFormRef.value) return
  
  await passwordFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        // TODO: 调用修改密码API
        ElMessage.success('密码修改成功')
        passwordDialogVisible.value = false
      } catch (error: any) {
        ElMessage.error(error.message || '密码修改失败')
      }
    }
  })
}

const handleLogout = async () => {
  try {
    // TODO: 调用登出API
    userStore.clearUser()
    router.push('/login')
    ElMessage.success('退出成功')
  } catch (error: any) {
    ElMessage.error(error.message || '退出失败')
  }
}

// 用户管理相关
const userManageDialogVisible = ref(false)
const userEditDialogVisible = ref(false)
const userTableLoading = ref(false)
const userFormRef = ref<FormInstance>()
const userList = ref([])
const total = ref(0)

const userQueryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  username: '',
  role: ''
})

const handleUserQuery = () => {
  // 处理查询逻辑
}

const resetUserQuery = () => {
  // 处理重置逻辑
}

const handleAddUser = () => {
  // 处理新增用户逻辑
}

const handleEditUser = (row: any) => {
  // 处理编辑用户逻辑
}

const handleDeleteUser = (row: any) => {
  // 处理删除用户逻辑
}

const handleUserManagement = () => {
  router.push('/user-management')
}
</script>

<style scoped>
.navbar {
  height: 60px;
  overflow: hidden;
  position: relative;
  background: #fff;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
}

.logo-container {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo {
  width: 36px;
  height: 36px;
  transition: transform 0.3s ease;
}

.logo:hover {
  transform: scale(1.05);
}

.title {
  font-size: 18px;
  font-weight: 600;
  color: #2c3e50;
  white-space: nowrap;
}

.right-menu {
  display: flex;
  align-items: center;
}

.avatar-container {
  cursor: pointer;
}

.avatar-wrapper {
  display: flex;
  align-items: center;
  padding: 0 8px;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.avatar-wrapper:hover {
  background: rgba(0, 0, 0, 0.025);
}

.user-name {
  margin: 0 8px;
  font-size: 14px;
  color: #333;
}

.user-name small {
  color: #909399;
  margin-left: 4px;
}

.el-dropdown-menu__item {
  display: flex;
  align-items: center;
}

.el-dropdown-menu__item .el-icon {
  margin-right: 8px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}
</style>
