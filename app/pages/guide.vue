<script setup lang="ts">
const { teams, fetchTeams } = useTeams()
onMounted(fetchTeams)
</script>

<template>
  <div>
    <div class="bg-primary px-4 pt-12 pb-6 text-white">
      <h1 class="text-2xl font-black">Guide</h1>
      <p class="text-green-200 text-sm mt-0.5">How the sweepstakes works</p>
    </div>

    <div class="px-4 py-4 flex flex-col gap-4">

      <!-- Draw -->
      <div class="rounded-xl border border-gray-100 bg-gray-50 p-4">
        <p class="text-xs font-semibold text-primary uppercase tracking-wide mb-2">The Draw</p>
        <p class="text-sm text-gray-700 leading-relaxed">
          48 teams are split into 4 seed pods by FIFA ranking — pod 1 has the favourites, pod 4 the underdogs.
          Each player is randomly assigned <span class="font-semibold">one team per pod</span> (4 teams total).
          You earn points for everything your teams do throughout the tournament.
        </p>
      </div>

      <!-- Group stage -->
      <div class="rounded-xl border border-gray-100 bg-gray-50 p-4">
        <p class="text-xs font-semibold text-primary uppercase tracking-wide mb-3">Group Stage</p>
        <div class="flex flex-col gap-1.5 text-sm">
          <div class="flex justify-between items-center">
            <span class="text-gray-700">Win</span>
            <span class="font-bold text-gray-900">3 pts</span>
          </div>
          <div class="flex justify-between items-center">
            <span class="text-gray-700">Draw</span>
            <span class="font-bold text-gray-900">1 pt</span>
          </div>
          <div class="flex justify-between items-center">
            <span class="text-gray-700">Loss</span>
            <span class="font-bold text-gray-900">0 pts</span>
          </div>
        </div>
      </div>

      <!-- Knockout advancement -->
      <div class="rounded-xl border border-gray-100 bg-gray-50 p-4">
        <p class="text-xs font-semibold text-primary uppercase tracking-wide mb-3">Knockout Advancement</p>
        <p class="text-xs text-gray-500 mb-3">Earned each time your team progresses to the next round.</p>
        <div class="flex flex-col gap-1.5 text-sm">
          <div class="flex justify-between items-center">
            <span class="text-gray-700">Reach Round of 32</span>
            <span class="font-bold text-gray-900">2 pts</span>
          </div>
          <div class="flex justify-between items-center">
            <span class="text-gray-700">Reach Round of 16</span>
            <span class="font-bold text-gray-900">4 pts</span>
          </div>
          <div class="flex justify-between items-center">
            <span class="text-gray-700">Reach Quarter-final</span>
            <span class="font-bold text-gray-900">6 pts</span>
          </div>
          <div class="flex justify-between items-center">
            <span class="text-gray-700">Reach Semi-final</span>
            <span class="font-bold text-gray-900">8 pts</span>
          </div>
          <div class="flex justify-between items-center">
            <span class="text-gray-700">Reach Final</span>
            <span class="font-bold text-gray-900">10 pts</span>
          </div>
          <div class="flex justify-between items-center border-t border-gray-200 pt-2 mt-1">
            <span class="text-gray-900 font-semibold">Win World Cup</span>
            <span class="font-bold text-primary">15 pts</span>
          </div>
        </div>
      </div>

      <!-- Upset bonus -->
      <div class="rounded-xl border border-gray-100 bg-gray-50 p-4">
        <p class="text-xs font-semibold text-primary uppercase tracking-wide mb-2">Upset Bonus</p>
        <p class="text-xs text-gray-500 mb-3">
          Awarded when a lower-ranked team beats or draws with a higher-ranked team.
          The bigger the gap in FIFA rankings, the bigger the bonus.
        </p>

        <p class="text-xs font-medium text-gray-600 mb-1.5">Win bonus</p>
        <div class="flex flex-col gap-1 text-sm mb-3">
          <div class="flex justify-between items-center">
            <span class="text-gray-700">1–5 ranking places</span>
            <span class="font-bold text-gray-900">+1</span>
          </div>
          <div class="flex justify-between items-center">
            <span class="text-gray-700">6–10 places</span>
            <span class="font-bold text-gray-900">+2</span>
          </div>
          <div class="flex justify-between items-center">
            <span class="text-gray-700">11–20 places</span>
            <span class="font-bold text-gray-900">+3</span>
          </div>
          <div class="flex justify-between items-center">
            <span class="text-gray-700">21–30 places</span>
            <span class="font-bold text-gray-900">+5</span>
          </div>
          <div class="flex justify-between items-center">
            <span class="text-gray-700">31+ places</span>
            <span class="font-bold text-gray-900">+7</span>
          </div>
        </div>

        <p class="text-xs font-medium text-gray-600 mb-1.5">Draw bonus</p>
        <div class="flex flex-col gap-1 text-sm">
          <div class="flex justify-between items-center">
            <span class="text-gray-700">11–20 places</span>
            <span class="font-bold text-gray-900">+1</span>
          </div>
          <div class="flex justify-between items-center">
            <span class="text-gray-700">21–30 places</span>
            <span class="font-bold text-gray-900">+2</span>
          </div>
          <div class="flex justify-between items-center">
            <span class="text-gray-700">31+ places</span>
            <span class="font-bold text-gray-900">+3</span>
          </div>
        </div>
      </div>

      <!-- Team rankings -->
      <div class="rounded-xl border border-gray-100 bg-gray-50 p-4">
        <p class="text-xs font-semibold text-primary uppercase tracking-wide mb-1">Team Rankings</p>
        <p class="text-xs text-gray-500 mb-3">All 48 teams by FIFA ranking.</p>
        <div class="flex flex-col">
          <div
            v-for="team in teams"
            :key="team.id"
            class="flex items-center gap-2.5 py-1.5 border-b border-gray-100 last:border-0"
          >
            <span class="text-xs text-gray-400 w-6 text-right flex-shrink-0">#{{ team.fifa_rank }}</span>
            <img
              :src="team.flag_url"
              :alt="team.name"
              class="w-7 h-5 object-cover rounded shadow-sm flex-shrink-0"
              loading="lazy"
            />
            <span class="text-sm text-gray-800 flex-1">{{ team.name }}</span>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>
