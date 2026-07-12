<script setup lang="ts">
import type { AppState, Participant, Team, Match } from '~/types/database'

const supabase = useSupabase()

const adminCode = ref('')
const isAuthenticated = ref(false)
const authError = ref('')

const appState = ref<AppState | null>(null)
const participants = ref<Participant[]>([])
const teams = ref<Team[]>([])
const fixtures = ref<Match[]>([])
const loading = ref(false)
const message = ref('')
const messageType = ref<'success' | 'error'>('success')

// Add fixture form
const showAddFixture = ref(false)
const newFixture = ref({ homeTeamApiId: 0, awayTeamApiId: 0, stage: 'Group Stage', matchDate: '' })
const addingFixture = ref(false)

// Result entry
const resultMatchId = ref<string | null>(null)
const resultEntry = ref({ homeScore: 0, awayScore: 0, homePensStr: '', awayPensStr: '' })
const savingResult = ref(false)

const STAGES = ['Group Stage', 'Round of 32', 'Round of 16', 'Quarter-finals', 'Semi-finals', 'Third Place', 'Final']

const teamMap = computed(() => new Map(teams.value.map(t => [t.api_team_id, t])))

const fixturesByStage = computed(() => {
  const groups = new Map<string, Match[]>()
  for (const s of STAGES) groups.set(s, [])
  for (const m of fixtures.value) {
    if (!groups.has(m.stage)) groups.set(m.stage, [])
    groups.get(m.stage)!.push(m)
  }
  return [...groups.entries()].filter(([, v]) => v.length > 0)
})

const checkAuth = () => {
  const stored = localStorage.getItem('wc_admin_code')
  if (stored) {
    adminCode.value = stored
    isAuthenticated.value = true
    loadData()
  }
}

const authenticate = () => {
  if (!adminCode.value.trim()) {
    authError.value = 'Enter admin code'
    return
  }
  localStorage.setItem('wc_admin_code', adminCode.value.trim())
  isAuthenticated.value = true
  authError.value = ''
  loadData()
}

const loadData = async () => {
  const [{ data: state }, { data: parts }, { data: t }, { data: f }] = await Promise.all([
    supabase.from('app_state').select().single(),
    supabase.from('participants').select().order('joined_at'),
    supabase.from('teams').select().order('seed').order('name'),
    supabase.from('matches').select().order('match_date'),
  ])
  appState.value = state as AppState
  participants.value = (parts ?? []) as Participant[]
  teams.value = (t ?? []) as Team[]
  fixtures.value = (f ?? []) as Match[]
}

const showMessage = (msg: string, type: 'success' | 'error' = 'success') => {
  message.value = msg
  messageType.value = type
  setTimeout(() => { message.value = '' }, 4000)
}

const triggerDraw = async (force = false) => {
  loading.value = true
  try {
    const data = await $fetch('/api/draw', {
      method: 'POST',
      body: { adminCode: adminCode.value, force },
    })
    showMessage(`Draw complete! ${(data as any).drawCount} assignments made`)
    await loadData()
  } catch (e: any) {
    showMessage(e?.data?.message ?? 'Draw failed', 'error')
  } finally {
    loading.value = false
  }
}

const resetDraw = async () => {
  if (!confirm('Reset the draw? All team assignments will be removed.')) return
  loading.value = true
  try {
    await $fetch('/api/draw', {
      method: 'POST',
      body: { adminCode: adminCode.value, reset: true },
    })
    showMessage('Draw reset successfully')
    await loadData()
  } catch (e: any) {
    showMessage(e?.data?.message ?? 'Reset failed', 'error')
  } finally {
    loading.value = false
  }
}

const removeParticipant = async (id: string, name: string) => {
  if (!confirm(`Remove ${name}?`)) return
  await supabase.from('participants').delete().eq('id', id)
  await loadData()
}

// ─── Fixture management ────────────────────────────────────────────────────────

