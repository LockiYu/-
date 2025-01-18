<template>
  <div class="layout-container">
    <div class="sidebar-container">
      <Sidebar />
    </div>
    <div class="main-container">
      <div class="header-container">
        <Header />
      </div>
      <div class="app-main">
        <router-view v-slot="{ Component }">
          <keep-alive>
            <component :is="Component" />
          </keep-alive>
        </router-view>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onBeforeMount } from 'vue'
import { useUserStore } from '@/stores/user'
import { useRouter } from 'vue-router'
import Sidebar from './components/Sidebar.vue'
import Header from './components/Header.vue'

const userStore = useUserStore()
const router = useRouter()

onBeforeMount(async () => {
  try {
    if (!userStore.token) {
      await router.replace('/login')
      return
    }
    
    await userStore.getUserInfo()
  } catch (error) {
    console.error('Failed to load user info:', error)
    await router.replace('/login')
  }
})
</script>

<style scoped>
.layout-container {
  display: flex;
  width: 100%;
  height: 100vh;
  overflow: hidden;
}

.sidebar-container {
  width: 200px;
  background-color: #304156;
  flex-shrink: 0;
}

.main-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.header-container {
  height: 60px;
  background-color: #fff;
  box-shadow: 0 1px 4px rgba(0,21,41,.08);
  flex-shrink: 0;
}

.app-main {
  flex: 1;
  padding: 20px;
  box-sizing: border-box;
  overflow-y: auto;
  background-color: #f0f2f5;
  margin-top: 0;
}

.loading-container {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
}
</style>