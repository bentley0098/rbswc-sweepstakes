<script setup lang="ts">
const props = defineProps<{ seed: 1 | 2 | 3 | 4 }>()

const colours: Record<number, string> = {
  1: 'bg-amber-100 text-amber-700 ring-amber-300',
  2: 'bg-slate-100 text-slate-600 ring-slate-300',
  3: 'bg-orange-100 text-orange-700 ring-orange-300',
  4: 'bg-blue-100 text-blue-700 ring-blue-300',
}
</script>

<template>
  <span
    class="inline-flex items-center justify-center w-7 h-7 rounded-full text-xs font-bold ring-1"
    :class="colours[seed]"
  >
    S{{ seed }}
  </span>
</template>