const addFixture = async () => {
  if (!newFixture.value.homeTeamApiId || !newFixture.value.awayTeamApiId || !newFixture.value.matchDate) {
    showMessage('Select both teams and a date', 'error')
    return
  }
  addingFixture.value = true
  try {
    await $fetch('/api/match', {
      method: 'POST',
      body: {
        adminCode: adminCode.value,
        action: 'add',
        homeTeamApiId: Number(newFixture.value.homeTeamApiId),
        awayTeamApiId: Number(newFixture.value.awayTeamApiId),
        stage: newFixture.value.stage,
        matchDate: new Date(newFixture.value.matchDate).toISOString(),
      },
    })
    showMessage('Fixture added')
    showAddFixture.value = false
    newFixture.value = { homeTeamApiId: 0, awayTeamApiId: 0, stage: 'Group Stage', matchDate: '' }
    await loadData()
  } catch (e: any) {
    showMessage(e?.data?.message ?? 'Failed to add fixture', 'error')
  } finally {
    addingFixture.value = false
  }
}

const openResult = (matchId: string) => {
  resultMatchId.value = matchId
  resultEntry.value = { homeScore: 0, awayScore: 0, homePensStr: '', awayPensStr: '' }
}

const cancelResult = () => { resultMatchId.value = null }

const saveResult = async () => {
  if (!resultMatchId.value) return
  savingResult.value = true
  try {
    const homePens = resultEntry.value.homePensStr !== '' ? parseInt(resultEntry.value.homePensStr) : null
    const awayPens = resultEntry.value.awayPensStr !== '' ? parseInt(resultEntry.value.awayPensStr) : null
    await $fetch('/api/match', {
      method: 'POST',
      body: {
        adminCode: adminCode.value,
        action: 'result',
        matchId: resultMatchId.value,
        homeScore: resultEntry.value.homeScore,
        awayScore: resultEntry.value.awayScore,
        homePens,
        awayPens,
      },
    })
    showMessage('Result saved')
    resultMatchId.value = null
    await loadData()
  } catch (e: any) {
    showMessage(e?.data?.message ?? 'Failed to save result', 'error')
  } finally {
    savingResult.value = false
  }
}

const deleteMatch = async (matchId: string) => {
  if (!confirm('Delete this fixture and any associated points?')) return
  loading.value = true
  try {
    await $fetch('/api/match', {
      method: 'POST',
      body: { adminCode: adminCode.value, action: 'delete', matchId },
    })
    showMessage('Fixture deleted')
    await loadData()
  } catch (e: any) {
    showMessage(e?.data?.message ?? 'Delete failed', 'error')
  } finally {
    loading.value = false
  }
}

