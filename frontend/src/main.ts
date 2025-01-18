import './assets/main.css'
import 'element-plus/dist/index.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { useUserStore } from '@/stores/user'

import App from './App.vue'
import router from './router'
import ElementPlus from 'element-plus'
import Antd from 'ant-design-vue'
import 'ant-design-vue/dist/reset.css'
import { Modal } from 'ant-design-vue'

// 配置 Ant Design Vue 的全局配置
Modal.install = function(app) {
  app.component('AModal', {
    ...Modal,
    props: {
      ...Modal.props,
      visible: undefined,
      open: { type: Boolean }
    }
  })
}

const app = createApp(App)
const pinia = createPinia()

// 恢复用户状态
const userStore = useUserStore(pinia)
const storedToken = localStorage.getItem('token')
if (storedToken) {
    userStore.setToken(storedToken)
}

const storedUser = localStorage.getItem('user')
if (storedUser) {
    userStore.setUserInfo(JSON.parse(storedUser))
}

app.use(pinia)
app.use(router)
app.use(ElementPlus)
app.use(Antd)

app.mount('#app')
