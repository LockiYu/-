<template>
  <div class="login-mask">
    <!-- 左侧系统描述 -->
    <div class="system-intro">
      <div class="logo-container">
        <img src="@/assets/logo_system.svg" alt="系统 Logo" class="logo" />
        <h2>毕业设计管理系统</h2>
      </div>
      <div class="intro-content">
        <p>欢迎使用毕业设计管理系统</p>
        <div class="feature-list">
          <div 
            class="feature-item" 
            v-for="(feature, index) in features" 
            :key="index"
            @click="toggleDetail(index)"
            :class="{ active: activeFeature === index }"
          >
            <el-icon>
              <component :is="feature.icon" />
            </el-icon>
            <span>{{ feature.title }}</span>
          </div>
        </div>
        <transition 
          name="feature-fade"
          mode="out-in"
        >
          <div class="feature-detail-wrapper" :key="activeFeature !== null ? 'detail' : 'empty'">
            <template v-if="activeFeature !== null">
              <div class="feature-detail">
                <div class="detail-icon">
                  <el-icon>
                    <component :is="features[activeFeature].icon" />
                  </el-icon>
                </div>
                <p>{{ features[activeFeature].detail }}</p>
              </div>
            </template>
            <template v-else>
              <div class="empty-state">
                <!-- 空状态内容 -->
              </div>
            </template>
          </div>
        </transition>
      </div>
    </div>

    <!-- 右侧登录框 -->
    <div class="login-container">
      <div class="login-header">
        <img src="@/assets/logo.svg" alt="Logo" class="logo" />
        <h3 class="title">用户登录</h3>
      </div>
      <el-form
        ref="loginFormRef"
        :model="loginForm"
        :rules="loginRules"
        class="login-form"
      >
        <el-form-item prop="username">
          <el-input
            v-model="loginForm.username"
            placeholder="用户名"
            type="text"
            prefix-icon="el-icon-user"
          />
        </el-form-item>

        <el-form-item prop="password">
          <el-input
            v-model="loginForm.password"
            placeholder="密码"
            type="password"
            show-password
            prefix-icon="el-icon-lock"
          />
        </el-form-item>

        <el-form-item class="role-selector">
          <div class="role-buttons">
            <el-tooltip
              v-for="role in roles"
              :key="role.value"
              :content="role.label"
              placement="top"
            >
              <el-button
                :class="['role-button', { active: selectedRole === role.value }]"
                @click="handleRoleSelect(role.value)"
              >
                <el-icon>
                  <component :is="role.icon" />
                </el-icon>
              </el-button>
            </el-tooltip>
          </div>
        </el-form-item>

        <el-form-item style="width: 100%">
          <el-button
            :loading="loading"
            type="primary"
            style="width: 100%"
            @click.prevent="handleLogin(loginFormRef)"
          >
            <span v-if="!loading">登 录</span>
            <span v-else>登 录 中...</span>
          </el-button>
        </el-form-item>

        <el-form-item>
          <div class="register-link">
            <el-button type="default" class="register-button" @click="showRegisterDialog">
              还没有账号？立即注册
            </el-button>
          </div>
        </el-form-item>
      </el-form>
    </div>
  </div>

  <!-- 注册对话框 -->
  <el-dialog
    v-model="registerVisible"
    title="用户注册"
    width="30%"
  >
    <el-form
      ref="registerFormRef"
      :model="registerForm"
      :rules="registerRules"
      label-width="80px"
      class="register-form"
    >
      <el-form-item label="用户名" prop="username">
        <el-input v-model="registerForm.username" />
      </el-form-item>
      
      <el-form-item label="密码" prop="password">
        <el-input
          v-model="registerForm.password"
          type="password"
          show-password
        />
      </el-form-item>

      <el-form-item label="确认密码" prop="confirmPassword">
        <el-input
          v-model="registerForm.confirmPassword"
          type="password"
          show-password
        />
      </el-form-item>
      
      <el-form-item label="用户类型" prop="role">
        <el-radio-group v-model="registerForm.role">
          <el-radio label="student">学生</el-radio>
          <el-radio label="teacher">教师</el-radio>
          <el-radio label="guest">访客</el-radio>
        </el-radio-group>
      </el-form-item>
      
      <el-form-item
        v-if="registerForm.role === 'teacher'"
        label="职工号"
        prop="staffId"
      >
        <el-input v-model="registerForm.staffId" />
      </el-form-item>

      <el-form-item
        v-if="registerForm.role === 'teacher'"
        label="职工口令"
        prop="staffSecret"
      >
        <el-input v-model="registerForm.staffSecret" />
      </el-form-item>
      
      <el-form-item
        v-if="registerForm.role === 'student'"
        label="学号"
        prop="studentId"
      >
        <el-input v-model="registerForm.studentId" />
      </el-form-item>
    </el-form>
    
    <template #footer>
      <span class="dialog-footer">
        <el-button @click="registerVisible = false">取消</el-button>
        <el-button type="primary" @click="handleRegister">注册</el-button>
      </span>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, reactive, nextTick } from 'vue'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { login } from '@/api/auth'