const formatDate = (iso: string) =>
  new Date(iso).toLocaleString('en-GB', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit', timeZone: 'UTC' }) + ' UTC'

onMounted(checkAuth)
</script>

<template>
  <div>
    <div class="bg-gray-900 px-4 pt-12 pb-6 text-white">
      <h1 class="text-2xl font-black">Admin</h1>
      <p class="text-gray-400 text-sm mt-0.5">World Cup Sweepstakes</p>
    </div>

    <div class="px-4 py-4 flex flex-col gap-4">
      <!-- Auth form -->
      <template v-if="!isAuthenticated">
        <div class="rounded-xl border border-gray-200 p-4">
          <p class="font-semibold text-gray-800 mb-3">Admin Access</p>
          <input
            v-model="adminCode"
            type="password"
            placeholder="Admin code"
            class="w-full rounded-xl border border-gray-200 px-4 py-3 text-base focus:outline-none focus:ring-2 focus:ring-gray-800 mb-3"
            @keydown.enter="authenticate"
          />
          <p v-if="authError" class="text-sm text-red-600 mb-2">{{ authError }}</p>
          <button
            class="w-full bg-gray-900 text-white font-bold py-3 rounded-xl"
            @click="authenticate"
          >
            Unlock Admin
          </button>
        </div>
      </template>

      <!-- Admin panel -->
      <template v-else>
        <!-- Status message -->
        <div
          v-if="message"
          class="rounded-xl px-4 py-3 text-sm font-medium"
          :class="messageType === 'success' ? 'bg-green-50 text-green-800 border border-green-200' : 'bg-red-50 text-red-800 border border-red-200'"
        >
          {{ message }}
        </div>

        <!-- App state card -->
        <div v-if="appState" class="rounded-xl border border-gray-200 p-4 bg-gray-50">
          <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-3">Status</p>
          <div class="grid grid-cols-2 gap-3 text-sm">
            <div>
              <p class="text-gray-500 text-xs">Draw</p>
              <p class="font-semibold" :class="appState.draw_completed ? 'text-green-700' : 'text-amber-600'">
                {{ appState.draw_completed ? 'Completed' : 'Not run' }}
              </p>
            </div>
            <div>
              <p class="text-gray-500 text-xs">Participants</p>
              <p class="font-semibold text-gray-900">{{ participants.length }}</p>
            </div>
            <div>
              <p class="text-gray-500 text-xs">Fixtures</p>
              <p class="font-semibold text-gray-900">{{ fixtures.length }}</p>
            </div>
            <div>
              <p class="text-gray-500 text-xs">Results entered</p>
              <p class="font-semibold text-gray-900">{{ fixtures.filter(f => f.status !== 'NS').length }}</p>
            </div>
          </div>
        </div>

        <!-- Draw actions -->
        <div class="rounded-xl border border-gray-200 p-4">
          <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-3">Draw</p>
          <!-- Draw buttons temporarily disabled to prevent accidental trigger before tournament starts -->
          <div class="flex flex-col gap-2">
            <button
              class="w-full bg-primary text-white font-bold py-3 rounded-xl disabled:opacity-40 active:scale-95 transition-transform"
              disabled
              @click="triggerDraw()"
            >
              🎲 Run Draw
            </button>
            <button
              class="w-full bg-primary text-white font-bold py-3 rounded-xl disabled:opacity-40 active:scale-95 transition-transform"
              disabled
              @click="triggerDraw(true)"
            >
              🎲 Run Draw (force)
            </button>
            <button
              v-if="appState?.draw_completed"
              class="w-full bg-red-600 text-white font-bold py-3 rounded-xl disabled:opacity-40 active:scale-95 transition-transform"
              disabled
              @click="resetDraw"
            >
              ↩️ Reset Draw
            </button>
          </div>
        </div>

        <!-- Participants list -->
        <div class="rounded-xl border border-gray-200 p-4">
          <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-3">
            Participants ({{ participants.length }}/12)
          </p>
          <div v-if="!participants.length" class="text-sm text-gray-400 italic">No one has joined yet</div>
          <div v-else class="flex flex-col gap-2">
            <div
              v-for="p in participants"
              :key="p.id"
              class="flex items-center justify-between bg-gray-50 rounded-lg px-3 py-2"
            >
              <div>
                <p class="text-sm font-medium text-gray-900">{{ p.name }}</p>
                <p class="text-xs text-gray-400">{{ new Date(p.joined_at).toLocaleString('en-GB') }}</p>
              </div>
              <button
                v-if="!appState?.draw_completed"
                class="text-red-400 text-xs hover:text-red-600 px-2 py-1"
                @click="removeParticipant(p.id, p.name)"
              >
                Remove
              </button>
            </div>
          </div>
        </div>

        <!-- Fixtures management -->
        <div class="rounded-xl border border-gray-200 p-4">
          <div class="flex items-center justify-between mb-3">
            <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide">Fixtures</p>
            <button
              class="text-xs font-semibold text-primary border border-primary rounded-lg px-3 py-1 active:scale-95 transition-transform"
              @click="showAddFixture = !showAddFixture"
            >
              {{ showAddFixture ? 'Cancel' : '+ Add' }}
            </button>
          </div>

          <!-- Add fixture form -->
          <div v-if="showAddFixture" class="mb-4 p-3 bg-gray-50 rounded-xl flex flex-col gap-3">
            <div>
              <label class="text-xs text-gray-500 block mb-1">Home team</label>
              <select
                v-model.number="newFixture.homeTeamApiId"
                class="w-full rounded-lg border border-gray-200 px-3 py-2 text-sm"
              >
                <option :value="0" disabled>Select team</option>
                <optgroup v-for="seed in [1,2,3,4]" :key="seed" :label="`Seed ${seed}`">
                  <option
                    v-for="t in teams.filter(x => x.seed === seed)"
                    :key="t.api_team_id"
                    :value="t.api_team_id"
                  >
                    {{ t.name }}
                  </option>
                </optgroup>
              </select>
            </div>
            <div>
              <label class="text-xs text-gray-500 block mb-1">Away team</label>
              <select
                v-model.number="newFixture.awayTeamApiId"
                class="w-full rounded-lg border border-gray-200 px-3 py-2 text-sm"
              >
                <option :value="0" disabled>Select team</option>
                <optgroup v-for="seed in [1,2,3,4]" :key="seed" :label="`Seed ${seed}`">
                  <option
                    v-for="t in teams.filter(x => x.seed === seed)"
                    :key="t.api_team_id"
                    :value="t.api_team_id"
                  >
                    {{ t.name }}
                  </option>
                </optgroup>
              </select>
            </div>
            <div class="grid grid-cols-2 gap-2">
              <div>
                <label class="text-xs text-gray-500 block mb-1">Stage</label>
                <select
                  v-model="newFixture.stage"
                  class="w-full rounded-lg border border-gray-200 px-3 py-2 text-sm"
                >
                  <option v-for="s in STAGES" :key="s" :value="s">{{ s }}</option>
                </select>
              </div>
              <div>
                <label class="text-xs text-gray-500 block mb-1">Date &amp; time (local)</label>
                <input
                  v-model="newFixture.matchDate"
                  type="datetime-local"
                  class="w-full rounded-lg border border-gray-200 px-3 py-2 text-sm"
                />
              </div>
            </div>
            <button
              class="w-full bg-primary text-white font-bold py-3 rounded-xl disabled:opacity-40 active:scale-95 transition-transform"
              :disabled="addingFixture"
              @click="addFixture"
            >
              Add Fixture
            </button>
          </div>

          <!-- Fixtures list grouped by stage -->
          <div v-if="!fixtures.length" class="text-sm text-gray-400 italic">
            No fixtures yet — run teams_update.sql then fixtures.sql in Supabase
          </div>
          <div v-else class="flex flex-col gap-4">
            <div v-for="[stage, stageFixtures] in fixturesByStage" :key="stage">
              <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-2">
                {{ stage }} ({{ stageFixtures.length }})
              </p>
              <div class="flex flex-col gap-2">
                <div
                  v-for="match in stageFixtures"
                  :key="match.id"
                  class="rounded-lg border border-gray-100 bg-gray-50 p-3"
                >
                  <!-- Teams row -->
                  <div class="flex items-center gap-2 mb-1">
                    <img
                      v-if="teamMap.get(match.home_team_api_id)?.flag_url"
                      :src="teamMap.get(match.home_team_api_id)?.flag_url"
                      class="w-5 h-3.5 object-cover rounded-sm flex-shrink-0"
                    />
                    <span class="text-sm font-medium text-gray-900 truncate flex-1">
                      {{ teamMap.get(match.home_team_api_id)?.name ?? '?' }}
                    </span>
                    <span v-if="match.status !== 'NS'" class="text-sm font-bold text-gray-800 flex-shrink-0">
                      {{ match.home_score }} – {{ match.away_score }}
                      <span v-if="match.status === 'PEN'" class="text-xs text-gray-500 font-normal">(PEN)</span>
                    </span>
                    <span v-else class="text-xs text-gray-400 flex-shrink-0">vs</span>
                    <span class="text-sm font-medium text-gray-900 truncate flex-1 text-right">
                      {{ teamMap.get(match.away_team_api_id)?.name ?? '?' }}
                    </span>
                    <img
                      v-if="teamMap.get(match.away_team_api_id)?.flag_url"
                      :src="teamMap.get(match.away_team_api_id)?.flag_url"
                      class="w-5 h-3.5 object-cover rounded-sm flex-shrink-0"
                    />
                  </div>

                  <!-- Date + actions row -->
                  <div class="flex items-center justify-between">
                    <span class="text-xs text-gray-400">{{ formatDate(match.match_date) }}</span>
                    <div class="flex items-center gap-1">
                      <span
                        v-if="match.status !== 'NS'"
                        class="text-xs font-semibold px-1.5 py-0.5 rounded"
                        :class="match.status === 'FT' ? 'bg-green-100 text-green-700' : 'bg-blue-100 text-blue-700'"
                      >
                        {{ match.status }}
                      </span>
                      <button
                        v-if="match.status === 'NS'"
                        class="text-xs text-blue-600 font-medium border border-blue-200 rounded px-2 py-0.5 active:scale-95 transition-transform"
                        @click="openResult(match.id)"
                      >
                        Result
                      </button>
                      <button
                        class="text-xs text-red-400 border border-red-100 rounded px-1.5 py-0.5 active:scale-95 transition-transform"
                        @click="deleteMatch(match.id)"
                      >
                        ×
                      </button>
                    </div>
                  </div>

                  <!-- Inline result entry -->
                  <div
                    v-if="resultMatchId === match.id"
                    class="mt-3 pt-3 border-t border-gray-200"
                  >
                    <div class="grid grid-cols-2 gap-2 mb-2">
                      <div>
                        <label class="text-xs text-gray-500 block mb-1">
                          {{ teamMap.get(match.home_team_api_id)?.name ?? 'Home' }}
                        </label>
                        <input
                          v-model.number="resultEntry.homeScore"
                          type="number"
                          min="0"
                          class="w-full rounded-lg border border-gray-200 px-3 py-2 text-sm text-center"
                        />
                      </div>
                      <div>
                        <label class="text-xs text-gray-500 block mb-1">
                          {{ teamMap.get(match.away_team_api_id)?.name ?? 'Away' }}
                        </label>
                        <input
                          v-model.number="resultEntry.awayScore"
                          type="number"
                          min="0"
                          class="w-full rounded-lg border border-gray-200 px-3 py-2 text-sm text-center"
                        />
                      </div>
                    </div>
                    <!-- Penalty scores (only shown when scores are level) -->
                    <div
                      v-if="resultEntry.homeScore === resultEntry.awayScore && resultEntry.homeScore > 0"
                      class="grid grid-cols-2 gap-2 mb-2"
                    >
                      <div>
                        <label class="text-xs text-gray-400 block mb-1">Home pens (opt)</label>
                        <input
                          v-model="resultEntry.homePensStr"
                          type="number"
                          min="0"
                          placeholder="–"
                          class="w-full rounded-lg border border-gray-200 px-3 py-2 text-sm text-center"
                        />
                      </div>
                      <div>
                        <label class="text-xs text-gray-400 block mb-1">Away pens (opt)</label>
                        <input
                          v-model="resultEntry.awayPensStr"
                          type="number"
                          min="0"
                          placeholder="–"
                          class="w-full rounded-lg border border-gray-200 px-3 py-2 text-sm text-center"
                        />
                      </div>
                    </div>
                    <div class="flex gap-2">
                      <button
                        class="flex-1 bg-primary text-white text-sm font-bold py-2 rounded-xl disabled:opacity-40 active:scale-95 transition-transform"
                        :disabled="savingResult"
                        @click="saveResult"
                      >
                        Save Result
                      </button>
                      <button
                        class="flex-1 bg-gray-100 text-gray-700 text-sm font-bold py-2 rounded-xl active:scale-95 transition-transform"
                        @click="cancelResult"
                      >
                        Cancel
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <button
          class="text-xs text-gray-400 underline text-center py-2"
          @click="() => { localStorage.removeItem('wc_admin_code'); isAuthenticated.value = false }"
        >
          Sign out of admin
        </button>
      </template>
    </div>
  </div>
</template>
