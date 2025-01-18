<template>
  <div class="student-view">
    <!-- 阶段进度 -->
    <a-card :bordered="false">
      <a-steps :current="currentStepIndex">
        <a-step v-for="stage in stages" :key="stage.type" :status="getStepStatus(stage)">
          <template #title>{{ stage.name }}</template>
          <template #description>
            <div class="step-description">
              <span>{{ getStatusText(stage.status) }}</span>
              <span v-if="stage.score" class="score">得分：{{ stage.score }}</span>
            </div>
</template>
        </a-step>
      </a-steps>
    </a-card>

    <!-- 当前阶段详情 -->
    <a-card class="mt-4" :title="getCurrentStageName" :bordered="false">
      <template #extra>
        <a-tag :color="getStatusColor(currentStage?.status)">
          {{ getStatusText(currentStage?.status) }}
        </a-tag>
      </template>

      <!-- 文件上传区域 -->
      <div class="upload-section" v-if="canSubmitFile">
        <a-upload
          :file-list="fileList"
          :before-upload="beforeUpload"
          @remove="handleRemove"
        >
          <a-button type="primary">
            <upload-outlined /> 上传文件
          </a-button>
        </a-upload>
        <a-button 
          type="primary"
          :disabled="!fileList.length"
          @click="handleSubmit"
          class="ml-2"
        >
          提交
        </a-button>
      </div>

      <!-- 已提交文件信息 -->
      <div v-if="currentStage?.file_url" class="file-info mt-4">
        <file-outlined /> 
        <a 
          :href="`http://localhost:3001/${currentStage.file_url}`" 
          target="_blank"
          rel="noopener noreferrer"
        >
          查看最近已提交文件
        </a>
        <span class="ml-2 text-gray-500">
          (可继续提交新版本)
        </span>
      </div>

      <!-- 教师评语 -->
      <div v-if="currentStage?.teacher_comment" class="comment-section">
        <a-alert type="info" show-icon>
          <template #message>教师评语</template>
          <template #description>{{ currentStage.teacher_comment }}</template>
        </a-alert>
      </div>

      <!-- 截止时间提醒 -->
      <div v-if="currentStage?.deadline" class="deadline-info">
        <a-alert 
          :type="isDeadlineNear ? 'warning' : 'info'" 
          show-icon
        >
          <template #message>截止时间</template>
          <template #description>
            {{ formatDate(currentStage.deadline) }}
            <span v-if="isDeadlineNear" class="text-red-500">
              (还剩 {{ getRemainingDays }} 天)
            </span>
          </template>
        </a-alert>
      </div>
    </a-card>

    <!-- 总体进度和分数 -->
    <a-card class="mt-4" :bordered="false">
      <template #title>
        <div class="progress-title">
          <span>总体进度</span>
          <div class="weighted-score-info">
            <span class="weighted-score">
              {{ literatureReview?.calculated_weighted_score ? 
                 Number(literatureReview.calculated_weighted_score).toFixed(2) : 
                 '0.00' }}
            </span>
            <a-tooltip>
              <template #title>
                <div>已完成阶段的加权总分：</div>
                <div v-for="detail in scoreDetails" :key="detail" style="text-align: left">
                  {{ detail }}
                </div>
              </template>
              <info-circle-outlined class="info-icon" />
            </a-tooltip>
          </div>
        </div>
      </template>
      
      <a-row :gutter="16">
        <a-col :span="12">
          <a-progress
            :percent="completionRate"
            :status="completionRate >= 100 ? 'success' : 'active'"
          />
        </a-col>
      </a-row>
      
    </a-card>

    <!-- 任务书部分 -->
    <a-card class="mt-4" title="任务书信息" :bordered="false">
      <template #extra>
        <div class="status-info">
          <a-tag :color="getStatusColor(taskBookRecord?.status || 'not_started')">
            {{ getStatusText(taskBookRecord?.status || 'not_started') }}
          </a-tag>
        </div>
      </template>

      <!-- 查看任务书按钮 -->
      <a-button 
        type="primary" 
        @click="showTaskDetail"
        class="mt-4"
        v-if="currentTask.task_id"
      >
        查看任务书详情
      </a-button>
    </a-card>

    <!-- 任务书详情抽屉 -->
    <a-drawer
      v-model:open="taskDetailVisible"
      :title="currentTask.title || '任务书详情'"
      width="600"
      placement="right"
    >
      <template v-if="currentTask.task_id">
        <a-descriptions>
          <a-descriptions-item label="指导教师">
            <template v-if="currentStage?.supervisor_name">
              {{ currentStage.supervisor_name }}
              <a-tag v-if="currentStage.supervisor_title" color="blue">
                {{ currentStage.supervisor_title }}
              </a-tag>
            </template>
            <template v-else>未分配</template>
          </a-descriptions-item>
          
          <a-descriptions-item v-if="currentStage?.supervisor_email" label="教师邮箱">
            {{ currentStage.supervisor_email }}
          </a-descriptions-item>
          
          <a-descriptions-item v-if="currentStage?.supervisor_phone" label="教师电话">
            {{ currentStage.supervisor_phone }}
          </a-descriptions-item>
          <a-descriptions-item label="截止时间">
            {{ currentTask.deadline ? dayjs(currentTask.deadline).format('YYYY-MM-DD HH:mm:ss') : '无' }}
          </a-descriptions-item>
          <a-descriptions-item label="状态">
            <a-tag :color="getStatusColor(currentTask.status)">
              {{ getStatusText(currentTask.status) }}
            </a-tag>
          </a-descriptions-item>
        </a-descriptions>

        <a-divider />

        <div class="content-section">
          <h3>任务内容：</h3>
          <div class="content">{{ currentTask.content }}</div>
        </div>

        <div class="requirements-section" v-if="currentTask.requirements">
          <h3>具体要求：</h3>
          <div class="requirements">{{ currentTask.requirements }}</div>
        </div>

        <div class="topic-section" v-if="topicInfo">
          <h3>关联选题：</h3>
          <div class="topic-info">{{ topicInfo.topic_title }}</div>
        </div>
      </template>
      <a-empty v-else description="未找到任务书信息" />
    </a-drawer>

    <!-- 文献综述评阅信息部分 -->
    <a-card class="mt-4" title="文献综述评阅信息" :bordered="false">
      <template #extra>
        <div class="status-info">
          <a-tag :color="getStatusColor(literatureRecord?.status || 'not_started')">
            {{ getStatusText(literatureRecord?.status || 'not_started') }}
          </a-tag>
        </div>
      </template>

      <!-- 查看详情按钮 -->
      <a-button 
        type="primary" 
        @click="showLiteratureDetail"
        class="mt-4"
        v-if="literatureReview"
      >
        查看评阅详情
      </a-button>
    </a-card>

    <!-- 文献综述详情抽屉 -->
    <a-drawer
      v-model:open="literatureDetailVisible"
      title="文献综述评阅详情"
      width="600"
      placement="right"
    >
      <template v-if="literatureReview">
        <a-descriptions>
          <a-descriptions-item label="指导教师" :span="2">
            {{ literatureReview.teacher_name }} {{ literatureReview.teacher_title }}
          </a-descriptions-item>
          <a-descriptions-item label="当前版本">
            第 {{ literatureReview.version }} 版
          </a-descriptions-item>
          <a-descriptions-item label="提交时间" :span="2">
            {{ literatureReview.submit_time || '尚未提交' }}
          </a-descriptions-item>
          <a-descriptions-item label="评阅时间">
            {{ literatureReview.review_time || '尚未评阅' }}
          </a-descriptions-item>
          <a-descriptions-item label="状态" :span="3">
            <a-tag :color="getStatusColor(literatureReview.status)">
              {{ getStatusText(literatureReview.status) }}
            </a-tag>
          </a-descriptions-item>
        </a-descriptions>

        <a-divider />

        <!-- 评分详情 -->
        <div class="score-section">
          <h3>评分详情</h3>
          <a-descriptions bordered>
            <a-descriptions-item label="内容完整性">
              {{ literatureReview.content_score || '-' }}
            </a-descriptions-item>
            <a-descriptions-item label="分析深度">
              {{ literatureReview.analysis_score || '-' }}
            </a-descriptions-item>
            <a-descriptions-item label="结构逻辑">
              {{ literatureReview.structure_score || '-' }}
            </a-descriptions-item>
            <a-descriptions-item label="写作规范">
              {{ literatureReview.writing_score || '-' }}
            </a-descriptions-item>
            <a-descriptions-item label="本阶段得分" :span="2">
              {{ literatureReview.literature_score || '尚未评分' }}
              <span class="score-weight">
                (权重：{{ (Number(literatureReview.literature_weight) * 100).toFixed(1) }}%)
              </span>
            </a-descriptions-item>
          </a-descriptions>
        </div>

        <a-divider />

        <!-- 评阅意见 -->
        <div v-if="literatureReview.status !== 'not_started'" class="comment-section">
          <h3>评阅意见</h3>
          <a-collapse v-model:activeKey="activeKey">
            <a-collapse-panel key="1" header="内容评价">
              {{ literatureReview.content_comment || '暂无评价' }}
            </a-collapse-panel>
            <a-collapse-panel key="2" header="改进建议">
              {{ literatureReview.improvement_suggestions || '暂无建议' }}
            </a-collapse-panel>
            <a-collapse-panel key="3" header="总体评语">
              {{ literatureReview.general_comment || '暂无评语' }}
            </a-collapse-panel>
          </a-collapse>
        </div>

        <a-divider />

        <!-- 文件信息 -->
        <div v-if="literatureReview.file_url" class="file-section">
          <h3>已提交文件</h3>
          <a-card class="file-card">
            <template #extra>
              <a :href="`http://localhost:3001/${literatureReview.file_url}`" 
                 target="_blank"
                 rel="noopener noreferrer">
                下载
              </a>
            </template>
            <a-space>
              <file-outlined />
              <span>{{ getFileName(literatureReview.file_url) }}</span>
              <a-tag>{{ formatFileSize(literatureReview.file_size) }}</a-tag>
            </a-space>
          </a-card>
        </div>
      </template>
      <a-empty v-else description="未找到文献综述评阅信息" />
    </a-drawer>

    <!-- 开题报告评审信息卡片 -->
    <a-card class="mt-4" title="开题报告评审信息" :bordered="false">
      <template #extra>
        <a-tag :color="getStatusColor(proposalReview?.status)">
          {{ getStatusText(proposalReview?.status) }}
        </a-tag>
      </template>

      <!-- 查看详情按钮 -->
      <a-button 
        type="primary" 
        @click="showProposalDetail"
        class="mt-4"
        v-if="proposalReview"
      >
        查看评审详情
      </a-button>
    </a-card>

    <!-- 开题报告详情抽屉 -->
    <a-drawer
      v-model:open="proposalDetailVisible"
      title="开题报告评审详情"
      width="600"
      placement="right"
    >
      <template v-if="proposalReview">
        <a-descriptions>
          <a-descriptions-item label="指导教师" :span="2">
            {{ proposalReview.teacher_name }} {{ proposalReview.teacher_title }}
          </a-descriptions-item>
          <a-descriptions-item label="当前版本">
            第 {{ proposalReview.version }} 版
          </a-descriptions-item>
          <a-descriptions-item label="提交时间" :span="2">
            {{ proposalReview.submit_time || '尚未提交' }}
          </a-descriptions-item>
          <a-descriptions-item label="评审时间">
            {{ proposalReview.review_time || '尚未评审' }}
          </a-descriptions-item>
          <a-descriptions-item label="状态" :span="3">
            <a-tag :color="getStatusColor(proposalReview.status)">
              {{ getStatusText(proposalReview.status) }}
            </a-tag>
          </a-descriptions-item>
        </a-descriptions>

        <a-divider />

        <!-- 评分详情 -->
        <div class="score-section">
          <h3>评分详情</h3>
          <a-descriptions bordered>
            <a-descriptions-item label="研究背景">
              {{ proposalReview.research_background_score || '-' }}
            </a-descriptions-item>
            <a-descriptions-item label="技术路线">
              {{ proposalReview.technical_route_score || '-' }}
            </a-descriptions-item>
            <a-descriptions-item label="可行性分析">
              {{ proposalReview.feasibility_score || '-' }}
            </a-descriptions-item>
            <a-descriptions-item label="创新点">
              {{ proposalReview.innovation_score || '-' }}
            </a-descriptions-item>
            <a-descriptions-item label="总分" :span="2">
              {{ proposalReview.total_score || '尚未评分' }}
              <span class="score-weight">
                (权重：{{ (Number(proposalReview.proposal_weight) * 100).toFixed(1) }}%)
              </span>
            </a-descriptions-item>
          </a-descriptions>
        </div>

        <a-divider />

        <!-- 评审意见 -->
        <div v-if="proposalReview.status !== 'not_started'" class="comment-section">
          <h3>评审意见</h3>
          <a-collapse v-model:activeKey="proposalActiveKey">
            <a-collapse-panel key="1" header="研究背景评语">
              {{ proposalReview.research_background_comment || '暂无评语' }}
            </a-collapse-panel>
            <a-collapse-panel key="2" header="技术路线评语">
              {{ proposalReview.technical_route_comment || '暂无评语' }}
            </a-collapse-panel>
            <a-collapse-panel key="3" header="可行性分析评语">
              {{ proposalReview.feasibility_comment || '暂无评语' }}
            </a-collapse-panel>
            <a-collapse-panel key="4" header="创新点评语">
              {{ proposalReview.innovation_comment || '暂无评语' }}
            </a-collapse-panel>
            <a-collapse-panel key="5" header="总体评语">
              {{ proposalReview.general_comment || '暂无评语' }}
            </a-collapse-panel>
            <a-collapse-panel key="6" header="改进建议">
              {{ proposalReview.improvement_suggestions || '暂无建议' }}
            </a-collapse-panel>
          </a-collapse>
        </div>

        <a-divider />

        <!-- 文件信息 -->
        <div v-if="proposalReview.file_url" class="file-section">
          <h3>已提交文件</h3>
          <a-card class="file-card">
            <template #extra>
              <a :href="`http://localhost:3001/${proposalReview.file_url}`" 
                 target="_blank"
                 rel="noopener noreferrer">
                下载
              </a>
            </template>
            <a-space>
              <file-outlined />
              <span>{{ getFileName(proposalReview.file_url) }}</span>
              <a-tag>{{ formatFileSize(proposalReview.file_size) }}</a-tag>
            </a-space>
          </a-card>
        </div>
      </template>
      <a-empty v-else description="未找到开题报告评审信息" />
    </a-drawer>

    <!-- 外文翻译评审信息卡片 -->
    <a-card class="mt-4" title="外文翻译评审信息" :bordered="false">
      <template #extra>
        <a-tag :color="getStatusColor(translationReview?.status || 'not_started')">
          {{ getStatusText(translationReview?.status || 'not_started') }}
        </a-tag>
      </template>

      <!-- 查看详情按钮 -->
      <a-button 
        type="primary" 
        @click="showTranslationDetail"
        class="mt-4"
      >
        查看评审详情
      </a-button>
    </a-card>

    <!-- 外文翻译详情抽屉 -->
    <a-drawer
      v-model:open="translationDetailVisible"
      title="外文翻译评审详情"
      width="600"
      placement="right"
    >
      <template v-if="translationReview">
        <a-descriptions>
          <a-descriptions-item label="指导教师" :span="2">
            {{ translationReview.teacher_name }} {{ translationReview.teacher_title }}
          </a-descriptions-item>
          <a-descriptions-item label="当前版本">
            第 {{ translationReview.version }} 版
          </a-descriptions-item>
          <a-descriptions-item label="提交时间" :span="2">
            {{ translationReview.submit_time || '尚未提交' }}
          </a-descriptions-item>
          <a-descriptions-item label="评审时间">
            {{ translationReview.review_time || '尚未评审' }}
          </a-descriptions-item>
          <a-descriptions-item label="状态" :span="3">
            <a-tag :color="getStatusColor(translationReview.status)">
              {{ getStatusText(translationReview.status) }}
            </a-tag>
          </a-descriptions-item>
        </a-descriptions>

        <a-divider />

        <!-- 评分详情 -->
        <div class="score-section">
          <h3>评分详情</h3>
          <a-descriptions bordered>
            <a-descriptions-item label="语言准确性">
              {{ translationReview.language_accuracy_score || '-' }}
            </a-descriptions-item>
            <a-descriptions-item label="内容完整性">
              {{ translationReview.content_integrity_score || '-' }}
            </a-descriptions-item>
            <a-descriptions-item label="格式规范">
              {{ translationReview.format_score || '-' }}
            </a-descriptions-item>
            <a-descriptions-item label="总分" :span="2">
              {{ translationReview.total_score || '尚未评分' }}
              <span class="score-weight">
                (权重：{{ (Number(translationReview.translation_weight) * 100).toFixed(1) }}%)
              </span>
            </a-descriptions-item>
          </a-descriptions>
        </div>

        <a-divider />

        <!-- 评审意见 -->
        <div v-if="translationReview.status !== 'not_started'" class="comment-section">
          <h3>评审意见</h3>
          <a-collapse v-model:activeKey="translationActiveKey">
            <a-collapse-panel key="1" header="语言准确性评语">
              {{ translationReview.language_accuracy_comment || '暂无评语' }}
            </a-collapse-panel>
            <a-collapse-panel key="2" header="内容完整性评语">
              {{ translationReview.content_integrity_comment || '暂无评语' }}
            </a-collapse-panel>
            <a-collapse-panel key="3" header="格式规范评语">
              {{ translationReview.format_comment || '暂无评语' }}
            </a-collapse-panel>
            <a-collapse-panel key="4" header="总体评语">
              {{ translationReview.general_comment || '暂无评语' }}
            </a-collapse-panel>
            <a-collapse-panel key="5" header="改进建议">
              {{ translationReview.improvement_suggestions || '暂无建议' }}
            </a-collapse-panel>
          </a-collapse>
        </div>

        <a-divider />

        <!-- 文件信息 -->
        <div v-if="translationReview.file_url" class="file-section">
          <h3>已提交文件</h3>
          <a-card class="file-card">
            <template #extra>
              <a :href="`http://localhost:3001/${translationReview.file_url}`" 
                 target="_blank"
                 rel="noopener noreferrer">
                下载
              </a>
            </template>
            <a-space>
              <file-outlined />
              <span>{{ getFileName(translationReview.file_url) }}</span>
              <a-tag>{{ formatFileSize(translationReview.file_size) }}</a-tag>
            </a-space>
          </a-card>
        </div>
      </template>
      <a-empty v-else description="未找到外文翻译评审信息" />
    </a-drawer>

    <!-- 中期检查评审信息 -->
    <a-card class="mt-4" title="中期检查评审信息" :bordered="false">
      <template #extra>
        <a-tag :color="getStatusColor(midtermReview?.status || 'not_started')">
          {{ getStatusText(midtermReview?.status || 'not_started') }}
        </a-tag>
      </template>

      <!-- 查看详情按钮 -->
      <a-button 
        type="primary" 
        @click="showMidtermDetail"
        class="mt-4"
        v-if="midtermReview"
      >
        查看评审详情
      </a-button>
    </a-card>

    <!-- 中期检查详情抽屉 -->
    <a-drawer
      v-model:open="midtermDetailVisible"
      title="中期检查详情"
      width="600"
      placement="right"
    >
      <template v-if="midtermReview">
        <a-descriptions>
          <a-descriptions-item label="指导教师" :span="2">
            {{ midtermReview.teacher_name }} {{ midtermReview.teacher_title }}
          </a-descriptions-item>
          <a-descriptions-item label="当前版本">
            第 {{ midtermReview.version }} 版
          </a-descriptions-item>
          <a-descriptions-item label="提交时间" :span="2">
            {{ midtermReview.submit_time || '尚未提交' }}
          </a-descriptions-item>
          <a-descriptions-item label="评审时间">
            {{ midtermReview.review_time || '尚未评审' }}
          </a-descriptions-item>
          <a-descriptions-item label="状态" :span="3">
            <a-tag :color="getStatusColor(midtermReview.status)">
              {{ getStatusText(midtermReview.status) }}
            </a-tag>
          </a-descriptions-item>
        </a-descriptions>

        <a-divider />

        <!-- 评分详情 -->
        <div class="score-section">
          <h3>评分详情</h3>
          <a-descriptions bordered>
            <a-descriptions-item label="研究进度">
              {{ midtermReview.research_progress_score || '-' }}
            </a-descriptions-item>
            <a-descriptions-item label="技术掌握">
              {{ midtermReview.technical_ability_score || '-' }}
            </a-descriptions-item>
            <a-descriptions-item label="工作态度">
              {{ midtermReview.work_attitude_score || '-' }}
            </a-descriptions-item>
            <a-descriptions-item label="总分" :span="3">
              {{ midtermReview.total_score || '尚未评分' }}
            </a-descriptions-item>
          </a-descriptions>
        </div>

        <a-divider />

        <!-- 评审意见 -->
        <div v-if="midtermReview.status !== 'pending'" class="comment-section">
          <h3>评审意见</h3>
          <a-collapse v-model:activeKey="midtermActiveKey">
            <a-collapse-panel key="1" header="研究进度评价">
              {{ midtermReview.progress_comment || '暂无评价' }}
            </a-collapse-panel>
            <a-collapse-panel key="2" header="技术能力评价">
              {{ midtermReview.technical_comment || '暂无评价' }}
            </a-collapse-panel>
            <a-collapse-panel key="3" header="工作态度评价">
              {{ midtermReview.attitude_comment || '暂无评价' }}
            </a-collapse-panel>
            <a-collapse-panel key="4" header="改进建议">
              {{ midtermReview.improvement_suggestions || '暂无建议' }}
            </a-collapse-panel>
          </a-collapse>
        </div>

        <a-divider />

        <!-- 文件信息 -->
        <div v-if="midtermReview.file_url" class="file-section">
          <h3>已提交文件</h3>
          <a-card class="file-card">
            <template #extra>
              <a :href="`http://localhost:3001/${midtermReview.file_url}`" 
                 target="_blank"
                 rel="noopener noreferrer">
                下载
              </a>
            </template>
            <a-space>
              <file-outlined />
              <span>{{ getFileName(midtermReview.file_url) }}</span>
              <a-tag>{{ formatFileSize(midtermReview.file_size) }}</a-tag>
            </a-space>
          </a-card>
        </div>
      </template>
      <a-empty v-else description="未找到中期检查评审信息" />
    </a-drawer>


    <!-- 论文提交评阅详情抽屉 -->
    <a-drawer
      v-model:open="thesisDetailVisible"
      title="论文提交评阅详情"
      width="600"
      placement="right"
    >
      <template v-if="thesisSubmission">
        <a-descriptions>
          <a-descriptions-item label="指导教师" :span="2">
            {{ thesisSubmission.advisor_name }}
          </a-descriptions-item>
          <a-descriptions-item label="当前版本">
            第 {{ thesisSubmission.version }} 版
          </a-descriptions-item>
          <a-descriptions-item label="提交时间" :span="2">
            {{ thesisSubmission.submit_time || '尚未提交' }}
          </a-descriptions-item>
          <a-descriptions-item label="评阅时间">
            {{ thesisSubmission.advisor_review_time || '尚未评阅' }}
          </a-descriptions-item>
          <a-descriptions-item label="论文标题" :span="3">
            {{ thesisSubmission.title }}
          </a-descriptions-item>
          <a-descriptions-item label="关键词" :span="3" v-if="thesisSubmission.keywords">
            {{ thesisSubmission.keywords }}
          </a-descriptions-item>
        </a-descriptions>

        <a-divider />

        <!-- 评阅状态 -->
        <div class="review-status-section">
          <h3>评阅状态</h3>
          <a-descriptions bordered>
            <a-descriptions-item label="指导教师评阅" :span="3">
              <a-tag :color="getStatusColor(thesisSubmission.advisor_review_status)">
                {{ getStatusText(thesisSubmission.advisor_review_status) }}
              </a-tag>
            </a-descriptions-item>
          </a-descriptions>
        </div>

        <a-divider />

        <!-- 指导教师评阅意见 -->
        <div v-if="thesisSubmission.advisor_review_status !== 'pending'" class="comment-section">
          <h3>指导教师评阅意见</h3>
          <a-collapse v-model:activeKey="thesisActiveKey">
            <a-collapse-panel key="1" header="评阅意见">
              {{ thesisSubmission.advisor_review_comments || '暂无评语' }}
            </a-collapse-panel>
            <a-collapse-panel key="2" header="修改建议">
              {{ thesisSubmission.advisor_comments || '暂无建议' }}
            </a-collapse-panel>
          </a-collapse>
        </div>

        <a-divider />

        <!-- 文件信息 -->
        <div v-if="thesisSubmission.file_url" class="file-section">
          <h3>已提交文件</h3>
          <a-card class="file-card">
            <template #extra>
              <a :href="`http://localhost:3001/${thesisSubmission.file_url}`" 
                 target="_blank"
                 rel="noopener noreferrer">
                下载
              </a>
            </template>
            <a-space>
              <file-outlined />
              <span>{{ getFileName(thesisSubmission.file_url) }}</span>
              <a-tag>{{ formatFileSize(thesisSubmission.file_size) }}</a-tag>
            </a-space>
          </a-card>
        </div>

        <!-- 摘要信息 -->
        <div v-if="thesisSubmission.abstract" class="abstract-section">
          <a-divider />
          <h3>论文摘要</h3>
          <div class="abstract-content">
            {{ thesisSubmission.abstract }}
          </div>
        </div>
      </template>
      <a-empty v-else description="未找到论文提交记录" />
    </a-drawer>

    <!-- 在中期检查卡片后添加论文提交评阅卡片 -->
    <a-card class="mt-4" title="论文提交评阅" :bordered="false">
      <template #extra>
        <a-tag :color="getStatusColor(thesisSubmission?.status || 'not_started')">
          {{ getStatusText(thesisSubmission?.status || 'not_started') }}
        </a-tag>
      </template>

      
      <!-- 已提交论文信息 -->
      <div v-if="thesisSubmission?.file_url" class="file-info mt-4">
        <file-outlined /> 
        <a 
          :href="`http://localhost:3001/${thesisSubmission.file_url}`" 
          target="_blank"
          rel="noopener noreferrer"
        >
          查看已提交论文
        </a>
        <span class="ml-2 text-gray-500">
          (可继续提交新版本)
        </span>
      </div>

      <!-- 查看评阅详情按钮 -->
      <a-button 
        type="primary" 
        @click="showThesisReviewDetail"
        class="mt-4"
        v-if="thesisSubmission"
      >
        查看评阅详情
      </a-button>
    </a-card>

    <!-- 论文评阅详情组件 -->
    <ThesisReviewDetail
      v-model:visible="thesisReviewVisible"
      :submission="thesisSubmission"
      @update="fetchThesisSubmission"
    />

    <!-- 在最后一个卡片之前添加 -->
    <a-card class="mt-4" title="论文答辩信息" :bordered="false">
      <template #extra>
        <div class="status-info">
          <a-tag :color="getStatusColor(defenseInfo?.status || 'pending')">
            {{ getStatusText(defenseInfo?.status || 'pending') }}
          </a-tag>
        </div>
      </template>

      <!-- 答辩安排信息 -->
      <template v-if="defenseInfo">
        <a-descriptions>
          <a-descriptions-item label="答辩时间" :span="2">
            {{ formatDate(defenseInfo.defense_time) }}
          </a-descriptions-item>
          <a-descriptions-item label="答辩地点">
            {{ defenseInfo.location }}
          </a-descriptions-item>
          <a-descriptions-item label="答辩时长" :span="1">
            {{ defenseInfo.duration }} 分钟
          </a-descriptions-item>
        </a-descriptions>

        <!-- 答辩委员会信息 -->
        <template v-if="defenseInfo.committee">
          <a-divider />
          <h3>答辩委员会</h3>
          <a-descriptions>
            <a-descriptions-item label="委员会名称" :span="3">
              {{ defenseInfo.committee.name }}
            </a-descriptions-item>
          </a-descriptions>
          
          <a-table
            :dataSource="defenseInfo.committee.members"
            :columns="committeeColumns"
            :pagination="false"
            size="small"
            class="mt-4"
          />
        </template>

        <!-- 备注信息 -->
        <template v-if="defenseInfo.notes">
          <a-divider />
          <h3>备注信息</h3>
          <div class="defense-notes">
            {{ defenseInfo.notes }}
          </div>
        </template>

        <template v-if="defenseInfo">
          <a-button 
            type="primary" 
            @click="defenseReviewVisible = true"
            class="mt-4"
            v-if="defenseInfo.status === 'completed'"
          >
            查看答辩评审详情
          </a-button>

          <!-- 添加评审详情组件 -->
          <DefenseReviewDetail
            :visible="defenseReviewVisible"
            :arrangement-id="defenseInfo?.id"
            @update:visible="defenseReviewVisible = $event"
          />
        </template>
      </template>

      <!-- 未安排答辩时显示 -->
      <a-empty v-else description="暂未安排答辩" />
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { message, Modal } from 'ant-design-vue'
import { UploadOutlined, FileOutlined, InfoCircleOutlined } from '@ant-design/icons-vue'
import { 
  getProgress, 
  submitFile, 
  getLiteratureReview, 
  getOrCreateProposalReview, 
  updateProgress, 
  getMidtermReview, 
  createOrUpdateMidtermReview,
  getDefenseInfo
} from '@/api/progress'
import { 
  getTranslationReview,
  createOrUpdateTranslationReview
} from '@/api/translation'
import { formatDate } from '@/utils/date'
import { getLatestStudentTask } from '@/api/tasks'
import { request } from '@/utils/request'
import { useUserStore } from '@/stores/user'
import dayjs from 'dayjs'
import { useRouter } from 'vue-router'
import { getStudentThesisHistory } from '@/api/studentThesis'
import ThesisReviewDetail from '@/views/thesis/ThesisReviewDetail.vue'
import DefenseReviewDetail from '@/components/DefenseReviewDetail.vue'