import axios from '@/utils/request'
import { ElMessage } from 'element-plus'
import type { FormInstance } from 'element-plus'
import request from '@/utils/request'

// 登录相关
const loading = ref(false)
const loginFormRef = ref<FormInstance>()
const router = useRouter()
const userStore = useUserStore()

const loginForm = reactive({
  username: '',
  password: ''
})

const loginRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' }
  ]
}

// 功能项数据
const features = [
  { 
    title: '论文题目申报与审批', 
    icon: ElementPlusIconsVue.Document, 
    detail: '学生可以在线提交论文题目，教师可以进行审批和反馈，确保选题符合要求。系统支持多次修改和历史记录查看。' 
  },
  { 
    title: '学生选题与教师认可', 
    icon: ElementPlusIconsVue.Select, 
    detail: '学生可以选择感兴趣的课题，教师可以查看并给予认可，促进师生互动。系统提供推荐功能，帮助学生找到合适的课题。' 
  },
  { 
    title: '进度管理与监控', 
    icon: ElementPlusIconsVue.Timer, 
    detail: '系统提供项目进度管理功能，帮助学生和教师跟踪项目进展，确保按时完成。支持甘特图和进度提醒功能。' 
  },
  { 
    title: '在线答辩与评审', 
    icon: ElementPlusIconsVue.ChatDotRound, 
    detail: '支持在线答辩和评审，方便教师和学生进行远程互动，提高评审效率。系统提供录音和笔记功能，便于记录重要信息。' 
  }
]

const activeFeature = ref<number | null>(null)

const toggleDetail = (index: number) => {
  if (activeFeature === index) {
    activeFeature.value = null
  } else {
    activeFeature.value = index
  }
}

// 添加角色定义
const roles = [
  { label: '访客', value: 'guest', icon: ElementPlusIconsVue.User },
  { label: '学生', value: 'student', icon: ElementPlusIconsVue.School },
  { label: '教师', value: 'teacher', icon: ElementPlusIconsVue.Briefcase },
  { label: '管理员', value: 'admin', icon: ElementPlusIconsVue.Management },
  { label: '系统管理员', value: 'superadmin', icon: ElementPlusIconsVue.Setting }
]

// 添加选中角色的响应式变量
const selectedRole = ref('student') // 默认选中学生

// 添加角色选择处理函数
const handleRoleSelect = (role: string) => {
  selectedRole.value = role
}

// 首先定义角色映射关系
const roleMap = {
  guest: 'guest',
  student: 'student',
  teacher: 'teacher',
  admin: 'admin',
  superadmin: 'superadmin'
} as const

// 修改登录处理函数
const handleLogin = async (formEl: FormInstance | undefined) => {
  if (!formEl) return
  
  try {
    loading.value = true
    await formEl.validate()
    
    const response = await userStore.loginAction({
      username: loginForm.username,
      password: loginForm.password
    })

    // 添加详细的调试日志
    console.log('登录响应:', {
      selectedRole: selectedRole.value,
      userRole: response.data.userInfo.role,
      fullResponse: response
    })

    if (response.code === 200) {
      // 检查用户角色是否匹配
      const userRole = response.data.userInfo.role?.toLowerCase()
      const selectedRoleValue = selectedRole.value.toLowerCase()

      if (userRole !== selectedRoleValue) {
        ElMessage({
          message: `身份验证失败：您选择的是${getRoleName(selectedRoleValue)}，但当前账号是${getRoleName(userRole)}`,
          type: 'error',
          duration: 5000
        })
        userStore.clearUser() // 清除登录状态
        return
      }

      await nextTick()
      ElMessage({
        message: '登录成功',
        type: 'success',
        duration: 3000
      })
      await router.replace('/home')
    } else {
      ElMessage({
        message: response.message || '登录失败',
        type: 'error',
        duration: 5000
      })
    }
  } catch (error: any) {
    console.error('登录错误:', error)
    ElMessage({
      message: error.message || '登录失败',
      type: 'error',
      duration: 5000
    })
  } finally {
    loading.value = false
  }
}

