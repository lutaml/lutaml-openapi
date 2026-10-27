<script setup lang="ts">
import { inject, computed } from 'vue'

const openapi = inject<Record<string, any>>('openapi') || {}
const props = defineProps<{ filter: string }>()

const entries = computed(() => {
  const schemas = ((openapi.components as any)?.schemas as any) || {}
  const q = props.filter.toLowerCase()
  return Object.entries(schemas)
    .filter(([name, schema]) => {
      if (!q) return true
      return (
        name.toLowerCase().includes(q) ||
        JSON.stringify(schema).toLowerCase().includes(q)
      )
    })
    .map(([name, schema]) => {
      const s = schema as any
      const properties = Object.entries(s.properties || {}).map(
        ([pname, p]: [string, any]) => ({
          name: pname,
          type: Array.isArray(p.type) ? p.type.join(' | ') : p.type || '',
          description: p.description || '',
        }),
      )
      return { name, description: s.description || '', type: s.type, properties }
    })
})
</script>

<template>
  <section aria-label="Schemas">
    <h2>Schemas</h2>
    <div v-for="e in entries" :key="e.name" class="schema">
      <h3>{{ e.name }}</h3>
      <p v-if="e.description">{{ e.description }}</p>
      <table v-if="e.properties.length">
        <caption>Properties of {{ e.name }}</caption>
        <thead>
          <tr><th>Name</th><th>Type</th><th>Description</th></tr>
        </thead>
        <tbody>
          <tr v-for="p in e.properties" :key="p.name">
            <td><code>{{ p.name }}</code></td>
            <td><code>{{ p.type }}</code></td>
            <td>{{ p.description }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <p v-if="!entries.length">No schemas match the filter.</p>
  </section>
</template>
