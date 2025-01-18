<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getPublicStats, getPublicDefenseArrangements } from '@/api/visitor'
import { Document, User, Calendar } from '@element-plus/icons-vue'
import { formatDate } from '@/utils/format'

const isLoading = ref(false)
const statsData = ref({
  topicsCount: 0,
  teachersCount: 0
})

const defenseData = ref([])
const showDefenseTable = ref(false)

// 获取统计数据
const fetchStats = async () => {
  isLoading.value = true
  try {
    const statsRes = await getPublicStats()
    statsData.value = statsRes.data
  } catch (error) {
    console.error('获取统计数据失败:', error)
  } finally {
    isLoading.value = false
  }
}

// 获取答辩安排
const fetchDefenseArrangements = async () => {
  try {
    const res = await getPublicDefenseArrangements()
    defenseData.value = res.data
  } catch (error) {
    console.error('获取答辩安排失败:', error)
  }
}

onMounted(() => {
  fetchStats()
})

// 查看答辩安排
const handleViewDefense = () => {
  showDefenseTable.value = true
  fetchDefenseArrangements()
}
</script>

<template>
  <div class="visitor-dashboard" v-loading="isLoading">
    <!-- 统计数据卡片 -->
    <div class="dashboard-cards">
      <el-row :gutter="20">
        <el-col :span="8">
          <el-card class="stat-card">
            <div class="card-content">
              <div class="card-icon">
                <el-icon><Document /></el-icon>
              </div>
              <div class="card-info">
                <div class="card-title">已发布课题</div>
                <div class="card-number">{{ statsData.topicsCount }}</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card class="stat-card">
            <div class="card-content">
              <div class="card-icon">
                <el-icon><User /></el-icon>
              </div>
              <div class="card-info">
                <div class="card-title">指导教师</div>
                <div class="card-number">{{ statsData.teachersCount }}</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card class="stat-card clickable" @click="handleViewDefense">
            <div class="card-content">
              <div class="card-icon">
                <el-icon><Calendar /></el-icon>
              </div>
              <div class="card-info">
                <div class="card-title">答辩安排</div>
                <div class="card-action">点击查看 →</div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- 答辩安排对话框 -->
    <el-dialog
      title="答辩安排"
      v-model="showDefenseTable"
      width="80%"
    >
      <el-table :data="defenseData" style="width: 100%">
        <el-table-column prop="student_name" label="学生姓名" />
        <el-table-column prop="major" label="专业" />
        <el-table-column prop="defense_time" label="答辩时间">
          <template #default="scope">
            {{ formatDate(scope.row.defense_time) }}
          </template>
        </el-table-column>
        <el-table-column prop="location" label="答辩地点" />
        <el-table-column prop="duration" label="时长">
          <template #default="scope">
            {{ scope.row.duration }}分钟
          </template>
        </el-table-column>
        <el-table-column prop="committee_name" label="答辩委员会" />
      </el-table>
    </el-dialog>
  </div>
</template>

<style scoped>
.visitor-dashboard {
  padding: 20px;
}

.dashboard-cards {
  margin-bottom: 20px;
}

.stat-card {
  .card-content {
    display: flex;
    align-items: center;
  }

  .card-icon {
    font-size: 48px;
    margin-right: 20px;
    color: var(--el-color-primary);
  }

  .card-info {
    .card-title {
      font-size: 16px;
      color: #909399;
    }

    .card-number {
      font-size: 24px;
      font-weight: bold;
      color: var(--el-color-primary);
    }

    .card-action {
      font-size: 14px;
      color: var(--el-color-primary);
      margin-top: 4px;
    }
  }

  &.clickable {
    cursor: pointer;
    transition: all 0.3s;

    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 2px 12px 0 rgba(0,0,0,0.1);
    }
  }
}
</style> 