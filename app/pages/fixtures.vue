<script setup lang="ts">
const { groupedFixtures, loading, fetchFixtures } = useFixtures()

onMounted(fetchFixtures)

const stageEmoji: Record<string, string> = {
  'Group Stage': '🏟',
  'Round of 32': '32',
  'Round of 16': '16',
  'Quarter-finals': '⚔️',
  'Semi-finals': '🥊',
  'Third Place': '🥉',
  'Final': '🏆',
}
</script>

<template>
  <div>
    <div class="bg-primary px-4 pt-12 pb-6 text-white">
      <h1 class="text-2xl font-black">Fixtures</h1>
      <p class="text-green-200 text-sm mt-0.5">All matches</p>
    </div>

    <div class="px-4 py-4">
      <div v-if="loading" class="flex justify-center py-12">
        <div class="w-8 h-8 rounded-full border-2 border-primary border-t-transparent animate-spin" />
      </div>

      <template v-else-if="groupedFixtures.length">
        <div v-for="group in groupedFixtures" :key="group.stage" class="mb-6">
          <h2 class="text-sm font-bold text-gray-500 uppercase tracking-wide mb-3 flex items-center gap-2">
            <span>{{ stageEmoji[group.stage] ?? '⚽' }}</span>
            <span>{{ group.stage }}</span>
          </h2>
          <div class="flex flex-col gap-2">
            <FixtureCard v-for="fixture in group.matches" :key="fixture.id" :fixture="fixture" />
          </div>
        </div>
      </template>

      <div v-else class="text-center py-16 text-gray-400">
        <p class="text-3xl mb-3">📅</p>
        <p class="text-sm">No fixtures loaded yet</p>
        <p class="text-xs mt-1">The admin will sync fixtures from the API</p>
      </div>
    </div>
  </div>
</template>
