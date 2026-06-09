import type { LeaderboardEntry, Participant, Team, PointsLog } from '~/types/database'

export const useLeaderboard = () => {
  const supabase = useSupabase()
  const leaderboard = useState<LeaderboardEntry[]>('leaderboard', () => [])
  const loading = ref(false)
  let channel: ReturnType<typeof supabase.channel> | null = null

  const fetchLeaderboard = async () => {
    loading.value = true
    try {
      const [{ data: participants }, { data: points }, { data: draws }] = await Promise.all([
        supabase.from('participants').select(),
        supabase.from('points_log').select('participant_id, points'),
        supabase.from('draws').select('participant_id, teams(*)'),
      ])

      const pointsByParticipant = new Map<string, number>()
      ;(points ?? []).forEach(p => {
        pointsByParticipant.set(p.participant_id, (pointsByParticipant.get(p.participant_id) ?? 0) + p.points)
      })

      const teamsByParticipant = new Map<string, Team[]>()
      ;(draws ?? []).forEach((d: any) => {
        if (!teamsByParticipant.has(d.participant_id)) teamsByParticipant.set(d.participant_id, [])
        if (d.teams) teamsByParticipant.get(d.participant_id)!.push(d.teams as Team)
      })

      leaderboard.value = ((participants as Participant[]) ?? [])
        .map(p => ({
          participant: p,
          teams: (teamsByParticipant.get(p.id) ?? []).sort((a, b) => a.seed - b.seed),
          totalPoints: pointsByParticipant.get(p.id) ?? 0,
        }))
        .sort((a, b) => b.totalPoints - a.totalPoints)
    } finally {
      loading.value = false
    }
  }

  const subscribeToUpdates = () => {
    channel = supabase
      .channel('points-updates')
      .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'points_log' }, () => {
        fetchLeaderboard()
      })
      .subscribe()
  }

  const unsubscribe = () => {
    if (channel) {
      supabase.removeChannel(channel)
      channel = null
    }
  }

  return { leaderboard, loading, fetchLeaderboard, subscribeToUpdates, unsubscribe }
}