const userStore = useUserStore()
const router = useRouter()

const stages = ref([])
const currentStage = ref(null)
const fileList = ref([])
const totalScore = ref(null)

// 任务书相关状态
const taskDetailVisible = ref(false)
const currentTask = ref({})
const teacherInfo = ref({})
const topicInfo = ref(null)

// 答辩评审详情
const defenseReviewVisible = ref(false)

// 获取进度数据
const fetchProgress = async () => {
  try {
    const res = await getProgress()
    if (res.code === 200) {
      stages.value = res.data.stages
      totalScore.value = res.data.totalScore
      updateCurrentStage()
    }
  } catch (error) {
    message.error('获取进度数据失败')
  }
}

// 更新当前阶段
const updateCurrentStage = () => {
  currentStage.value = stages.value.find(s => 
    s.status === 'in_progress' || s.status === 'reviewing'
  ) || stages.value.find(s => s.status === 'not_started');
}

// 计算当前步骤索引
const currentStepIndex = computed(() => {
  const inProgressIndex = stages.value.findIndex(s => 
    s.status === 'in_progress' || s.status === 'reviewing'
  );
  return inProgressIndex >= 0 ? inProgressIndex : 
    stages.value.findIndex(s => s.status === 'not_started');
});

// 获取步骤状态
const getStepStatus = (stage) => {
  switch (stage.status) {
    case 'completed': return 'finish';
    case 'in_progress':
    case 'reviewing': return 'process';
    case 'revision_needed': return 'error';
    default: return 'wait';
  }
}

