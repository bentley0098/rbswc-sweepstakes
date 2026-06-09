<script setup lang="ts">
import type { FixtureWithTeams } from '~/composables/useFixtures'

const props = defineProps<{ fixture: FixtureWithTeams }>()

const isFinished = computed(() => ['FT', 'AET', 'PEN'].includes(props.fixture.status))
const isPending = computed(() => props.fixture.status === 'NS')

const formattedDate = computed(() => {
  const d = new Date(props.fixture.match_date)
  return d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' })
})
</script>

<template>
  <div class="bg-white rounded-xl border border-gray-100 shadow-sm p-3">
    <div class="flex items-center gap-2">
      <!-- Home team -->
      <div class="flex-1 flex flex-col items-end gap-1 min-w-0">
        <div class="flex items-center gap-2">
          <span class="text-sm font-medium text-gray-800 truncate text-right">
            {{ fixture.homeTeam?.name ?? `Team ${fixture.home_team_api_id}` }}
          </span>
          <img
            v-if="fixture.homeTeam"
            :src="fixture.homeTeam.flag_url"
            :alt="fixture.homeTeam.name"
            class="w-8 h-5 object-cover rounded-sm shadow-sm flex-shrink-0"
          />
          <div v-else class="w-8 h-5 bg-gray-200 rounded-sm flex-shrink-0" />
        </div>
      </div>

      <!-- Score / time -->
      <div class="flex-shrink-0 w-20 text-center">
        <template v-if="isFinished">
          <span class="text-xl font-black text-gray-900">
            {{ fixture.home_score }} – {{ fixture.away_score }}
          </span>
          <span class="block text-xs text-gray-400">{{ fixture.status }}</span>
        </template>
        <template v-else>
          <span class="text-xs font-medium text-gray-500">{{ formattedDate }}</span>
        </template>
      </div>

      <!-- Away team -->
      <div class="flex-1 flex flex-col items-start gap-1 min-w-0">
        <div class="flex items-center gap-2">
          <img
            v-if="fixture.awayTeam"
            :src="fixture.awayTeam.flag_url"
            :alt="fixture.awayTeam.name"
            class="w-8 h-5 object-cover rounded-sm shadow-sm flex-shrink-0"
          />
          <div v-else class="w-8 h-5 bg-gray-200 rounded-sm flex-shrink-0" />
          <span class="text-sm font-medium text-gray-800 truncate">
            {{ fixture.awayTeam?.name ?? `Team ${fixture.away_team_api_id}` }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>
