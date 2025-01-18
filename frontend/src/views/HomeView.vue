/*
 * @Author: test abc@163.com
 * @Date: 2024-12-08 21:10:23
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-30 14:28:39
 * @FilePath: \Graduation Design Management System\frontend\src\views\HomeView.vue
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */

<script setup lang="ts">
import { computed, ref, onMounted, h, watch, reactive } from 'vue'
import { useUserStore } from '@/stores/user'
import request from '@/utils/request'
import { ElMessage, ElMessageBox, ElLoading } from 'element-plus'
import { getSystemMessages, getSystemLogs } from '@/api/system'
import { formatDate } from '@/utils/format'
import { InfoFilled, User, UserFilled, Message, List, Document, Timer, CircleCheck, CircleClose, Search, Edit, School, ChatLineRound, Warning } from '@element-plus/icons-vue'
import { debounce } from 'lodash'
import { getTopicDetails } from '@/api/thesis'
import VisitorDashboard from '@/components/VisitorDashboard.vue'

const userStore = useUserStore()
const isLoading = ref(false)
const statsData = ref({
  totalUsers: 0,
  activeUsers: 0,
  systemMessages: 0,
  systemLogs: 0
})

// 创建一个防抖的获取用户信息方法，延迟时间改为3秒
const debouncedGetUserInfo = debounce(async () => {
    try {
        if (!userStore.userInfo.userId) {
            await userStore.getUserInfo();
        }
    } catch (error) {
        console.error('获取用户信息失败:', error);
    }
}, 3000);  // 增加防抖时间到3秒

// 获取超级管理员统计数据
const fetchSuperAdminStats = async () => {
  try {
    isLoading.value = true
    const response = await request.get('/dashboard/superadmin/stats')

    console.log('Dashboard stats response:', response)

    if (response.code === 200) {
      // 直接使用后端返回的数据
      statsData.value = response.data
    } else {
      throw new Error(response.message || '获取数据失败')
    }
  } catch (error: any) {
    console.error('获取统计数据失败:', error)
    if (error.response) {
      ElMessage.error(error.response.data?.message || '获取数据失败')
    } else if (error.request) {
      ElMessage.error('网络请求失败，请检查网络连接')
    } else {
      ElMessage.error(error.message || '获取数据失败')
    }
  } finally {
    isLoading.value = false
  }
}

// 计算欢迎语
const welcomeMessage = computed(() => {
  const loginCount = userStore.userInfo?.loginCount || 0
  const username = userStore.userInfo?.username || '用户'

  if (loginCount === 1) {
    return `欢迎注册 ${username}，开启您的学习之旅！`
  } else {
    const hour = new Date().getHours()
    if (hour < 6) return `夜深了 ${username}，注意休息哦！`
    if (hour < 11) return `早上好 ${username}，开启美好的一天！`
    if (hour < 14) return `中午好 ${username}，记得午休哦！`
    if (hour < 18) return `下午好 ${username}，继续加油！`
    return `晚上好 ${username}，今天过得如何？`
  }
})

// 根据角色显示不同的统计数据
const dashboardData = computed(() => {
  if (userStore.userInfo?.role === 'admin') {
    return [
      {
        label: '待审核题目',
        number: statsData.value.pendingTopics?.toString() || '0',
        type: 'warning',
        icon: 'Timer',
        description: '需要审核的选题'
      },
      {
        label: '已通过题目',
        number: statsData.value.approvedTopics?.toString() || '0',
        type: 'success',
        icon: 'CircleCheck',
        description: '审核通过的选题'
      },
      {
        label: '已拒绝题目',
        number: statsData.value.rejectedTopics?.toString() || '0',
        type: 'danger',
        icon: 'CircleClose',
        description: '审核拒绝的选题'
      }
    ];
  }
  return [];
});

// 格式化数字大于1000显示为k）
const formatNumber = (num: number): string => {
  return num >= 1000 ? (num/1000).toFixed(1) + 'k' : num.toString()
}

// 添加数据和方法
const systemMessagesData = ref([])
const pagination = ref({
  total: 0,
  page: 1,
  pageSize: 10
})

const tableLoading = ref(false)

const isVisitor = computed(() => userStore.userInfo?.role === 'guest')

const dialogVisible = ref(false)

// 获取系统消息列表
const fetchSystemMessages = async (params = {}) => {
  try {
    tableLoading.value = true
    const response = await getSystemMessages({
      page: pagination.value.page,
      pageSize: pagination.value.pageSize,
      ...params
    })

    if (response.code === 200) {
      systemMessagesData.value = response.data.list
      pagination.value = response.data.pagination
    }
  } catch (error) {
    console.error('获取系统消息失败:', error)
  } finally {
    tableLoading.value = false
  }
}

// 处理分页变化
const handlePageChange = (newPage: number) => {
  pagination.value.page = newPage
  fetchSystemMessages()
}

// 系统日志数据
const systemLogsData = ref([])
const logsTableLoading = ref(false)
const logsPagination = ref({
  total: 0,
  page: 1,
  pageSize: 10
})

// 获取系统日志列表
const fetchSystemLogs = async (params = {}) => {
  try {
    logsTableLoading.value = true
    const response = await getSystemLogs({
      page: logsPagination.value.page,
      pageSize: logsPagination.value.pageSize,
      ...params
    })

    if (response.code === 200) {
      systemLogsData.value = response.data.list
      logsPagination.value = response.data.pagination
    }
  } catch (error) {
    console.error('获取系统日志失败:', error)
  } finally {
    logsTableLoading.value = false
  }
}

// 处理日志分页变化
const handleLogsPageChange = (newPage: number) => {
  logsPagination.value.page = newPage
  fetchSystemLogs()
}

// 添加获取管理员统计数据的函数
const fetchAdminStats = async () => {
  try {
    isLoading.value = true;
    const response = await request.get('/dashboard/admin/stats');

    if (response.code === 200) {
      statsData.value = {
        ...statsData.value,
        pendingTopics: response.data.pendingTopics,
        approvedTopics: response.data.approvedTopics,
        rejectedTopics: response.data.rejectedTopics,
        recentLogs: response.data.recentLogs,
        department: response.data.department
      };
    } else {
      throw new Error(response.message || '获取数据失败');
    }
  } catch (error: any) {
    console.error('获取统计数据失败:', error);
    ElMessage.error(error.message || '获取数据失败');
  } finally {
    isLoading.value = false;
  }
};

// 选题列表相关的数据
const topicsData = ref([])
const topicsLoading = ref(false)
const topicsPagination = ref({
  total: 0,
  page: 1,
  pageSize: 10
})

// 更新筛选选项
const typeOptions = [
  { value: '应用研究', label: '应用研究' },
  { value: '理论研究', label: '理论研究' },
  { value: '工程实践', label: '工程实践' }
]

const sourceOptions = [
  { value: '教师科研', label: '教师科研' },
  { value: '企业合作', label: '企业合作' },
  { value: '横向项目', label: '横向项目' },
  { value: '纵向项目', label: '纵向项目' }
]

const statusOptions = [
  { value: 'draft', label: '草稿' },
  { value: 'pending', label: '待审核' },
  { value: 'approved', label: '已通过' },
  { value: 'rejected', label: '已拒绝' },
  { value: 'selected', label: '已选择' }
]

// 筛选表单数据
const filterForm = ref({
  type: '',
  source: '',
  status: ''
})

// 获取选题列表
const fetchTopicsList = async () => {
  try {
    topicsLoading.value = true
    const params = {
      page: topicsPagination.value.page,
      pageSize: topicsPagination.value.pageSize,
      type: filterForm.value.type || undefined,
      source: filterForm.value.source || undefined,
      status: filterForm.value.status || undefined
    }

    const response = await request.get('/dashboard/admin/topics', { params })

    if (response.code === 200) {
      topicsData.value = response.data.list.map(item => ({
        ...item,
        status: item.status,  // 保持原始状态值以便处理
        statusText: getStatusText(item.status)  // 添加显示文本
      }))

      topicsPagination.value = {
        ...topicsPagination.value,
        total: response.data.pagination.total
      }
    } else {
      throw new Error(response.message || '获取选题列表失败')
    }
  } catch (error: any) {
    console.error('获取选题列表失败:', error)
    ElMessage.error(error.message || '获取选题列表失败')
  } finally {
    topicsLoading.value = false
  }
}

