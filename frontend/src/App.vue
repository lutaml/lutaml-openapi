<script setup lang="ts">
import { computed, ref, provide, onMounted } from 'vue'
import OverviewView from './components/OverviewView.vue'
import PathsView from './components/PathsView.vue'
import SchemasView from './components/SchemasView.vue'
import { t, tf, initLocaleFromUrl, localeLabel, nextLocale, setLocale } from './i18n'

const props = defineProps<{ openapi: Record<string, any> }>()
provide('openapi', props.openapi)

const filter = ref('')
const view = ref<'overview' | 'paths' | 'schemas'>('overview')
const views = [
  { id: 'overview', label: 'nav.overview' },
  { id: 'paths', label: 'nav.paths' },
  { id: 'schemas', label: 'nav.schemas' },
] as const

onMounted(() => initLocaleFromUrl())

function switchLocale() {
  setLocale(nextLocale())
}

const info = computed(() => (props.openapi.info as any) || {})
const schemaCount = computed(
  () => Object.keys(((props.openapi.components as any)?.schemas as any) || {}).length,
)
const pathCount = computed(() => Object.keys((props.openapi.paths as any) || {}).length)
</script>

<template>
  <div class="docs">
    <header class="docs-header">
      <h1>{{ info.title || t('app.titleFallback') }}</h1>
      <p v-if="info.version" class="version">
        {{ info.title ? t('app.version') : '' }} {{ info.version }}
      </p>
      <input
        v-model="filter"
        class="filter"
        type="search"
        :placeholder="t('app.filterPlaceholder')"
        :aria-label="t('app.filterAria')"
      />
      <nav :aria-label="t('nav.sections')">
        <button
          v-for="v in views"
          :key="v.id"
          class="nav-btn"
          :class="{ active: view === v.id }"
          @click="view = v.id"
        >
          {{ t(v.label) }}
        </button>
      </nav>
      <button
        class="nav-btn locale-btn"
        :title="t('app.switchLocale')"
        @click="switchLocale"
      >
        {{ localeLabel(nextLocale()) }}
      </button>
    </header>
    <main>
      <OverviewView v-if="view === 'overview'" :filter="filter" />
      <PathsView v-else-if="view === 'paths'" :filter="filter" />
      <SchemasView v-else :filter="filter" />
    </main>
    <footer class="docs-footer">
      <span>{{ tf('footer.stats', { schemas: schemaCount, paths: pathCount }) }}</span>
    </footer>
  </div>
</template>
