<script setup lang="ts">
import type { Team } from '~/types/database'

defineProps<{
  team: Team
  points?: number
  showPoints?: boolean
}>()
</script>

<template>
  <div class="flex items-center gap-3 bg-white rounded-xl p-3 shadow-sm border border-gray-100">
    <img
      :src="team.flag_url"
      :alt="team.name"
      class="w-10 h-7 object-cover rounded shadow-sm flex-shrink-0"
      loading="lazy"
    />
    <div class="flex-1 min-w-0">
      <p class="font-semibold text-gray-900 text-sm truncate">{{ team.name }}</p>
      <p class="text-xs text-gray-400">FIFA Rank {{ team.fifa_rank }}</p>
    </div>
    <div class="flex items-center gap-2 flex-shrink-0">
      <SeedBadge :seed="team.seed" />
      <div v-if="showPoints" class="text-right">
        <span class="text-lg font-bold text-primary">{{ points ?? 0 }}</span>
        <span class="text-xs text-gray-400 block">pts</span>
      </div>
    </div>
  </div>
</template>
