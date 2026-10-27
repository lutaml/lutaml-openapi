<script setup lang="ts">
import { computed, ref, provide } from 'vue'
import OverviewView from './components/OverviewView.vue'
import PathsView from './components/PathsView.vue'
import SchemasView from './components/SchemasView.vue'

const props = defineProps<{ openapi: Record<string, any> }>()
provide('openapi', props.openapi)

const filter = ref('')
const view = ref<'overview' | 'paths' | 'schemas'>('overview')
const views = [
  { id: 'overview', label: 'Overview' },
  { id: 'paths', label: 'Paths' },
  { id: 'schemas', label: 'Schemas' },
] as const

const info = computed(() => (props.openapi.info as any) || {})
const schemaCount = computed(
  () => Object.keys(((props.openapi.components as any)?.schemas as any) || {}).length,
)
const pathCount = computed(() => Object.keys((props.openapi.paths as any) || {}).length)
</script>

<template>
  <div class="docs">
    <header class="docs-header">
      <h1>{{ info.title || 'OpenAPI document' }}</h1>
      <p v-if="info.version" class="version">
        {{ info.title ? 'version' : '' }} {{ info.version }}
      </p>
      <input
        v-model="filter"
        class="filter"
        type="search"
        placeholder="Filter…"
        aria-label="Filter sections"
      />
      <nav aria-label="Sections">
        <button
          v-for="v in views"
          :key="v.id"
          class="nav-btn"
          :class="{ active: view === v.id }"
          @click="view = v.id"
        >
          {{ v.label }}
        </button>
      </nav>
    </header>
    <main>
      <OverviewView v-if="view === 'overview'" :filter="filter" />
      <PathsView v-else-if="view === 'paths'" :filter="filter" />
      <SchemasView v-else :filter="filter" />
    </main>
    <footer class="docs-footer">
      <span>{{ schemaCount }} schemas · {{ pathCount }} paths</span>
    </footer>
  </div>
</template>