// 移除单个筛选条件
const removeFilter = (field: 'type' | 'source' | 'status') => {
  filterForm.value[field] = ''
}

// 查询按钮点击事件
const handleQuery = () => {
  topicsPagination.value.page = 1
  fetchTopicsList()
}

// 重置筛选条件
const handleFilterReset = () => {
  filterForm.value = {
    type: '',
    source: '',
    status: ''
  }
  topicsPagination.value.page = 1
  fetchTopicsList()
}

// 处理每页数量变化
const handleSizeChange = (val: number) => {
  topicsPagination.value.pageSize = val
  topicsPagination.value.page = 1 // 切换每页数量时重置为第一页
  fetchTopicsList()
}

// 处理页码变化
const handleCurrentChange = (val: number) => {
  topicsPagination.value.page = val
  fetchTopicsList()
}

// 详情对话框相关
const detailsDialogVisible = ref(false)
const currentTopic = ref(null)

// 编辑对话框相关
const editDialogVisible = ref(false)
const currentEditRow = ref<any>(null)

// 查看详情
const handleTopicDetails = async (topic: any) => {
  try {
    if (!topic?.topic_id) {
      ElMessage.error('题目ID不存在');
      return;
    }

    const response = await getTopicDetails(topic.topic_id);
    if (response.code === 200) {
      currentTopic.value = response.data;
      detailsDialogVisible.value = true;
    } else {
      throw new Error(response.message || '获取详情失败');
    }
  } catch (error: any) {
    console.error('获取题目详情失败:', error);
    ElMessage.error(error.message || '获取详情失败');
  }
};

const handleEdit = async (row: any) => {
  // 如果不是待审核状态，显示确认对话框
  if (row.status !== 'pending') {
    try {
      await ElMessageBox.confirm(
        '确定要编辑吗？编辑后将无法再次修改',
        '提示',
        {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }
      )
    } catch (error) {
      return // 用户取消编辑
    }
  }

  // 继续编辑操作...
  currentTopicEditRow.value = { ...row }  // 使用正确的变量
  topicEditDialogVisible.value = true     // 使用正确的对话框变量
}

// 保存编辑
const handleSaveTopicEdit = async (row: any) => {
  try {
    if (!row?.topic_id) {
      console.error('缺少题目ID:', row)
      ElMessage.error('题目ID不能为空')
      return
    }

    // 使用 dashboard 路由
    const response = await request.put(`/dashboard/admin/topics/${row.topic_id}/status`, {
      status: row.status
    })

    if (response.code === 200) {
      ElMessage.success('更新成功')
      topicEditDialogVisible.value = false
      fetchTopicsList()
    }
  } catch (error) {
    console.error('更新失败:', error)
    ElMessage.error('更新失败')
  }
}

// 添加教师统计数据
const teacherStats = ref({
  supervisingStudents: 0,
  pendingSelections: 0,
  maxStudents: 8
})

// 获取教师统计数据
const fetchTeacherStats = async () => {
  try {
    const response = await request.get('/dashboard/teacher/stats')
    if (response.code === 200) {
      teacherStats.value = response.data
    }
  } catch (error) {
    console.error('获取教师统计数据失败:', error)
    ElMessage.error('获取统计数据失败')
  }
}

// 添加学生列表相关的数据
const supervisionList = ref([])
const studentListLoading = ref(false)

// 获取指导学生列表
const fetchSupervisionList = async () => {
  try {
    studentListLoading.value = true
    const response = await request.get('/dashboard/teacher/supervision-list')
    console.log('指导学生列表响应:', response)
    console.log('指导学生列表数据:', response.data)

    if (response.code === 200) {
      supervisionList.value = response.data
      console.log('更新后的supervisionList:', supervisionList.value)
    }
  } catch (error) {
    console.error('获取指导学生列表失败:', error)
  } finally {
    studentListLoading.value = false
  }
}

// 刷新学生列表
const refreshStudentList = () => {
  fetchSupervisionList()
}

// 学生详情相关
const studentDetailsDialogVisible = ref(false)
const currentStudent = ref(null)

// 查看学生详情
const handleStudentDetails = (student: any) => {
  currentStudent.value = student
  studentDetailsDialogVisible.value = true
}

// 添加相关数据和方法
const pendingSelections = ref([])
const pendingListLoading = ref(false)
const pendingDetailsVisible = ref(false)
const currentPending = ref(null)

// 获取待审核选题列表
const fetchPendingSelections = async () => {
  try {
    pendingListLoading.value = true
    const response = await request.get('/dashboard/teacher/pending-selections')
    console.log('待审核选题列表响应:', response) // 添加日志

    if (response.code === 200) {
      pendingSelections.value = response.data
    }
  } catch (error) {
    console.error('获取待审核选题列表失败:', error)
    ElMessage.error('获取待审核选题列表失败')
  } finally {
    pendingListLoading.value = false
  }
}

// 刷新待审核列表
const refreshPendingList = () => {
  fetchPendingSelections()
}

// 教师审批相关代码保持不变
const handleUpdateStatus = async (row: any, status: string) => {
  try {
    if (row.teacher_approval_status !== 'pending') {
      ElMessage.warning('该申请已经审批过，不能重复审批')
      return
    }

    const response = await request.put(
      `/dashboard/teacher/selection/${row.selection_id}/status`,
      { status }
    )

    if (response.code === 200) {
      ElMessage.success(status === 'approved' ? '已通过该选题申请' : '已拒绝该选题申请')

      if (status === 'approved') {
        ElMessage({
          type: 'warning',
          message: '申请已通过教师审核，等待系主任审核',
          duration: 5000
        })
      }

      fetchPendingSelections()
      fetchTeacherStats()
      fetchSupervisionList()
    }
  } catch (error: any) {
    console.error('教师审批失败:', error)
    ElMessage.error(error.response?.data?.message || '更新状态失败')
  }
}

const handleApprove = (row: any) => {
  ElMessageBox.confirm(
    `确定通过 ${row.student_name} 选题申请吗？`,
    '教师审批确认',
    {
      confirmButtonText: '确定通过',
      cancelButtonText: '取消',
      type: 'info',
      distinguishCancelAndClose: true,
      confirmButtonClass: 'el-button--success'
    }
  ).then(() => {
    handleUpdateStatus(row, 'approved')
  }).catch(() => {
    ElMessage.info('已取消操作')
  })
}

// 修改教师拒绝处理函数
const handleReject = (row: any) => {
  ElMessageBox.confirm(
    '确���要绝该选题申请吗？',
    '教师审批确认',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
      inputType: 'textarea',
      inputPlaceholder: '请输入拒绝理由（必填）',
      inputValidator: (value) => {
        if (!value) {
          return '拒绝理由不能为空'
        }
        return true
      },
      showInput: true
    }
  ).then(({ value: rejectReason }) => {
    request.put(
      `/dashboard/teacher/selection/${row.selection_id}/status`,
      {
        status: 'rejected',
        rejectReason
      }
    ).then(response => {
      if (response.code === 200) {
        ElMessage.success('已拒绝该选题申请')
        window.location.reload() // 直接刷新页面
      }
    }).catch(error => {
      console.error('教师审批失败:', error)
      ElMessage.error('审批失败')
    })
  }).catch(() => {
    ElMessage.info('已取消操作')
  })
}

// 查看申请详情
const handlePendingDetails = (row: any) => {
  currentPending.value = row
  pendingDetailsVisible.value = true
}

onMounted(async () => {

  try {
    if (!userStore.userInfo.userId) {
      await userStore.getUserInfo();
    } else {
      debouncedGetUserInfo();
    }

    if (userStore.userInfo?.role === 'superadmin') {
      await Promise.all([
        fetchSuperAdminStats(),    // 获取统计数据
        fetchSystemMessages(),      // 获取系统消息
        fetchSystemLogs()          // 获取系统日志
      ]);
    } else if (userStore.userInfo?.role === 'admin') {
      await fetchAdminStats();
      await fetchTopicsList();

      if (isDirector.value) {
        await fetchDirectorPendingList();
      }
    } else if (userStore.userInfo?.role === 'teacher') {
      await Promise.all([
        fetchTeacherStats(),
        fetchSupervisionList(),
        fetchPendingSelections()
      ]);
    }
  } catch (error) {
    console.error('初始化数据失败:', error);
  }
});

