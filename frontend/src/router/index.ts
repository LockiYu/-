import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'
import Layout from '@/layout/index.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'Login',
      component: () => import('@/views/Login.vue'),
      meta: {
        requiresAuth: false,
        layout: 'blank'
      }
    },
    {
      path: '/',
      component: Layout,
      redirect: '/home',
      children: [
        {
          path: 'home',
          name: 'Home',
          component: () => import('@/views/HomeView.vue'),
          meta: {
            title: '首页',
            requiresAuth: false  // 设置首页为公开路由
          }
        },
        // 所有角色都可见的路由
        {
          path: 'personal-info',
          name: 'PersonalInfo',
          component: () => import('@/views/personal/index.vue'),
          meta: { title: '个人信息' }
        },

        // 教师可见的路由
        {
          path: 'thesis-topic',
          name: 'ThesisTopic',
          component: () => import('@/views/thesis/ThesisTopic.vue'),
          meta: {
            title: '论文题目管理',
            roles: ['teacher']
          }
        },
        {
          path: 'student-progress',
          name: 'StudentProgress',
          component: () => import('@/views/progress/TeacherView.vue'),
          meta: {
            title: '学生进度',
            roles: ['teacher']
          }
        },
        {
          path: 'thesis-review',
          name: 'ThesisReview',
          component: () => import('@/views/thesis/Review.vue'),
          meta: {
            title: '论文评阅',
            roles: ['teacher']
          }
        },

        // 学生可见的路由
        {
          path: 'topic-selection',
          name: 'TopicSelection',
          component: () => import('@/views/selection/StudentView.vue'),
          meta: {
            title: '选题',
            roles: ['student']
          }
        },
        {
          path: 'my-progress',
          name: 'MyProgress',
          component: () => import('@/views/progress/StudentView.vue'),
          meta: {
            title: '论文进度',
            icon: 'Timeline',
            roles: ['student']
          }
        },

        // 管理员可见的路由
        {
          path: 'user-management',
          name: 'UserManagement',
          component: () => import('@/views/user/UserManagement.vue'),
          meta: {
            title: '用户管理',
            roles: ['admin', 'superadmin']
          }
        },
        {
          path: 'system-settings',
          name: 'SystemSettings',
          component: () => import('@/views/system/Settings.vue'),
          meta: {
            title: '系统设置',
            roles: ['superadmin']
          }
        },

        // 访客可见的路由
        {
          path: 'thesis-list',
          name: 'ThesisList',
          component: () => import('@/views/thesis/PublicList.vue'),
          meta: {
            title: '论文列表',
            roles: ['guest']
          }
        },
        {
          path: 'change-password',
          name: 'ChangePassword',
          component: () => import('@/views/ChangePassword.vue'),
          meta: { title: '修改密码' }
        },
        {
          path: '/task-assignment',
          component: () => import('@/views/TaskAssignment.vue'),
          meta: {
            title: '任务书管理',
            requiresAuth: true,
            roles: ['teacher']
          }
        },
        {
          path: 'literature-review',
          name: 'LiteratureReview',
          component: () => import('@/views/progress/LiteratureReview.vue'),
          meta: {
            title: '文献综述评阅',
            roles: ['teacher']
          }
        },
        {
          path: 'proposal-review',
          name: 'ProposalReview',
          component: () => import('@/views/progress/ProposalReview.vue'),
          meta: {
            title: '开题报告评阅',
            requiresAuth: true,
            roles: ['teacher']
          }
        },
        {
          path: 'translation-review',
          name: 'TranslationReview',
          component: () => import('@/views/progress/TranslationReview.vue'),
          meta: {
            title: '外文翻译评阅',
            roles: ['teacher']
          }
        },
        {
          path: '/progress/midterm-review',
          name: 'MidtermReview',
          component: () => import('@/views/progress/MidtermReview.vue'),
          meta: {
            title: '中期检查评阅',
            requiresAuth: true,
            roles: ['teacher']
          }
        },
        {
          path: '/progress/pass-confirmation',
          name: 'PassConfirmation',
          component: () => import('@/views/progress/PassConfirmation.vue'),
          meta: {
            title: '论文通过确认',
            requiresAuth: true,
            roles: ['teacher']
          }
        },
        {
          path: 'thesis-review-assignment',
          name: 'ThesisReviewAssignment',
          component: () => import('@/views/thesis/ReviewAssignment.vue'),
          meta: {
            title: '论文评阅分配',
            roles: ['admin']
          }
        },
        {
          path: '/defense',
          name: 'Defense',
          meta: {
            title: '答辩管理',
            roles: ['admin']
          },
          children: [
            {
              path: 'committee',
              name: 'DefenseCommittee',
              component: () => import('@/views/defense/CommitteeView.vue'),
              meta: {
                title: '答辩委员会',
                roles: ['admin']
              }
            },
            {
              path: 'arrangement',
              name: 'DefenseArrangement',
              component: () => import('@/views/defense/ArrangementView.vue'),
              meta: {
                title: '答辩安排',
                roles: ['admin']
              }
            }
          ]
        },
        {
          path: 'defense-view',
          component: () => import('@/views/defense/DefenseLayout.vue'),
          meta: {
            title: '答辩查看',
            roles: ['teacher']
          },
          children: [
            {
              path: 'committee',
              name: 'TeacherDefenseCommittee',
              component: () => import('@/views/defense/CommitteeView.vue'),
              meta: {
                title: '答辩委员会',
                readOnly: true
              }
            },
            {
              path: 'arrangement',
              name: 'TeacherDefenseArrangement',
              component: () => import('@/views/defense/ArrangementView.vue'),
              meta: {
                title: '答辩安排',
                readOnly: true
              }
            },
            {
              path: 'scoring',
              name: 'TeacherDefenseScoring',
              component: () => import('@/views/defense/ScoringView.vue'),
              meta: {
                title: '答辩评审',
                roles: ['teacher']
              }
            }
          ]
        }
      ]
    }
  ]
})

// 路由守卫
router.beforeEach(async (to, from, next) => {
  const userStore = useUserStore()

  // 检查是否需要认证
  if (to.matched.some(record => record.meta.requiresAuth)) {
    if (!userStore.isLoggedIn) {
      ElMessage.warning('请先登录')
      next({
        path: '/login',
        query: { redirect: to.fullPath }
      })
      return
    }

    // 检查角色权限
    if (to.meta.roles && !to.meta.roles.includes(userStore.userInfo?.role)) {
      ElMessage.error('无权访问该页面')
      next({ path: '/403' })
      return
    }
  }

  next()
})

export default router