// 获取状态颜色
const getStatusColor = (status) => {
  const statusColors = {
    'not_started': 'default',
    'in_progress': 'processing',
    'reviewing': 'warning',
    'revision_needed': 'error',
    'completed': 'success',
    'advisor_approved': 'success',
    'review_assigned': 'success',
    'overdue': 'error',
    'pending': 'warning'
  }
  return statusColors[status] || 'default'
}

// 获取状态文本
const getStatusText = (status: string) => {
  const statusMap: { [key: string]: string } = {
    not_started: '未开始',
    in_progress: '进行中',
    reviewing: '评阅中',
    revision_needed: '需修改',
    completed: '已完成',
    pending: '待提交',
    advisor_approved: '已完成',
    review_assigned: '已分配评阅人'
  };
  return statusMap[status] || status;
}

// 是否可以提交文件
const canSubmitFile = computed(() => {
  return currentStage.value?.status === 'not_started' 
    || currentStage.value?.status === 'in_progress'
    || currentStage.value?.status === 'reviewing'
    || currentStage.value?.status === 'revision_needed';
})

// 文件上传前检查
const beforeUpload = (file: any) => {
  // 检查文件类型
  const isValidType = file.type === 'application/pdf' || 
                     file.type === 'application/msword' || 
                     file.type === 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
  if (!isValidType) {
    message.error('只能上传 PDF 或 Word 文档！');
    return false;
  }

  // 检查文件大小（限制为20MB）
  const isLt20M = file.size / 1024 / 1024 < 20;
  if (!isLt20M) {
    message.error('文件必须小于 20MB！');
    return false;
  }

  fileList.value = [{
    originFileObj: file,
    name: file.name,
    size: file.size,
    type: file.type,
    uid: Date.now().toString()
  }];
  return false; // 阻止自动上传
}