// 添加角色名称转换函数
const getRoleName = (role: string): string => {
  const roleNames = {
    superadmin: '系统管理员',
    admin: '管理员',
    teacher: '教师',
    student: '学生',
    guest: '访客'
  }
  return roleNames[role as keyof typeof roleNames] || role
}

// 注册对话框显示状态
const registerVisible = ref(false)

// 注册表单数据
const registerForm = reactive({
  username: '',
  password: '',
  confirmPassword: '',
  role: 'student', // 默认为学生
  staffId: '', // 教师职工号
  studentId: '', // 学生学号
  staffSecret: '' // 教师职工口令
})

// 注册表单引用
const registerFormRef = ref()

// 注册表单验证规则
const registerRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    { validator: (rule, value, callback) => {
        if (value !== registerForm.password) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      }, trigger: 'blur' }
  ],
  role: [
    { required: true, message: '请选择用户类型', trigger: 'change' }
  ],
  staffSecret: [
    { required: true, message: '请输入职工口令', trigger: 'blur', validator: (rule, value, callback) => {
        if (registerForm.role === 'teacher' && value !== 'BUCT') {
          callback(new Error('职工口令错误'))
        } else {
          callback()
        }
      }, trigger: 'blur' }
  ],
  staffId: [
    { required: true, message: '请输入职工号', trigger: 'blur',
      validator: (rule, value, callback) => {
        if (registerForm.role === 'teacher' && !value) {
          callback(new Error('请输入职工号'))
        } else {
          callback()
        }
      }
    }
  ],
  studentId: [
    { required: true, message: '请输入学号', trigger: 'blur',
      validator: (rule, value, callback) => {
        if (registerForm.role === 'student' && !value) {
          callback(new Error('请输入学号'))
        } else {
          callback()
        }
      }
    }
  ]
}

// 显示注册对话框
const showRegisterDialog = () => {
  registerVisible.value = true
}

// 修改注册处理函数
const handleRegister = async () => {
  if (!registerFormRef.value) return
  
  try {
    await registerFormRef.value.validate()
    
    // 构建注册数据
    const registerData = {
      username: registerForm.username,
      password: registerForm.password,
      role: registerForm.role,
      studentId: registerForm.role === 'student' ? registerForm.studentId : undefined,
      staffId: registerForm.role === 'teacher' ? registerForm.staffId : undefined,
      staffSecret: registerForm.role === 'teacher' ? registerForm.staffSecret : undefined
    }

    const response = await request({
      url: '/auth/register',
      method: 'post',
      data: registerData
    })
    
    ElMessage.success('注册成功')
    registerVisible.value = false
    // 重置表单
    registerForm.username = ''
    registerForm.password = ''
    registerForm.confirmPassword = ''
    registerForm.role = 'student'
    registerForm.staffId = ''
    registerForm.studentId = ''
    registerForm.staffSecret = ''
    
  } catch (error: any) {
    console.error('注册请求失败:', error)
  }
}
</script>

<style scoped>
.login-mask {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: linear-gradient(135deg, #3f87a6, #ebf8e1);
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 50px;
  padding: 0 50px;
}

/* 左侧系统介绍样式 */
.system-intro {
  flex: 1;
  max-width: 600px;
  color: white;
  padding: 40px;
}

.system-intro h2 {
  font-size: 36px;
  margin-bottom: 20px;
  font-weight: 700;
}

.intro-content {
  font-size: 16px;
  line-height: 1.6;
}

.intro-content p {
  margin-bottom: 20px;
  font-size: 18px;
}

.feature-list {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}

.feature-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 15px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.feature-item:hover {
  transform: translateY(-3px);
}

.feature-item .el-icon {
  font-size: 24px;
  color: #fff;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.feature-detail {
  margin-top: 20px;
  padding: 15px;
  background: transparent;
  border-radius: 8px;
  color: #fff;
  display: flex;
  align-items: flex-start;
  gap: 20px;
}

.feature-detail .detail-icon {
  flex-shrink: 0;
}

.feature-detail .el-icon {
  font-size: 36px;
  color: #fff;
  opacity: 0.9;
}

.feature-detail p {
  margin: 0;
  line-height: 1.6;
  font-size: 15px;
  opacity: 0.9;
}

/* 右侧登录框样式 */
.login-container {
  width: 400px;
  padding: 30px;
  background-color: rgba(255, 255, 255, 0.95);
  border-radius: 8px;
}

.login-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 20px;
}

