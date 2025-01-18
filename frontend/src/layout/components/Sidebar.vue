<template>
  <div class="sidebar-container">
    <el-menu
      :default-active="activeMenu"
      background-color="rgb(48, 65, 86)"
      text-color="#fff"
      :collapse="isCollapse"
      router
    >
      <!-- 所有用户都可见的菜单项 -->
      <el-menu-item index="/home">
        <el-icon><House /></el-icon>
        <template #title>首页</template>
      </el-menu-item>

      <!-- 教师菜单 -->
      <template v-if="userRole === 'teacher'">
        <el-menu-item index="/thesis-topic">
          <el-icon><Document /></el-icon>
          <template #title>论文题目管理</template>
        </el-menu-item>

        <el-menu-item index="/student-progress">
          <el-icon><Timer /></el-icon>
          <template #title>学生进度</template>
        </el-menu-item>

        <!-- 新增进度审核子菜单 -->
        <el-sub-menu index="progress-review">
          <template #title>
            <el-icon><Check /></el-icon>
            <span>进度审核</span>
          </template>
          
          <el-menu-item index="/task-assignment">
            <el-icon><Document /></el-icon>
            <template #title>任务书管理</template>
          </el-menu-item>

          <el-menu-item index="/literature-review">
            <el-icon><Reading /></el-icon>
            <template #title>文献综述评阅</template>
          </el-menu-item>

          <el-menu-item index="/proposal-review">
            <el-icon><Document /></el-icon>
            <template #title>开题报告评阅</template>
          </el-menu-item>

          <el-menu-item index="/translation-review">
            <el-icon><Document /></el-icon>
            <template #title>外文翻译评阅</template>
          </el-menu-item>

          <!-- 新增中期检查评阅菜单项 -->
          <el-menu-item index="/progress/midterm-review">
            <el-icon><Document /></el-icon>
            <template #title>中期检查评阅</template>
          </el-menu-item>

          <!-- 新增通过确认菜单项 -->
          <el-menu-item index="/progress/pass-confirmation">
            <el-icon><CircleCheck /></el-icon>
            <template #title>通过确认</template>
          </el-menu-item>
        </el-sub-menu>

        <el-menu-item index="/thesis-review">
          <el-icon><Reading /></el-icon>
          <template #title>论文评阅</template>
        </el-menu-item>

        <el-sub-menu index="/defense-view">
          <template #title>
            <el-icon><Calendar /></el-icon>
            <span>答辩管理</span>
          </template>
          
          <el-menu-item index="/defense-view/committee">
            <el-icon><UserFilled /></el-icon>
            <template #title>答辩委员会</template>
          </el-menu-item>
          
          <el-menu-item index="/defense-view/arrangement">
            <el-icon><Timer /></el-icon>
            <template #title>答辩安排</template>
          </el-menu-item>

          <!-- 新增答辩评审菜单项 -->
          <el-menu-item index="/defense-view/scoring">
            <el-icon><Edit /></el-icon>
            <template #title>答辩评审</template>
          </el-menu-item>
        </el-sub-menu>
      </template>

      <!-- 学生菜单 -->
      <template v-if="userRole === 'student'">
        <el-menu-item index="/topic-selection">
          <el-icon><Select /></el-icon>
          <template #title>选题</template>
        </el-menu-item>

        <el-menu-item index="/my-progress">
          <el-icon><Timer /></el-icon>
          <template #title>我的进度</template>
        </el-menu-item>
      </template>

      <!-- 管理员菜单 -->
      <template v-if="userRole === 'admin'">

        <el-menu-item index="/user-management">
          <el-icon><User /></el-icon>
          <template #title>用户管理</template>
        </el-menu-item>

        <el-menu-item index="/thesis-review-assignment">
          <el-icon><Document /></el-icon>
          <template #title>论文评阅分配</template>
        </el-menu-item>

        <!-- 添加答辩管理子菜单 -->
        <el-sub-menu index="defense-management">
          <template #title>
            <el-icon><Calendar /></el-icon>
            <span>答辩管理</span>
          </template>
          
          <el-menu-item index="/defense/committee">
            <el-icon><UserFilled /></el-icon>
            <template #title>答辩委员会</template>
          </el-menu-item>
          
          <el-menu-item index="/defense/arrangement">
            <el-icon><Timer /></el-icon>
            <template #title>答辩安排</template>
          </el-menu-item>
        </el-sub-menu>
      </template>

      <!-- 系统管理员特有菜单 -->
      <template v-if="userRole === 'superadmin'">
        <el-menu-item index="/user-management">
          <el-icon><User /></el-icon>
          <template #title>用户管理</template>
        </el-menu-item>
        <el-menu-item index="/system-settings">
          <el-icon><Setting /></el-icon>
          <template #title>系统设置</template>
        </el-menu-item>
      </template>

      <!-- 访客菜单 -->
      <template v-if="userRole === 'guest'">
        <el-menu-item index="/thesis-list">
          <el-icon><List /></el-icon>
          <template #title>选题列表</template>
        </el-menu-item>
      </template>

    </el-menu>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import {
  House,
  Menu,
  Document,
  Timer,
  Reading,
  Select,
  Upload,
  User,
  Setting,
  List,
  Bell,
  Check,
  CircleCheck,
  Calendar,
  UserFilled,
  Edit
} from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const isCollapse = ref(false)

const activeMenu = computed(() => route.path)
const userRole = computed(() => userStore.userInfo?.role)

// 添加路由守卫
router.beforeEach((to, from, next) => {
  // 打印路由信息，帮助调试
  console.log('Route from:', from.path)
  console.log('Route to:', to.path)
  next()
})
</script>

<style scoped>
.sidebar-container {
  height: 100%;
}

.sidebar-container :deep(.el-menu) {
  height: 100%;
  border-right: none;
}

.sidebar-container :deep(.el-menu-item) {
  &.is-active {
    background-color: var(--el-menu-hover-bg-color);
  }
  
  &:hover {
    background-color: var(--el-menu-hover-bg-color);
  }
}
</style> 