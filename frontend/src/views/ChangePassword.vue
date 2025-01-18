<template>
  <div class="app-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>修改密码</span>
        </div>
      </template>

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
            placeholder="请输入新密码（至少6位）"
          />
        </el-form-item>
        
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input
            v-model="passwordForm.confirmPassword"
            type="password"
            show-password
            placeholder="请确认新密码"
          />
        </el-form-item>
        
        <el-form-item>
          <el-button 
            type="primary" 
            @click="handlePasswordSubmit" 
            :loading="loading"
          >提交</el-button>
          <el-button @click="resetForm">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import request from '@/utils/request'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const passwordFormRef = ref<FormInstance>()
const passwordForm = ref({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

// 密码验证规则
const validatePass = (rule: any, value: string, callback: Function) => {
  if (value.length < 6) {
    callback(new Error('密码长度不能小于6位'))
  } else {
    if (passwordForm.value.confirmPassword !== '') {
      passwordFormRef.value?.validateField('confirmPassword')
    }
    callback()
  }
}

const validateConfirmPass = (rule: any, value: string, callback: Function) => {
  if (value !== passwordForm.value.newPassword) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const passwordRules: FormRules = {
  oldPassword: [
    { required: true, message: '请输入原密码', trigger: 'blur' }
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { validator: validatePass, trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认新密码', trigger: 'blur' },
    { validator: validateConfirmPass, trigger: 'blur' }
  ]
}

// 提交表单
const handlePasswordSubmit = async () => {
  if (!passwordFormRef.value) return
  
  try {
    // 先进行表单验证
    await passwordFormRef.value.validate()
    
    // 验证通过后再进行请求
    loading.value = true
    const res = await request.put('/users/change-password', {
      oldPassword: passwordForm.value.oldPassword,
      newPassword: passwordForm.value.newPassword
    })
    
    // 只处理成功的情况
    ElMessage.success('密码修改成功，请重新登录')
    userStore.clearUser()
    router.push('/login')
    
  } catch (error: any) {
    // 统一错误处理
    const errorMessage = error.response?.data?.message || '密码修改失败'
    ElMessage.error(errorMessage)
  } finally {
    loading.value = false
  }
}

// 重置表单
const resetForm = () => {
  passwordFormRef.value?.resetFields()
}
</script>

<style scoped>
.app-container {
  padding: 20px;
}

.box-card {
  margin-bottom: 20px;
  max-width: 600px;
  margin: 0 auto;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style> 