// 移除文件
const handleRemove = () => {
  console.log('handleRemove 触发')
  fileList.value = []
}

// 提交文件
const handleSubmit = async () => {
  if (!fileList.value.length) {
    message.error('请先选择要上传的文件');
    return;
  }

  try {
    const confirmed = await new Promise((resolve) => {
      Modal.confirm({
        title: '确认提交',
        content: '提交后将生成新的版本，是否继续？',
        okText: '确认',
        cancelText: '取消',
        onOk: () => resolve(true),
        onCancel: () => resolve(false),
      });
    });

    if (!confirmed) return;

    const formData = new FormData();
    formData.append('file', fileList.value[0].originFileObj);
    formData.append('type', currentStage.value?.type || '');

    // 先上传文件
    const res = await submitFile(formData);
    if (res.code === 200) {
      const { file_url, file_size } = res.data;

      // 更新进度
      const updateRes = await updateProgress({
        stage_type: currentStage.value?.type,
        file_url,
        file_size,
        status: 'reviewing'
      });

      if (updateRes.code === 200) {
        message.success('提交成功');
        fileList.value = [];  // 清空文件列表，但保持上传区域可见
        await fetchProgress();
      }
    }
  } catch (error) {
    console.error('提交失败:', error);
    message.error('提交失败，请稍后重试');
  }
};

