<script setup lang="ts">
import { inject, computed } from 'vue'
import { t } from '../i18n'

const openapi = inject<Record<string, any>>('openapi') || {}
const props = defineProps<{ filter: string }>()

const info = computed(() => (openapi.info as any) || {})
const servers = computed(() => (openapi.servers as any[]) || [])
const shown = computed(() => {
  const q = props.filter.toLowerCase()
  if (!q) return servers.value
  return servers.value.filter((s) => JSON.stringify(s).toLowerCase().includes(q))
})
</script>

<template>
  <section :aria-label="t('overview.heading')">
    <h2>{{ t('overview.heading') }}</h2>
    <p v-if="info.description">{{ info.description }}</p>
    <h3 v-if="shown.length">{{ t('overview.servers') }}</h3>
    <ul>
      <li v-for="s in shown" :key="s.url">
        <code>{{ s.url }}</code> — {{ s.protocol || 'https' }}
        <span v-if="s.description">: {{ s.description }}</span>
      </li>
    </ul>
  </section>
</template>
