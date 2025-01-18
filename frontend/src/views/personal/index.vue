/*
 * @Author: test abc@163.com
 * @Date: 2024-12-09 11:56:17
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-12 15:53:27
 * @FilePath: \Graduation Design Management System\frontend\src\views\personal\index.vue
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
<template>
  <div class="app-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>个人信息</span>
          <el-button type="primary" @click="handleEdit">编辑</el-button>
        </div>
      </template>

      <!-- 只读信息展示 -->
      <el-descriptions v-if="!isEditing" :column="2" border>
        <!-- 基础信息 - 所有角色都显示 -->
        <el-descriptions-item label="用户名">
          {{ userInfo.username }}
        </el-descriptions-item>
        <el-descriptions-item label="角色">
          {{ formattedRole }}
        </el-descriptions-item>
        
        <!-- 工号/学号 -->
        <el-descriptions-item v-if="isTeacherOrStudent" :label="idLabel">
          {{ userInfo.staff_id || userInfo.student_id || '未设置' }}
        </el-descriptions-item>
        
        <!-- 登录次数 -->
        <el-descriptions-item v-if="!isSuperAdmin" label="登录次数">
          {{ userInfo.login_count || 0 }}
        </el-descriptions-item>
        
        <!-- 真实姓名 -->
        <el-descriptions-item label="真实姓名">
          {{ userInfo.name || '未设置' }}
        </el-descriptions-item>
        
        <!-- 性别 -->
        <el-descriptions-item label="性别">
          {{ formatGender(userInfo.gender || 'male') }}
        </el-descriptions-item>
        
        <!-- 部门信息 -->
        <el-descriptions-item :label="departmentLabel">
          {{ userInfo.department || '未设置' }}
        </el-descriptions-item>
        
        <!-- 职位信息 -->
        <el-descriptions-item :label="positionLabel">
          {{ positionValue }}
        </el-descriptions-item>
        
        <!-- 联系方式 -->
        <el-descriptions-item label="邮箱">
          {{ userInfo.email || '未设置' }}
        </el-descriptions-item>
        <el-descriptions-item label="手机">
          {{ userInfo.phone || '未设置' }}
        </el-descriptions-item>
        
        <!-- 简介 -->
        <el-descriptions-item label="简介" :span="2">
          {{ userInfo.introduction || '暂无简介' }}
        </el-descriptions-item>
      </el-descriptions>

      <!-- 编辑表单 -->
      <el-form v-else ref="formRef" :model="form" :rules="rules" label-width="100px">
        <!-- 只读字段 -->
        <el-form-item label="登录名">
          <el-input v-model="userInfo.username" disabled />
        </el-form-item>
        <el-form-item label="角色">
          <el-input :value="formattedRole" disabled />
        </el-form-item>
        
        <!-- 可编辑字段 -->
        <el-form-item label="真实姓名" prop="name">
          <el-input 
            v-model="form.name" 
            placeholder="请输入真实姓名"
          />
        </el-form-item>
        
        <!-- 性别 -->
        <el-form-item label="性别" prop="gender">
          <el-radio-group v-model="form.gender">
            <el-radio label="male">男</el-radio>
            <el-radio label="female">女</el-radio>
          </el-radio-group>
        </el-form-item>

        <!-- 部门信息 -->
        <el-form-item :label="departmentLabel" prop="department">
          <el-input v-model="form.department" />
        </el-form-item>

        <!-- 根据角色显示不同的职位输入 -->
        <template v-if="isStudent">
          <el-form-item label="专业" prop="major">
            <el-input v-model="form.major" />
          </el-form-item>
        </template>
        <template v-else-if="isTeacher">
          <el-form-item label="职称" prop="title">
            <el-input v-model="form.title" />
          </el-form-item>
        </template>

        <!-- 邮箱 -->
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="form.email" />
        </el-form-item>

        <!-- 手机 -->
        <el-form-item label="手机" prop="phone">
          <el-input v-model="form.phone" />
        </el-form-item>

        <!-- 简介 -->
        <el-form-item label="简介" prop="introduction">
          <el-input
            v-model="form.introduction"
            type="textarea"
            :rows="4"
            placeholder="请输入个人简介"
          />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleSubmit">保存</el-button>
          <el-button @click="cancelEdit">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import type { FormInstance, FormRules } from 'element-plus'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'

const userStore = useUserStore()
const formRef = ref<FormInstance>()
const isEditing = ref(false)

// 用户信息接口定义
interface UserInfo {
  username: string
  role: string
  name: string
  gender: 'male' | 'female'
  department: string
  major?: string
  title?: string
  email: string
  phone: string
  introduction: string
  staff_id?: string
  student_id?: string
  login_count: number
}

// 初始化用户信息
const userInfo = ref<UserInfo>({
  username: '',
  role: '',
  name: '',
  gender: 'male',
  department: '',
  major: '',
  title: '',
  email: '',
  phone: '',
  introduction: '',
  login_count: 0
})

// 编辑表单数据
const form = reactive({
  name: '',
  gender: 'male' as 'male' | 'female',
  department: '',
  major: '',
  title: '',
  email: '',
  phone: '',
  introduction: ''
})

// 表单校验规则
const rules = computed(() => ({
  name: [
    { required: true, message: '请输入真实姓名', trigger: 'blur' },
    { min: 2, max: 20, message: '真实姓名长度在 2 到 20 个字符', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号格式', trigger: 'blur' }
  ]
}))

// 格式化函数
const formatRole = (role: string) => {
  const roleMap: Record<string, string> = {
    'student': '学生',
    'teacher': '教师',
    'admin': '管理员',
    'superadmin': '系统管理员'
  }
  return roleMap[role] || role
}

const formatGender = (gender: string) => {
  return gender === 'male' ? '男' : '女'
}

// 处理函数
const handleEdit = () => {
  isEditing.value = true
  form.name = userInfo.value.name || ''
}

const cancelEdit = () => {
  isEditing.value = false
}

// 获取用户详细信息
const fetchUserInfo = async () => {
  try {
    const res = await request.get('/users/profile')
    if (res.code === 200) {
      userInfo.value = {
        ...res.data,
        name: res.data.name || '',
      }
      
      // 更新 store 中的用户信息
      userStore.setUserInfo(userInfo.value)
      
      console.log('Processed user info:', userInfo.value)  // 调试日志
    }
  } catch (error: any) {
    console.error('获取用户信息失败:', error)
    ElMessage.error(error.message || '获取用户信息失败')
  }
}

// 更新用户信息
const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        // 构建更新数据，包含日志信息
        const updateData = {
          ...form,
          // 添加日志相关信息
          action: 'user.profile.update',
          description: `用户 ${userInfo.value.username} 更新了个人信息`,
          details: JSON.stringify({
            name: form.name !== userInfo.value.name ? `姓名: ${userInfo.value.name} -> ${form.name}` : null,
            gender: form.gender !== userInfo.value.gender ? `性别: ${formatGender(userInfo.value.gender)} -> ${formatGender(form.gender)}` : null,
            department: form.department !== userInfo.value.department ? `${departmentLabel.value}: ${userInfo.value.department || '未设置'} -> ${form.department}` : null,
            major: isStudent.value && form.major !== userInfo.value.major ? `专业: ${userInfo.value.major || '未设置'} -> ${form.major}` : null,
            title: isTeacher.value && form.title !== userInfo.value.title ? `职称: ${userInfo.value.title || '未设置'} -> ${form.title}` : null,
            email: form.email !== userInfo.value.email ? `邮箱: ${userInfo.value.email || '未设置'} -> ${form.email}` : null,
            phone: form.phone !== userInfo.value.phone ? `电话: ${userInfo.value.phone || '未设置'} -> ${form.phone}` : null
          })
        }

        const res = await request.put('/users/profile', updateData)
        if (res.code === 200) {
          ElMessage.success('保存成功')
          await fetchUserInfo()
          isEditing.value = false
        }
      } catch (error: any) {
        console.error('更新用户信息失败:', error)
        ElMessage.error(error.message || '保存失败')
      }
    }
  })
}

// 在组件挂载时获取用户信息
onMounted(() => {
  fetchUserInfo()
})

// 计算属性：格式化后的角色名称
const formattedRole = computed(() => {
  return formatRole(userInfo.value.role)
})

// 角色相关的计算属性
const isStudent = computed(() => userInfo.value.role === 'student')
const isTeacher = computed(() => userInfo.value.role === 'teacher')
const isAdmin = computed(() => userInfo.value.role === 'admin')
const isSuperAdmin = computed(() => userInfo.value.role === 'superadmin')
const isTeacherOrStudent = computed(() => isStudent.value || isTeacher.value)

// 标签计算属性
const departmentLabel = computed(() => {
  if (isStudent.value) return '所属院系'
  if (isTeacher.value) return '所属部门'
  return '部门'
})

const positionLabel = computed(() => {
  if (isStudent.value) return '专业'
  if (isTeacher.value) return '职称'
  if (isAdmin.value) return '职位'
  return '职务'
})

const idLabel = computed(() => isStudent.value ? '学号' : '工号')

const positionValue = computed(() => {
  if (isStudent.value) return userInfo.value.major || '未设置'
  if (isTeacher.value) return userInfo.value.title || '未设置'
  return '管理人员'
})
</script>

<style scoped>
.app-container {
  padding: 20px;
}

.box-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

:deep(.el-descriptions) {
  padding: 20px;
}
</style> 