// 移除或修改其他可能触发重复请求的监听器
watch([supervisionList, pendingSelections], ([newSupervisionList, newPendingSelections]) => {
  console.log('supervisionList 更新:', newSupervisionList);
  console.log('pendingSelections 更新:', newPendingSelections);
}, { deep: true });  // 添加 deep 选项以避免不必要的触发

// 系主任待审核列表相关数据
const directorPendingList = ref([])
const directorPendingLoading = ref(false)
const directorPendingPagination = ref({
  total: 0,
  page: 1,
  pageSize: 10
})

// 获取系主任待审核列表
const fetchDirectorPendingList = async () => {
  try {
    directorPendingLoading.value = true
    const response = await request.get('/dashboard/director/pending-selections', {
      params: {
        page: directorPendingPagination.value.page,
        pageSize: directorPendingPagination.value.pageSize
      }
    })

    if (response.code === 200) {
      directorPendingList.value = response.data.list
      directorPendingPagination.value = {
        ...directorPendingPagination.value,
        total: response.data.pagination.total
      }
    }
  } catch (error) {
    console.error('获取系主任待审核列表失败:', error)
    ElMessage.error('获取待审核列表失败')
  } finally {
    directorPendingLoading.value = false
  }
}

// 处理页码变化
const handleDirectorPendingPageChange = (newPage: number) => {
  directorPendingPagination.value.page = newPage
  fetchDirectorPendingList()
}

// 处理每页条数变化
const handleDirectorPendingSizeChange = (newSize: number) => {
  directorPendingPagination.value.pageSize = newSize
  directorPendingPagination.value.page = 1
  fetchDirectorPendingList()
}

// 系主任查看的状态文本
const getDirectorStatusText = (row: any) => {
  if (row.teacher_approval_status === 'rejected') {
    return '教师已拒绝'
  }
  if (row.director_approval_status === 'rejected') {
    return '系主任已拒绝'
  }
  if (row.teacher_approval_status === 'pending') {
    return '待教师审核'
  }
  if (row.teacher_approval_status === 'approved' &&
      row.director_approval_status === 'pending') {
    return '待系主任审核'
  }
  if (row.director_approval_status === 'approved') {
    return '审核通过'
  }
  return '待审核'
}

// 修改系主任通过处理函数
const handleDirectorApprove = async (row: any) => {
  try {
    // 先获取同一题目的其他待审核申请数量
    const checkResponse = await request.get(
      `/dashboard/director/topic/${row.topic_id}/pending-count?currentSelectionId=${row.selection_id}`
    )

    const otherPendingCount = checkResponse.data?.count || 0

    // 构建确认消息，使用HTML格式以支持换行
    let confirmMessage = `<div style="text-align: left; padding: 10px;">
      <p>确定要通过该选题申请吗？</p>`

    if (otherPendingCount > 0) {
      confirmMessage += `
        <div style="margin-top: 15px; padding: 10px; background-color: #FEF0F0; border-radius: 4px;">
          <p style="color: #F56C6C; margin: 0;">
            <i class="el-icon-warning" style="margin-right: 5px;"></i>
            <strong>重要提醒：</strong>
          </p>
          <p style="margin: 10px 0;">该题目还有 ${otherPendingCount} 个待处理的申请</p>
          <p style="margin: 0;">通过此申请将会：</p>
          <ul style="margin: 5px 0; padding-left: 20px;">
            <li>将题目状态设置为"已选择"</li>
            <li>自动拒绝其他 ${otherPendingCount} 个申请</li>
            <li>被拒绝的申请将收到系统自动生成的拒绝理由</li>
          </ul>
        </div>`
    }

    confirmMessage += '</div>'

    await ElMessageBox.confirm(
      confirmMessage,
      '系主任审批确认',
      {
        confirmButtonText: '确定通过',
        cancelButtonText: '取消',
        type: 'warning',
        dangerouslyUseHTMLString: true,
        customClass: 'custom-message-box'
      }
    )

    const response = await request.put(
      `/dashboard/director/selection/${row.selection_id}/status`,
      { status: 'approved' }
    )

    if (response.code === 200) {
      ElMessage({
        type: 'success',
        message: otherPendingCount > 0
          ? `已通过该选题申请，并自动拒绝了其他 ${otherPendingCount} 个申请`
          : '已通过该选题申请'
      })
      window.location.reload()
    }
  } catch (error: any) {
    if (error === 'cancel' || error.type === 'cancel') {
      ElMessage.info('已取消操作')
      return
    }
    console.error('系主任审批失败:', error)
    ElMessage.error(error.response?.data?.message || '审批失败')
  }
}

// 系主任拒绝申请
const handleDirectorReject = (row: any) => {
  ElMessageBox.confirm(
    '确定要拒绝该选题申请吗？',
    '系主任审批确认',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
      inputType: 'textarea',
      inputPlaceholder: '请输入拒绝理由（必填）',
      inputValidator: (value) => {
        if (!value) {
          return '拒绝理由不能为空'
        }
        return true
      },
      showInput: true
    }
  ).then(({ value: rejectReason }) => {
    request.put(
      `/dashboard/director/selection/${row.selection_id}/status`,
      {
        status: 'rejected',
        rejectReason
      }
    ).then(response => {
      if (response.code === 200) {
        ElMessage.success('已拒绝该选题申请')
        fetchDirectorPendingList() // 刷新列表
      }
    }).catch(error => {
      console.error('系主任审批失败:', error)
      ElMessage.error('审批失败')
    })
  }).catch(() => {
    ElMessage.info('已取消操作')
  })
}

// 实现查看详情方法
const handleDirectorViewDetails = async (row: any) => {
  try {
    // 修改API路径，使用正确的endpoint
    const response = await request.get(`/dashboard/director/selection/${row.selection_id}/details`)

    if (response.code === 200) {
      currentDirectorPending.value = response.data
      directorPendingDetailsVisible.value = true
    } else {
      ElMessage.error(response.message || '获取���情失败')
    }
  } catch (error) {
    console.error('获取选题申请详情失败:', error)
    ElMessage.error('获取选题申请详情失败')
  }
}

const isAdmin = computed(() => userStore.userInfo?.role === 'admin');
const isDirector = computed(() => {
  const directorIds = ['admin_ai_001', 'admin_cs_001', 'admin_ee_001', 'admin_se_001'];
  return userStore.userInfo?.role === 'admin' &&
         directorIds.includes(userStore.userInfo?.user_id);
});


// 状态类型映射
const getStatusType = (status: string) => {
  const statusMap = {
    'selected': 'success',   // 已选中 - 绿色
    'approved': 'success',   // 已通过 - 绿色
    'pending': 'warning',    // 待审核 - 黄色
    'rejected': 'danger',    // 已拒绝 - 红色
    'draft': 'info'         // 草稿 - 灰色
  }
  return statusMap[status] || 'info'
}

// 教师查看的状态文本
const getTeacherStatusText = (row: any) => {
  if (row.teacher_approval_status === 'rejected') {
    return '已拒绝'
  }
  if (row.teacher_approval_status === 'approved') {
    return '已通过'
  }
  return '待审核'
}

// 管理员查看的选题状态文本
const getTopicStatusText = (status: string) => {
  const statusMap = {
    draft: '草稿',
    pending: '待审核',
    approved: '已通过',
    rejected: '已拒绝'
  }
  return statusMap[status] || status
}

