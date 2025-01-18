/*
 * @Author: test abc@163.com
 * @Date: 2024-12-08 21:14:40
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-08 21:14:56
 * @FilePath: \Graduation Design Management System\frontend\src\views\users\UserList.vue
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
 <template>
  <div class="user-list">
    <div class="header">
      <h2>用户管理</h2>
      <el-button type="primary" @click="showCreateDialog">
        创建用户
      </el-button>
    </div>

    <el-table :data="users" border>
      <el-table-column prop="username" label="用户名" />
      <el-table-column prop="role" label="角色">
        <template #default="{ row }">
          {{ getRoleText(row.role) }}
        </template>
      </el-table-column>
      <el-table-column prop="status" label="状态">
        <template #default="{ row }">
          <el-tag :type="row.status === 'active' ? 'success' : 'danger'">
            {{ row.status === 'active' ? '正常' : '禁用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="created_at" label="创建时间" />
      <el-table-column label="操作">
        <template #default="{ row }">
          <el-button-group>
            <el-button 
              type="primary" 
              size="small"
              @click="showResetDialog(row)"
            >
              重置密码
            </el-button>
            <el-button 
              :type="row.status === 'active' ? 'danger' : 'success'"
              size="small"
              @click="handleStatusChange(row)"
            >
              {{ row.status === 'active' ? '禁用' : '启用' }}
            </el-button>
          </el-button-group>
        </template>
      </el-table-column>
    </el-table>

    <!-- 创建用户对话框 -->
    <el-dialog 
      v-model="createDialogVisible" 
      title="创建用户"
    >
      <el-form :model="userForm" :rules="rules" ref="userFormRef">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="userForm.username" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input type="password" v-model="userForm.password" />
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select v-model="userForm.role">
            <el-option label="教师" value="teacher" />
            <el-option label="学生" value="student" />
            <el-option label="管理员" value="admin" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="createDialogVisible = false">取消</el-button>
        <el-button 
          type="primary" 
          @click="handleCreate"
          :loading="submitting"
        >
          确定
        </el-button>
      </template>
    </el-dialog>

    <!-- 重置密码对话框 -->
    <el-dialog 
      v-model="resetDialogVisible" 
      title="重置密码"
    >
      <el-form :model="resetForm" :rules="resetRules" ref="resetFormRef">
        <el-form-item label="新密码" prop="new_password">
          <el-input type="password" v-model="resetForm.new_password" />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirm_password">
          <el-input type="password" v-model="resetForm.confirm_password" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="resetDialogVisible = false">取消</el-button>
        <el-button 
          type="primary" 
          @click="handleReset"
          :loading="submitting"
        >
          确定
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getUsers, createUser, updateUserStatus, resetPassword } from '@/api/user'
import { ElMessage } from 'element-plus'

const users = ref([])
const createDialogVisible = ref(false)
const resetDialogVisible = ref(false)
const submitting = ref(false)
const currentUser = ref(null)

const userForm = ref({
  username: '',
  password: '',
  role: ''
})

const resetForm = ref({
  new_password: '',
  confirm_password: ''
})

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  role: [{ required: true, message: '请选择角色', trigger: 'change' }]
}

const resetRules = {
  new_password: [{ required: true, message: '请输入新密码', trigger: 'blur' }],
  confirm_password: [{ 
    required: true, 
    validator: (rule: any, value: string, callback: Function) => {
      if (value !== resetForm.value.new_password) {
        callback(new Error('两次输入的密码不一致'))
      } else {
        callback()
      }
    },
    trigger: 'blur'
  }]
}

const fetchUsers = async () => {
  try {
    const res = await getUsers()
    users.value = res.data
  } catch (error) {
    ElMessage.error('获取用户列表失败')
  }
}

const handleCreate = async () => {
  try {
    submitting.value = true
    await createUser(userForm.value)
    ElMessage.success('用户创建成功')
    createDialogVisible.value = false
    fetchUsers()
  } catch (error) {
    ElMessage.error('用户创建失败')
  } finally {
    submitting.value = false
  }
}

const handleStatusChange = async (row: any) => {
  try {
    const newStatus = row.status === 'active' ? 'inactive' : 'active'
    await updateUserStatus({ 
      user_id: row.user_id, 
      status: newStatus 
    })
    ElMessage.success('状态更新成功')
    fetchUsers()
  } catch (error) {
    ElMessage.error('状态更新失败')
  }
}

const handleReset = async () => {
  try {
    submitting.value = true
    await resetPassword({
      user_id: currentUser.value.user_id,
      new_password: resetForm.value.new_password
    })
    ElMessage.success('密码重置成功')
    resetDialogVisible.value = false
  } catch (error) {
    ElMessage.error('密码重置失败')
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  fetchUsers()
})
</script>

<style scoped>
.user-list {
  padding: 20px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
</style>