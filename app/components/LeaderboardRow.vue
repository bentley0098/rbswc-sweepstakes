<script setup lang="ts">
import type { LeaderboardEntry } from '~/types/database'

defineProps<{
  entry: LeaderboardEntry
  rank: number
  isCurrentUser?: boolean
}>()

const rankStyle = (rank: number) => {
  if (rank === 1) return 'text-amber-500 font-black text-xl'
  if (rank === 2) return 'text-slate-400 font-black text-xl'
  if (rank === 3) return 'text-orange-600 font-black text-xl'
  return 'text-gray-400 font-bold text-lg'
}
</script>

<template>
  <div
    class="flex items-center gap-3 p-4 rounded-xl border transition-colors"
    :class="isCurrentUser ? 'bg-green-50 border-primary/30' : 'bg-white border-gray-100'"
  >
    <span class="w-8 text-center flex-shrink-0" :class="rankStyle(rank)">{{ rank }}</span>

    <div class="flex-1 min-w-0">
      <p class="font-semibold text-gray-900 truncate">
        {{ entry.participant.name }}
        <span v-if="isCurrentUser" class="text-xs text-primary font-normal ml-1">(you)</span>
      </p>
      <div class="flex gap-1 mt-1">
        <template v-if="entry.teams.length">
          <img
            v-for="team in entry.teams"
            :key="team.id"
            :src="team.flag_url"
            :alt="team.name"
            :title="team.name"
            class="w-6 h-4 object-cover rounded-sm shadow-sm"
            loading="lazy"
          />
        </template>
        <span v-else class="text-xs text-gray-400 italic">Draw pending</span>
      </div>
    </div>

    <div class="flex-shrink-0 text-right">
      <span class="text-2xl font-black text-primary">{{ entry.totalPoints }}</span>
      <span class="text-xs text-gray-400 block">pts</span>
    </div>
  </div>
</template>