// 状态处理相关函数集中管理
const statusHandler = {
  // 获取状态标签类型
  getStatusTagType: (row: any) => {
    // 如果是选题状态
    if (row.status) {
      return getStatusType(row.status)
    }

    // 如果是审批状态
    if (row.teacher_approval_status === 'rejected' ||
        row.director_approval_status === 'rejected') {
      return 'danger'  // 红色
    }
    if (row.teacher_approval_status === 'approved' &&
        row.director_approval_status === 'approved') {
      return 'success'  // 绿色
    }
    return 'warning'  // 黄色
  },

  // 系主任查看的状态文本
  getDirectorStatusText: (row: any) => {
    if (row.teacher_approval_status === 'rejected') {
      return '教师已拒绝'
    }
    if (row.director_approval_status === 'rejected') {
      return '系主任已拒绝'
    }
    if (row.teacher_approval_status === 'pending') {
      return '待教师审核'
    }
    if (row.teacher_approval_status === 'approved' &&
        row.director_approval_status === 'pending') {
      return '待系主任审核'
    }
    if (row.director_approval_status === 'approved') {
      return '审核通过'
    }
    return '待审核'
  },

  // 教师查看的状态文本
  getTeacherStatusText: (row: any) => {
    if (row.teacher_approval_status === 'rejected') {
      return '已拒绝'
    }
    if (row.teacher_approval_status === 'approved') {
      return '已通过'
    }
    return '待审核'
  },

  // 管理员查看的选题状态文本
  getTopicStatusText: (status: string) => {
    const statusMap = {
      draft: '草稿',
      pending: '待审核',
      approved: '已通过',
      rejected: '已拒绝',
      selected: '已选择'
    }
    return statusMap[status] || status
  },

  // 获取拒绝原因
  getRejectReason: (row: any) => {
    if (row.teacher_reject_reason) {
      return `教师拒绝原因：${row.teacher_reject_reason}`
    }
    if (row.director_reject_reason) {
      return `系主任拒绝原因：${row.director_reject_reason}`
    }
    return ''
  },

  // 判断是否可以编辑
  canEdit: (row: any) => {
    // 如果系主任已经处理过（通过或拒绝），则不能再编辑
    return row.director_approval_status === 'pending' &&
           row.teacher_approval_status === 'approved'
  }
}

// 详情对话框相关
const directorPendingDetailsVisible = ref(false)
const currentDirectorPending = ref<any>(null)

// 在 <script setup> 中添加
const getFinalStatusType = (status: string) => {
  switch (status) {
    case 'approved':
      return 'success'
    case 'rejected':
      return 'danger'
    case 'pending':
    default:
      return 'warning'
  }
}

const getFinalStatusText = (status: string) => {
  switch (status) {
    case 'approved':
      return '已通过'
    case 'rejected':
      return '已拒绝'
    case 'pending':
    default:
      return '审核中'
  }
}

// 选题编辑相关的响应式变量
const topicEditForm = ref({})
const topicEditDialogVisible = ref(false)
const currentTopicEditRow = ref(null)

// 编辑处理方法也需要相应修改
const handleTopicEdit = (row: any) => {
  console.log('编辑行数据:', row) // 添加调试日志
  currentTopicEditRow.value = {
    ...row,
    topic_id: Number(row.topic_id)
  }
  topicEditDialogVisible.value = true
}

// 添加相关变量和方法
const detailDialogVisible = ref(false)
const currentDetail = ref(null)

// 格式化日期时间
const formatDateTime = (datetime: string) => {
  return new Date(datetime).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
}

// 查看详情处理函数
const handleViewDetail = async (row: any) => {
  try {
    const response = await request.get(`/dashboard/director/selection/${row.selection_id}/detail`)
    if (response.code === 200) {
      currentDetail.value = response.data
      detailDialogVisible.value = true
    }
  } catch (error) {
    console.error('获取详情失败:', error)
    ElMessage.error('获取详情失败')
  }
}

// 添加卡片点击处理函数
const handleCardClick = (type: string) => {
  // 可以根据需要添加点击处理逻辑
  console.log('Card clicked:', type)
}

// 教师待审核选题申请列表
const teacherPendingSelections = ref<any[]>([]);
const teacherPendingLoading = ref(false);
const teacherRejectDialog = ref(false);
const teacherRejectFormRef = ref();
const currentTeacherSelection = ref<any>(null);

const teacherRejectForm = reactive({
  reason: ''
});

// 获取教师待审核选题列表
const fetchTeacherPendingSelections = async () => {
  try {
    teacherPendingLoading.value = true;
    const response = await request.get('/dashboard/teacher/pending-selections');
    if (response.code === 200) {
      teacherPendingSelections.value = response.data.map((item: any) => ({
        ...item,
        approving: false,
        rejecting: false
      }));
    }
  } catch (error) {
    console.error('获取待审核选题失败:', error);
    ElMessage.error('获取待审核选题失败');
  } finally {
    teacherPendingLoading.value = false;
  }
};

// 通过选题申请
const handleTeacherApprove = async (row: any) => {
  try {
    row.approving = true;
    const response = await request.post(`/dashboard/teacher/selection/${row.selection_id}/approve`);
    if (response.code === 200) {
      ElMessage.success('已通过该选题申请');
      await fetchTeacherPendingSelections();
    }
  } catch (error) {
    console.error('审批失败:', error);
    ElMessage.error('审批失败');
  } finally {
    row.approving = false;
  }
};

// 打开拒绝对话框
const handleTeacherReject = (row: any) => {
  currentTeacherSelection.value = row;
  teacherRejectForm.reason = '';
  teacherRejectDialog.value = true;
};

// 提交拒绝
const submitTeacherReject = async () => {
  if (!teacherRejectFormRef.value) return;

  await teacherRejectFormRef.value.validate(async (valid: boolean) => {
    if (valid && currentTeacherSelection.value) {
      try {
        currentTeacherSelection.value.rejecting = true;
        const response = await request.post(
          `/dashboard/teacher/selection/${currentTeacherSelection.value.selection_id}/reject`,
          { reason: teacherRejectForm.reason }
        );

        if (response.code === 200) {
          ElMessage.success('已拒绝该选题申请');
          teacherRejectDialog.value = false;
          await fetchTeacherPendingSelections();
        }
      } catch (error) {
        console.error('拒绝失败:', error);
        ElMessage.error('拒绝失败');
      } finally {
        currentTeacherSelection.value.rejecting = false;
      }
    }
  });
};



// 在 onMounted 中调用
onMounted(async () => {
  if (userStore.userInfo?.role === 'teacher') {
    await fetchTeacherPendingSelections();
  }
});

// 系主任审批相关的变量
const directorRejectDialog = ref(false)
const directorRejectFormRef = ref()
const currentDirectorSelection = ref<any>(null)

const directorRejectForm = reactive({
  reason: ''
})



// 提交拒绝
const submitDirectorReject = async () => {
  if (!directorRejectFormRef.value) return;

  await directorRejectFormRef.value.validate(async (valid: boolean) => {
    if (valid && currentDirectorSelection.value) {
      try {
        currentDirectorSelection.value.rejecting = true;
        const response = await request.put(
          `/dashboard/director/selection/${currentDirectorSelection.value.selection_id}/status`,
          {
            status: 'rejected',
            rejectReason: directorRejectForm.reason
          }
        );

        if (response.code === 200) {
          ElMessage.success('已拒绝该选题申请');
          directorRejectDialog.value = false;
          await fetchDirectorPendingSelections();
        }
      } catch (error) {
        console.error('拒绝失败:', error);
        ElMessage.error('拒绝失败');
      } finally {
        currentDirectorSelection.value.rejecting = false;
      }
    }
  });
};

// 状态处理函数
const getStatusTagType = (row: any) => {
  // 如果任何一方拒绝，显示红色
  if (row.teacher_approval_status === 'rejected' ||
      row.director_approval_status === 'rejected') {
    return 'danger'
  }
  // 如果都通过，显示绿色
  if (row.teacher_approval_status === 'approved' &&
      row.director_approval_status === 'approved') {
    return 'success'
  }
  // 其他情况显示黄色（待审核）
  return 'warning'
}

// 获取状态文本
const getStatusText = (row: any) => {
  if (row.teacher_approval_status === 'rejected') {
    return '教师已拒绝'
  }
  if (row.director_approval_status === 'rejected') {
    return '系主任已拒绝'
  }
  if (row.teacher_approval_status === 'pending') {
    return '待教师审核'
  }
  if (row.teacher_approval_status === 'approved' &&
      row.director_approval_status === 'pending') {
    return '待系主任审核'
  }
  if (row.director_approval_status === 'approved') {
    return '审核通过'
  }
  return '待审核'
}

// 获取拒绝原因
const getRejectReason = (row: any) => {
  if (row.teacher_reject_reason) {
    return `教师拒绝原因：${row.teacher_reject_reason}`
  }
  if (row.director_reject_reason) {
    return `系主任拒绝原因：${row.director_reject_reason}`
  }
  return ''
}

