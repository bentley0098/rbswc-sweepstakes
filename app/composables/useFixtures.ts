import type { Match, Team } from '~/types/database'

const STAGE_ORDER = ['Group Stage', 'Round of 32', 'Round of 16', 'Quarter-finals', 'Semi-finals', 'Third Place', 'Final']

export interface FixtureWithTeams extends Match {
  homeTeam: Team | undefined
  awayTeam: Team | undefined
}

export const useFixtures = () => {
  const supabase = useSupabase()
  const { teams, fetchTeams } = useTeams()
  const matches = useState<Match[]>('matches', () => [])
  const loading = ref(false)

  const fixturesWithTeams = computed<FixtureWithTeams[]>(() =>
    matches.value.map(m => ({
      ...m,
      homeTeam: teams.value.find(t => t.api_team_id === m.home_team_api_id),
      awayTeam: teams.value.find(t => t.api_team_id === m.away_team_api_id),
    }))
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
      await fetchTeams()
      const { data } = await supabase.from('matches').select().order('match_date')
      matches.value = (data as Match[]) ?? []
    } finally {
      loading.value = false
    }
  }

  return { matches, groupedFixtures, loading, fetchFixtures }
}
