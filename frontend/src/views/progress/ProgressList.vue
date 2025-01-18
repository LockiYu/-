 <template>
  <div class="progress-list">
    <el-card v-for="item in progressList" :key="item.progress_id" class="progress-card">
      <template #header>
        <div class="card-header">
          <span>{{ item.topic_name }}</span>
          <span>学生：{{ item.student_name }}</span>
        </div>
      </template>
      
      <el-timeline>
        <el-timeline-item
          v-for="(stage, index) in progressStages"
          :key="index"
          :type="getTimelineType(item[stage.field])"
        >
          <h4>{{ stage.label }}</h4>
          <div class="stage-content">
            <el-tag :type="getStatusType(item[stage.field])">
              {{ getStatusText(item[stage.field]) }}
            </el-tag>
            
            <div v-if="userStore.role === 'student'" class="upload-area">
              <el-upload
                :action="uploadUrl"
                :on-success="(res) => handleUploadSuccess(res, item.progress_id, stage.field)"
                :disabled="item[stage.field] === 'approved'"
              >
                <el-button type="primary" size="small">
                  上传文件
                </el-button>
              </el-upload>
            </div>

            <div v-if="userStore.role === 'teacher'" class="review-area">
              <el-button-group>
                <el-button 
                  type="success" 
                  size="small"
                  @click="handleReview(item.progress_id, stage.field, 'approved')"
                >
                  通过
                </el-button>
                <el-button 
                  type="danger" 
                  size="small"
                  @click="handleReview(item.progress_id, stage.field, 'rejected')"
                >
                  驳回
                </el-button>
              </el-button-group>
            </div>
          </div>
        </el-timeline-item>
      </el-timeline>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import { getProgress, updateProgress, submitFile } from '@/api/progress'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const progressList = ref([])

const progressStages = [
  { field: 'task_book_status', label: '任务书' },
  { field: 'literature_review_status', label: '文献综述' },
  { field: 'proposal_status', label: '开题报告' },
  { field: 'translation_status', label: '原文翻译' },
  { field: 'midterm_status', label: '中期检查' },
  { field: 'thesis_status', label: '论文' },
  { field: 'defense_status', label: '答辩' }
]

const fetchProgress = async () => {
  try {
    const params = userStore.role === 'student' 
      ? { student_id: userStore.userId }
      : { teacher_id: userStore.userId }
    
    const res = await getProgress(params)
    progressList.value = res.data
  } catch (error) {
    ElMessage.error('获取进度失败')
  }
}

const handleReview = async (progressId: number, field: string, status: string) => {
  try {
    await updateProgress({ progress_id: progressId, field, status })
    ElMessage.success('审核完成')
    fetchProgress()
  } catch (error) {
    ElMessage.error('审核失败')
  }
}

const handleUploadSuccess = async (res: any, progressId: number, field: string) => {
  try {
    await submitFile({
      progress_id: progressId,
      field,
      file_url: res.url
    })
    ElMessage.success('文件提交成功')
    fetchProgress()
  } catch (error) {
    ElMessage.error('文件提交失败')
  }
}

onMounted(() => {
  fetchProgress()
})
</script>

<style scoped>
.progress-list {
  padding: 20px;
}

.progress-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.stage-content {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-top: 10px;
}
</style>