<template>
  <div class="thesis-review-detail">
    <a-card title="论文评阅信息">
      <a-collapse v-model:activeKey="activeKey">
        <!-- 导师评阅详情 -->
        <a-collapse-panel 
          key="advisor" 
          header="导师评阅详情"
        >
          <div v-if="advisorReview">
            <a-descriptions bordered>
              <a-descriptions-item label="评阅人" :span="1">
                {{ advisorReview.reviewer_name }}
                <span v-if="advisorReview.reviewer_title">
                  ({{ advisorReview.reviewer_title }})
                </span>
              </a-descriptions-item>
              <a-descriptions-item label="分配时间" :span="1">
                {{ formatDate(advisorReview.assigned_at) }}
              </a-descriptions-item>
              <a-descriptions-item label="评阅状态" :span="1">
                <a-tag :color="getReviewStatusColor(advisorReview.status)">
                  {{ getReviewStatusText(advisorReview.status) }}
                </a-tag>
              </a-descriptions-item>
              
              <!-- 评阅详情 -->
              <template v-if="advisorReview.score_innovation">
                <a-descriptions-item label="创新性评分" :span="1">
                  {{ advisorReview.score_innovation }}
                </a-descriptions-item>
                <a-descriptions-item label="质量评分" :span="1">
                  {{ advisorReview.score_quality }}
                </a-descriptions-item>
                <a-descriptions-item label="工作量评分" :span="1">
                  {{ advisorReview.score_workload }}
                </a-descriptions-item>
                <a-descriptions-item label="写作水平评分" :span="1">
                  {{ advisorReview.score_writing }}
                </a-descriptions-item>
                <a-descriptions-item label="总评分" :span="1">
                  <span class="total-score">{{ advisorReview.total_score }}</span>
                </a-descriptions-item>
                <a-descriptions-item label="评阅时间" :span="1">
                  {{ formatDate(advisorReview.review_time) }}
                </a-descriptions-item>
                <a-descriptions-item label="评阅意见" :span="3">
                  {{ advisorReview.review_comments || '暂无评阅意见' }}
                </a-descriptions-item>
              </template>
              <template v-else>
                <a-descriptions-item label="评阅状态" :span="3">
                  <a-alert
                    message="暂未评阅"
                    description="评阅人尚未提交评阅意见和评分"
                    type="info"
                    show-icon
                  />
                </a-descriptions-item>
              </template>
            </a-descriptions>
          </div>
          <a-empty v-else description="暂无导师评阅信息" />
        </a-collapse-panel>

        <!-- 专家评阅详情 -->
        <a-collapse-panel 
          key="peers" 
          header="专家评阅详情"
        >
          <div v-if="peerReviews.length > 0">
            <div v-for="(review, index) in peerReviews" 
                 :key="review.id"
                 style="margin-bottom: 24px;"
            >
              <div class="peer-review-header">专家评阅 #{{ index + 1 }}</div>
              <a-descriptions bordered>
                <a-descriptions-item label="评阅人" :span="1">
                  {{ review.reviewer_name }}
                  <span v-if="review.reviewer_title">
                    ({{ review.reviewer_title }})
                  </span>
                </a-descriptions-item>
                <a-descriptions-item label="分配时间" :span="1">
                  {{ formatDate(review.assigned_at) }}
                </a-descriptions-item>
                <a-descriptions-item label="评阅状态" :span="1">
                  <a-tag :color="getReviewStatusColor(review.status)">
                    {{ getReviewStatusText(review.status) }}
                  </a-tag>
                </a-descriptions-item>

                <!-- 评阅详情 -->
                <template v-if="review.score_innovation">
                  <a-descriptions-item label="创新性评分" :span="1">
                    {{ review.score_innovation }}
                  </a-descriptions-item>
                  <a-descriptions-item label="质量评分" :span="1">
                    {{ review.score_quality }}
                  </a-descriptions-item>
                  <a-descriptions-item label="工作量评分" :span="1">
                    {{ review.score_workload }}
                  </a-descriptions-item>
                  <a-descriptions-item label="写作水平评分" :span="1">
                    {{ review.score_writing }}
                  </a-descriptions-item>
                  <a-descriptions-item label="总评分" :span="1">
                    <span class="total-score">{{ review.total_score }}</span>
                  </a-descriptions-item>
                  <a-descriptions-item label="评阅时间" :span="1">
                    {{ formatDate(review.review_time) }}
                  </a-descriptions-item>
                  <a-descriptions-item label="评阅意见" :span="3">
                    {{ review.review_comments || '暂无评阅意见' }}
                  </a-descriptions-item>
                </template>
                <template v-else>
                  <a-descriptions-item label="评阅状态" :span="3">
                    <a-alert
                      message="暂未评阅"
                      description="评阅人尚未提交评阅意见和评分"
                      type="info"
                      show-icon
                    />
                  </a-descriptions-item>
                </template>
              </a-descriptions>
            </div>
          </div>
          <a-empty v-else description="暂无专家评阅信息" />
        </a-collapse-panel>
      </a-collapse>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { message } from 'ant-design-vue';
import { formatDate } from '@/utils/date';
import { getStudentThesisReviews } from '@/api/thesis';

const activeKey = ref([]);
const reviewData = ref([]);

// 计算属性：获取导师评阅信息
const advisorReview = computed(() => 
  reviewData.value.find(r => r.review_type === 'advisor')
);

// 计算属性：获取专家评阅信息
const peerReviews = computed(() => 
  reviewData.value.filter(r => r.review_type === 'peer')
);

// 获取评阅信息
const fetchReviews = async () => {
  try {
    const res = await getStudentThesisReviews();
    console.log('评阅信息响应:', res);
    if (res.code === 200) {
      reviewData.value = res.data;
    }
  } catch (error) {
    console.error('获取评阅信息失败:', error);
    message.error('获取评阅信息失败');
  }
};

// 评审状态颜色
const getReviewStatusColor = (status: string) => {
  const colorMap: { [key: string]: string } = {
    pending: 'warning',
    completed: 'success'
  };
  return colorMap[status] || 'default';
};

// 评审状态文本
const getReviewStatusText = (status: string) => {
  const statusMap: { [key: string]: string } = {
    pending: '待评审',
    completed: '已完成'
  };
  return statusMap[status] || status;
};

onMounted(() => {
  fetchReviews();
});
</script>

<style scoped>
.thesis-review-detail {
  padding: 24px;
}

.peer-review-header {
  font-size: 16px;
  font-weight: 500;
  margin-bottom: 16px;
  color: #1890ff;
}

.total-score {
  font-size: 18px;
  font-weight: bold;
  color: #1890ff;
}
</style> 