import type { Team } from '~/types/database'

export const useTeams = () => {
  const supabase = useSupabase()
  const teams = useState<Team[]>('teams', () => [])

  const fetchTeams = async () => {
    if (teams.value.length) return
    const { data } = await supabase.from('teams').select().order('fifa_rank')
    teams.value = (data as Team[]) ?? []
  }

  const getByApiId = (apiId: number) =>
    teams.value.find(t => t.api_team_id === apiId)

  return { teams, fetchTeams, getByApiId }
}
