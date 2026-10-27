import { createApp } from 'vue'
import App from './App.vue'
import './style.css'

declare global {
  interface Window {
    OPENAPI_DATA?: Record<string, unknown>
  }
}

const data = window.OPENAPI_DATA || {}
const app = createApp(App, { openapi: data })
app.mount('#app')
