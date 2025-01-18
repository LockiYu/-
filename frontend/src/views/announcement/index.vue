<template>
  <div class="app-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>系统公告</span>
          <div class="filter-container">
            <el-input
              v-model="queryParams.keyword"
              placeholder="搜索公告"
              style="width: 200px"
              class="filter-item"
              clearable
              @keyup.enter="handleQuery"
            />
            <el-select
              v-model="queryParams.type"
              placeholder="公告类型"
              style="width: 130px"
              class="filter-item"
              clearable
            >
              <el-option label="通知" value="notice" />
              <el-option label="新闻" value="news" />
              <el-option label="重要" value="important" />
            </el-select>
            <el-button
              type="primary"
              class="filter-item"
              @click="handleQuery"
            >
              搜索
            </el-button>
          </div>
        </div>
      </template>

      <!-- 公告列表 -->
      <div class="announcement-list">
        <el-timeline>
          <el-timeline-item
            v-for="item in announcementList"
            :key="item.id"
            :timestamp="item.createTime"
            :type="getTimelineType(item.type)"
          >
            <el-card class="announcement-card" @click="handleViewDetails(item)">
              <template #header>
                <div class="announcement-header">
                  <div class="title-container">
                    <el-tag
                      :type="getTagType(item.type)"
                      effect="dark"
                      size="small"
                      class="type-tag"
                    >
                      {{ getTypeText(item.type) }}
                    </el-tag>
                    <span 
                      class="announcement-title"
                    >
                      {{ item.title }}
                    </span>
                  </div>
                  <div class="announcement-info">
                    <span class="publisher">发布人：{{ item.publisher }}</span>
                    <span class="view-count">
                      <el-icon><View /></el-icon>
                      {{ item.viewCount }}
                    </span>
                  </div>
                </div>
              </template>
              <div class="announcement-content">
                <div 
                  class="content-preview"
                  :class="{ 'show-all': item.showAll }"
                >
                  {{ item.content }}
                </div>
                <div 
                  v-if="item.content.length > 200"
                  class="show-more"
                  @click="toggleContent(item)"
                >
                  {{ item.showAll ? '收起' : '显示更多' }}
                </div>
              </div>
              <div v-if="item.attachments?.length" class="attachment-list">
                <div class="attachment-title">
                  <el-icon><Document /></el-icon>
                  附件：
                </div>
                <div 
                  v-for="file in item.attachments"
                  :key="file.id"
                  class="attachment-item"
                >
                  <el-button 
                    link 
                    type="primary"
                    @click="handleDownload(file)"
                  >
                    {{ file.name }}
                  </el-button>
                  <span class="file-size">{{ formatFileSize(file.size) }}</span>
                </div>
              </div>
            </el-card>
          </el-timeline-item>
        </el-timeline>
      </div>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="queryParams.pageNum"
          v-model:page-size="queryParams.pageSize"
          :total="total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 公告详情对话框 -->
    <el-dialog
      v-model="detailsDialogVisible"
      :title="currentAnnouncement?.title"
      width="800px"
      @opened="handleDialogOpened"
    >
      <div class="dialog-content">
        <div class="dialog-header">
          <div class="dialog-info">
            <el-tag
              :type="getTagType(currentAnnouncement?.type)"
              effect="dark"
              size="small"
            >
              {{ getTypeText(currentAnnouncement?.type) }}
            </el-tag>
            <span class="publisher">
              发布人：{{ currentAnnouncement?.publisher }}
            </span>
            <span class="publish-time">
              发布时间：{{ currentAnnouncement?.createTime }}
            </span>
          </div>
        </div>
        <div 
          class="announcement-detail"
          v-html="formattedContent"
        ></div>
        <div 
          v-if="currentAnnouncement?.attachments?.length"
          class="attachment-section"
        >
          <div class="attachment-title">
            <el-icon><Document /></el-icon>
            附件列表
          </div>
          <div 
            v-for="file in currentAnnouncement.attachments"
            :key="file.id"
            class="attachment-item"
          >
            <el-button 
              link 
              type="primary"
              @click="handleDownload(file)"
            >
              {{ file.name }}
            </el-button>
            <span class="file-size">{{ formatFileSize(file.size) }}</span>
          </div>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { View, Document } from '@element-plus/icons-vue'
import { marked } from 'marked'
import { useRouter } from 'vue-router'

const router = useRouter()

