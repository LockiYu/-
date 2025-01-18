<template>
  <a-drawer
    :open="visible"
    title="答辩评审详情"
    width="600"
    placement="right"
    @update:open="handleVisibleChange"
  >
    <template v-if="defenseScores && defenseScores.scores && defenseScores.scores.length">
      <!-- 总体评分信息 -->
      <div class="overall-score">
        <h3>总体评分</h3>
        <a-descriptions bordered>
          <a-descriptions-item label="最终得分" :span="3">
            {{ calculateAverageScore() }}
          </a-descriptions-item>
          <a-descriptions-item label="评定结果" :span="3">
            <a-tag :color="getResultColor(defenseScores.finalResult?.status)">
              {{ getStatusText(defenseScores.finalResult?.status) }}
            </a-tag>
          </a-descriptions-item>
        </a-descriptions>
      </div>

      <a-divider />

      <!-- 评委评分列表 -->
      <div class="committee-scores">
        <h3>评委评分详情</h3>
        <a-collapse v-model:activeKey="activeKeys">
          <a-collapse-panel 
            v-for="(score, index) in defenseScores.scores" 
            :key="index"
            :header="`评委 ${score.teacher_name || index + 1} 评分`"
          >
            <a-descriptions bordered size="small">
              <a-descriptions-item label="答辩陈述" :span="3">
                {{ score.presentation_score }}
              </a-descriptions-item>
              <a-descriptions-item label="问答表现" :span="3">
                {{ score.qa_score }}
              </a-descriptions-item>
              <a-descriptions-item label="创新性" :span="3">
                {{ score.innovation_score }}
              </a-descriptions-item>
              <a-descriptions-item label="完成度" :span="3">
                {{ score.completion_score }}
              </a-descriptions-item>
              <a-descriptions-item label="评委总分" :span="3">
                {{ score.total_score }}
              </a-descriptions-item>
              <a-descriptions-item label="评委职称" :span="3">
                {{ score.teacher_title || '未知' }}
              </a-descriptions-item>
            </a-descriptions>

            <!-- 评语和修改要求 -->
            <div class="mt-4">
              <h4>评语</h4>
              <p>{{ score.comments || '无' }}</p>
              
              <h4 class="mt-4">修改要求</h4>
              <p>{{ score.revision_requirements || '无' }}</p>
            </div>
          </a-collapse-panel>
        </a-collapse>
      </div>

      <!-- 最终评审意见 -->
      <div class="final-review mt-4" v-if="defenseScores.finalResult">
        <h3>最终评审意见</h3>
        <a-descriptions bordered>
          <a-descriptions-item label="评审时间" :span="3">
            {{ formatDateTime(defenseScores.finalResult.review_time) }}
          </a-descriptions-item>
          <a-descriptions-item label="评审意见" :span="3">
            {{ defenseScores.finalResult.teacher_comment || '无' }}
          </a-descriptions-item>
        </a-descriptions>
      </div>
    </template>
    <a-empty v-else description="暂无答辩评分信息" />
  </a-drawer>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { message } from 'ant-design-vue'
import { getDefenseScores } from '@/api/defenseStudent'

const props = defineProps<{
  visible: boolean
  arrangementId?: string | number
}>()

const emit = defineEmits<{
  'update:visible': [value: boolean]
}>()

const handleVisibleChange = (value: boolean) => {
  emit('update:visible', value)
}

const defenseScores = ref<any>({
  scores: [],
  finalResult: null
})
const activeKeys = ref([])

// 计算平均分
const calculateAverageScore = () => {
  if (!defenseScores.value.scores?.length) return 0
  const total = defenseScores.value.scores.reduce((sum: number, score: any) => 
    sum + Number(score.total_score), 0)
  return (total / defenseScores.value.scores.length).toFixed(2)
}

// 获取状态文字
const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    'completed': '通过',
    'revision_needed': '需要修改',
    'failed': '不通过'
  }
  return map[status] || '未知'
}

// 获取状态颜色
const getResultColor = (status: string) => {
  const map: Record<string, string> = {
    'completed': 'success',
    'revision_needed': 'warning',
    'failed': 'error'
  }
  return map[status] || 'default'
}

// 格式化日期时间
const formatDateTime = (datetime: string) => {
  if (!datetime) return ''
  return new Date(datetime).toLocaleString('zh-CN')
}

// 获取答辩评分数据
const fetchDefenseScores = async () => {
  try {
    const res = await getDefenseScores()
    if (res.code === 200) {
      defenseScores.value = res.data
    }
  } catch (error) {
    console.error('获取答辩评分失败:', error)
    message.error('获取答辩评分失败')
  }
}

// 当抽屉打开时获取数据
watch(() => props.visible, (newVal) => {
  if (newVal) {
    fetchDefenseScores()
  }
})
</script>

<style scoped>
.mt-4 {
  margin-top: 1rem;
}
</style> 