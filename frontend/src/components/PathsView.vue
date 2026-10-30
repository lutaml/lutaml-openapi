<script setup lang="ts">
import { inject, computed } from 'vue'
import { t } from '../i18n'

const openapi = inject<Record<string, any>>('openapi') || {}
const props = defineProps<{ filter: string }>()

const METHODS = ['get', 'put', 'post', 'delete', 'options', 'head', 'patch', 'trace']

const entries = computed(() => {
  const paths = (openapi.paths as any) || {}
  const q = props.filter.toLowerCase()
  return Object.entries(paths)
    .filter(([path, item]) => {
      if (!q) return true
      return (
        path.toLowerCase().includes(q) ||
        JSON.stringify(item).toLowerCase().includes(q)
      )
    })
    .map(([path, item]) => ({
      path,
      operations: Object.entries(item as any)
        .filter(([m, op]) => METHODS.includes(m) && op && typeof op === 'object')
        .map(([m, op]) => ({
          method: m.toUpperCase(),
          summary: (op as any).summary || '',
          description: (op as any).description || '',
        })),
    }))
})
</script>

<template>
  <section :aria-label="t('paths.heading')">
    <h2>{{ t('paths.heading') }}</h2>
    <div v-for="e in entries" :key="e.path" class="path">
      <h3><code>{{ e.path }}</code></h3>
      <div v-for="op in e.operations" :key="op.method" class="op">
        <span class="method" :class="op.method.toLowerCase()">{{ op.method }}</span>
        <strong v-if="op.summary"> {{ op.summary }}</strong>
        <p v-if="op.description">{{ op.description }}</p>
      </div>
    </div>
    <p v-if="!entries.length">{{ t('paths.noMatch') }}</p>
  </section>
</template>
