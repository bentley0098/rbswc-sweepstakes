<script setup lang="ts">
const { leaderboard, loading, fetchLeaderboard, subscribeToUpdates, unsubscribe } = useLeaderboard()
const { data: appState } = await useAsyncData('appState', async () => {
  const supabase = useSupabase()
  const { data } = await supabase.from('app_state').select().single()
  return data
})

onMounted(async () => {
  await fetchLeaderboard()
  subscribeToUpdates()
})

onUnmounted(() => {
  unsubscribe()
})
</script>

<template>
  <div>
    <!-- Header -->
    <div class="bg-primary px-4 pt-12 pb-6 text-white">
      <h1 class="text-2xl font-black">Leaderboard</h1>
      <p class="text-green-200 text-sm mt-0.5">World Cup 2026 Sweepstakes</p>
    </div>

    <div class="px-4 py-4 flex flex-col gap-3">
      <!-- Pre-draw state -->
      <div v-if="!appState?.draw_completed" class="rounded-xl bg-amber-50 border border-amber-200 p-4 text-center">
        <p class="text-2xl mb-1">🎲</p>
        <p class="font-semibold text-amber-800 text-sm">Draw not yet run</p>
        <p class="text-amber-600 text-xs mt-1">Teams will be assigned once the draw takes place</p>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="flex justify-center py-12">
        <div class="w-8 h-8 rounded-full border-2 border-primary border-t-transparent animate-spin" />
      </div>

      <!-- Leaderboard rows -->
      <template v-else>
        <LeaderboardRow
          v-for="(entry, i) in leaderboard"
          :key="entry.participant.id"
          :entry="entry"
          :rank="i + 1"
        />
        <p v-if="!leaderboard.length" class="text-center text-gray-400 text-sm py-8">
          No participants yet
        </p>
      </template>
    </div>
  </div>
</template>
