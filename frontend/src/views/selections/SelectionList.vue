 <template>
  <div class="selection-list">
    <div class="header">
      <h2>选题管理</h2>
      <el-select v-model="currentStatus" @change="fetchSelections">
        <el-option label="待审核" value="pending" />
        <el-option label="已通过" value="approved" />
        <el-option label="已拒绝" value="rejected" />
      </el-select>
    </div>

    <el-table :data="selections" border>
      <el-table-column prop="topic_name" label="题目名称" />
      <el-table-column prop="student_name" label="学生姓名" />
      <el-table-column prop="major" label="专业" />
      <el-table-column prop="class_name" label="班级" />
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
            v-if="userStore.role === 'teacher' && row.status === 'pending'"
            type="success" 
            size="small" 
            @click="handleReview(row, 'approved')"
          >
            通过
          </el-button>
          <el-button 
            v-if="userStore.role === 'teacher' && row.status === 'pending'"
            type="danger" 
            size="small" 
            @click="handleReview(row, 'rejected')"
          >
            拒绝
          </el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import { getSelections, reviewSelection } from '@/api/selection'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const selections = ref([])
const currentStatus = ref('pending')

const fetchSelections = async () => {
  try {
    const res = await getSelections({ status: currentStatus.value })
    selections.value = res.data
  } catch (error) {
    ElMessage.error('获取选题列表失败')
  }
}

const handleReview = async (row: any, status: string) => {
  try {
    await reviewSelection({ selection_id: row.selection_id, status })
    ElMessage.success('审核完成')
    fetchSelections()
  } catch (error) {
    ElMessage.error('审核失败')
  }
}

onMounted(() => {
  fetchSelections()
})
</script>

<style scoped>
.selection-list {
  padding: 20px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
</style>