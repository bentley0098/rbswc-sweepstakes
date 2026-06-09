<script setup lang="ts">
import type { Team, PointsLog, Participant } from '~/types/database'

interface Entry {
  participant: Participant
  teams: Team[]
  totalPoints: number
  pointsLog: PointsLog[]
}

const supabase = useSupabase()
const entries = ref<Entry[]>([])
const loading = ref(true)

const pointsForTeam = (log: PointsLog[], teamId: string) =>
  log.filter(p => p.team_id === teamId).reduce((sum, p) => sum + p.points, 0)

const eventsForTeam = (log: PointsLog[], teamId: string) =>
  log.filter(p => p.team_id === teamId).sort((a, b) =>
    new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
  )

onMounted(async () => {
  try {
    const [{ data: participants }, { data: draws }, { data: points }] = await Promise.all([
      supabase.from('participants').select().order('name'),
      supabase.from('draws').select('participant_id, teams(*)'),
      supabase.from('points_log').select().order('created_at', { ascending: false }),
    ])

    const teamsByParticipant = new Map<string, Team[]>()
    ;(draws ?? []).forEach((d: any) => {
      if (!teamsByParticipant.has(d.participant_id)) teamsByParticipant.set(d.participant_id, [])
      if (d.teams) teamsByParticipant.get(d.participant_id)!.push(d.teams as Team)
    })

    const logByParticipant = new Map<string, PointsLog[]>()
    ;(points ?? []).forEach((p: any) => {
      if (!logByParticipant.has(p.participant_id)) logByParticipant.set(p.participant_id, [])
      logByParticipant.get(p.participant_id)!.push(p as PointsLog)
    })

    entries.value = ((participants as Participant[]) ?? []).map(p => {
      const log = logByParticipant.get(p.id) ?? []
      return {
        participant: p,
        teams: (teamsByParticipant.get(p.id) ?? []).sort((a, b) => a.seed - b.seed),
        totalPoints: log.reduce((sum, e) => sum + e.points, 0),
        pointsLog: log,
      }
    })
  } finally {
    loading.value = false
  }
})

const eventLabel: Record<string, string> = {
  group_win: 'Group win',
  group_draw: 'Group draw',
  reach_round_of_32: 'Reached R32',
  reach_round_of_16: 'Reached R16',
  reach_quarter_final: 'Reached QF',
  reach_semi_final: 'Reached SF',
  reach_final: 'Reached Final',
  win_world_cup: 'World Cup Winner! 🏆',
  upset_bonus: 'Upset bonus',
}
</script>

<template>
  <div>
    <div class="bg-primary px-4 pt-12 pb-6 text-white">
      <h1 class="text-2xl font-black">Teams</h1>
      <p class="text-green-200 text-sm mt-0.5">World Cup 2026 Sweepstakes</p>
    </div>

    <div class="px-4 py-4 flex flex-col gap-6">
      <!-- Loading -->
      <div v-if="loading" class="flex justify-center py-12">
        <div class="w-8 h-8 rounded-full border-2 border-primary border-t-transparent animate-spin" />
      </div>

      <!-- No participants yet -->
      <div v-else-if="!entries.length" class="text-center py-8 text-gray-400 text-sm">
        <p class="text-2xl mb-2">🎲</p>
        <p>No participants yet</p>
      </div>

      <!-- Participant blocks -->
      <div v-for="entry in entries" :key="entry.participant.id" class="flex flex-col gap-3">
        <!-- Participant header -->
        <div class="flex items-center justify-between">
          <h2 class="font-bold text-gray-900 text-base">{{ entry.participant.name }}</h2>
          <span class="text-lg font-black text-primary">{{ entry.totalPoints }} <span class="text-xs font-normal text-gray-400">pts</span></span>
        </div>

        <!-- No draw yet for this participant -->
        <div v-if="!entry.teams.length" class="text-center py-4 text-gray-400 text-sm bg-gray-50 rounded-xl">
          <p class="text-xl mb-1">🎲</p>
          <p>Draw pending</p>
        </div>

        <!-- Team cards -->
        <div v-for="team in entry.teams" :key="team.id" class="flex flex-col gap-2">
          <TeamCard :team="team" :points="pointsForTeam(entry.pointsLog, team.id)" show-points />

          <div v-if="eventsForTeam(entry.pointsLog, team.id).length" class="ml-3 flex flex-col gap-1">
            <div
              v-for="event in eventsForTeam(entry.pointsLog, team.id)"
              :key="event.id"
              class="flex items-center justify-between text-xs text-gray-600 bg-gray-50 rounded-lg px-3 py-1.5"
            >
              <span>{{ eventLabel[event.event_type] ?? event.event_type }}</span>
              <span class="font-bold text-primary">+{{ event.points }}</span>
            </div>
          </div>
        </div>

        <div class="border-b border-gray-100" />
      </div>
    </div>
  </div>
</template>