// 计算完成率
const completionRate = computed(() => {
  const completed = stages.value.filter(s => s.status === 'completed').length
  return Math.round((completed / stages.value.length) * 100)
})

// 检查截止时间
const isDeadlineNear = computed(() => {
  if (!currentStage.value?.deadline) return false
  const deadline = new Date(currentStage.value.deadline)
  const now = new Date()
  const days = Math.ceil((deadline - now) / (1000 * 60 * 60 * 24))
  return days <= 7 && days > 0
})

// 获取剩余天数
const getRemainingDays = computed(() => {
  if (!currentStage.value?.deadline) return 0
  const deadline = new Date(currentStage.value.deadline)
  const now = new Date()
  return Math.ceil((deadline - now) / (1000 * 60 * 60 * 24))
})

// 获取当前阶段名称
const getCurrentStageName = computed(() => {
  return currentStage.value?.name || '暂无进行中的阶段'
})

// 显示任务书详情
const showTaskDetail = () => {
  if (currentTask.value.task_id) {
    taskDetailVisible.value = true;
  }
}

// 初始化数据
const initData = async () => {
  const studentId = userStore.userInfo.userId;
  if (studentId) {
    try {
      const response = await getLatestStudentTask(studentId);
      if (response.code === 200 && response.data) {
        currentTask.value = response.data;
      }
    } catch (error) {
      console.error('获取学生任务书失败:', error);
    }
  }
};