// 判断是否可以编辑
const canEdit = (row: any) => {
  // 如果系主任已经处理过（通过或拒绝），则不能再编辑
  return row.director_approval_status === 'pending' &&
         row.teacher_approval_status === 'approved'
}


// 格式化日期的函数
const formatDate = (date: string) => {
  if (!date) return ''
  return new Date(date).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 添加筛选表单的响应式数据
const directorFilterForm = reactive({
  status: 'pending' // 默认显示待审核的
})

// 重置筛选条件
const resetDirectorFilter = () => {
  directorFilterForm.status = 'pending'
  fetchDirectorPendingSelections()
}

// 添加加载状态变量
const loading = ref(false)

// 修改 fetchDirectorPendingSelections 函数
const fetchDirectorPendingSelections = async () => {
  try {
    loading.value = true // 使用正确的变量名
    const params = {
      page: currentPage.value,
      pageSize: pageSize.value,
      status: directorFilterForm.status
    }

    const res = await request.get('/dashboard/director/selections', { params })
    if (res.code === 200) {
      directorPendingList.value = res.data.list
      total.value = res.data.pagination.total
    }
  } catch (error) {
    console.error('获取待审核列表失败:', error)
    ElMessage.error('获取待审核列表失败')
  } finally {
    loading.value = false // 使用正确的变量名
  }
}

// 添加教师已审批记录相关的响应式变量
const teacherApprovedList = ref([])
const teacherApprovedLoading = ref(false)
const teacherApprovedPagination = ref({
  total: 0,
  page: 1,
  pageSize: 10
})

// 获取教师已审批通过的记录
const fetchTeacherApprovedList = async () => {
  try {
    teacherApprovedLoading.value = true
    const response = await request.get('/dashboard/teacher/approved-selections', {
      params: {
        page: teacherApprovedPagination.value.page,
        pageSize: teacherApprovedPagination.value.pageSize
      }
    })

    if (response.code === 200) {
      teacherApprovedList.value = response.data.list
      teacherApprovedPagination.value = {
        ...teacherApprovedPagination.value,
        total: response.data.pagination.total
      }
    }
  } catch (error) {
    console.error('获取教师已审批记录失败:', error)
    ElMessage.error('获取已审批记录失败')
  } finally {
    teacherApprovedLoading.value = false
  }
}

// 处理分页变化
const handleTeacherApprovedPageChange = (newPage: number) => {
  teacherApprovedPagination.value.page = newPage
  fetchTeacherApprovedList()
}

const handleTeacherApprovedSizeChange = (newSize: number) => {
  teacherApprovedPagination.value.pageSize = newSize
  teacherApprovedPagination.value.page = 1
  fetchTeacherApprovedList()
}

// 在组件挂载时获取数据
onMounted(async () => {
  if (userStore.userInfo?.role === 'teacher') {
    await fetchTeacherPendingSelections()
    await fetchTeacherApprovedList() // 添加这行
  }
})

// 添加详情弹窗相关的响应式变量
const selectionDetailVisible = ref(false)
const currentSelectionDetail = ref(null)
const detailLoading = ref(false)

// 查看详情方法
const handleViewSelectionDetail = async (row: any) => {
  try {
    detailLoading.value = true
    selectionDetailVisible.value = true
    // 打印请求信息以便调试
    console.log('正在请求选题详情，ID:', row.selection_id)
    const res = await request.get(`/dashboard/selection/${row.selection_id}/detail`)
    if (res.code === 200) {
      currentSelectionDetail.value = res.data
    }
  } catch (error) {
    console.error('获取选题详情失败:', error)
    ElMessage.error('获取选题详情失败')
  } finally {
    detailLoading.value = false
  }
}
</script>

<template>
  <div class="dashboard">
    <div class="welcome-text">{{ welcomeMessage }}</div>
    <!-- 访客视图 -->
    <template v-if="isVisitor">
      <visitor-dashboard />
    </template>
    <div class="dashboard-cards">
      <el-row :gutter="20">
        <el-col :span="8" v-for="item in dashboardData" :key="item.label">
          <el-card
            shadow="hover"
            :class="['stat-card', item.type]"
            @click="handleCardClick(item.type)"
          >
            <div class="card-content">
              <div class="card-icon">
                <el-icon :size="32">
                  <component :is="item.icon" />
                </el-icon>
              </div>
              <div class="card-info">
                <div class="card-title">{{ item.label }}</div>
                <div class="card-number">{{ item.number }}</div>
                <div class="card-description">{{ item.description }}</div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>
<!-- 系统管理员的统计卡片 -->
    <div v-if="userStore.userInfo?.role === 'superadmin'" class="dashboard-cards">
      <el-row :gutter="20">
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="card-content">
              <div class="card-icon">
                <el-icon><User /></el-icon>
              </div>
              <div class="card-info">
                <div class="card-title">总用户数</div>
                <div class="card-number">{{ statsData.totalUsers }}</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="card-content">
              <div class="card-icon">
                <el-icon><UserFilled /></el-icon>
              </div>
              <div class="card-info">
                <div class="card-title">活跃用户</div>
                <div class="card-number">{{ statsData.activeUsers }}</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="card-content">
              <div class="card-icon">
                <el-icon><Message /></el-icon>
              </div>
              <div class="card-info">
                <div class="card-title">系统消息</div>
                <div class="card-number">{{ statsData.systemMessages }}</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="card-content">
              <div class="card-icon">
                <el-icon><List /></el-icon>
              </div>
              <div class="card-info">
                <div class="card-title">系统日志</div>
                <div class="card-number">{{ statsData.systemLogs }}</div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>
    <div v-if="userStore.userInfo?.role === 'superadmin'" class="system-logs">
      <h2>系统日志</h2>
      <el-table
        v-loading="logsTableLoading"
        :data="systemLogsData"
        style="width: 100%"
      >
        <el-table-column prop="user_name" label="用户" />
        <el-table-column prop="action" label="操作" />
        <el-table-column prop="ip_address" label="IP地址" />
        <el-table-column prop="details" label="详情" show-overflow-tooltip />
        <el-table-column prop="created_at" label="时间">
          <template #default="{ row }">
            {{ new Date(row.created_at).toLocaleString() }}
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination">
        <el-pagination
          v-model:current-page="logsPagination.page"
          v-model:page-size="logsPagination.pageSize"
          :total="logsPagination.total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next"
          @size-change="fetchSystemLogs"
          @current-change="handleLogsPageChange"
        />
      </div>
    </div>

    <div v-if="userStore.userInfo?.role === 'superadmin'" class="system-messages">
      <h2>系统消息</h2>
      <el-table
        v-loading="tableLoading"
        :data="systemMessagesData"
        style="width: 100%"
      >
        <el-table-column prop="title" label="标题" />
        <el-table-column prop="type" label="类型">
          <template #default="{ row }">
            <el-tag
              :type="row.type === 'error' ? 'danger' : row.type === 'warning' ? 'warning' : 'success'"
            >
              {{ row.type }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="priority" label="优先级">
          <template #default="{ row }">
            <el-tag
              :type="row.priority === 'high' ? 'danger' : row.priority === 'medium' ? 'warning' : 'info'"
            >
              {{ row.priority }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="creator_name" label="创建人" />
        <el-table-column prop="created_at" label="创建时间">
          <template #default="{ row }">
            {{ new Date(row.created_at).toLocaleString() }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="row.status === 'active' ? 'success' : 'info'">
              {{ row.status }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination">
        <el-pagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.pageSize"
          :total="pagination.total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next"
          @size-change="fetchSystemMessages"
          @current-change="handlePageChange"
        />
      </div>
    </div>

    <!-- 系主任待审核列表 -->
    <el-card v-if="isAdmin" class="mt-4">
      <template #header>
        <div class="card-header">
          <el-icon><Document /></el-icon>
          <span class="ml-2">待审核学生选题申请</span>
          <el-tag type="warning" class="ml-2">
            待审核{{ directorPendingPagination.total }}项
          </el-tag>
        </div>

      </template>

      <!-- 根据角色显示不同的提示信息 -->
      <el-alert
        type="info"
        show-icon
        :closable="false"
        class="mb-4"
      >
        <template #title>
          <template v-if="isDirector">
            显示本院系教师已审批通过的选题申请
          </template>
          <template v-else>
            显示所有院系教师已审批通过的选题申请
          </template>
        </template>
      </el-alert>

      <el-table
        v-loading="directorPendingLoading"
        :data="directorPendingList"
        style="width: 100%"
        border
      >
        <el-table-column prop="topic_title" label="论文题目" min-width="200">
          <template #header>
            <el-icon><Document /></el-icon>
            <span class="ml-1">论文题目</span>
          </template>
        </el-table-column>

        <el-table-column prop="student_name" label="申请学生" width="120">
          <template #header>
            <el-icon><User /></el-icon>
            <span class="ml-1">申请学生</span>
          </template>
        </el-table-column>

        <el-table-column prop="student_department" label="所属院系" width="150">
          <template #header>
            <el-icon><School /></el-icon>
            <span class="ml-1">所属院系</span>
          </template>
        </el-table-column>

        <!-- 操作列 -->
        <el-table-column label="操作" width="280" fixed="right">
          <template #default="{ row }">
            <el-button-group v-if="statusHandler.canEdit(row)">
              <el-button
                type="success"
                size="small"
                :loading="row.approving"
                @click="handleDirectorApprove(row)"
              >
                通过
              </el-button>
              <el-button
                type="danger"
                size="small"
                :loading="row.rejecting"
                @click="handleDirectorReject(row)"
              >
                拒绝
              </el-button>
            </el-button-group>
            <el-tag
              v-else
              type="info"
            >
              已处理或教师未审核
            </el-tag>
            <!-- 添加查看详情按钮，无论状态如何都可以查看 -->
            <el-button
              type="primary"
              size="small"
              plain
              class="ml-2"
              @click="handleDirectorViewDetails(row)"
            >
              查看详情
            </el-button>
          </template>
        </el-table-column>

        <!-- 在系主任待审核列表中添加状态列 -->
        <el-table-column label="审批状态" width="180">
          <template #default="{ row }">
            <el-tag :type="statusHandler.getStatusTagType(row)">
              {{ statusHandler.getDirectorStatusText(row) }}
            </el-tag>
            <el-tooltip
              v-if="row.teacher_reject_reason || row.director_reject_reason"
              :content="statusHandler.getRejectReason(row)"
              placement="top"
            >
              <el-icon class="ml-2"><Warning /></el-icon>
            </el-tooltip>
          </template>
        </el-table-column>
      </el-table>

      <!-- 添加分页组件 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="directorPendingPagination.page"
          v-model:page-size="directorPendingPagination.pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="directorPendingPagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleDirectorPendingSizeChange"
          @current-change="handleDirectorPendingPageChange"
        />
      </div>
    </el-card>

    <!-- 管理员的选题列表 -->
    <div v-if="userStore.userInfo?.role === 'admin'" class="topics-list">
      <h2>{{ userStore.userInfo.department }}选题列表</h2>

      <!-- 筛选表单 -->
      <div class="filter-container">
        <el-form :inline="true" :model="filterForm">
          <el-form-item label="类型" class="filter-item">
            <div class="select-with-tag">
              <el-select v-model="filterForm.type" placeholder="选择类型" clearable>
                <el-option
                  v-for="option in typeOptions"
                  :key="option.value"
                  :label="option.label"
                  :value="option.value"
                />
              </el-select>
              <el-tag
                v-if="filterForm.type"
                closable
                @close="removeFilter('type')"
                class="filter-tag"
              >
                {{ typeOptions.find(t => t.value === filterForm.type)?.label }}
              </el-tag>
            </div>
          </el-form-item>

          <el-form-item label="来源" class="filter-item">
            <div class="select-with-tag">
              <el-select v-model="filterForm.source" placeholder="选择来源" clearable>
                <el-option
                  v-for="option in sourceOptions"
                  :key="option.value"
                  :label="option.label"
                  :value="option.value"
                />
              </el-select>
              <el-tag
                v-if="filterForm.source"
                closable
                @close="removeFilter('source')"
                class="filter-tag"
              >
                {{ sourceOptions.find(s => s.value === filterForm.source)?.label }}
              </el-tag>
            </div>
          </el-form-item>

          <el-form-item label="状态" class="filter-item">
            <div class="select-with-tag">
              <el-select v-model="filterForm.status" placeholder="选择状态" clearable>
                <el-option
                  v-for="option in statusOptions"
                  :key="option.value"
                  :label="option.label"
                  :value="option.value"
                />
              </el-select>
              <el-tag
                v-if="filterForm.status"
                closable
                @close="removeFilter('status')"
                class="filter-tag"
              >
                {{ statusOptions.find(s => s.value === filterForm.status)?.label }}
              </el-tag>
            </div>
          </el-form-item>

          <el-form-item>
            <el-button type="primary" @click="handleQuery">查询</el-button>
            <el-button @click="handleFilterReset">重置</el-button>
          </el-form-item>
        </el-form>
      </div>

      <!-- 选题列表表格 -->
      <el-table
        v-loading="topicsLoading"
        :data="topicsData"
        style="width: 100%"
      >
        <el-table-column prop="title" label="题目" show-overflow-tooltip />
        <el-table-column prop="type" label="类型">
          <template #default="{ row }">
            {{ typeOptions.find(t => t.value === row.type)?.label || row.type }}
          </template>
        </el-table-column>
        <el-table-column prop="source" label="来源">
          <template #default="{ row }">
            {{ sourceOptions.find(s => s.value === row.source)?.label || row.source }}
          </template>
        </el-table-column>
        <el-table-column prop="teacher_name" label="指导教师" />
        <el-table-column prop="status" label="状态" width="120">
          <template #default="{ row }">
            <el-tag :type="statusHandler.getStatusTagType(row)" size="small">
              {{ statusHandler.getTopicStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="250" fixed="right">
          <template #default="{ row }">
            <el-tooltip
              :content="row.status !== 'pending' ? '已审核完毕，不可编辑' : ''"
              :disabled="row.status === 'pending'"
              placement="top"
            >
              <div style="display: inline-block">
                <el-button
                  type="primary"
                  size="small"
                  :disabled="row.status !== 'pending'"
                  @click="handleEdit(row)"
                >
                  编辑
                </el-button>
              </div>
            </el-tooltip>
            <el-button
              type="primary"
              size="small"
              @click="handleTopicDetails(row)"
              link
            >
              查看详情
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination">
        <el-pagination
          v-model:current-page="topicsPagination.page"
          v-model:page-size="topicsPagination.pageSize"
          :total="topicsPagination.total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </div>

    <!-- 选题详情对话框 -->
    <el-dialog
      v-model="detailsDialogVisible"
      title="选题详情"
      width="50%"
    >
      <div v-if="currentTopic" class="topic-details">
        <div class="detail-item">
          <span class="label">题目：</span>
          <span>{{ currentTopic.title }}</span>
        </div>
        <div class="detail-item">
          <span class="label">类型：</span>
          <span>{{ currentTopic.type }}</span>
        </div>
        <div class="detail-item">
          <span class="label">来源：</span>
          <span>{{ currentTopic.source }}</span>
        </div>
        <div class="detail-item">
          <span class="label">指导教师：</span>
          <span>{{ currentTopic.teacher_name }}</span>
          <el-tag size="small" class="ml-2">{{ currentTopic.teacher_title }}</el-tag>
        </div>
        <div class="detail-item">
          <span class="label">院系：</span>
          <span>{{ currentTopic.teacher_department }}</span>
        </div>
        <div class="detail-item">
          <span class="label">描述：</span>
          <p class="description">{{ currentTopic.description }}</p>
        </div>
        <div class="detail-item">
          <span class="label">专业要求：</span>
          <p>{{ currentTopic.major_requirements }}</p>
        </div>
        <div class="detail-item">
          <span class="label">学生要求：</span>
          <p>{{ currentTopic.student_requirements }}</p>
        </div>
        <div class="detail-item">
          <span class="label">创建时间：</span>
          <span>{{ formatDate(currentTopic.created_at) }}</span>
        </div>
        <div class="detail-item">
          <span class="label">更新时间：</span>
          <span>{{ formatDate(currentTopic.updated_at) }}</span>
        </div>
      </div>
    </el-dialog>

    <!-- 选题编辑对话框 -->
    <el-dialog
      v-model="topicEditDialogVisible"
      title="编辑选题状态"
      width="30%"
    >
      <el-form
        v-if="currentTopicEditRow"
        :model="currentTopicEditRow"
        label-width="100px"
      >
        <el-form-item label="状态">
          <el-select v-model="currentTopicEditRow.status">
            <el-option label="已通过" value="approved" />
            <el-option label="待审核" value="pending" />
            <el-option label="已拒绝" value="rejected" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="topicEditDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSaveTopicEdit(currentTopicEditRow)">
            确定
          </el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 添加学生详情对话框 -->
    <el-dialog
      v-model="studentDetailsDialogVisible"
      title="学生详情"
      width="50%"
    >
      <div v-if="currentStudent" class="student-details">
        <div class="detail-item">
          <span class="label">姓名：</span>
          <span>{{ currentStudent.name }}</span>
        </div>
        <div class="detail-item">
          <span class="label">性别：</span>
          <span>{{ currentStudent.gender === 'male' ? '男' : '女' }}</span>
        </div>
        <div class="detail-item">
          <span class="label">院系：</span>
          <span>{{ currentStudent.department }}</span>
        </div>
        <div class="detail-item">
          <span class="label">专业：</span>
          <span>{{ currentStudent.major }}</span>
        </div>
        <div class="detail-item">
          <span class="label">选题：</span>
          <span>{{ currentStudent.topic_title }}</span>
        </div>
        <div class="detail-item">
          <span class="label">联系方式：</span>
          <div class="contact-info">
            <p>电话：{{ currentStudent.phone }}</p>
            <p>箱：{{ currentStudent.email }}</p>
          </div>
        </div>
        <div class="detail-item">
          <span class="label">选题时间：</span>
          <span>{{ formatDate(currentStudent.selection_time) }}</span>
        </div>
      </div>
    </el-dialog>

    <!-- 选题详情对话框 -->
    <el-dialog
      v-model="detailDialogVisible"
      title="选题申请详情"
      width="700px"
      destroy-on-close
    >
      <el-descriptions
        v-if="currentDetail"
        :column="2"
        border
      >
        <el-descriptions-item label="论文题目" :span="2">
          {{ currentDetail.topic_title }}
        </el-descriptions-item>
        <el-descriptions-item label="题目类型">
          {{ currentDetail.topic_type }}
        </el-descriptions-item>
        <el-descriptions-item label="题目来源">
          {{ currentDetail.topic_source }}
        </el-descriptions-item>
        <el-descriptions-item label="指导教师">
          {{ currentDetail.teacher_name }}
          {{ currentDetail.teacher_title }}
        </el-descriptions-item>
        <el-descriptions-item label="申请学生">
          {{ currentDetail.student_name }}
          ({{ currentDetail.student_class }})
        </el-descriptions-item>
        <el-descriptions-item label="申请理由" :span="2">
          {{ currentDetail.student_reason || '无' }}
        </el-descriptions-item>
        <el-descriptions-item label="专业要求" :span="2">
          {{ currentDetail.major_requirements || '无' }}
        </el-descriptions-item>
        <el-descriptions-item label="学生要求" :span="2">
          {{ currentDetail.student_requirements || '无' }}
        </el-descriptions-item>
        <el-descriptions-item label="教师审核状态">
          <el-tag :type="statusHandler.getTagType(currentDetail.teacher_approval_status)">
            {{ statusHandler.getBasicText(currentDetail.teacher_approval_status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="教师拒绝理由" v-if="currentDetail.teacher_reject_reason">
          {{ currentDetail.teacher_reject_reason }}
        </el-descriptions-item>
        <el-descriptions-item label="申请时间" :span="2">
          {{ formatDate(currentDetail.created_at) }}
        </el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="detailDialogVisible = false">关闭</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 拒绝原因对话框 -->
    <el-dialog
      v-model="teacherRejectDialog"
      title="拒绝原因"
      width="500px"
    >
      <el-form
        ref="teacherRejectFormRef"
        :model="teacherRejectForm"
        :rules="rejectFormRules"
        label-width="100px"
      >
        <el-form-item label="拒绝原因" prop="reason">
          <el-input
            v-model="teacherRejectForm.reason"
            type="textarea"
            rows="4"
            placeholder="请输入拒绝原因"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="teacherRejectDialog = false">取消</el-button>
          <el-button type="primary" @click="submitTeacherReject">确定</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 教师待审核选题申请列表 -->
    <el-card v-if="userStore.userInfo?.role === 'teacher'" class="mt-4">
      <template #header>
        <div class="card-header">
          <el-icon><Document /></el-icon>
          <span class="ml-2">待审核学生选题申请</span>
          <el-tag type="warning" class="ml-2">
            待审核{{ teacherPendingSelections.length }}项
          </el-tag>
        </div>

      </template>

      <el-table
        v-loading="teacherPendingLoading"
        :data="teacherPendingSelections"
        style="width: 100%"
        border
      >
        <el-table-column prop="topic_title" label="论文题目" min-width="200" />
        <el-table-column prop="student_name" label="申请学生" width="120" />
        <el-table-column prop="student_reason" label="申请理由" show-overflow-tooltip />
        <el-table-column prop="created_at" label="申请时间" width="180">
          <template #default="{ row }">
            {{ formatDate(row.created_at) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="250" fixed="right">
          <template #default="{ row }">
            <el-button-group>
              <el-button
                type="success"
                size="small"
                :loading="row.approving"
                @click="handleTeacherApprove(row)"
              >
                通过
              </el-button>
              <el-button
                type="danger"
                size="small"
                :loading="row.rejecting"
                @click="handleTeacherReject(row)"
              >
                拒绝
              </el-button>
            </el-button-group>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 添加拒绝对话框 -->
    <el-dialog
      v-model="teacherRejectDialog"
      title="拒绝原因"
      width="500px"
    >
      <el-form
        ref="teacherRejectFormRef"
        :model="teacherRejectForm"
        :rules="rejectFormRules"
        label-width="100px"
      >
        <el-form-item label="拒绝原因" prop="reason">
          <el-input
            v-model="teacherRejectForm.reason"
            type="textarea"
            rows="4"
            placeholder="请输入拒绝原因"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="teacherRejectDialog = false">取消</el-button>
          <el-button type="primary" @click="submitTeacherReject">确定</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 添加拒绝对话框 -->
    <el-dialog
      v-model="directorRejectDialog"
      title="拒绝原因"
      width="500px"
    >
      <el-form
        ref="directorRejectFormRef"
        :model="directorRejectForm"
        :rules="rejectFormRules"
        label-width="100px"
      >
        <el-form-item label="拒绝原因" prop="reason">
          <el-input
            v-model="directorRejectForm.reason"
            type="textarea"
            rows="4"
            placeholder="请输入拒绝原因"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="directorRejectDialog = false">取消</el-button>
          <el-button type="primary" @click="submitDirectorReject">确定</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 添加选题申请详情对话框 -->
    <el-dialog
      v-model="directorPendingDetailsVisible"
      title="选题申请详情"
      width="700px"
    >
      <el-descriptions
        v-if="currentDirectorPending"
        :column="2"
        border
      >
        <el-descriptions-item label="论文题目" :span="2">
          {{ currentDirectorPending.topic_title }}
        </el-descriptions-item>
        <el-descriptions-item label="指导教师">
          {{ currentDirectorPending.teacher_name }}
        </el-descriptions-item>
        <el-descriptions-item label="申请学生">
          {{ currentDirectorPending.student_name }}
        </el-descriptions-item>
        <el-descriptions-item label="学号">
          {{ currentDirectorPending.student_number }}
        </el-descriptions-item>
        <el-descriptions-item label="申请时间">
          {{ formatDate(currentDirectorPending.created_at) }}
        </el-descriptions-item>
        <el-descriptions-item label="申请理由" :span="2">
          {{ currentDirectorPending.student_reason || '无' }}
        </el-descriptions-item>
        <el-descriptions-item label="教师审核状态">
          <el-tag :type="statusHandler.getStatusTagType(currentDirectorPending)">
            {{ statusHandler.getTeacherStatusText(currentDirectorPending) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="教师拒绝原因" v-if="currentDirectorPending.teacher_reject_reason">
          {{ currentDirectorPending.teacher_reject_reason }}
        </el-descriptions-item>
        <el-descriptions-item label="系主任审核状态">
          <el-tag :type="statusHandler.getStatusTagType(currentDirectorPending)">
            {{ statusHandler.getDirectorStatusText(currentDirectorPending) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="系主任拒绝原因" v-if="currentDirectorPending.director_reject_reason">
          {{ currentDirectorPending.director_reject_reason }}
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>

    <!-- 在教师待审核列表后添加已审批记录列表 -->
    <el-card v-if="userStore.userInfo?.role === 'teacher'" class="mt-4">
      <template #header>
        <div class="card-header">
          <el-icon><Document /></el-icon>
          <span class="ml-2">已审批通过的选题申请</span>
          <el-tag type="success" class="ml-2">
            共{{ teacherApprovedPagination.total }}项
          </el-tag>
        </div>
      </template>

      <el-table
        v-loading="teacherApprovedLoading"
        :data="teacherApprovedList"
        style="width: 100%"
        border
      >
        <el-table-column prop="topic_title" label="论文题目" min-width="200" />
        <el-table-column prop="student_name" label="申请学生" width="120" />
        <el-table-column prop="student_reason" label="申请理由" show-overflow-tooltip />
        <el-table-column prop="created_at" label="申请时间" width="180">
          <template #default="{ row }">
            {{ formatDate(row.created_at) }}
          </template>
        </el-table-column>
        <el-table-column label="状态" width="120">
          <template #default="{ row }">
            <el-tag :type="row.director_approval_status === 'approved' ? 'success' : 'warning'">
              {{ row.director_approval_status === 'approved' ? '最终通过' : '待系主任审核' }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="teacherApprovedPagination.page"
          v-model:page-size="teacherApprovedPagination.pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="teacherApprovedPagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleTeacherApprovedSizeChange"
          @current-change="handleTeacherApprovedPageChange"
        />
      </div>
    </el-card>

    <!-- 添加详情弹窗 -->
    <el-dialog
      v-model="selectionDetailVisible"
      title="选题申请详情"
      width="60%"
      destroy-on-close
    >
      <div v-loading="detailLoading">
        <el-descriptions
          v-if="currentSelectionDetail"
          :column="2"
          border
        >
          <el-descriptions-item label="论文题目" :span="2">
            {{ currentSelectionDetail.topic_title }}
          </el-descriptions-item>
          <el-descriptions-item label="申请学生">
            {{ currentSelectionDetail.student_name }}
          </el-descriptions-item>
          <el-descriptions-item label="学生专业">
            {{ currentSelectionDetail.student_department }}
          </el-descriptions-item>
          <el-descriptions-item label="申请理由" :span="2">
            {{ currentSelectionDetail.student_reason }}
          </el-descriptions-item>
          <el-descriptions-item label="申请时间">
            {{ formatDate(currentSelectionDetail.created_at) }}
          </el-descriptions-item>
          <el-descriptions-item label="教师审核状态">
            <el-tag :type="currentSelectionDetail.teacher_approval_status === 'approved' ? 'success' : 'warning'">
              {{ currentSelectionDetail.teacher_approval_status === 'approved' ? '已通过' : '待审核' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="系主任审核状态" :span="2">
            <el-tag :type="currentSelectionDetail.director_approval_status === 'approved' ? 'success' : 'warning'">
              {{ currentSelectionDetail.director_approval_status === 'approved' ? '已通过' : '待审核' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item
            v-if="currentSelectionDetail.teacher_reject_reason"
            label="教师拒绝原因"
            :span="2"
          >
            {{ currentSelectionDetail.teacher_reject_reason }}
          </el-descriptions-item>
          <el-descriptions-item
            v-if="currentSelectionDetail.director_reject_reason"
            label="系主任拒绝原因"
            :span="2"
          >
            {{ currentSelectionDetail.director_reject_reason }}
          </el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer>
        <el-button @click="selectionDetailVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
/* 在已有的 style 中添加新的样式 */
.dialog-footer {
  padding: 20px 0 0;
}

:deep(.el-descriptions) {
  padding: 10px;
}

:deep(.el-descriptions__cell) {
  padding: 12px;
}

.dashboard-cards {
  margin: 20px 0;
}

.stat-card {
  transition: all 0.3s ease;
  border-radius: 8px;
  overflow: hidden;
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
}

.card-content {
  display: flex;
  align-items: center;
  padding: 20px;
}

.card-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 64px;
  height: 64px;
  border-radius: 12px;
  margin-right: 16px;
}

.card-info {
  flex: 1;
}

.card-title {
  font-size: 16px;
  color: #606266;
  margin-bottom: 8px;
}

.card-number {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 4px;
}

.card-description {
  font-size: 14px;
  color: #909399;
}

/* 为不同状态的卡片设置不同样式 */
.stat-card.pending .card-icon {
  background-color: #fdf6ec;
  color: #e6a23c;
}

.stat-card.approved .card-icon {
  background-color: #f0f9eb;
  color: #67c23a;
}

.stat-card.rejected .card-icon {
  background-color: #fef0f0;
  color: #f56c6c;
}

/* 添加卡片点击效果 */
.stat-card {
  cursor: pointer;
}

.stat-card:active {
  transform: scale(0.98);
}

/* 添加响应式布局 */
@media screen and (max-width: 768px) {
  .el-col {
    width: 100%;
    margin-bottom: 20px;
  }

  .card-content {
    padding: 15px;
  }

  .card-icon {
    width: 48px;
    height: 48px;
  }

  .card-number {
    font-size: 24px;
  }
}

/* 添加渐变背景 */
.stat-card.pending {
  background: linear-gradient(135deg, #fff 0%, #fdf6ec 100%);
}

.stat-card.approved {
  background: linear-gradient(135deg, #fff 0%, #f0f9eb 100%);
}

.stat-card.rejected {
  background: linear-gradient(135deg, #fff 0%, #fef0f0 100%);
}

/* 添加卡片内容动画 */
.card-content {
  transition: all 0.3s ease;
}

.stat-card:hover .card-content {
  transform: scale(1.02);
}

/* 添加图标动画 */
.card-icon {
  transition: all 0.3s ease;
}

.stat-card:hover .card-icon {
  transform: rotate(10deg);
}

.dashboard-cards {
  margin-bottom: 20px;
}

.card-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.card-icon {
  padding: 12px;
  border-radius: 8px;
}

.pending .card-icon {
  background-color: #fdf6ec;
  color: #e6a23c;
}

.approved .card-icon {
  background-color: #f0f9eb;
  color: #67c23a;
}

.rejected .card-icon {
  background-color: #fef0f0;
  color: #f56c6c;
}

.card-header {
  display: flex;
  align-items: center;
}

.ml-1 {
  margin-left: 4px;
}

.ml-2 {
  margin-left: 8px;
}

.mt-4 {
  margin-top: 16px;
}

:deep(.el-table .cell) {
  display: flex;
  align-items: center;
  gap: 4px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.el-descriptions {
  margin: 20px 0;
}

:deep(.el-descriptions__cell) {
  padding: 12px 20px;
}

.mb-4 {
  margin-bottom: 16px;
}

/* 添加到已有的 style 标签内 */

.filter-container {
  margin: 20px 0;  /* 调整上下间距 */
  padding: 15px;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0,0,0,0.1);
}

/* 添加一个分隔线 */
.filter-container + .el-table {
  margin-top: 20px;
  border-top: 1px solid #EBEEF5;
  padding-top: 20px;
}

.filter-item {
  margin-right: 10px;
  margin-bottom: 10px;
}

.select-with-tag {
  display: flex;
  align-items: center;
}

.filter-tag {
  margin-left: 8px;
}

:deep(.el-select) {
  width: 160px;
}

:deep(.el-form--inline .el-form-item) {
  margin-right: 20px;
}

:deep(.el-form-item__label) {
  font-weight: 500;
}

/* 添加响应式样式 */
@media screen and (max-width: 768px) {
  .filter-container {
    padding: 10px;
  }

  :deep(.el-select) {
    width: 120px;
  }

  .filter-item {
    margin-bottom: 8px;
  }
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.card-header {
  display: flex;
  align-items: center;
}

.ml-2 {
  margin-left: 8px;
}

.mt-4 {
  margin-top: 16px;
}
</style>