.logo {
  width: 80px;
  height: 80px;
  margin-bottom: 10px;
}

.title {
  text-align: center;
  color: #2c3e50;
  font-size: 28px;
  font-weight: bold;
  letter-spacing: 2px;
}

.register-link {
  text-align: right;
  width: 100%;
  padding: 0;
  margin-top: -10px;
}

:deep(.el-input__wrapper) {
  border-radius: 8px;
  padding: 10px 14px;
  border: 1px solid #ccc;
  font-family: 'Arial', sans-serif;
}

:deep(.el-input__inner) {
  font-size: 16px;
}

:deep(.el-button--primary) {
  height: 45px;
  font-size: 16px;
  border-radius: 8px;
  background-color: #3f87a6;
  border-color: #3f87a6;
  font-family: 'Arial', sans-serif;
}

:deep(.el-button--text) {
  padding: 0;
  font-size: 14px;
  color: #3f87a6;
}

:deep(.el-form-item:last-child) {
  margin-bottom: 0;
}

:deep(.el-dialog) {
  border-radius: 8px;
  overflow: hidden;
}

:deep(.el-dialog__header) {
  background-color: #f5f7fa;
  margin: 0;
  padding: 15px 20px;
}

:deep(.el-dialog__title) {
  font-size: 18px;
  color: #2c3e50;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

:deep(.el-radio-group) {
  display: flex;
  gap: 20px;
}

:deep(.el-radio) {
  margin-right: 0;
}

:deep(.el-input__wrapper:focus-within) {
  box-shadow: 0 0 0 1px #3f87a6 inset;
}

:deep(.el-button--primary:hover) {
  background-color: #2d7594;
  border-color: #2d7594;
}

.feature-fade-enter-active,
.feature-fade-leave-active {
  transition: opacity 0.3s ease;
}

.feature-fade-enter-from,
.feature-fade-leave-to {
  opacity: 0;
}

.feature-detail {
  margin-top: 20px;
  padding: 15px;
  background: transparent;
  border-radius: 8px;
  color: #fff;
  display: flex;
  align-items: flex-start;
  gap: 20px;
}

.feature-detail .detail-icon {
  flex-shrink: 0;
}

.feature-detail .el-icon {
  font-size: 36px;
  color: #fff;
  opacity: 0.9;
}

.feature-detail p {
  margin: 0;
  line-height: 1.6;
  font-size: 15px;
  opacity: 0.9;
}

/* 添加选中状态样式 */
.feature-item {
  transition: all 0.3s ease;
}

.feature-item.active {
  background-color: rgba(255, 255, 255, 0.1);
  transform: scale(1.02);
}

/* 优化按钮样式 */
.register-button {
  color: #3f87a6;
  font-size: 14px;
  padding: 0;
  background: none;
  border: none;
  box-shadow: none;
}

.register-button:hover {
  color: #2d7594;
  text-decoration: underline;
}

.register-form :deep(.el-form-item) {
  margin-bottom: 20px;
  display: flex;
  align-items: center;
}

.register-form :deep(.el-form-item__label) {
  line-height: 40px;
  height: 40px;
  display: flex;
  align-items: center;
}

.register-form :deep(.el-input__wrapper) {
  height: 40px;
}

.register-form :deep(.el-radio-group) {
  height: 40px;
  display: flex;
  align-items: center;
}

.logo-container {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 30px;
}

.logo {
  width: 48px;
  height: 48px;
}

/* 添加到 style 部分 */
.role-selector {
  margin-bottom: 20px;
}

.role-buttons {
  display: flex;
  justify-content: space-between;
  gap: 10px;
  width: 100%;
}

.role-button {
  flex: 1;
  height: 50px;
  border-radius: 8px;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
  background: #f5f7fa;
  border: 2px solid transparent;
}

.role-button:hover {
  background: #e4e7ed;
}

.role-button.active {
  background: #3f87a6;
  border-color: #2d7594;
}

.role-button.active .el-icon {
  color: white;
}

.role-button .el-icon {
  font-size: 24px;
  color: #606266;
}

.feature-detail-wrapper {
  min-height: 100px; /* 设置一个固定的最小高度，避免切换时的跳动 */
}

.empty-state {
  height: 100px;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 优化过渡动画 */
.feature-fade-enter-active,
.feature-fade-leave-active {
  transition: all 0.3s ease;
}

.feature-fade-enter-from,
.feature-fade-leave-to {
  opacity: 0;
  transform: translateY(10px);
}
</style>