const literatureReview = ref<any>(null)

// 获取文献综述记录
const fetchLiteratureReview = async () => {
  try {
    const res = await getLiteratureReview()
    if (res.code === 200) {
      literatureReview.value = res.data
      // 更新界面显示
      if (literatureReview.value) {
        // 可以显示评阅状态、评语等信息
      }
    }
  } catch (error) {
    console.error('获取文献综述记录失败:', error)
  }
}

// 添加开题报告相关的响应式数据
const proposalReview = ref<any>(null)

// 获取开题报告记录
const fetchProposalReview = async () => {
  try {
    const res = await getOrCreateProposalReview()
    if (res.code === 200) {
      proposalReview.value = res.data
    }
  } catch (error) {
    console.error('获取开题报告记录失败:', error)
  }
}
const taskBookRecord = ref(null)
const literatureRecord = ref(null)

const fetchStageRecords = async () => {
  try {
    const res = await getProgress()
    if (res.code === 200 && res.data.stages) {
      // 找到任务书和文献综述的记录
      taskBookRecord.value = res.data.stages.find(s => s.type === 'task_book')
      literatureRecord.value = res.data.stages.find(s => s.type === 'literature')
    }
  } catch (error) {
    console.error('获取阶段记录失败:', error)
  }
}

onMounted(async () => {
  await Promise.all([
    fetchProgress(),  // 原有的方法
    fetchLiteratureReview(),    // 添加
    fetchProposalReview(),      // 添加
    fetchMidtermReview(),       // 添加
    fetchTranslationReview(),   // 添加
    fetchThesisSubmission(),
    fetchStageRecords(),
    initData()                  // 添加
  ])
})

