import type { Match, Team } from '~/types/database'

const STAGE_ORDER = ['Group Stage', 'Round of 32', 'Round of 16', 'Quarter-finals', 'Semi-finals', 'Third Place', 'Final']

export interface FixtureWithTeams extends Match {
  homeTeam: Team | undefined
  awayTeam: Team | undefined
  homeParticipant: string | undefined
  awayParticipant: string | undefined
}

export const useFixtures = () => {
  const supabase = useSupabase()
  const { teams, fetchTeams } = useTeams()
  const matches = useState<Match[]>('matches', () => [])
  const participantByTeamId = useState<Map<string, string>>('participantByTeamId', () => new Map())
  const loading = ref(false)

  const fixturesWithTeams = computed<FixtureWithTeams[]>(() =>
    matches.value.map(m => {
      const homeTeam = teams.value.find(t => t.api_team_id === m.home_team_api_id)
      const awayTeam = teams.value.find(t => t.api_team_id === m.away_team_api_id)
      return {
        ...m,
        homeTeam,
        awayTeam,
        homeParticipant: homeTeam ? participantByTeamId.value.get(homeTeam.id) : undefined,
        awayParticipant: awayTeam ? participantByTeamId.value.get(awayTeam.id) : undefined,
      }
    })
  )

  const groupedFixtures = computed(() =>
    STAGE_ORDER
      .map(stage => ({
        stage,
        matches: fixturesWithTeams.value.filter(m => m.stage === stage),
      }))
      .filter(g => g.matches.length > 0)
  )

  const fetchFixtures = async () => {
    loading.value = true
    try {
      const [, { data: draws }, { data: matchData }] = await Promise.all([
        fetchTeams(),
        supabase.from('draws').select('team_id, participants(name)'),
        supabase.from('matches').select().order('match_date'),
      ])

      const map = new Map<string, string>()
      ;(draws ?? []).forEach((d: any) => {
        if (d.participants?.name) map.set(d.team_id, d.participants.name)
      })
      participantByTeamId.value = map
      matches.value = (matchData as Match[]) ?? []
    } finally {
      loading.value = false
    }
  }

  return { matches, groupedFixtures, loading, fetchFixtures }
}
