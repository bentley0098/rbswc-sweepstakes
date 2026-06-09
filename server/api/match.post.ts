import { createClient } from '@supabase/supabase-js'

type Action = 'add' | 'result' | 'delete'

export default defineEventHandler(async (event) => {
  const body = await readBody<{
    adminCode: string
    action: Action
    // add
    homeTeamApiId?: number
    awayTeamApiId?: number
    stage?: string
    matchDate?: string
    // result
    matchId?: string
    homeScore?: number
    awayScore?: number
    homePens?: number | null
    awayPens?: number | null
    // delete
  }>(event)

  const config = useRuntimeConfig()

  if (!body.adminCode || body.adminCode !== String(config.adminCode)) {
    throw createError({ statusCode: 403, message: 'Unauthorized' })
  }

  const supabase = createClient(config.public.supabaseUrl, config.supabaseServiceRoleKey)

  // ─── ADD FIXTURE ───────────────────────────────────────────────────────────
  if (body.action === 'add') {
    if (!body.homeTeamApiId || !body.awayTeamApiId || !body.stage || !body.matchDate) {
      throw createError({ statusCode: 400, message: 'homeTeamApiId, awayTeamApiId, stage and matchDate are required' })
    }
    const { data, error } = await supabase.from('matches').insert({
      api_fixture_id: Date.now(), // synthetic ID for manually added matches
      home_team_api_id: body.homeTeamApiId,
      away_team_api_id: body.awayTeamApiId,
      stage: body.stage,
      match_date: body.matchDate,
      status: 'NS',
    }).select().single()

    if (error) throw createError({ statusCode: 500, message: error.message })
    return { success: true, match: data }
  }

  // ─── ENTER RESULT ──────────────────────────────────────────────────────────
  if (body.action === 'result') {
    if (!body.matchId || body.homeScore == null || body.awayScore == null) {
      throw createError({ statusCode: 400, message: 'matchId, homeScore and awayScore are required' })
    }

    // Check points haven't already been awarded for this match
    const { data: existingPoints } = await supabase
      .from('points_log')
      .select('id')
      .eq('match_id', body.matchId)
      .limit(1)

    if (existingPoints?.length) {
      throw createError({ statusCode: 409, message: 'Points already awarded for this match. Delete the match result first to re-enter.' })
    }

    // Determine status
    const homePens = body.homePens ?? null
    const awayPens = body.awayPens ?? null
    const isDraw90 = body.homeScore === body.awayScore
    const status = isDraw90 && homePens !== null ? 'PEN' : 'FT'

    // Update match record
    const { data: match, error: mErr } = await supabase
      .from('matches')
      .update({ home_score: body.homeScore, away_score: body.awayScore, status, synced_at: new Date().toISOString() })
      .eq('id', body.matchId)
      .select()
      .single()

    if (mErr || !match) throw createError({ statusCode: 500, message: mErr?.message ?? 'Match not found' })

    // Load teams + draws for points calculation
    const { data: teams } = await supabase.from('teams').select()
    const teamByApiId = new Map((teams ?? []).map(t => [t.api_team_id, t]))
    const { data: draws } = await supabase.from('draws').select('participant_id, team_id')
    const participantByTeamId = new Map((draws ?? []).map(d => [d.team_id, d.participant_id]))

    const homeTeam = teamByApiId.get(match.home_team_api_id)
    const awayTeam = teamByApiId.get(match.away_team_api_id)

    if (!homeTeam || !awayTeam) {
      return { success: true, pointsAwarded: 0, warning: 'Teams not found in DB — no points awarded' }
    }

    const homeParticipant = participantByTeamId.get(homeTeam.id)
    const awayParticipant = participantByTeamId.get(awayTeam.id)

    // Determine winner
    let homeWon: boolean
    let awayWon: boolean
    if (homePens !== null && awayPens !== null) {
      homeWon = homePens > awayPens
      awayWon = awayPens > homePens
    } else {
      homeWon = body.homeScore > body.awayScore
      awayWon = body.awayScore > body.homeScore
    }
    const isDraw = !homeWon && !awayWon

    const pointsToInsert: object[] = []

    if (match.stage === 'Group Stage') {
      if (isDraw) {
        if (homeParticipant) pointsToInsert.push({ participant_id: homeParticipant, team_id: homeTeam.id, match_id: match.id, event_type: 'group_draw', points: POINTS.group_draw, description: `${homeTeam.name} drew with ${awayTeam.name}` })
        if (awayParticipant) pointsToInsert.push({ participant_id: awayParticipant, team_id: awayTeam.id, match_id: match.id, event_type: 'group_draw', points: POINTS.group_draw, description: `${awayTeam.name} drew with ${homeTeam.name}` })
      } else {
        const [wTeam, wPart, lTeam] = homeWon ? [homeTeam, homeParticipant, awayTeam] : [awayTeam, awayParticipant, homeTeam]
        if (wPart) pointsToInsert.push({ participant_id: wPart, team_id: wTeam.id, match_id: match.id, event_type: 'group_win', points: POINTS.group_win, description: `${wTeam.name} beat ${lTeam.name}` })
      }
      // Upset bonus — group stage
      for (const row of calcUpsetRows(homeTeam, awayTeam, body.homeScore, body.awayScore, homeParticipant, awayParticipant, match.id)) {
        pointsToInsert.push(row)
      }
    } else {
      if (!homeWon && !awayWon) {
        return { success: true, pointsAwarded: 0, warning: 'Draw in knockout stage with no penalties recorded — no points awarded' }
      }
      const [wTeam, wPart, lTeam] = homeWon
        ? [homeTeam, homeParticipant, awayTeam]
        : [awayTeam, awayParticipant, homeTeam]

      // Both teams in R32 confirmed their group-stage qualification
      if (match.stage === 'Round of 32') {
        if (homeParticipant) pointsToInsert.push({ participant_id: homeParticipant, team_id: homeTeam.id, match_id: match.id, event_type: 'reach_round_of_32', points: POINTS.reach_round_of_32, description: `${homeTeam.name} reached Round of 32` })
        if (awayParticipant) pointsToInsert.push({ participant_id: awayParticipant, team_id: awayTeam.id, match_id: match.id, event_type: 'reach_round_of_32', points: POINTS.reach_round_of_32, description: `${awayTeam.name} reached Round of 32` })
      }

      const eventType = stageToEventType(match.stage)
      if (eventType && wPart) {
        pointsToInsert.push({ participant_id: wPart, team_id: wTeam.id, match_id: match.id, event_type: eventType, points: POINTS[eventType], description: `${wTeam.name} advanced from ${match.stage}` })
      }
      const bonus = calcUpsetBonus(wTeam.fifa_rank, lTeam.fifa_rank, false)
      if (bonus > 0 && wPart) {
        pointsToInsert.push({ participant_id: wPart, team_id: wTeam.id, match_id: match.id, event_type: 'upset_bonus', points: bonus, description: `Upset bonus: ${wTeam.name} (#${wTeam.fifa_rank}) beat ${lTeam.name} (#${lTeam.fifa_rank})` })
      }
    }

    if (pointsToInsert.length) {
      await supabase.from('points_log').insert(pointsToInsert)
    }

    return { success: true, pointsAwarded: pointsToInsert.length }
  }

  // ─── DELETE MATCH ──────────────────────────────────────────────────────────
  if (body.action === 'delete') {
    if (!body.matchId) throw createError({ statusCode: 400, message: 'matchId required' })
    // points_log rows cascade via ON DELETE SET NULL on match_id, so delete them first
    await supabase.from('points_log').delete().eq('match_id', body.matchId)
    await supabase.from('matches').delete().eq('id', body.matchId)
    return { success: true }
  }

  throw createError({ statusCode: 400, message: 'Unknown action' })
})