// 修改第一个 handleSubmitSuccess 函数名称
const handleStageSubmitSuccess = async () => {
  if (currentStage.value?.type === 'proposal') {
    await fetchProposalReview()
  } else if (currentStage.value?.type === 'literature') {
    await fetchLiteratureReview()
  }
}

const activeKey = ref(['1'])

// 获取文件名
const getFileName = (url: string) => {
  if (!url) return ''
  return url.split('/').pop() || ''
}

// 格式化文件大小
const formatFileSize = (size: number) => {
  if (size < 1024) return size + ' B'
  if (size < 1024 * 1024) return (size / 1024).toFixed(2) + ' KB'
  return (size / (1024 * 1024)).toFixed(2) + ' MB'
}

// 修改调试 watch
watch(() => literatureReview.value, (newVal) => {
  if (newVal) {
    console.log('完整的文献综述数据:', newVal)
    console.log('关键数据:', {
      literature_score: newVal.literature_score,
      literature_weight: newVal.literature_weight,
      calculated_weighted_score: newVal.calculated_weighted_score,
      task_book_score: newVal.task_book_score,
      // 其他分数
      proposal_score: newVal.proposal_score,
      translation_score: newVal.translation_score,
      midterm_score: newVal.midterm_score,
      thesis_draft_score: newVal.thesis_draft_score,
      thesis_review_score: newVal.thesis_review_score,
      defense_prep_score: newVal.defense_prep_score,
      defense_score: newVal.defense_score,
      // 权重信息
      stage_weights: newVal.stage_weights
    })
  }
}, { deep: true, immediate: true })

// 修改计算已完成阶段数的函数
const getCompletedStagesCount = () => {
  if (!literatureReview.value) return 0;
  
  const scores = {
    task_book: literatureReview.value.task_book_score,
    literature: literatureReview.value.literature_score,
    proposal: literatureReview.value.proposal_score,
    translation: literatureReview.value.translation_score,
    midterm: literatureReview.value.midterm_score,
    thesis_draft: literatureReview.value.thesis_draft_score,
    thesis_review: literatureReview.value.thesis_review_score,
    defense_prep: literatureReview.value.defense_prep_score,
    defense: literatureReview.value.defense_score
  };

  return Object.values(scores).filter(score => score !== null).length;
};

// 添加调试信息
watch(() => literatureReview.value, (newVal) => {
  if (newVal) {
    console.log('加权分数:', {
      calculated: newVal.calculated_weighted_score,
      formatted: Number(newVal.calculated_weighted_score).toFixed(2)
    });
  }
}, { immediate: true });

// 解析分数详情
const scoreDetails = computed(() => {
  if (!literatureReview.value?.score_details) return []
  return literatureReview.value.score_details.split(',').map(detail => {
    const [stage, score] = detail.split(':')
    return `${stage}: ${score}`
  })
})

// 添加 watch 监听当前阶段变化
watch(() => currentStage.value?.type, async (newType) => {
  if (newType === 'proposal') {
    await fetchProposalReview()
  }
})

// 文献综述详情抽屉控制
const literatureDetailVisible = ref(false)

// 显示文献综述详情
const showLiteratureDetail = () => {
  if (literatureReview.value) {
    literatureDetailVisible.value = true
  }
}

// 开题报告详情控制
const proposalDetailVisible = ref(false)
const proposalActiveKey = ref(['1'])

// 显示开题报告详情
const showProposalDetail = () => {
  if (proposalReview.value) {
    proposalDetailVisible.value = true
  }
}

// 添加响应式数据
const translationReview = ref<any>(null)
const translationDetailVisible = ref(false)
const translationActiveKey = ref(['1'])

