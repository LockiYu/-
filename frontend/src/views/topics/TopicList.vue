 <template>
  <div class="topic-list">
    <div class="header">
      <h2>论文题目管理</h2>
      <el-button 
        v-if="userStore.role === 'teacher'"
        type="primary" 
        @click="showTopicDialog"
      >
        申报新题目
      </el-button>
    </div>

    <el-table :data="topics" border>
      <el-table-column prop="topic_name" label="题目名称" />
      <el-table-column prop="topic_type" label="题目类型" />
      <el-table-column prop="teacher_name" label="指导教师" />
      <el-table-column prop="status" label="状态">
        <template #default="{ row }">
          <el-tag :type="getStatusType(row.status)">
            {{ getStatusText(row.status) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作">
        <template #default="{ row }">
          <el-button 
            v-if="userStore.role === 'admin' && row.status === 'pending'"
            type="success" 
            size="small" 
            @click="handleReview(row, 'approved')"
          >
            通过
          </el-button>
          <el-button 
            v-if="userStore.role === 'admin' && row.status === 'pending'"
            type="danger" 
            size="small" 
            @click="handleReview(row, 'rejected')"
          >
            拒绝
          </el-button>
          <el-button 
            type="primary" 
            size="small" 
            @click="showTopicDetail(row)"
          >
            查看详情
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 新增/编辑题目对话框 -->
    <el-dialog 
      v-model="dialogVisible" 
      :title="dialogType === 'create' ? '申报新题目' : '题目详情'"
    >
      <el-form :model="topicForm" :rules="rules" ref="topicFormRef">
        <el-form-item label="题目名称" prop="topic_name">
          <el-input v-model="topicForm.topic_name" />
        </el-form-item>
        <el-form-item label="题目类型" prop="topic_type">
          <el-select v-model="topicForm.topic_type">
            <el-option label="工程设计" value="engineering" />
            <el-option label="理论研究" value="theoretical" />
            <el-option label="应用开发" value="development" />
          </el-select>
        </el-form-item>
        <el-form-item label="内容简介" prop="description">
          <el-input 
            type="textarea" 
            v-model="topicForm.description" 
            rows="4"
          />
        </el-form-item>
        <el-form-item label="专业要求" prop="major_requirement">
          <el-input v-model="topicForm.major_requirement" />
        </el-form-item>
        <el-form-item label="学生要求" prop="student_requirement">
          <el-input v-model="topicForm.student_requirement" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button 
          type="primary" 
          @click="handleSubmit"
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
import { useUserStore } from '@/stores/user'
import { getTopics, createTopic, reviewTopic } from '@/api/topic'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const topics = ref([])
const dialogVisible = ref(false)
const dialogType = ref('create')
const submitting = ref(false)

const topicForm = ref({
  topic_name: '',
  topic_type: '',
  description: '',
  major_requirement: '',
  student_requirement: ''
})

const rules = {
  topic_name: [{ required: true, message: '请输入题目名称', trigger: 'blur' }],
  topic_type: [{ required: true, message: '请选择题目类型', trigger: 'change' }],
  description: [{ required: true, message: '请输入内容简介', trigger: 'blur' }]
}

const fetchTopics = async () => {
  try {
    const res = await getTopics()
    topics.value = res.data
  } catch (error) {
    ElMessage.error('获取题目列表失败')
  }
}

const handleSubmit = async () => {
  try {
    submitting.value = true
    await createTopic(topicForm.value)
    ElMessage.success('题目申报成功')
    dialogVisible.value = false
    fetchTopics()
  } catch (error) {
    ElMessage.error('题目申报失败')
  } finally {
    submitting.value = false
  }
}

const handleReview = async (row: any, status: string) => {
  try {
    await reviewTopic({ topic_id: row.topic_id, status })
    ElMessage.success('审核完成')
    fetchTopics()
  } catch (error) {
    ElMessage.error('审核失败')
  }
}

onMounted(() => {
  fetchTopics()
})
</script>

<style scoped>
.topic-list {
  padding: 20px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
</style>