// 查询参数
const queryParams = reactive({
  keyword: '',
  type: '',
  pageNum: 1,
  pageSize: 10
})

// 数据
const loading = ref(false)
const announcementList = ref([])
const total = ref(0)
const detailsDialogVisible = ref(false)
const currentAnnouncement = ref(null)

// 计算属性
const formattedContent = computed(() => {
  if (!currentAnnouncement.value?.content) return ''
  return marked(currentAnnouncement.value.content)
})

// 类型样式映射
const getTagType = (type: string) => {
  const typeMap: Record<string, string> = {
    'notice': '',
    'news': 'success',
    'important': 'danger'
  }
  return typeMap[type] || ''
}

const getTimelineType = (type: string) => {
  const typeMap: Record<string, string> = {
    'notice': 'primary',
    'news': 'success',
    'important': 'danger'
  }
  return typeMap[type] || 'info'
}

const getTypeText = (type: string) => {
  const typeMap: Record<string, string> = {
    'notice': '通知',
    'news': '新闻',
    'important': '重要'
  }
  return typeMap[type] || type
}

// 工具函数
const formatFileSize = (size: number) => {
  if (size < 1024) {
    return size + ' B'
  } else if (size < 1024 * 1024) {
    return (size / 1024).toFixed(2) + ' KB'
  } else {
    return (size / 1024 / 1024).toFixed(2) + ' MB'
  }
}

// 处理函数
const handleQuery = async () => {
  loading.value = true
  try {
    // TODO: 调用查询API
    // const response = await getAnnouncementList(queryParams)
    // announcementList.value = response.data.list.map(item => ({
    //   ...item,
    //   showAll: false
    // }))
    // total.value = response.data.total
  } catch (error: any) {
    ElMessage.error(error.message || '查询失败')
  } finally {
    loading.value = false
  }
}

const toggleContent = (item: any) => {
  item.showAll = !item.showAll
}

const handleViewDetails = (item: any) => {
  router.push({ name: 'AnnouncementDetail', params: { id: item.id } })
}

const handleDialogOpened = async () => {
  if (!currentAnnouncement.value?.id) return
  try {
    // TODO: 调用更新浏览量API
    // await updateAnnouncementViews(currentAnnouncement.value.id)
  } catch (error) {
    console.error('更新浏览量失败:', error)
  }
}

const handleDownload = async (file: any) => {
  try {
    // TODO: 调用下载API
    window.open(file.url)
  } catch (error: any) {
    ElMessage.error(error.message || '下载失败')
  }
}

const handleSizeChange = (val: number) => {
  queryParams.pageSize = val
  handleQuery()
}

const handleCurrentChange = (val: number) => {
  queryParams.pageNum = val
  handleQuery()
}

// 初始化
onMounted(() => {
  handleQuery()
})
</script>

<style scoped>
.app-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.filter-container {
  display: flex;
  gap: 10px;
}

.announcement-list {
  margin-top: 20px;
}

.announcement-card {
  margin-bottom: 10px;
}

.announcement-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.title-container {
  display: flex;
  align-items: center;
  gap: 8px;
}

.announcement-title {
  font-weight: bold;
  cursor: pointer;
  &:hover {
    color: #409EFF;
  }
}

.announcement-info {
  display: flex;
  align-items: center;
  gap: 16px;
  color: #666;
  font-size: 14px;
}

.view-count {
  display: flex;
  align-items: center;
  gap: 4px;
}

.content-preview {
  max-height: 100px;
  overflow: hidden;
  transition: max-height 0.3s;
  &.show-all {
    max-height: none;
  }
}

.show-more {
  color: #409EFF;
  cursor: pointer;
  margin-top: 8px;
  font-size: 14px;
}

.attachment-list {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #EBEEF5;
}

.attachment-title {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #666;
  margin-bottom: 8px;
}

.attachment-item {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 4px;
}

.file-size {
  color: #999;
  font-size: 12px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}

.dialog-content {
  padding: 0 20px;
}

.dialog-header {
  margin-bottom: 20px;
}

.dialog-info {
  display: flex;
  align-items: center;
  gap: 16px;
  color: #666;
  font-size: 14px;
}

.announcement-detail {
  line-height: 1.6;
  :deep(img) {
    max-width: 100%;
  }
}

.attachment-section {
  margin-top: 24px;
  padding-top: 16px;
  border-top: 1px solid #EBEEF5;
}
</style> 