// 获取翻译评审记录
const fetchTranslationReview = async () => {
  try {
    const res = await getTranslationReview();
    if (res.code === 200) {
      translationReview.value = res.data;
    }
  } catch (error) {
    console.error('获取外文翻译记录失败:', error);
    message.error('获取外文翻译记录失败');
  }
};

// 显示翻译详情
const showTranslationDetail = () => {
  if (translationReview.value) {
    translationDetailVisible.value = true
  }
}

// 修改第二个 handleSubmitSuccess 函数名称为 handleTranslationSubmitSuccess
const handleTranslationSubmitSuccess = async () => {
  if (currentStage.value?.type === 'proposal') {
    await fetchProposalReview()
  } else if (currentStage.value?.type === 'literature') {
    await fetchLiteratureReview()
  } else if (currentStage.value?.type === 'translation') {
    await fetchTranslationReview()
  }
}

// 中期检查相关状态
const midtermReview = ref<any>(null)
const midtermDetailVisible = ref(false)
const midtermActiveKey = ref(['1'])

// 获取中期检查记录
const fetchMidtermReview = async () => {
  try {
    const res = await getMidtermReview()
    if (res.code === 200) {
      midtermReview.value = {
        ...res.data,
        research_progress_score: res.data.research_progress_score || null,
        technical_ability_score: res.data.technical_ability_score || null,
        work_attitude_score: res.data.work_attitude_score || null,
        total_score: res.data.total_score || null,
        progress_comment: res.data.progress_comment || '',
        technical_comment: res.data.technical_comment || '',
        attitude_comment: res.data.attitude_comment || '',
        improvement_suggestions: res.data.improvement_suggestions || '',
        status: res.data.status || 'pending',
        submit_time: res.data.submit_time,
        review_time: res.data.review_time,
        version: res.data.version || 1
      }
    }
  } catch (error) {
    console.error('获取中期检查记录失败:', error)
    message.error('获取中期检查记录失败')
  }
}

// 显示中期检查详情
const showMidtermDetail = () => {
  if (midtermReview.value) {
    midtermDetailVisible.value = true
  }
}

// 论文提交相关状态
const thesisSubmission = ref<any>(null)
const thesisDetailVisible = ref(false)
const thesisActiveKey = ref(['1', '2']) // 导师评阅详情默认展开所有面板
const expertActiveKey = ref(['1', '2']) // 专家评阅详情默认展开所有面板

// 获取论文提交记录
const fetchThesisSubmission = async () => {
  try {
    const res = await getStudentThesisHistory()
    if (res.code === 200) {
      thesisSubmission.value = res.data
    }
  } catch (error) {
    console.error('获取论文提交记录失败:', error)
    message.error('获取论文提交记录失败')
  }
}

// 显示论文详情
const showThesisDetail = () => {
  if (thesisSubmission.value) {
    thesisDetailVisible.value = true
  }
}

// 论文相关状态
const thesisFileList = ref<any[]>([])
const thesisReviewVisible = ref(false)

// 论文上传相关方法
const beforeThesisUpload = (file: File) => {
  // 检查文件类型
  const isDoc = file.type === 'application/msword' || 
                file.type === 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' ||
                file.type === 'application/pdf'
  if (!isDoc) {
    message.error('只能上传 Word 或 PDF 文件!')
    return false
  }
  // 检查文件大小
  const isLt20M = file.size / 1024 / 1024 < 20
  if (!isLt20M) {
    message.error('文件必须小于 20MB!')
    return false
  }
  thesisFileList.value = [file]
  return false
}

const handleThesisRemove = () => {
  thesisFileList.value = []
}

const handleThesisSubmit = async () => {
  const formData = new FormData()
  formData.append('file', thesisFileList.value[0])
  try {
    const res = await submitThesis(formData)
    if (res.code === 200) {
      message.success('论文提交成功')
      thesisFileList.value = []
      await fetchThesisSubmission()
    }
  } catch (error) {
    console.error('论文提交失败:', error)
    message.error('论文提交失败，请稍后重试')
  }
}

// 显示论文评阅详情
const showThesisReviewDetail = () => {
  if (thesisSubmission.value) {
    thesisDetailVisible.value = true
  }
}

const canSubmitThesis = computed(() => {
  return currentStage.value?.type === 'thesis_submit' && 
    (currentStage.value?.status === 'not_started' || 
     currentStage.value?.status === 'in_progress' ||
     currentStage.value?.status === 'reviewing' ||
     currentStage.value?.status === 'revision_needed')
})

// 在 script setup 中添加
const defenseInfo = ref<any>(null)

// 获取答辩信息
const fetchDefenseInfo = async () => {
  try {
    const res = await getDefenseInfo()
    if (res.code === 200) {
      defenseInfo.value = res.data
    }
  } catch (error) {
    console.error('获取答辩信息失败:', error)
  }
}

// 在 onMounted 中添加
onMounted(async () => {
  await Promise.all([
    // ... 原有的异步调用 ...
    fetchDefenseInfo()
  ])
})
const committeeColumns = [
  {
    title: '角色',
    dataIndex: 'role',
    key: 'role',
    width: 100
  },
  {
    title: '姓名',
    dataIndex: 'name',
    key: 'name',
    width: 120
  },
  {
    title: '职称',
    dataIndex: 'title',
    key: 'title',
    width: 120
  }
];
</script>

<style scoped>
.weighted-score {
  font-size: 24px;          /* 更大的字体 */
  font-weight: bold;        /* 加粗 */
  color: #1890ff;          /* 使用主题蓝色 */
  padding: 4px 8px;        /* 内边距 */
  border-radius: 4px;      /* 圆角 */
  background-color: #e6f7ff; /* 浅蓝色背景 */
  margin-right: 8px;       /* 右边距 */
  display: inline-block;   /* 块级显示 */
}

.weighted-score-info {
  display: flex;
  align-items: center;
  gap: 8px;               /* 元素间距 */
}

.info-icon {
  color: #1890ff;         /* 图标颜色 */
  font-size: 16px;        /* 图标大小 */
}

</style> 