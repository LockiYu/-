<template>
  <el-config-provider :locale="locale">
    <div class="app-wrapper">
      <router-view v-slot="{ Component }">
        <transition name="fade-transform" mode="out-in">
          <div :key="$route.path">
            <component :is="Component" />
          </div>
        </transition>
      </router-view>
    </div>
  </el-config-provider>
</template>

<script setup lang="ts">
import { ElConfigProvider } from 'element-plus'
import zhCn from 'element-plus/dist/locale/zh-cn.mjs'

const locale = zhCn
</script>

<style>
/* 重置所有容器的默认样式 */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

/* 确保从根元素到app的所有容器都占满空间 */
html, 
body {
  margin: 0;
  padding: 0;
  width: 100%;
  height: 100%;
  overflow: hidden;
}

#app {
  width: 100%;
  height: 100%;
  overflow: hidden;
  display: block; /* 改用 block 而不是 flex */
}

/* 移除所有可能的额外样式 */
body > #app {
  width: 100% !important;
  min-width: 100% !important;
  max-width: 100% !important;
}

/* fade-transform */
.fade-transform-leave-active,
.fade-transform-enter-active {
  transition: all 0.5s;
}

.fade-transform-enter-from {
  opacity: 0;
  transform: translateX(-30px);
}

.fade-transform-leave-to {
  opacity: 0;
  transform: translateX(30px);
}

/* 优化按钮样式 */
.register-button {
  color: #3f87a6;
  font-size: 14px;
  padding: 0;
}

.register-button:hover {
  color: #2d7594;
}
</style>