function calcUpsetRows(
  homeTeam: { id: string; fifa_rank: number; name: string },
  awayTeam: { id: string; fifa_rank: number; name: string },
  homeScore: number,
  awayScore: number,
  homeParticipant: string | undefined,
  awayParticipant: string | undefined,
  matchId: string,
) {
  const rows: object[] = []
  const isDraw = homeScore === awayScore
  const homeWon = homeScore > awayScore
  if (isDraw) {
    const hb = calcUpsetBonus(homeTeam.fifa_rank, awayTeam.fifa_rank, true)
    const ab = calcUpsetBonus(awayTeam.fifa_rank, homeTeam.fifa_rank, true)
    if (hb > 0 && homeParticipant) rows.push({ participant_id: homeParticipant, team_id: homeTeam.id, match_id: matchId, event_type: 'upset_bonus', points: hb, description: `Upset bonus: ${homeTeam.name} (#${homeTeam.fifa_rank}) drew ${awayTeam.name} (#${awayTeam.fifa_rank})` })
    if (ab > 0 && awayParticipant) rows.push({ participant_id: awayParticipant, team_id: awayTeam.id, match_id: matchId, event_type: 'upset_bonus', points: ab, description: `Upset bonus: ${awayTeam.name} (#${awayTeam.fifa_rank}) drew ${homeTeam.name} (#${homeTeam.fifa_rank})` })
  } else {
    const [wTeam, lTeam, wPart] = homeWon ? [homeTeam, awayTeam, homeParticipant] : [awayTeam, homeTeam, awayParticipant]
    const b = calcUpsetBonus(wTeam.fifa_rank, lTeam.fifa_rank, false)
    if (b > 0 && wPart) rows.push({ participant_id: wPart, team_id: wTeam.id, match_id: matchId, event_type: 'upset_bonus', points: b, description: `Upset bonus: ${wTeam.name} (#${wTeam.fifa_rank}) beat ${lTeam.name} (#${lTeam.fifa_rank})` })
  }
  return rows
}
