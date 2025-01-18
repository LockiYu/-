<template>
  <el-form
    ref="formRef"
    :model="form"
    :rules="rules"
    label-width="100px"
  >
    <el-form-item label="用户名" prop="username">
      <el-input 
        v-model="form.username" 
        :disabled="!isNew"
        placeholder="请输入用户名"
      />
    </el-form-item>
    
    <el-form-item label="角色" prop="role">
      <el-select 
        v-model="form.role" 
        placeholder="请选择角色"
        :disabled="!availableRoles.length"
      >
        <el-option
          v-for="role in availableRoles"
          :key="role"
          :label="roleMap[role]"
          :value="role"
        />
      </el-select>
    </el-form-item>

    <el-form-item label="邮箱" prop="email">
      <el-input v-model="form.email" placeholder="请输入邮箱" />
    </el-form-item>

    <el-form-item 
      v-if="isNew"
      label="密码" 
      prop="password"
    >
      <el-input
        v-model="form.password"
        type="password"
        show-password
        placeholder="请输入密码"
      />
    </el-form-item>

    <el-form-item label="姓名" prop="name">
      <el-input v-model="form.name" placeholder="请输入姓名" />
    </el-form-item>
    
    <el-form-item label="性别" prop="gender">
      <el-radio-group v-model="form.gender">
        <el-radio :value="'male'">男</el-radio>
        <el-radio :value="'female'">女</el-radio>
      </el-radio-group>
    </el-form-item>

    <el-form-item label="部门" prop="department">
      <el-input v-model="form.department" placeholder="请输入部门" />
    </el-form-item>

    <el-form-item 
      :label="form.role === 'student' ? '专业' : '职称'" 
      :prop="form.role === 'student' ? 'major' : 'title'"
    >
      <el-input 
        v-if="form.role === 'student'"
        v-model="form.major" 
        placeholder="请输入专业"
      />
      <el-input 
        v-else
        v-model="form.title" 
        placeholder="请输入职称"
      />
    </el-form-item>

    <el-form-item label="手机号" prop="phone">
      <el-input v-model="form.phone" placeholder="请输入手机号" />
    </el-form-item>

    <el-form-item label="简介" prop="introduction">
      <el-input 
        v-model="form.introduction" 
        type="textarea" 
        :rows="3"
        placeholder="请输入简介"
      />
    </el-form-item>
  </el-form>
</template>

<script setup lang="ts">
import { ref, reactive, defineProps, defineExpose, watch, computed } from 'vue'
import type { FormInstance, FormRules } from 'element-plus'
import { useUserStore } from '@/stores/user'

const props = defineProps({
  userInfo: {
    type: Object,
    required: true
  },
  isAdmin: {
    type: Boolean,
    default: false
  },
  isNew: {
    type: Boolean,
    default: false
  }
})

const formRef = ref<FormInstance>()
const form = reactive({
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

const userStore = useUserStore()

// 角色映射
const roleMap = {
  superadmin: '系统管理员',
  admin: '管理员',
  teacher: '教师',
  student: '学生',
  guest: '访客'
}

// 根据当前用户角色计算可用的角色列表
const availableRoles = computed(() => {
  const currentUserRole = userStore.userInfo?.role
  
  if (currentUserRole === 'superadmin') {
    // 超级管理员可以创建除了超级管理员之外的所有角色
    return ['admin', 'teacher', 'student', 'guest']
  } else if (currentUserRole === 'admin') {
    // 管理员只能创建教师、学生和访客
    return ['teacher', 'student', 'guest']
  }
  return []
})

// 监听 userInfo 变化
watch(() => props.userInfo, (newVal) => {
  Object.assign(form, newVal)
}, { deep: true, immediate: true })

// 表单验证规则
const rules = reactive<FormRules>({
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, message: '用户名长度不能小于3位', trigger: 'blur' }
  ],
  role: [
    { required: true, message: '请选择角色', trigger: 'change' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  password: [
    { required: props.isNew, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能小于6位', trigger: 'blur' }
  ],
  name: [
    { required: true, message: '请输入姓名', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号格式', trigger: 'blur' }
  ]
})

// 对外暴露方法
defineExpose({
  validate: () => formRef.value?.validate(),
  getFormData: () => ({ ...form })
})
</script> 